<#
.SYNOPSIS
    Kịch bản thực thi tự động toàn bộ (hoặc từng file) script T-SQL cho dự án BK-LMS (BTL2 Hệ CSDL).
.DESCRIPTION
    - Chạy tuần tự các file từ 00_create_database.sql đến 06_functions_cursor.sql (và 07_demo_test_cases.sql nếu bật -IncludeDemo).
    - Hỗ trợ đầy đủ từ khóa phân tách batch `GO` (và `GO [count]`) của MS SQL Server.
    - Tự động sử dụng `sqlcmd` nếu có sẵn trên máy, hoặc tự động chuyển sang `.NET SqlClient` (tách batch `GO` trực tiếp trong bộ nhớ, hỗ trợ hiển thị PRINT/RAISERROR).
.EXAMPLE
    .\scripts\run_all.ps1 -ServerInstance "localhost\SQLEXPRESS"
.EXAMPLE
    .\scripts\run_all.ps1 -ServerInstance "localhost" -Username "sa" -Password "YourPassword123" -IncludeDemo
.EXAMPLE
    .\scripts\run_all.ps1 -ServerInstance "localhost\SQLEXPRESS" -Database "LMS_DB" -File "03_proc_crud.sql"
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$ServerInstance = "localhost\SQLEXPRESS",

    [Parameter(Mandatory = $false)]
    [string]$Database = "",

    [Parameter(Mandatory = $false)]
    [string]$Username = "",

    [Parameter(Mandatory = $false)]
    [string]$Password = "",

    [Parameter(Mandatory = $false)]
    [string]$File = "",

    [Parameter(Mandatory = $false)]
    [switch]$IncludeDemo,

    [Parameter(Mandatory = $false)]
    [switch]$UseDotNet
)

$ErrorActionPreference = "Stop"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$ProjectRoot = Split-Path -Parent $PSScriptRoot
$DatabaseDir = Join-Path $ProjectRoot "database"

if (-not (Test-Path $DatabaseDir)) {
    Write-Error "Không tìm thấy thư mục database tại: $DatabaseDir"
    exit 1
}

# Danh sách thứ tự chuẩn 8 file SQL
$OrderedFiles = @(
    "00_create_database.sql",
    "01_schema_tables.sql",
    "02_seed_data.sql",
    "03_proc_crud.sql",
    "04_triggers.sql",
    "05_proc_queries.sql",
    "06_functions_cursor.sql"
)

if ($IncludeDemo) {
    $OrderedFiles += "07_demo_test_cases.sql"
}

if (-not [string]::IsNullOrWhiteSpace($File)) {
    $OrderedFiles = @($File)
}

function Split-SqlBatches {
    param([string]$SqlContent)

    # Tách theo dòng chứa lệnh GO độc lập (hỗ trợ cả `GO` và `GO <count>`, không phân biệt hoa thường)
    $Lines = $SqlContent -split "\r?\n"
    $Batches = New-Object System.Collections.Generic.List[PSObject]
    $CurrentLines = New-Object System.Collections.Generic.List[string]
    $BatchStartLine = 1
    $LineNumber = 0

    foreach ($Line in $Lines) {
        $LineNumber++
        if ($Line -match '^\s*GO(?:\s+(\d+))?\s*(?:--.*)?$') {
            $RepeatCount = if ($Matches[1]) { [int]$Matches[1] } else { 1 }
            $BatchText = ($CurrentLines -join [Environment]::NewLine).Trim()
            if (-not [string]::IsNullOrWhiteSpace($BatchText)) {
                $Batches.Add([PSCustomObject]@{
                    Sql        = $BatchText
                    Repeat     = $RepeatCount
                    StartLine  = $BatchStartLine
                    EndLine    = ($LineNumber - 1)
                })
            }
            $CurrentLines.Clear()
            $BatchStartLine = $LineNumber + 1
        }
        else {
            $CurrentLines.Add($Line)
        }
    }

    $RemainingText = ($CurrentLines -join [Environment]::NewLine).Trim()
    if (-not [string]::IsNullOrWhiteSpace($RemainingText)) {
        $Batches.Add([PSCustomObject]@{
            Sql        = $RemainingText
            Repeat     = 1
            StartLine  = $BatchStartLine
            EndLine    = $LineNumber
        })
    }

    return $Batches
}

