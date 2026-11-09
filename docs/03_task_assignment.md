# Phân công công việc & Cấu trúc điểm Giai đoạn Database (BTL2)

## 1. Mục tiêu điểm số Giai đoạn Database ($7.0 / 10$ điểm BTL2)

1. **Phần 1 – Tạo bảng & Dữ liệu mẫu ($3.0$ điểm):**
   * `1.1` ($2.0$ điểm): Viết lệnh tạo đủ 25 bảng (`PK`, `FK`, `UNIQUE`, `CHECK`) trong `database/01_schema_tables.sql`. *Lưu ý: Ràng buộc nào kiểm tra được bằng lệnh tạo bảng thì bắt buộc dùng `CHECK`/`UNIQUE`/`FK`, không dùng Trigger.*
   * `1.2` ($1.0$ điểm): Nhập dữ liệu mẫu có ý nghĩa cho tất cả 25 bảng ($\ge 5$ dòng/bảng) trong `database/02_seed_data.sql`.
2. **Phần 2 – Thủ tục, Trigger, Hàm ($4.0$ điểm):** *(Mỗi thành viên bắt buộc viết ít nhất 1 câu)*
   * `2.1` ($1.0$ điểm): Viết 3 thủ tục Thêm (`INSERT`), Sửa (`UPDATE`), Xóa (`DELETE`) vào **MỘT bảng** do nhóm tự chọn (`database/03_proc_crud.sql`). Có validate dữ liệu, báo lỗi cụ thể và xác định điều kiện được xóa.
   * `2.2` ($1.0$ điểm): Viết **2 Trigger** (`database/04_triggers.sql` — `2.2.1`: Kiểm tra 1 ràng buộc nghiệp vụ không dùng `CHECK` được; `2.2.2`: Tự động tính giá trị cho 1 thuộc tính dẫn xuất).
   * `2.3` ($1.0$ điểm): Viết **2 Thủ tục truy vấn** (`database/05_proc_queries.sql` — Thủ tục 1: $\ge 2$ bảng + `WHERE` + `ORDER BY`; Thủ tục 2: $\ge 2$ bảng + hàm tổng hợp + `GROUP BY` + `HAVING` + `WHERE` + `ORDER BY`). Ít nhất 1 thủ tục lấy dữ liệu liên quan đến bảng ở câu 2.1.
   * `2.4` ($1.0$ điểm): Viết **2 Hàm (Function)** (`database/06_functions_cursor.sql`) có tham số đầu vào, kiểm tra tham số, chứa `IF`/vòng lặp, truy vấn dữ liệu và **bắt buộc sử dụng Con trỏ (`CURSOR`)**.

---

## 2. Khung phân công công việc cho 5 thành viên

> **Quy định bắt buộc của đề bài:** Tất cả sinh viên trong nhóm **PHẢI** viết ít nhất 1 câu trong Phần 2 (Trigger, Function, Procedure); nếu ai không làm sẽ không có điểm BTL2. Mọi thành viên phải nắm rõ ý nghĩa và nội dung của từng hàm, thủ tục trong nhóm dù không phải phần mình viết.
>
> **Cơ chế chống Merge Conflict bằng Section:** Trong các file có nhiều thành viên cùng làm (`02_seed_data.sql`, `04_triggers.sql`, `07_demo_test_cases.sql`), các khung comment (`PHẦN CỦA TV...`) đã được chia sẵn. Mỗi thành viên **chỉ viết code vào đúng khung của mình** để Git tự động ghép (Auto-Merge) mà không bao giờ bị xung đột.

Nhóm họp thống nhất và điền thông tin phân công vào bảng dưới đây:

