# Hệ thống Quản lý Học tập Trực tuyến E-Learning (BK-LMS)

> **Môn học:** Hệ cơ sở Dữ liệu (CO2014 – HCMUT) – Bài tập lớn số 2 (Database & Ứng dụng Web)  
> **Hệ quản trị CSDL:** Microsoft SQL Server 2016+ (Transact-SQL / T-SQL)  
> **Ứng dụng kết nối CSDL:** Python 3.12 (FastAPI + `pyodbc`) & HTML5 / Bootstrap 5

---

## 1. Giới thiệu chung

Dự án hiện thực trọn vẹn **Bài tập lớn số 2 (BTL2)** cho hệ thống quản lý học tập trực tuyến **BK-LMS** dựa trên thiết kế từ BTL1:
- **Phần 1 & Phần 2 (Database – `LMS_DB`):** Gồm **25 bảng quan hệ** (đã gộp `User_acc` vào `[USER]`), **36 khóa ngoại**, **29 ràng buộc ngữ nghĩa** (`CHECK`, `UNIQUE`, `TRIGGER`), bộ thủ tục CRUD (`[POST]`), thủ tục truy vấn và hàm tính toán dùng `CURSOR`.
- **Phần 3 (Ứng dụng Web):** Kết nối trực tiếp tới `LMS_DB` qua `pyodbc`, cung cấp giao diện Quản lý Bài đăng `[POST]` (Thêm/Sửa/Xóa/Tìm kiếm/Lọc), Thống kê kết quả bài kiểm tra và Tính điểm sinh viên bằng hàm `CURSOR`.

---

## 2. Công cụ & Công nghệ thống nhất

| Thành phần | Công cụ / Công nghệ | Vai trò |
| :--- | :--- | :--- |
| **Hệ QTCSDL** | **MS SQL Server Express / Developer** | Chạy dịch vụ CSDL cục bộ `LMS_DB` (VD: `localhost\SQLEXPRESS`, kèm ODBC Driver 17/18). |
| **Viết & chạy SQL** | **VS Code** (`SQL Server (mssql)`) hoặc **SSMS** | Kết nối vào SQL Server cục bộ để thực thi và kiểm thử các file `.sql`. |
| **Backend Web & DB** | **Python 3.12 (FastAPI + `pyodbc`)** | Cung cấp REST API gọi trực tiếp Stored Procedure / Function và chuẩn hóa mã lỗi SQL. |
| **Frontend Web** | **HTML5 + Bootstrap 5 + Vanilla JS** | Giao diện 3 Tab chức năng (Mục 3.1, 3.2, 3.3) và Modal Thêm/Sửa/Xóa. |
| **Quản lý mã nguồn** | **Git & GitHub** | Đồng bộ code giữa 5 thành viên trong nhóm. |

---

## 3. Cấu trúc thư mục dự án

```text
BTL2_LMS/
├── README.md                         # Hướng dẫn cài đặt, chạy SQL và khởi động ứng dụng Web
├── .gitignore                        # Bỏ qua file rác, backup SQL, .venv, .env, file tạm LaTeX
├── .gitattributes                    # Đồng bộ chuẩn xuống dòng (CRLF) chống Merge Conflict
├── .env.example                      # File mẫu biến môi trường kết nối SQL Server
├── requirements.txt                  # Danh sách thư viện Python cho Phần 3
│
├── app/                              # [Phần 3] Ứng dụng Web kết nối CSDL LMS_DB
│   ├── main.py                       # Khởi tạo FastAPI, /api/health, phục vụ giao diện & chuẩn hóa lỗi
│   ├── db.py                         # Kết nối pyodbc (.env), helper execute_sp/fetch_all & bóc lỗi SQL
│   ├── routers/                      # Các API Router tách riêng theo từng thành viên
│   │   ├── lookups.py                # API lấy dữ liệu nền cho Dropdown & chi tiết bài đăng
│   │   ├── posts_crud.py             # [Mục 3.1] API Thêm/Sửa/Xóa [POST] gọi usp_Post_*
│   │   ├── queries.py                # [Mục 3.2 & 3.3] API tìm kiếm [POST] & thống kê bài kiểm tra
│   │   └── functions.py              # [Mục 3.3] API gọi 2 hàm Cursor tính điểm sinh viên
│   └── static/                       # Giao diện Frontend (HTML/CSS/JS)
│       ├── index.html                # Trang chủ Bootstrap 5 với 3 Tab chức năng
│       └── js/
│           ├── core.js               # Kiểm tra kết nối DB, apiRequest(), showAlert(), nạp Lookups
│           ├── posts_crud.js         # Logic Modal Thêm/Sửa/Xóa [POST]
│           ├── queries.js            # Logic tìm kiếm, lọc, sắp xếp [POST] & bảng thống kê
│           └── functions.js          # Logic giao diện gọi 2 hàm Cursor
│
├── database/                         # [Phần 1 & 2] Toàn bộ script T-SQL của nhóm
│   ├── 00_create_database.sql        # Khởi tạo Database (LMS_DB)
│   ├── 01_schema_tables.sql          # [Mục 1.1] Tạo 25 bảng + PK, FK, UNIQUE, CHECK
│   ├── 02_seed_data.sql              # [Mục 1.2] Dữ liệu mẫu (>= 5 dòng/bảng, chia 4 Section)
│   ├── 03_proc_crud.sql              # [Mục 2.1] 3 Thủ tục Insert / Update / Delete trên [POST]
│   ├── 04_triggers.sql               # [Mục 2.2] Trigger RB18 & chuỗi Trigger thuộc tính dẫn xuất
│   ├── 05_proc_queries.sql           # [Mục 2.3] 2 Thủ tục truy vấn (usp_Post_Search, usp_Test_ScoreStatistics)
│   ├── 06_functions_cursor.sql       # [Mục 2.4] 2 Hàm tính toán có sử dụng CURSOR
│   ├── 07_demo_test_cases.sql        # Kịch bản kiểm thử tự động & minh họa (chia 5 Section)
│   ├── Counting_Check.sql            # Kiểm tra nhanh số dòng của 25 bảng
│   ├── Delete_Database.sql           # Xóa sạch LMS_DB khi cần khởi tạo lại từ đầu
│   └── show_db.sql                   # Xem nhanh dữ liệu cả 25 bảng
│
├── scripts/                          # Kịch bản tự động chạy các file SQL (hỗ trợ batch GO)
│   ├── run_all.ps1                   # PowerShell runner (chạy toàn bộ hoặc từng file lẻ qua -File)
│   ├── run_all.bat                   # Batch wrapper chạy nhanh toàn bộ trên Windows
│   ├── run_file.bat                  # Batch chạy 1 file SQL bất kỳ (hỗ trợ kéo-thả file)
│   └── run_all.sh                    # Bash runner cho macOS / Linux / Git Bash
│
└── docs/                             # Tài liệu thiết kế & phân công nhiệm vụ nhóm
    ├── 01_schema_25_tables.md        # Phụ lục A: Danh sách 25 bảng và các cột
    ├── 02_semantic_constraints.md    # Phụ lục B: Phân loại 29 ràng buộc ngữ nghĩa
    └── 03_task_assignment.md         # Phân công công việc (DB, App, LaTeX) & sườn báo cáo BTL2
```

