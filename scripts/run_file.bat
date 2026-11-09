@echo off
chcp 65001 >nul
setlocal

REM =================================================================================
REM KỊCH BẢN CHẠY 1 FILE SQL BẤT KỲ TRÊN WINDOWS
REM Cách dùng:
REM   1. Kéo thả trực tiếp bất kỳ file .sql nào vào file run_file.bat này.
REM   2. Hoặc mở cmd/terminal gõ: scripts\run_file.bat database\00_create_database.sql
REM =================================================================================

if "%~1"=="" (
    echo [HƯỚNG DẪN] Bạn hãy kéo thả file .sql cần chạy vào biểu tượng run_file.bat
    echo            Hoặc chạy lệnh: scripts\run_file.bat path\to\file.sql
    echo.
    pause
    exit /b 1
)

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0run_all.ps1" -File "%~1"
if %ERRORLEVEL% neq 0 (
    echo.
    echo [LỖI] Quá trình thực thi gặp lỗi. Xem thông báo phía trên.
)
pause
