# Phân công công việc & Sườn Báo cáo BTL2 (Database – Ứng dụng – LaTeX)

> **Thông tin nhóm:** Nhóm 2 – Lớp L05 | GVHD: ThS. Dương Huỳnh Anh Đức  
> **Thành viên:** Phạm Hoàng Hà (`2410857`), Phan Trung Kiên (`2411763`), Dương Bảo Kiệt (`2311752`), Trần Minh Nhật (`2412490`), Nguyễn Hữu Khánh (`2411524`).

---

## 1. Phân công Giai đoạn Database (Phần 1 & Phần 2 – 7.0 điểm | Đã hoàn thành)

> **Quy định bắt buộc của đề bài:** Tất cả sinh viên trong nhóm **PHẢI** viết ít nhất 1 câu trong Phần 2 (Trigger, Function, Procedure). Mọi thành viên phải nắm rõ ý nghĩa và nội dung của từng hàm, thủ tục trong nhóm.

| Thành viên | Phụ trách Phần 1 (Tạo bảng & Dữ liệu mẫu) | Phụ trách Phần 2 (Mỗi thành viên $\ge 1$ câu) | Kịch bản kiểm thử (`database/07_demo_test_cases.sql`) |
| :--- | :--- | :--- | :--- |
| **Phạm Hoàng Hà** *(TV1)* | **Dựng khung DDL toàn bộ 25 bảng** (`database/01_schema_tables.sql` gồm PK, FK, UNIQUE, CHECK). | **Mục 2.1:** 3 thủ tục `INSERT`/`UPDATE`/`DELETE` bảng `[POST]` (`database/03_proc_crud.sql`). | Test 8/8 case CRUD `[POST]` (hợp lệ & bắt lỗi `51001`–`51026`). |
| **Phan Trung Kiên** *(TV2)* | **Dữ liệu mẫu Cụm 1 (`02_seed_data.sql`):** `[USER]`, `USER_SESSION`, `STUDENT`, `LECTURER`, `LECTURER_DEGREE`, `ADMIN`, `FACULTY`, `SUBJECT`, `PREREQUISITE`. | **Mục 2.2.1:** 2 Trigger kiểm tra ràng buộc nghiệp vụ **RB18** (`database/04_triggers.sql`). | Test 5/5 case Trigger RB18 trên `[ATTEMPT]` và `[TEST]`. |
| **Dương Bảo Kiệt** *(TV3)* | **Dữ liệu mẫu Cụm 2 (`02_seed_data.sql`):** `SEMESTER`, `STATUS`, `CLASS`, `ENROLLS`, `CHAPTER`, `TOPIC`, `[FILE]`. | **Mục 2.2.2:** Chuỗi 3 Trigger tính thuộc tính dẫn xuất `ATTEMPT.score` $\rightarrow$ `TAKES_TEST.final_score` (`database/04_triggers.sql`). | Test 8/8 case Trigger dẫn xuất (thêm/sửa/xóa điểm, đổi `grading_method`). |
| **Trần Minh Nhật** *(TV4)* | **Dữ liệu mẫu Cụm 3 (`02_seed_data.sql`):** `TEST`, `QUESTION`, `CHOICE`, `CONTAINS_QUESTION`. | **Mục 2.3:** 2 Thủ tục truy vấn `usp_Post_Search` (bảng `[POST]`) & `usp_Test_ScoreStatistics` (`database/05_proc_queries.sql`). | Test tự động PASS/FAIL + minh họa tham số `WHERE` / `HAVING`. |
| **Nguyễn Hữu Khánh** *(TV5)* | **Dữ liệu mẫu Cụm 4 (`02_seed_data.sql`):** `TAKES_TEST`, `ATTEMPT`, `STUDENT_ANSWER`, `POST`, `[COMMENT]`. | **Mục 2.4:** 2 Hàm tính toán sử dụng `CURSOR`: `fn_CalculateStudentTestScore` & `fn_CalculateStudentEngagementScore` (`database/06_functions_cursor.sql`). | Test 13/13 case hợp lệ, biên và tham số sai (`-1.00`, `-2.00`, `NULL`). |