---

## 4. Hướng dẫn thiết lập và chạy Database (Phần 1 & 2)

### Cách 1: Chạy toàn bộ qua PowerShell Runner

Mở **PowerShell** tại thư mục gốc dự án và chạy:

```powershell
# Chạy tuần tự từ 00 đến 06 với Windows Authentication (mặc định: localhost\SQLEXPRESS)
.\scripts\run_all.ps1

# Chạy kèm toàn bộ kịch bản kiểm thử 07_demo_test_cases.sql
.\scripts\run_all.ps1 -IncludeDemo

# Chạy với SQL Server Authentication (tài khoản sa)
.\scripts\run_all.ps1 -ServerInstance "localhost" -Username "sa" -Password "YourPassword"
```

### Cách 2: Chạy riêng lẻ từng file SQL

* **Bằng phím tắt trong VS Code:** Mở file `.sql` cần chạy và nhấn **`Ctrl + Shift + B`** (hoặc dùng extension `mssql` nhấn `Ctrl + Shift + E`).
* **Bằng PowerShell:**
  ```powershell
  .\scripts\run_all.ps1 -File "01_schema_tables.sql"
  .\scripts\run_all.ps1 -File "07_demo_test_cases.sql"
  ```
* **Bằng kéo-thả trên Windows:** Kéo file `.sql` bất kỳ thả vào biểu tượng `scripts\run_file.bat`.

---

## 5. Hướng dẫn cài đặt & chạy Ứng dụng Web (Phần 3)

*(Thực hiện sau khi đã nạp xong `LMS_DB` ở Mục 4)*

### Bước 1: Tạo môi trường ảo và cài đặt thư viện Python
```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
```

### Bước 2: Cấu hình kết nối SQL Server qua `.env`
Tạo file `.env` từ file mẫu `.env.example`:
```powershell
Copy-Item .env.example .env
```
Mở file `.env` và kiểm tra thông số cho đúng với máy của bạn (mặc định dùng Windows Authentication trên `localhost\SQLEXPRESS` với `ODBC Driver 18 for SQL Server`; nếu dùng `sa`, đổi `DB_TRUSTED_CONNECTION=no` và điền `DB_USER`, `DB_PASSWORD`).

### Bước 3: Khởi động máy chủ ứng dụng
```powershell
uvicorn app.main:app --reload
```
Truy cập trên trình duyệt:
* **Giao diện chính:** `http://localhost:8000`
* **Kiểm tra trạng thái kết nối DB:** `http://localhost:8000/api/health`
* **Tài liệu API thử nghiệm (Swagger UI):** `http://localhost:8000/docs`

---

## 6. Quy ước làm việc nhóm

1. **Giữ nguyên tên bảng và tên cột từ BTL1:** Tra cứu tại [`docs/01_schema_25_tables.md`](docs/01_schema_25_tables.md). Với các bảng trùng từ khóa SQL Server (`USER`, `FILE`, `COMMENT`, `STATUS`), luôn đặt trong cặp ngoặc vuông: `[USER]`, `[FILE]`, `[COMMENT]`, `[STATUS]`.
2. **Chống xung đột trên các file SQL chia Section (`02`, `04`, `07`):** Chỉ sửa code trong khung `-- PHẦN CỦA TV...` của mình; không dùng *Format Document* toàn bộ file.
3. **Không commit file cá nhân lên GitHub:** Không đẩy `.env`, `.venv/`, `__pycache__/` lên repo. Mỗi thành viên phát triển tính năng Phần 3 trên một router/JS riêng theo phân công tại [`docs/03_task_assignment.md`](docs/03_task_assignment.md).
