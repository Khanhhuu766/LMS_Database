import os
import re
from datetime import date, datetime
from decimal import Decimal
from typing import Any

import pyodbc
from dotenv import load_dotenv
from fastapi.responses import JSONResponse

# Tự động tìm và nạp các biến từ file .env ở thư mục gốc dự án
load_dotenv()

DB_SERVER = os.getenv("DB_SERVER", r"localhost\SQLEXPRESS")
DB_NAME = os.getenv("DB_NAME", "LMS_DB")
DB_DRIVER = os.getenv("DB_DRIVER", "ODBC Driver 18 for SQL Server")
DB_TRUSTED = os.getenv("DB_TRUSTED_CONNECTION", "yes").strip().lower()
DB_USER = os.getenv("DB_USER", "")
DB_PASSWORD = os.getenv("DB_PASSWORD", "")


def build_connection_string() -> str:
    parts = [
        f"DRIVER={{{DB_DRIVER}}}",
        f"SERVER={DB_SERVER}",
        f"DATABASE={DB_NAME}",
        "TrustServerCertificate=yes",
    ]
    if DB_TRUSTED in ("yes", "true", "1"):
        parts.append("Trusted_Connection=yes")
    else:
        parts.append(f"UID={DB_USER}")
        parts.append(f"PWD={DB_PASSWORD}")

    return ";".join(parts) + ";"


def get_connection() -> pyodbc.Connection:
    conn_str = build_connection_string()
    return pyodbc.connect(conn_str, autocommit=False)


# ---------------------------------------------------------------------------
# Chuẩn hóa dữ liệu & Format JSON thống nhất cho toàn bộ API
# ---------------------------------------------------------------------------
def _serialize_value(val: Any) -> Any:
    if isinstance(val, Decimal):
        return float(val)
    if isinstance(val, (datetime, date)):
        return val.isoformat()
    return val


def _rows_to_dicts(cursor: pyodbc.Cursor) -> list[dict[str, Any]]:
    # Nhảy qua các result set rỗng (nếu có) để đến đúng tập kết quả SELECT
    while cursor.description is None:
        if not cursor.nextset():
            return []

    columns = [col[0] for col in cursor.description]
    rows = cursor.fetchall()
    return [
        {col: _serialize_value(val) for col, val in zip(columns, row)}
        for row in rows
    ]


def api_ok(data: Any = None, status_code: int = 200) -> JSONResponse:
    return JSONResponse(
        status_code=status_code,
        content={"success": True, "data": data},
    )


def api_error(
    message: str,
    error_code: int | str | None = None,
    status_code: int = 400,
) -> JSONResponse:
    return JSONResponse(
        status_code=status_code,
        content={
            "success": False,
            "error_code": error_code,
            "message": message,
        },
    )


def parse_sql_error(exc: pyodbc.Error) -> tuple[int | None, str, int]:
    """
    Trích xuất mã lỗi SQL Server (vd: 51001..51026, 50018..50019, 547, 2627)
    và thông báo lỗi gọn sạch.
    Trả về: (error_code, clean_message, http_status_code)
    """
    raw_msg = str(exc.args[1]) if len(exc.args) > 1 else str(exc)

    # ODBC có thể nối thông báo THROW với thông báo kết thúc câu lệnh.
    for diagnostic in raw_msg.split("[SQL Server]")[1:]:
        match = re.search(r"\s*\((5\d{4})\)(?=\s*(?:\([^()]*\))?\s*(?:;|$))", diagnostic)
        if match:
            return int(match.group(1)), diagnostic[:match.start()].strip(), 400

    # Tìm mã lỗi dạng (51026) đứng trước (SQLExecDirectW) hoặc cuối đoạn thông báo
    code_match = re.search(r"\((\d+)\)\s*(?:\([^)]+\)\s*)?$", raw_msg)
    error_code = int(code_match.group(1)) if code_match else None

    # Lấy phần nội dung nằm sau "[SQL Server]" và bỏ phần "(51026) (SQLExecDirectW)"
    clean_msg = raw_msg
    if "[SQL Server]" in clean_msg:
        clean_msg = clean_msg.split("[SQL Server]")[-1]
    clean_msg = re.sub(r"\s*\(\d+\)\s*(?:\([^)]+\)\s*)?$", "", clean_msg).strip()

    # Nhận diện các mã lỗi nghiệp vụ (50000-59999 do THROW, 547 FK/CHECK, 2627/2601 UNIQUE)
    if error_code is not None and (
        50000 <= error_code <= 59999 or error_code in (547, 2627, 2601)
    ):
        return error_code, clean_msg, 400

    return error_code, clean_msg or "Lỗi kết nối hoặc thực thi cơ sở dữ liệu.", 500


def handle_sql_error(exc: pyodbc.Error) -> JSONResponse:
    error_code, clean_msg, http_status = parse_sql_error(exc)
    return api_error(message=clean_msg, error_code=error_code, status_code=http_status)


# ---------------------------------------------------------------------------
# Các hàm Helper dùng chung để gọi SELECT / Stored Procedure / Scalar Function
# ---------------------------------------------------------------------------
def fetch_all(sql: str, params: tuple[Any, ...] = ()) -> list[dict[str, Any]]:
    with get_connection() as conn:
        cursor = conn.cursor()
        cursor.execute(sql, params)
        return _rows_to_dicts(cursor)


def fetch_one(sql: str, params: tuple[Any, ...] = ()) -> dict[str, Any] | None:
    rows = fetch_all(sql, params)
    return rows[0] if rows else None


def execute_sp(sql: str, params: tuple[Any, ...] = ()) -> list[dict[str, Any]]:
    """
    Thực thi Stored Procedure có thay đổi dữ liệu (INSERT/UPDATE/DELETE)
    và commit transaction nếu thành công.
    """
    conn = get_connection()
    try:
        cursor = conn.cursor()
        cursor.execute(sql, params)
        result = _rows_to_dicts(cursor)
        conn.commit()
        return result
    except Exception:
        conn.rollback()
        raise
    finally:
        conn.close()