---

## 2. Bảng nhiệm vụ Phần 3: Hiện thực Ứng dụng (FastAPI + `pyodbc` + HTML/Bootstrap – 3.0 điểm) & Báo cáo LaTeX

| Thành viên | Nhiệm vụ chính Phần Ứng dụng (UI & Backend) | Nhiệm vụ chính Phần Báo cáo LaTeX |
| :--- | :--- | :--- |
| **Nguyễn Hữu Khánh** | **Dựng khung Core App & Tab Hàm Cursor (3.3):** Cấu hình FastAPI + `db.py` (`pyodbc` nối `LMS_DB`), hàm bóc lỗi SQL chung, API Lookup cho Dropdown; viết API + giao diện tính điểm bằng 2 hàm Cursor. | Dựng khung LaTeX nối tiếp BTL1 (bảng phân công, style code T-SQL); viết **Mục 1.2 (Dữ liệu mẫu)**, **Mục 2.4 (2 Hàm Cursor)**, **Mục 3.3 (phần Hàm Cursor)**; tổng hợp & biên dịch PDF cuối. |
| **Phạm Hoàng Hà** | **Chức năng Thêm / Sửa / Xóa `[POST]` (Mục 3.1):** Viết API gọi `usp_Post_Insert`, `usp_Post_Update`, `usp_Post_Delete` (+ chi tiết 1 bài); làm Modal Form Thêm/Sửa & xác nhận Xóa (validate & hiện lỗi `51001`–`51026`). | Viết **Mục 1.1 (25 bảng & 9 ràng buộc `CHECK/UNIQUE/FK`)**, **Mục 2.1 (3 thủ tục CRUD `[POST]`, lý do/điều kiện xóa)** và phối hợp mô tả **Mục 3.1**. |
| **Trần Minh Nhật** | **Giao diện Danh sách `[POST]` & Thống kê (Mục 3.2 & 3.3):** Viết API gọi `usp_Post_Search` và `usp_Test_ScoreStatistics`; làm trang Danh sách `[POST]` (Search, Filter, Sort, nút Sửa/Xóa từng dòng) + bảng Thống kê điểm kiểm tra. | Viết **Mục 2.3 (2 thủ tục truy vấn `WHERE/ORDER BY` & `GROUP BY/HAVING`)**, **Mục 3.2 (giao diện danh sách tìm kiếm/lọc)** và **Mục 3.3 (phần Thống kê)**. |
| **Phan Trung Kiên** | **QA Kiểm thử App & Môi trường sạch:** Cài đặt lại App từ đầu trên máy độc lập; test toàn bộ luồng hợp lệ & bắt lỗi trên UI (SV4 khóa thảo luận lớp 2, xóa bài có bình luận, tham số biên); chụp bộ ảnh màn hình App cho báo cáo. | Viết **Mục 2.2.1 (Trigger RB18: phân tích 2 chiều DML trên `[ATTEMPT]` & `[TEST]` + ảnh test)** và **Mục 3.1 (kịch bản & ảnh chụp màn hình CRUD)**. |
| **Dương Bảo Kiệt** | **Kiểm thử đồng bộ & Kịch bản Demo bảo vệ:** Đối chiếu số liệu hiển thị trên App khớp 100% với Trigger dẫn xuất trong `LMS_DB`; xây dựng kịch bản bấm demo trực tiếp (từ App xuống DB) để cả nhóm tập dượt vấn đáp. | Viết **Mục 2.2.2 (Chuỗi Trigger dẫn xuất RB25 $\rightarrow$ RB26, thứ tự tính `B` trước `A`, sơ đồ luồng DML + ảnh test)**, **Kết luận** và rà soát toàn bộ LaTeX. |

---

## 3. Tóm tắt Luồng / Trình tự làm việc (Tách riêng Code App & Viết LaTeX)

Để tránh xung đột và không phải ngồi chờ nhau, nhóm tách rõ **2 luồng làm việc độc lập** (có thể triển khai song song):

---

### 3.1. Luồng Code Ứng dụng (FastAPI + `pyodbc` + HTML/Bootstrap)

