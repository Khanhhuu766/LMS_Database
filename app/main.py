from pathlib import Path

import pyodbc
from fastapi import FastAPI, Request
from fastapi.exceptions import RequestValidationError
from fastapi.responses import FileResponse, HTMLResponse
from fastapi.staticfiles import StaticFiles

from app.db import api_error, api_ok, fetch_one, handle_sql_error
from app.routers import functions, lookups, posts_crud, queries

BASE_DIR = Path(__file__).resolve().parent
STATIC_DIR = BASE_DIR / "static"

app = FastAPI(
    title="BK-LMS Database Application",
    description="Ứng dụng kết nối CSDL LMS_DB (BTL2 - Hệ Cơ sở Dữ liệu)",
    version="1.0.0",
)


# Chuẩn hóa lỗi validate tham số của FastAPI/Pydantic về cùng 1 format JSON
@app.exception_handler(RequestValidationError)
async def validation_exception_handler(request: Request, exc: RequestValidationError):
    errors = exc.errors()
    first_err = errors[0] if errors else {}
    field = " -> ".join(str(loc) for loc in first_err.get("loc", []) if loc != "body")
    msg = first_err.get("msg", "Dữ liệu đầu vào không hợp lệ.")
    full_msg = f"Trường '{field}': {msg}" if field else msg
    return api_error(message=full_msg, error_code=422, status_code=422)


# Đăng ký các router
app.include_router(lookups.router)
app.include_router(posts_crud.router)
app.include_router(queries.router)
app.include_router(functions.router)

# Mount thư mục tĩnh nếu đã tồn tại
if STATIC_DIR.exists():
    app.mount("/static", StaticFiles(directory=str(STATIC_DIR)), name="static")


@app.get("/api/health", tags=["Health Check"])
def health_check():
    sql = """
        SELECT
            DB_NAME() AS database_name,
            @@SERVERNAME AS server_name,
            (SELECT COUNT(*) FROM dbo.[POST]) AS post_count,
            (SELECT COUNT(*) FROM dbo.[CLASS]) AS class_count;
    """
    try:
        info = fetch_one(sql)
        return api_ok(info)
    except pyodbc.Error as exc:
        return handle_sql_error(exc)


@app.get("/", include_in_schema=False)
def serve_index():
    index_file = STATIC_DIR / "index.html"
    if index_file.exists():
        return FileResponse(str(index_file))
    return HTMLResponse(
        content=(
            "<h3>BK-LMS Backend Core đã chạy thành công!</h3>"
            "<p>Kiểm tra kết nối CSDL: <a href='/api/health'>/api/health</a></p>"
            "<p>Tài liệu API thử nghiệm (Swagger): <a href='/docs'>/docs</a></p>"
            "<p><i>(Hãy tạo file <code>app/static/index.html</code> để hoàn thiện giao diện khung).</i></p>"
        )
    )