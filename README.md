# Hệ thống Quản lý Học tập Trực tuyến E-Learning (BK-LMS)

> **Môn học:** Hệ cơ sở Dữ liệu (CO2014 – HCMUT) – Bài tập lớn số 2 (Giai đoạn Database: Phần 1 & Phần 2)  
> **Hệ quản trị CSDL:** Microsoft SQL Server (Transact-SQL / T-SQL)

---

## 1. Giới thiệu chung

Dự án hiện thực Cơ sở dữ liệu cho hệ thống **BK-LMS** dựa trên thiết kế từ BTL1 gồm:
- **25 bảng quan hệ** (đã gộp `User_acc` vào `[USER]`).
- **36 khóa ngoại** (`FOREIGN KEY`) và **29 ràng buộc ngữ nghĩa** (`CHECK`, `UNIQUE`, `TRIGGER`, `STORED PROCEDURE`).

---

## 2. Công cụ làm việc thống nhất

| Thành phần | Công cụ | Vai trò |
| :--- | :--- | :--- |
| **Hệ QTCSDL** | **MS SQL Server Express / Developer** | Chạy dịch vụ CSDL cục bộ trên máy mỗi thành viên (VD: `localhost\SQLEXPRESS`). |
| **Công cụ viết & chạy SQL** | **VS Code** (`SQL Server (mssql)`) hoặc **SSMS** | Kết nối vào SQL Server cục bộ để thực thi và kiểm thử các file `.sql`. |
| **Quản lý mã nguồn** | **Git & GitHub** | Đồng bộ các file script `.sql` giữa 5 thành viên trong nhóm. |

---

## 3. Cấu trúc thư mục dự án

```text
BTL2_LMS/
├── README.md                         # Hướng dẫn thứ tự chạy các file .sql và quy ước làm việc nhóm
├── .gitignore                        # Bỏ qua các file rác hệ thống, file backup (.bak, .mdf, .ldf)
├── .gitattributes                    # Đồng bộ chuẩn xuống dòng (CRLF) chống Merge Conflict
│
├── database/                         # Chứa toàn bộ 8 script T-SQL của nhóm
│   ├── 00_create_database.sql        # Khởi tạo Database (LMS_DB)
│   ├── 01_schema_tables.sql          # [Mục 1.1] Tạo 25 bảng + PK, FK, UNIQUE, CHECK
│   ├── 02_seed_data.sql              # [Mục 1.2] Dữ liệu mẫu (>= 5 dòng/bảng, chia 4 Section cho TV2-TV5)
│   ├── 03_proc_crud.sql              # [Mục 2.1] 3 Thủ tục Insert / Update / Delete trên 1 bảng
│   ├── 04_triggers.sql               # [Mục 2.2] 2 Trigger (chia 2 Section cho TV2 & TV3)
│   ├── 05_proc_queries.sql           # [Mục 2.3] 2 Thủ tục truy vấn hiển thị dữ liệu
│   ├── 06_functions_cursor.sql       # [Mục 2.4] 2 Hàm tính toán có sử dụng CURSOR
│   └── 07_demo_test_cases.sql        # Kịch bản kiểm thử khi báo cáo (chia 5 Section cho TV1-TV5)
│
├── scripts/                          # Kịch bản tự động chạy các file SQL (hỗ trợ batch GO)
│   ├── run_all.ps1                   # PowerShell runner (chạy toàn bộ hoặc từng file lẻ qua -File)
│   ├── run_all.bat                   # Batch wrapper chạy nhanh toàn bộ trên Windows
│   ├── run_file.bat                  # Batch chạy 1 file SQL bất kỳ (hỗ trợ kéo-thả file)
│   └── run_all.sh                    # Bash runner cho macOS / Linux / Git Bash
│
└── docs/                             # Tài liệu tham chiếu từ BTL1 & phân công nhiệm vụ
    ├── 01_schema_25_tables.md        # Phụ lục A: Danh sách 25 bảng và các cột
    ├── 02_semantic_constraints.md    # Phụ lục B: Phân loại 29 ràng buộc ngữ nghĩa
    └── 03_task_assignment.md         # Khung phân công công việc cho 5 thành viên
```

---

## 4. Hướng dẫn chạy các file SQL

### Cách 1: Chạy toàn bộ từ đầu đến cuối qua Runner

Mở **PowerShell** tại thư mục gốc của dự án và chạy:

```powershell
# Chạy tuần tự từ 00 đến 06 với Windows Authentication (mặc định: localhost\SQLEXPRESS)
.\scripts\run_all.ps1

# Chạy kèm kịch bản kiểm thử 07_demo_test_cases.sql
.\scripts\run_all.ps1 -IncludeDemo

# Chạy với SQL Server Authentication (tài khoản sa)
.\scripts\run_all.ps1 -ServerInstance "localhost" -Username "sa" -Password "YourPassword"
```

### Cách 2: Chạy riêng lẻ từng file SQL

* **Bằng phím tắt trong VS Code:** Mở file `.sql` cần chạy và nhấn **`Ctrl + Shift + B`** (hoặc dùng extension `mssql` nhấn `Ctrl + Shift + E`).
* **Bằng PowerShell:**
  ```powershell
  .\scripts\run_all.ps1 -File "01_schema_tables.sql"
  .\scripts\run_all.ps1 -File "02_seed_data.sql"
  ```
* **Bằng kéo-thả trên Windows:** Kéo file `.sql` bất kỳ thả vào biểu tượng `scripts\run_file.bat`.

---