```text
[Giai đoạn 1: Dựng khung Core & Chuẩn API]
 - Nguyễn Hữu Khánh: Tạo app/, db.py, JSON format, API Lookup -> Merge main
                 │
                 ▼
[Giai đoạn 2: Phát triển song song các chức năng (trên branch riêng)]
 - Phạm Hoàng Hà  : API + Modal Thêm/Sửa/Xóa [POST] (Mục 3.1)
 - Trần Minh Nhật : API + Danh sách [POST] (Mục 3.2) & Bảng Thống kê (Mục 3.3)
 - Nguyễn Hữu Khánh: API + Tab Tính điểm bằng 2 Hàm Cursor (Mục 3.3)
                 │
                 ▼
[Giai đoạn 3: Kiểm thử tích hợp, Test máy sạch & Tập dượt Demo]
 - Phan Trung Kiên: Cài từ đầu trên máy sạch, test UI (hợp lệ + bắt lỗi), chụp ảnh
 - Dương Bảo Kiệt : Đối chiếu số liệu với Trigger LMS_DB, soạn kịch bản bấm Demo
```

#### Chi tiết các bước trong Luồng Code Ứng dụng:
1. **Giai đoạn 1 – Dựng khung Core & Chốt hợp đồng giao tiếp:**
   * **Nguyễn Hữu Khánh:** Thư mục `app/` (`requirements.txt`, `.env.example`, `db.py` kết nối `LMS_DB`, `main.py` FastAPI, `static/` chứa Bootstrap 5). Viết sẵn các API Lookup (`GET /api/lookups/classes`, `users`, `students`, `tests`, `semesters`) và chốt chuẩn JSON trả về:
     * Thành công: `{ "success": true, "data": ... }`
     * Lỗi từ SQL Server: `{ "success": false, "error_code": 51026, "message": "..." }`
2. **Giai đoạn 2 – Code song song các chức năng độc lập:**
   * **Phạm Hoàng Hà:** Viết router `app/routers/posts_crud.py` (`POST`, `PUT`, `DELETE`, `GET /{id}`) gọi `usp_Post_Insert`, `usp_Post_Update`, `usp_Post_Delete`; hoàn thiện Modal Form Thêm/Sửa và xác nhận Xóa ở `static/js/posts_crud.js` (validate + hiển thị lỗi `51001`–`51026`).
   * **Trần Minh Nhật:** Viết router `app/routers/queries.py` gọi `usp_Post_Search` và `usp_Test_ScoreStatistics`; xây dựng trang Danh sách `[POST]` (tìm kiếm, lọc, sắp xếp, gắn nút Sửa/Xóa gọi sang Modal của Hà) + bảng Thống kê điểm kiểm tra.
   * **Nguyễn Hữu Khánh:** Viết router `app/routers/functions.py` gọi `fn_CalculateStudentTestScore` và `fn_CalculateStudentEngagementScore`; xây dựng Tab Tính điểm Sinh viên kèm diễn giải các mã trạng thái (`NULL`, `-1.00`, `-2.00`).
3. **Giai đoạn 3 – Kiểm thử tích hợp, Test máy sạch & Tập dượt Demo:**
   * **Phan Trung Kiên:** Kéo toàn bộ code App về máy độc lập, cài `.venv` + `requirements.txt` từ đầu, chạy kiểm tra đủ các luồng đúng và các ca lỗi (SV4 khóa thảo luận lớp 2, xóa bài có bình luận, tham số biên); chụp lại bộ ảnh màn hình rõ nét chuyển cho team viết báo cáo.
   * **Dương Bảo Kiệt:** Kiểm chứng số liệu thống kê/tính điểm trên App khớp 100% với Trigger dẫn xuất dưới SQL Server; soạn **Kịch bản bấm Demo vấn đáp** chi tiết cho cả 5 thành viên cùng tập chạy thử.

---

### 3.2. Luồng Viết Báo cáo LaTeX

