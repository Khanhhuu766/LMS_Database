# Phụ lục B – Phân loại 29 Ràng buộc ngữ nghĩa từ BTL1

> **Quy tắc bắt buộc của đề bài:**
> *"Những ràng buộc nào có thể kiểm tra trong câu lệnh tạo bảng thì bắt buộc dùng `CHECK`/`UNIQUE`/`FK`, không dùng Trigger để kiểm tra."*

---

## Nhóm 1: Các ràng buộc kiểm tra trực tiếp trong lệnh `CREATE TABLE` (`PK` / `FK` / `UNIQUE` / `CHECK`)

Các ràng buộc dưới đây phải được hiện thực trực tiếp trong file `database/01_schema_tables.sql`:

* **RB1:** Mỗi người dùng có một địa chỉ Email duy nhất và thuộc tên miền `@hcmut.edu.vn` (`[USER]`).
* **RB4:** Một sinh viên không được đăng ký lặp lại cùng một lớp học (`[ENROLLS]`).
* **RB8:** Mỗi tập tin tải lên hệ thống không vượt quá dung lượng tối đa $200\text{ MB}$ (`[FILE]`).
* **RB11:** Nếu bài kiểm tra liên kết với một chương học thì chương đó phải thuộc chính lớp học chứa bài kiểm tra (Khóa ngoại tổ hợp `(class_id, chapter_id)` trên bảng `[TEST]` tham chiếu `[CHAPTER]`).
* **RB12:** Thời điểm bắt đầu mở đề của bài kiểm tra phải sớm hơn thời điểm đóng đề (`[TEST]`).
* **RB13:** Thời lượng làm bài phải lớn hơn $0$ và không vượt quá khoảng thời gian từ thời điểm mở đề đến thời điểm đóng đề (`[TEST]`).
* **RB15:** Điểm số tùy chỉnh của một câu hỏi trong bài kiểm tra, nếu được thiết lập, phải lớn hơn hoặc bằng $0$ (`[CONTAINS_QUESTION]`).
* **RB20:** Thời điểm nộp bài của một lần làm phải bằng hoặc muộn hơn thời điểm bắt đầu làm bài (`[ATTEMPT]`).
* **Ràng buộc ngày học kỳ:** Ngày bắt đầu của một học kỳ phải sớm hơn ngày kết thúc của học kỳ đó (`[SEMESTER]`).

---

## Nhóm 2: Các ràng buộc liên bảng / nghiệp vụ phức tạp

*(Dùng để chọn làm Trigger 2.2.1, Trigger 2.2.2 trong `database/04_triggers.sql` hoặc kiểm tra trong Procedure 2.1 tại `database/03_proc_crud.sql`)*

* **RB2:** Sinh viên chỉ được đăng ký lớp học thuộc học kỳ đang cho phép đăng ký và có trạng thái phù hợp.
* **RB3:** Sinh viên chỉ được truy cập nội dung học tập và thực hiện hoạt động của những lớp đã đăng ký hợp lệ.
* **RB5:** Sinh viên chỉ được đăng ký môn học khi đã đáp ứng đầy đủ các môn học tiên quyết của môn đó.
* **RB6:** Tổng số tín chỉ sinh viên đăng ký trong một học kỳ không được thấp hơn $11$ tín chỉ.
* **RB7:** Chỉ giảng viên được phân công phụ trách lớp học mới có quyền thêm, chỉnh sửa hoặc xóa chương, chủ đề, tài liệu học tập và bài kiểm tra của lớp học đó.
* **RB9:** Số lượng tập tin đính kèm cho một nội dung (`[TOPIC]`) tại một thời điểm không vượt quá $5$ tập tin.
* **RB10:** Bài kiểm tra chỉ được phép công bố hoặc cho sinh viên thực hiện khi lớp học chứa bài kiểm tra đang ở trạng thái hoạt động.
* **RB14:** Một bài kiểm tra phải có ít nhất một câu hỏi trước khi được công bố cho sinh viên thực hiện.
* **RB16:** Đối với câu hỏi trắc nghiệm nhiều lựa chọn hoặc đúng/sai, phải tồn tại ít nhất một lựa chọn là đáp án đúng trước khi câu hỏi được sử dụng trong bài kiểm tra.
* **RB17:** Sinh viên chỉ được bắt đầu làm bài kiểm tra trong khoảng thời gian từ thời điểm mở đề đến thời điểm đóng đề.
* **RB18:** Sinh viên chỉ được tạo một lần làm bài mới khi số lần đã thực hiện chưa đạt đến số lần làm bài tối đa của bài kiểm tra.
* **RB19:** Số thứ tự lần làm bài (`attempt_index`) của một sinh viên đối với một bài kiểm tra phải tăng tuần tự và không trùng nhau.
* **RB21:** Một lần làm bài phải kết thúc khi sinh viên chủ động nộp bài, hết thời lượng làm bài hoặc đạt đến thời điểm đóng đề.
* **RB22:** Sau khi một lần làm bài đã được nộp hoặc tự động kết thúc, sinh viên không được tiếp tục thay đổi câu trả lời của lần làm đó.
* **RB23 (Thuộc tính dẫn xuất):** Thời gian làm bài được tính từ khoảng chênh lệch giữa thời điểm kết thúc/nộp bài và thời điểm bắt đầu làm bài, không nhập trực tiếp.
* **RB24:** Đối với câu hỏi tự luận, điểm của câu trả lời do giảng viên chấm phải nằm trong khoảng từ $0$ đến điểm tối đa áp dụng cho câu hỏi đó trong bài kiểm tra.
* **RB25 (Thuộc tính dẫn xuất):** Tổng điểm của một lần làm bài được tính từ điểm của các câu trả lời thành phần và không được nhập trực tiếp.
* **RB26 (Thuộc tính dẫn xuất):** Điểm số chung cuộc của sinh viên đối với một bài kiểm tra được tính từ các lần làm bài hợp lệ theo phương thức tính điểm đã thiết lập (điểm cao nhất, trung bình, lần đầu hoặc lần cuối).
* **RB27:** Chỉ giảng viên phụ trách lớp học mới được xem toàn bộ các lần làm bài và kết quả kiểm tra của tất cả sinh viên trong lớp; sinh viên chỉ xem kết quả của chính mình.
* **RB28 & RB29:** Người dùng chỉ được tạo bài đăng hoặc bình luận trong những lớp học mà họ có quyền tham gia; mỗi bình luận phải thuộc về một bài đăng đang tồn tại.