function Invoke-SqlFileWithDotNet {
    param(
        [string]$FilePath,
        [string]$Server,
        [string]$DbName,
        [string]$User,
        [string]$Pass
    )

    $ConnBuilder = New-Object System.Data.SqlClient.SqlConnectionStringBuilder
    $ConnBuilder["Data Source"] = $Server
    $ConnBuilder["TrustServerCertificate"] = $true
    if (-not [string]::IsNullOrWhiteSpace($DbName)) {
        $ConnBuilder["Initial Catalog"] = $DbName
    }
    if ([string]::IsNullOrWhiteSpace($User)) {
        $ConnBuilder["Integrated Security"] = $true
    }
    else {
        $ConnBuilder["User ID"] = $User
        $ConnBuilder["Password"] = $Pass
    }

    $SqlContent = Get-Content -Path $FilePath -Raw -Encoding UTF8
    $Batches = Split-SqlBatches -SqlContent $SqlContent

    $Connection = New-Object System.Data.SqlClient.SqlConnection($ConnBuilder.ConnectionString)
    # Bắt các thông báo PRINT / RAISERROR mức thông tin từ SQL Server
    $EventHandler = [System.Data.SqlClient.SqlInfoMessageEventHandler]{
        param($sender, $event)
        foreach ($err in $event.Errors) {
            Write-Host "    [SQL] $($err.Message)" -ForegroundColor Gray
        }
    }
    $Connection.add_InfoMessage($EventHandler)
    $Connection.FireInfoMessageEventOnUserErrors = $false

    try {
        $Connection.Open()
        $BatchIndex = 0
        foreach ($Batch in $Batches) {
            $BatchIndex++
            for ($r = 1; $r -le $Batch.Repeat; $r++) {
                $Command = $Connection.CreateCommand()
                $Command.CommandText = $Batch.Sql
                $Command.CommandTimeout = 120
                try {
                    [void]$Command.ExecuteNonQuery()
                }
                catch {
                    Write-Host "  [LỖI] Batch #$BatchIndex (dòng $($Batch.StartLine)-$($Batch.EndLine)):" -ForegroundColor Red
                    Write-Host "  $($_.Exception.Message)" -ForegroundColor Red
                    throw
                }
                finally {
                    $Command.Dispose()
                }
            }
        }
    }
    finally {
        if ($Connection.State -eq [System.Data.ConnectionState]::Open) {
            $Connection.Close()
        }
        $Connection.Dispose()
    }
}

function Invoke-SqlFileWithSqlCmd {
    param(
        [string]$FilePath,
        [string]$Server,
        [string]$DbName,
        [string]$User,
        [string]$Pass
    )

    $ArgsList = @("-S", $Server, "-C", "-b", "-f", "65001", "-i", $FilePath)
    if (-not [string]::IsNullOrWhiteSpace($DbName)) {
        $ArgsList += @("-d", $DbName)
    }
    if ([string]::IsNullOrWhiteSpace($User)) {
        $ArgsList += "-E"
    }
    else {
        $ArgsList += @("-U", $User, "-P", $Pass)
    }

    & sqlcmd @ArgsList
    if ($LASTEXITCODE -ne 0) {
        throw "sqlcmd kết thúc với mã lỗi $LASTEXITCODE khi chạy file $(Split-Path $FilePath -Leaf)."
    }
}

$HasSqlCmd = ($null -ne (Get-Command "sqlcmd" -ErrorAction SilentlyContinue)) -and (-not $UseDotNet)
$RunnerMode = if ($HasSqlCmd) { "sqlcmd CLI (Native GO batch)" } else { ".NET SqlClient (Regex GO batch splitter)" }

Write-Host "=================================================================" -ForegroundColor Cyan
Write-Host " BK-LMS DATABASE RUNNER - MS SQL SERVER" -ForegroundColor Cyan
Write-Host "=================================================================" -ForegroundColor Cyan
Write-Host " Server Instance : $ServerInstance"
Write-Host " Chế độ thực thi : $RunnerMode"
Write-Host " Thư mục SQL     : $DatabaseDir"
Write-Host "=================================================================" -ForegroundColor Cyan

$StopwatchTotal = [System.Diagnostics.Stopwatch]::StartNew()

function Resolve-SqlFilePath {
    param([string]$PathInput)

    if ([System.IO.Path]::IsPathRooted($PathInput) -and (Test-Path $PathInput)) {
        return $PathInput
    }
    if (Test-Path $PathInput) {
        return (Resolve-Path $PathInput).Path
    }
    $InDb = Join-Path $DatabaseDir $PathInput
    if (Test-Path $InDb) {
        return $InDb
    }
    $InProj = Join-Path $ProjectRoot $PathInput
    if (Test-Path $InProj) {
        return $InProj
    }
    return $null
}

foreach ($FileName in $OrderedFiles) {
    $FilePath = Resolve-SqlFilePath -PathInput $FileName
    if (-not $FilePath) {
        Write-Host "[BỎ QUA] Không tìm thấy file: $FileName" -ForegroundColor Yellow
        continue
    }

    # Với file 00_create_database.sql, không ép Initial Catalog nếu Database chưa tồn tại
    $EffectiveDb = if ((Split-Path $FilePath -Leaf) -eq "00_create_database.sql") { "" } else { $Database }

    Write-Host "`n--> Đang thực thi: $(Split-Path $FilePath -Leaf) ..." -ForegroundColor Yellow
    $Sw = [System.Diagnostics.Stopwatch]::StartNew()

    if ($HasSqlCmd) {
        Invoke-SqlFileWithSqlCmd -FilePath $FilePath -Server $ServerInstance -DbName $EffectiveDb -User $Username -Pass $Password
    }
    else {
        Invoke-SqlFileWithDotNet -FilePath $FilePath -Server $ServerInstance -DbName $EffectiveDb -User $Username -Pass $Password
    }

    $Sw.Stop()
    Write-Host "    [HOÀN TẤT] $(Split-Path $FilePath -Leaf) ($($Sw.ElapsedMilliseconds) ms)" -ForegroundColor Green
}

$StopwatchTotal.Stop()
Write-Host "`n=================================================================" -ForegroundColor Cyan
Write-Host " ĐÃ CHẠY THÀNH CÔNG TOÀN BỘ SCRIPT ($($StopwatchTotal.ElapsedMilliseconds) ms)" -ForegroundColor Green
Write-Host "=================================================================" -ForegroundColor Cyan