```text
[Giai đoạn 1: Dựng khung LaTeX 
 - Nguyễn Hữu Khánh: Tạo sections/*.tex tách rời từng chương -> Merge main
                 │
                 ▼
[Giai đoạn 2: Viết song song Phần 1 & Phần 2 (Chưa cần chờ App xong)]
 - Phạm Hoàng Hà  : Chương 5 (Mục 5.1 - 25 bảng/CHECK) & Chương 6 (Mục 6.1 - CRUD)
 - Nguyễn Hữu Khánh: Chương 4 (Bảng nhiệm vụ) + Mục 5.2 (Seed) + Mục 6.4 (2 Hàm Cursor)
 - Phan Trung Kiên: Chương 6 (Mục 6.2.1 - Trigger RB18 + ảnh test SQL)
 - Dương Bảo Kiệt : Chương 6 (Mục 6.2.2 - Trigger dẫn xuất RB25->RB26 + ảnh test SQL)
 - Trần Minh Nhật : Chương 6 (Mục 6.3 - 2 Thủ tục truy vấn + ảnh test SQL)
                 │
                 ▼
[Giai đoạn 3: Viết Phần 3 (Chương 7 – sau khi có ảnh chụp App từ Kiên)]
 - Hoàng Hà & Trung Kiên (Mục 7.2 - UI 3.1) | Minh Nhật (Mục 7.3 & 7.4 - UI 3.2, 3.3)
 - Hữu Khánh (Mục 7.1 Kiến trúc & 7.4 Hàm Cursor) | Bảo Kiệt (Chương 8 Kết luận)
                 │
                 ▼
[Giai đoạn 4: Rà soát định dạng & Biên dịch PDF hoàn chỉnh]
 - Dương Bảo Kiệt : Rà soát văn phong, ký hiệu bảng/thuộc tính, bảng biểu, code listing
```

---

## 4. Sườn Báo cáo BTL2

