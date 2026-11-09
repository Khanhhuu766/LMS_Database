#!/usr/bin/env bash
# =================================================================================
# KỊCH BẢN CHẠY TUẦN TỰ CÁC FILE T-SQL CHO DỰ ÁN BK-LMS (BTL2 HỆ CSDL)
# Môi trường : Linux / macOS / Git Bash (sử dụng sqlcmd hỗ trợ batch GO)
# Cách dùng  :
#   ./scripts/run_all.sh
#   DB_SERVER="localhost,1433" DB_USER="sa" DB_PASS="YourStrong!Pass" ./scripts/run_all.sh --include-demo
# =================================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
DB_DIR="$PROJECT_ROOT/database"

DB_SERVER="${DB_SERVER:-localhost\\SQLEXPRESS}"
DB_NAME="${DB_NAME:-}"
DB_USER="${DB_USER:-}"
DB_PASS="${DB_PASS:-}"
INCLUDE_DEMO=0

for arg in "$@"; do
    case "$arg" in
        --include-demo)
            INCLUDE_DEMO=1
            ;;
    esac
done

if ! command -v sqlcmd >/dev/null 2>&1; then
    echo "[LỖI] Không tìm thấy công cụ 'sqlcmd' trong PATH." >&2
    echo "      Trên Windows, bạn có thể chạy './scripts/run_all.ps1' (hỗ trợ cả sqlcmd và .NET SqlClient)." >&2
    exit 1
fi

SQL_FILES=(
    "00_create_database.sql"
    "01_schema_tables.sql"
    "02_seed_data.sql"
    "03_proc_crud.sql"
    "04_triggers.sql"
    "05_proc_queries.sql"
    "06_functions_cursor.sql"
)

if [[ "$INCLUDE_DEMO" -eq 1 ]]; then
    SQL_FILES+=("07_demo_test_cases.sql")
fi

echo "================================================================="
echo " BK-LMS DATABASE RUNNER (sqlcmd - Native GO Batch)"
echo " Server : $DB_SERVER"
echo "================================================================="

for file in "${SQL_FILES[@]}"; do
    filepath="$DB_DIR/$file"
    if [[ ! -f "$filepath" ]]; then
        echo "[BỎ QUA] Không tìm thấy file: $file"
        continue
    fi

    echo ""
    echo "--> Đang thực thi: $file ..."

    CMD_ARGS=(-S "$DB_SERVER" -C -b -i "$filepath")
    if [[ "$file" != "00_create_database.sql" && -n "$DB_NAME" ]]; then
        CMD_ARGS+=(-d "$DB_NAME")
    fi

    if [[ -z "$DB_USER" ]]; then
        CMD_ARGS+=(-E)
    else
        CMD_ARGS+=(-U "$DB_USER" -P "$DB_PASS")
    fi

    sqlcmd "${CMD_ARGS[@]}"
    echo "    [HOÀN TẤT] $file"
done

echo ""
echo "================================================================="
echo " ĐÃ CHẠY THÀNH CÔNG TOÀN BỘ SCRIPT SQL!"
echo "================================================================="