| Thành viên | Phụ trách Phần 1 (Tạo bảng & Dữ liệu mẫu) | Phụ trách Phần 2 (Mỗi thành viên $\ge 1$ câu) | Kịch bản kiểm thử (`database/07_demo_test_cases.sql`) |
| :--- | :--- | :--- | :--- |
| **TV1:** *(Hoàng Hà)* | **Dựng khung DDL toàn bộ 25 bảng** (`database/01_schema_tables.sql` bao gồm đầy đủ PK, FK, CHECK); phối hợp rà soát tính toàn vẹn tham chiếu. | **Mục 2.1:** Bộ 3 thủ tục Thêm/Sửa/Xóa cho 1 bảng tự chọn (`database/03_proc_crud.sql`) | **Section TV1:** Chuẩn bị lệnh test Thêm, Sửa, Xóa (trường hợp hợp lệ & bắt lỗi validate cụ thể) |
| **TV2:** *(Trung Kiên)* | **Dữ liệu mẫu Cụm 1 (`database/02_seed_data.sql` – Section TV2):** `[USER]`, `USER_SESSION`, `STUDENT`, `LECTURER`, `LECTURER_DEGREE`, `ADMIN`, `FACULTY`, `SUBJECT`, `PREREQUISITE` ($\ge 5$ dòng/bảng). | **Mục 2.2.1:** Trigger kiểm tra 1 ràng buộc nghiệp vụ (`database/04_triggers.sql` – Section TV2) | **Section TV2:** Chuẩn bị lệnh DML minh họa Trigger phát hiện và chặn thao tác vi phạm |
| **TV3:** *(Bảo Kiệt)* | **Dữ liệu mẫu Cụm 2 (`database/02_seed_data.sql` – Section TV3):** `SEMESTER`, `STATUS`, `CLASS`, `ENROLLS`, `CHAPTER`, `TOPIC`, `[FILE]` ($\ge 5$ dòng/bảng). | **Mục 2.2.2:** Trigger tính giá trị cho 1 thuộc tính dẫn xuất (`database/04_triggers.sql` – Section TV3) | **Section TV3:** Chuẩn bị lệnh DML minh họa thuộc tính dẫn xuất tự động tính toán chính xác |
| **TV4:** *(Minh Nhật)* | **Dữ liệu mẫu Cụm 3 (`database/02_seed_data.sql` – Section TV4):** `TEST`, `QUESTION`, `CHOICE`, `CONTAINS_QUESTION` ($\ge 5$ dòng/bảng). | **Mục 2.3:** 2 Thủ tục truy vấn dữ liệu (`database/05_proc_queries.sql`) | **Section TV4:** Chuẩn bị lệnh gọi 2 thủ tục truy vấn với các bộ tham số lọc/gom nhóm khác nhau |
| **TV5:** *(Hữu Khánh)* | **Dữ liệu mẫu Cụm 4 (`database/02_seed_data.sql` – Section TV5):** `TAKES_TEST`, `ATTEMPT`, `STUDENT_ANSWER`, `POST`, `[COMMENT]` ($\ge 5$ dòng/bảng). | **Mục 2.4:** 2 Hàm tính toán có sử dụng Con trỏ (`database/06_functions_cursor.sql`) | **Section TV5:** Chuẩn bị lệnh gọi 2 hàm tính toán (kiểm tra tham số hợp lệ & tham số biên/lỗi) |

---

## 3. Quy tắc làm việc trên các file chia Section (`02`, `04`, `07`) để không bị Conflict

1. **Chỉ viết trong khung được phân công:** Mỗi thành viên tìm đúng khung `-- PHẦN CỦA TV...` của mình và thay thế dòng `-- TODO` bằng code SQL. Tuyệt đối không xóa hoặc sửa khung comment của các thành viên khác.
2. **Không dùng Format Document toàn bộ file:** Trên các file dùng chung (`02_seed_data.sql`, `04_triggers.sql`, `07_demo_test_cases.sql`), tránh dùng phím tắt *Format Document* cho cả file để không làm thay đổi khoảng trắng ở khung của người khác (nếu muốn format, chỉ bôi đen phần code của mình rồi chọn *Format Selection*).
3. **Đồng bộ kết thúc dòng tự động:** Dự án đã có sẵn file `.gitattributes` cố định chuẩn `CRLF` cho toàn bộ file `.sql`, giúp Git tự động hòa trộn (auto-merge) code của 5 thành viên một cách trơn tru.