```text
================================================================================
CHƯƠNG 4: PHÂN CÔNG NHIỆM VỤ & KIẾN TRÚC TRIỂN KHAI BTL2
================================================================================
  Bảng phân công nhiệm vụ toàn diện (Bảng 3 cột: Database | UI/App | Báo cáo)
================================================================================
CHƯƠNG 5: TẠO BẢNG VÀ DỮ LIỆU MẪU (PHẦN 1 – 3.0 ĐIỂM)
================================================================================
  5.1. Hiện thực 25 bảng dữ liệu và các ràng buộc toàn vẹn (Mục 1.1)
       - Giải thích gộp User_acc vào [USER], xử lý từ khóa ([USER], [FILE], [COMMENT], [STATUS]).
       - Giải thích quy ước ON DELETE / ON UPDATE (tránh lỗi multiple cascade paths).
       - Bảng đối chiếu 9 ràng buộc hiện thực trực tiếp bằng CHECK / UNIQUE / FK (RB1, RB4, RB8, RB11, RB12, RB13, RB15, RB20, học kỳ).
  5.2. Khởi tạo dữ liệu mẫu có ý nghĩa cho 25 bảng (Mục 1.2)
       - Mô tả dữ liệu 4 cụm bảng (người dùng/đào tạo, học kỳ/lớp học, đề thi/câu hỏi, làm bài/thảo luận).
       - Bảng thống kê số dòng thực tế (>= 5 dòng/bảng) + Ảnh chụp kết quả chạy trong SQL Server.

================================================================================
CHƯƠNG 6: THỦ TỤC, TRIGGER VÀ HÀM NGHIỆP VỤ (PHẦN 2 – 4.0 ĐIỂM)
================================================================================
  6.1. Bộ 3 Thủ tục Thêm / Sửa / Xóa trên bảng [POST] (Mục 2.1 – Phạm Hoàng Hà)
       - Lý do chọn bảng [POST]; mục đích & điều kiện được/không được xóa (bảo toàn lịch sử bình luận).
       - Mô tả tham số, luồng validate & bảng mã lỗi cụ thể (51001–51026) của usp_Post_Insert, usp_Post_Update, usp_Post_Delete.
       - Kịch bản & Ảnh chụp kết quả kiểm thử (hợp lệ và bị chặn lỗi).
  6.2. Hiện thực Trigger kiểm tra nghiệp vụ và thuộc tính dẫn xuất (Mục 2.2)
       - 6.2.1. Trigger kiểm tra ràng buộc nghiệp vụ RB18 (Phan Trung Kiên):
                Phân tích 2 thao tác DML gây vi phạm ([ATTEMPT] & [TEST]), giải thích 2 trigger & ảnh test 5/5 PASS.
       - 6.2.2. Trigger tự động tính thuộc tính dẫn xuất RB25 -> RB26 (Dương Bảo Kiệt):
                Phân tích phụ thuộc (ATTEMPT.score phải tính trước TAKES_TEST.final_score), bảng ma trận DML (INSERT/UPDATE/DELETE) & 3 trigger + ảnh test 8/8 PASS.
  6.3. Hai Thủ tục truy vấn hiển thị dữ liệu (Mục 2.3 – Trần Minh Nhật)
       - 6.3.1. Thủ tục 1: dbo.usp_Post_Search (liên quan bảng [POST] câu 2.1; JOIN + WHERE + ORDER BY).
       - 6.3.2. Thủ tục 2: dbo.usp_Test_ScoreStatistics (Aggregate + GROUP BY + HAVING + WHERE + ORDER BY).
       - Minh họa các bộ tham số lọc và ảnh chụp kết quả trả về.
  6.4. Hai Hàm tính toán sử dụng Con trỏ CURSOR (Mục 2.4 – Nguyễn Hữu Khánh)
       - 6.4.1. Hàm 1: dbo.fn_CalculateStudentTestScore (kiểm tra tham số + RB3, CURSOR + IF/WHILE tính RB26).
       - 6.4.2. Hàm 2: dbo.fn_CalculateStudentEngagementScore (CURSOR duyệt lớp theo học kỳ tính điểm tích cực).
       - Bảng kết quả kiểm thử (13/13 PASS, bao gồm tham số hợp lệ, biên và không hợp lệ).

================================================================================
CHƯƠNG 7: HIỆN THỰC ỨNG DỤNG KẾT NỐI CSDL (PHẦN 3 – 3.0 ĐIỂM)
================================================================================
  7.1. Kiến trúc ứng dụng & Kết nối CSDL LMS_DB
       - Sơ đồ kiến trúc: Giao diện (HTML/Bootstrap) <-> API (FastAPI) <-> pyodbc <-> SQL Server (LMS_DB).
       - Cơ chế bắt lỗi Exception từ SQL Server (THROW) trả về thông báo cụ thể trên UI.
  7.2. Chức năng Thêm / Sửa / Xóa bảng [POST] (Mục 3.1)
       - Mô tả Form nhập liệu, validation phía client/server, gọi trực tiếp usp_Post_*.
       - Ảnh chụp màn hình: thêm mới thành công, sửa bài, báo lỗi khi xóa bài có bình luận / sai tác giả.
  7.3. Giao diện Danh sách [POST] (Mục 3.2)
       - Mô tả màn hình gọi usp_Post_Search: các control tìm kiếm (từ khóa, lớp, tác giả, khoảng ngày, số bình luận), sắp xếp, nút Sửa/Xóa trên từng dòng.
       - Ảnh chụp màn hình kết quả lọc/tìm kiếm thực tế.
  7.4. Giao diện Thống kê kết quả & Tính điểm bằng Hàm Cursor (Mục 3.3)
       - Mô tả màn hình gọi usp_Test_ScoreStatistics và 2 hàm Cursor (fn_CalculateStudentTestScore, fn_CalculateStudentEngagementScore).
       - Ảnh chụp màn hình kết quả thống kê và tra cứu điểm (kèm case báo tham số/quyền lớp).

================================================================================
CHƯƠNG 8: KẾT LUẬN VÀ HƯỚNG PHÁT TRIỂN
================================================================================
  - Tổng kết mức độ hoàn thành các mục tiêu BTL1 & BTL2.
  - Bài học kinh nghiệm và hướng mở rộng hệ thống BK-LMS.
```
