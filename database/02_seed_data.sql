-- =================================================================================
-- MỤC 1.2: TẠO DỮ LIỆU MẪU (SEED DATA)
-- Yêu cầu đề bài  :
--   1. Tạo dữ liệu mẫu có ý nghĩa thực tế ở TẤT CẢ 25 bảng.
--   2. Số lượng tối thiểu: Ít nhất 5 hàng dữ liệu cho mỗi bảng.
--   3. Tuân thủ đúng thứ tự khóa ngoại và thỏa mãn các ràng buộc đã tạo.
-- =================================================================================

-- =================================================================================
-- PHẦN CỦA TV2: CỤM 1 - NGƯỜI DÙNG & CƠ CẤU ĐÀO TẠO
-- Bảng: [USER], [USER_SESSION], [STUDENT], [LECTURER], [LECTURER_DEGREE], [ADMIN], [FACULTY], [SUBJECT], [PREREQUISITE]
-- Quy ước: TV2 CHỈ VIẾT TRONG KHUNG NÀY, KHÔNG SỬA RA NGOÀI KHUNG
-- =================================================================================
-- TODO
USE [LMS_DB];
GO
SET NOCOUNT ON;
SET XACT_ABORT ON;

DECLARE @identity_on SYSNAME = NULL;
BEGIN TRY
    BEGIN TRANSACTION;
    SET IDENTITY_INSERT dbo.[USER] ON;
    SET @identity_on = N'USER';
    INSERT INTO dbo.[USER] ([user_id], [first_name], [middle_name], [last_name], [sex], [email], [birthday], [nationality], [ua_id], [ua_username], [ua_password], [ua_image])
    VALUES
        (1, N'An', N'Văn', N'Nguyễn', N'Male', N'sv01@hcmut.edu.vn', N'2005-02-03', N'Việt Nam', 1001, N'student01', N'NO_LOGIN_DEMO_STUDENT_01', NULL),
        (2, N'Bình', N'Thị', N'Trần', N'Female', N'sv02@hcmut.edu.vn', N'2005-06-14', N'Việt Nam', 1002, N'student02', N'NO_LOGIN_DEMO_STUDENT_02', NULL),
        (3, N'Chi', N'Ngọc', N'Lê', N'Female', N'sv03@hcmut.edu.vn', N'2004-08-22', N'Việt Nam', 1003, N'student03', N'NO_LOGIN_DEMO_STUDENT_03', NULL),
        (4, N'Dũng', N'Minh', N'Phạm', N'Male', N'sv04@hcmut.edu.vn', N'2005-11-07', N'Việt Nam', 1004, N'student04', N'NO_LOGIN_DEMO_STUDENT_04', NULL),
        (5, N'Hà', N'Thanh', N'Võ', N'Female', N'sv05@hcmut.edu.vn', N'2006-04-17', N'Việt Nam', 1005, N'student05', N'NO_LOGIN_DEMO_STUDENT_05', NULL),
        (6, N'Khoa', N'Văn', N'Đặng', N'Male', N'admin01@hcmut.edu.vn', N'1980-03-09', N'Việt Nam', 1006, N'admin01', N'NO_LOGIN_DEMO_ADMIN_01', NULL),
        (7, N'Linh', N'Thị', N'Ngô', N'Female', N'admin02@hcmut.edu.vn', N'1983-09-25', N'Việt Nam', 1007, N'admin02', N'NO_LOGIN_DEMO_ADMIN_02', NULL),
        (8, N'Minh', N'Hoàng', N'Bùi', N'Male', N'admin03@hcmut.edu.vn', N'1979-01-17', N'Việt Nam', 1008, N'admin03', N'NO_LOGIN_DEMO_ADMIN_03', NULL),
        (9, N'Ngân', N'Thu', N'Đỗ', N'Female', N'admin04@hcmut.edu.vn', N'1985-12-30', N'Việt Nam', 1009, N'admin04', N'NO_LOGIN_DEMO_ADMIN_04', NULL),
        (10, N'Phúc', N'Đức', N'Huỳnh', N'Male', N'admin05@hcmut.edu.vn', N'1984-05-11', N'Việt Nam', 1010, N'admin05', N'NO_LOGIN_DEMO_ADMIN_05', NULL),
        (11, N'Quân', N'Hải', N'Nguyễn', N'Male', N'gv01@hcmut.edu.vn', N'1975-10-19', N'Việt Nam', 1011, N'lecturer01', N'NO_LOGIN_DEMO_LECTURER_01', NULL),
        (12, N'Thảo', N'Kim', N'Trần', N'Female', N'gv02@hcmut.edu.vn', N'1982-02-28', N'Việt Nam', 1012, N'lecturer02', N'NO_LOGIN_DEMO_LECTURER_02', NULL),
        (13, N'Tuấn', N'Anh', N'Lê', N'Male', N'gv03@hcmut.edu.vn', N'1977-07-09', N'Việt Nam', 1013, N'lecturer03', N'NO_LOGIN_DEMO_LECTURER_03', NULL),
        (14, N'Uyên', N'Phương', N'Phạm', N'Female', N'gv04@hcmut.edu.vn', N'1981-09-02', N'Việt Nam', 1014, N'lecturer04', N'NO_LOGIN_DEMO_LECTURER_04', NULL),
        (15, N'Vinh', N'Quốc', N'Võ', N'Male', N'gv05@hcmut.edu.vn', N'1978-12-18', N'Việt Nam', 1015, N'lecturer05', N'NO_LOGIN_DEMO_LECTURER_05', NULL);
    SET IDENTITY_INSERT dbo.[USER] OFF;
    SET @identity_on = NULL;

  
    INSERT INTO dbo.[STUDENT] ([user_id], [student_code], [enrollment_year])
    VALUES
        (1, N'2410001', 2024),
        (2, N'2410002', 2024),
        (3, N'2310003', 2023),
        (4, N'2410004', 2024),
        (5, N'2510005', 2025);

  
    INSERT INTO dbo.[ADMIN] ([user_id], [admin_code], [office_room])
    VALUES
        (6, N'ADM001', N'A101'),
        (7, N'ADM002', N'A102'),
        (8, N'ADM003', N'B201'),
        (9, N'ADM004', N'B202'),
        (10, N'ADM005', N'C301');

    SET IDENTITY_INSERT dbo.[FACULTY] ON;
    SET @identity_on = N'FACULTY';
    INSERT INTO dbo.[FACULTY] ([faculty_id], [faculty_name], [admin_id])
    VALUES
        (1, N'Khoa Khoa học và Kỹ thuật Máy tính', 6),
        (2, N'Khoa Điện - Điện tử', 7),
        (3, N'Khoa Cơ khí', 8),
        (4, N'Khoa Kỹ thuật Hóa học', 9),
        (5, N'Khoa Quản lý Công nghiệp', 10);
    SET IDENTITY_INSERT dbo.[FACULTY] OFF;
    SET @identity_on = NULL;

    
    INSERT INTO dbo.[LECTURER] ([user_id], [lecturer_code], [academic_rank], [faculty_id])
    VALUES
        (11, N'GV001', N'Phó giáo sư', 1),
        (12, N'GV002', N'Tiến sĩ', 2),
        (13, N'GV003', N'Thạc sĩ', 3),
        (14, N'GV004', N'Tiến sĩ', 4),
        (15, N'GV005', N'Thạc sĩ', 5);


    INSERT INTO dbo.[LECTURER_DEGREE] ([lecturer_id], [degree])
    VALUES
        (11, N'PhD'),
        (11, N'MSc'),
        (12, N'PhD'),
        (12, N'MSc'),
        (13, N'MSc'),
        (14, N'PhD'),
        (15, N'MSc');

  
    INSERT INTO dbo.[USER_SESSION] ([login_time], [ip_address], [ua_id])
    VALUES
        (N'2026-11-01T08:00:00', N'192.0.2.1', 1001),
        (N'2026-11-01T08:15:00', N'192.0.2.2', 1002),
        (N'2026-11-02T09:00:00', N'192.0.2.3', 1003),
        (N'2026-11-02T09:20:00', N'192.0.2.4', 1004),
        (N'2026-11-03T10:00:00', N'192.0.2.5', 1005),
        (N'2026-11-04T07:30:00', N'192.0.2.6', 1006),
        (N'2026-11-05T14:30:00', N'192.0.2.7', 1011);


    SET IDENTITY_INSERT dbo.[SUBJECT] ON;
    SET @identity_on = N'SUBJECT';
    INSERT INTO dbo.[SUBJECT] ([subject_id], [subject_name], [credit], [faculty_id])
    VALUES
        (1, N'Nhập môn lập trình', 3, 1),
        (2, N'Cấu trúc dữ liệu và giải thuật', 4, 1),
        (3, N'Cơ sở dữ liệu', 3, 1),
        (4, N'Hệ điều hành', 3, 1),
        (5, N'Mạng máy tính', 3, 1),
        (6, N'Công nghệ phần mềm', 3, 1),
        (7, N'Trí tuệ nhân tạo', 3, 1),
        (8, N'Mạch số', 3, 2),
        (9, N'Vi điều khiển', 3, 2),
        (10, N'Hệ thống nhúng', 3, 2),
        (11, N'Cơ học kỹ thuật', 3, 3),
        (12, N'Công nghệ hóa học đại cương', 3, 4),
        (13, N'Quản trị vận hành', 3, 5);
    SET IDENTITY_INSERT dbo.[SUBJECT] OFF;
    SET @identity_on = NULL;

    INSERT INTO dbo.[PREREQUISITE] ([subject_id], [prereq_subject_id])
    VALUES
        (2, 1),
        (3, 2),
        (4, 2),
        (5, 2),
        (6, 3),
        (7, 2),
        (7, 3),
        (9, 8),
        (10, 9),
        (10, 5);

    COMMIT TRANSACTION;
    PRINT N'TV2: Da insert thanh cong du lieu mau cho 9 bang: [USER], [STUDENT], [ADMIN], [FACULTY], [LECTURER], [LECTURER_DEGREE], [USER_SESSION], [SUBJECT], [PREREQUISITE].';
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
    IF @identity_on = N'USER' SET IDENTITY_INSERT dbo.[USER] OFF;
    IF @identity_on = N'FACULTY' SET IDENTITY_INSERT dbo.[FACULTY] OFF;
    IF @identity_on = N'SUBJECT' SET IDENTITY_INSERT dbo.[SUBJECT] OFF;
    THROW;
END CATCH;
GO

-- =================================================================================
-- PHẦN CỦA TV3: CỤM 2 - HỌC KỲ, LỚP HỌC & NỘI DUNG HỌC TẬP
-- Bảng: [SEMESTER], [STATUS], [CLASS], [ENROLLS], [CHAPTER], [TOPIC], [FILE]
-- Quy ước: TV3 CHỈ VIẾT TRONG KHUNG NÀY, KHÔNG SỬA RA NGOÀI KHUNG
-- =================================================================================
-- TODO
SET NOCOUNT ON;
SET XACT_ABORT ON;

DECLARE @identity_on SYSNAME = NULL;
BEGIN TRY
    BEGIN TRANSACTION;

    -- -----------------------------------------------------------------------------
    -- SEMESTER (6 hàng)
    -- -----------------------------------------------------------------------------
    SET IDENTITY_INSERT dbo.[SEMESTER] ON;
    SET @identity_on = N'SEMESTER';
    INSERT INTO dbo.[SEMESTER] ([semester_id], [semester_start], [semester_end])
    VALUES
        (1, N'2024-09-02', N'2025-01-12'),   -- HK1 2024-2025
        (2, N'2025-02-10', N'2025-06-15'),   -- HK2 2024-2025
        (3, N'2025-09-01', N'2026-01-11'),   -- HK1 2025-2026
        (4, N'2026-02-09', N'2026-06-14'),   -- HK2 2025-2026
        (5, N'2026-09-07', N'2027-01-17'),   -- HK1 2026-2027 (đang diễn ra)
        (6, N'2027-02-15', N'2027-06-20');   -- HK2 2026-2027 (sắp tới)
    SET IDENTITY_INSERT dbo.[SEMESTER] OFF;
    SET @identity_on = NULL;

    -- -----------------------------------------------------------------------------
    -- STATUS (5 hàng)
    -- -----------------------------------------------------------------------------
    SET IDENTITY_INSERT dbo.[STATUS] ON;
    SET @identity_on = N'STATUS';
    INSERT INTO dbo.[STATUS] ([status_id], [status_display])
    VALUES
        (1, N'Sắp mở'),
        (2, N'Đang diễn ra'),
        (3, N'Đã kết thúc'),
        (4, N'Tạm hoãn'),
        (5, N'Đã hủy');
    SET IDENTITY_INSERT dbo.[STATUS] OFF;
    SET @identity_on = NULL;

    -- -----------------------------------------------------------------------------
    -- CLASS (8 hàng)  subject_id -> SUBJECT, semester_id -> SEMESTER,
    --                 status_id -> STATUS, lecturer_id -> LECTURER (NOT NULL)
    -- -----------------------------------------------------------------------------
    SET IDENTITY_INSERT dbo.[CLASS] ON;
    SET @identity_on = N'CLASS';
    INSERT INTO dbo.[CLASS] ([class_id], [class_name], [subject_id], [semester_id], [status_id], [lecturer_id])
    VALUES
        (1, N'Nhập môn lập trình - L01',              1,  3, 3, 11),
        (2, N'Cấu trúc dữ liệu và giải thuật - L01',  2,  4, 3, 11),
        (3, N'Cơ sở dữ liệu - L01',                   3,  5, 2, 11),
        (4, N'Mạng máy tính - L02',                   5,  5, 2, 11),
        (5, N'Mạch số - L01',                         8,  5, 2, 12),
        (6, N'Cơ học kỹ thuật - L01',                 11, 5, 4, 13),
        (7, N'Công nghệ hóa học đại cương - L01',     12, 2, 3, 14),
        (8, N'Quản trị vận hành - L01',               13, 6, 1, 15);
    SET IDENTITY_INSERT dbo.[CLASS] OFF;
    SET @identity_on = NULL;

    -- -----------------------------------------------------------------------------
    -- ENROLLS (17 hàng)  PK (student_id, class_id) không trùng
    -- -----------------------------------------------------------------------------
    INSERT INTO dbo.[ENROLLS] ([student_id], [class_id], [is_allowed_to_discuss])
    VALUES
        (1, 1, 1), (2, 1, 1), (4, 1, 1), (5, 1, 1),   -- Nhập môn lập trình (HK1 25-26)
        (1, 2, 1), (2, 2, 1), (4, 2, 0),              -- CTDL&GT (đã học môn 1); SV4 bị khóa thảo luận
        (1, 3, 1), (2, 3, 1), (4, 3, 1),              -- CSDL (đã học môn 2)
        (1, 4, 1), (4, 4, 1),                         -- Mạng máy tính (đã học môn 2)
        (3, 5, 1), (5, 5, 1),                         -- Mạch số (không có tiên quyết)
        (3, 7, 1),                                    -- CN hóa học đại cương (HK2 24-25)
        (2, 8, 1), (3, 8, 1);                         -- Quản trị vận hành (sắp mở)

    -- -----------------------------------------------------------------------------
    -- CHAPTER (13 hàng)  PK (class_id, chapter_id)
    -- -----------------------------------------------------------------------------
    INSERT INTO dbo.[CHAPTER] ([class_id], [chapter_id], [chapter_name])
    VALUES
        (1, 1, N'Chương 1: Tổng quan về lập trình C++'),
        (1, 2, N'Chương 2: Cấu trúc điều khiển và hàm'),
        (2, 1, N'Chương 1: Phân tích độ phức tạp thuật toán'),
        (2, 2, N'Chương 2: Danh sách liên kết, ngăn xếp, hàng đợi'),
        (3, 1, N'Chương 1: Tổng quan về hệ cơ sở dữ liệu'),
        (3, 2, N'Chương 2: Mô hình thực thể - liên kết (ERD/EERD)'),
        (3, 3, N'Chương 3: Ngôn ngữ truy vấn SQL'),
        (4, 1, N'Chương 1: Mô hình OSI và TCP/IP'),
        (4, 2, N'Chương 2: Tầng giao vận'),
        (5, 1, N'Chương 1: Hệ đếm và đại số Boole'),
        (5, 2, N'Chương 2: Mạch logic tổ hợp'),
        (7, 1, N'Chương 1: Nhiệt động học hóa học'),
        (8, 1, N'Chương 1: Tổng quan về quản trị vận hành');

    -- -----------------------------------------------------------------------------
    -- TOPIC (15 hàng)  PK (class_id, chapter_id, topic_id), FK -> CHAPTER
    -- -----------------------------------------------------------------------------
    INSERT INTO dbo.[TOPIC] ([class_id], [chapter_id], [topic_id], [topic_name], [topic_content])
    VALUES
        (1, 1, 1, N'Biến, kiểu dữ liệu và toán tử',
                  N'Khai báo biến, các kiểu dữ liệu cơ bản, toán tử số học và logic, nhập xuất với cin/cout.'),
        (1, 2, 1, N'Câu lệnh rẽ nhánh và vòng lặp',
                  N'if-else, switch-case, for, while, do-while; ví dụ tính tổng và tìm số nguyên tố.'),
        (1, 2, 2, N'Hàm và truyền tham số',
                  N'Khai báo, định nghĩa hàm; truyền tham trị, tham chiếu; hàm đệ quy.'),
        (2, 1, 1, N'Ký hiệu Big-O',
                  N'Đánh giá thời gian chạy trường hợp tốt nhất, trung bình, xấu nhất; so sánh các lớp độ phức tạp.'),
        (2, 2, 1, N'Danh sách liên kết đơn',
                  N'Cấu trúc node, thêm/xóa/tìm kiếm phần tử và độ phức tạp từng thao tác.'),
        (3, 1, 1, N'Khái niệm CSDL và hệ quản trị CSDL',
                  N'Dữ liệu, CSDL, DBMS; so sánh với hệ thống tập tin; kiến trúc ba mức.'),
        (3, 2, 1, N'Thực thể, thuộc tính và khóa',
                  N'Thực thể mạnh/yếu, thuộc tính đơn, đa trị, dẫn xuất; khóa chính và khóa riêng phần.'),
        (3, 2, 2, N'Chuyên biệt hóa và tổng quát hóa',
                  N'Ràng buộc rời nhau/chồng lấp, toàn phần/riêng phần trong EERD.'),
        (3, 3, 1, N'Truy vấn SELECT, JOIN, GROUP BY',
                  N'Truy vấn một bảng, kết nối nhiều bảng, gom nhóm với HAVING và hàm tổng hợp.'),
        (4, 1, 1, N'Chức năng các tầng OSI',
                  N'Bảy tầng OSI, đơn vị dữ liệu mỗi tầng, ánh xạ sang mô hình TCP/IP.'),
        (4, 2, 1, N'Giao thức TCP và UDP',
                  N'Bắt tay ba bước, kiểm soát luồng, kiểm soát tắc nghẽn; khi nào dùng UDP.'),
        (5, 1, 1, N'Chuyển đổi hệ đếm',
                  N'Hệ nhị phân, bát phân, thập lục phân và cách chuyển đổi qua lại.'),
        (5, 2, 1, N'Thiết kế mạch cộng',
                  N'Mạch cộng bán phần, toàn phần và mạch cộng nhiều bit.'),
        (7, 1, 1, N'Định luật thứ nhất nhiệt động học',
                  N'Nội năng, nhiệt, công; enthalpy và nhiệt phản ứng.'),
        (8, 1, 1, N'Vai trò của quản trị vận hành',
                  N'Khái niệm hệ thống sản xuất - dịch vụ, mục tiêu năng suất và chất lượng.');

    -- -----------------------------------------------------------------------------
    -- FILE (12 hàng)  PK (class_id, chapter_id, topic_id, file_id), FK -> TOPIC
    -- file_size: byte, 0 .. 209715200 (200 MB)
    -- -----------------------------------------------------------------------------
    INSERT INTO dbo.[FILE] ([class_id], [chapter_id], [topic_id], [file_id], [file_name], [file_path], [file_size], [update_date])
    VALUES
        (1, 1, 1, 1, N'NMLT_C1_BienKieuDuLieu.pdf',  N'/uploads/class_1/chapter_1/topic_1/NMLT_C1_BienKieuDuLieu.pdf',  1887436,   N'2025-09-03T08:00:00'),
        (1, 2, 2, 1, N'NMLT_C2_Ham_ViDu.zip',        N'/uploads/class_1/chapter_2/topic_2/NMLT_C2_Ham_ViDu.zip',        524288,    N'2025-09-20T14:30:00'),
        (2, 1, 1, 1, N'CTDL_C1_BigO.pdf',            N'/uploads/class_2/chapter_1/topic_1/CTDL_C1_BigO.pdf',            1048576,   N'2026-02-11T09:00:00'),
        (2, 2, 1, 1, N'CTDL_C2_LinkedList.pptx',     N'/uploads/class_2/chapter_2/topic_1/CTDL_C2_LinkedList.pptx',     4194304,   N'2026-02-25T09:15:00'),
        (3, 1, 1, 1, N'CSDL_C1_TongQuan.pdf',        N'/uploads/class_3/chapter_1/topic_1/CSDL_C1_TongQuan.pdf',        2457600,   N'2026-09-08T07:30:00'),
        (3, 2, 1, 1, N'CSDL_C2_ERD.pptx',            N'/uploads/class_3/chapter_2/topic_1/CSDL_C2_ERD.pptx',            6291456,   N'2026-09-22T10:00:00'),
        (3, 2, 1, 2, N'CSDL_C2_ERD_BaiTap.docx',     N'/uploads/class_3/chapter_2/topic_1/CSDL_C2_ERD_BaiTap.docx',     358400,    N'2026-09-22T10:05:00'),
        (3, 3, 1, 1, N'CSDL_C3_SQL_Lab.sql',         N'/uploads/class_3/chapter_3/topic_1/CSDL_C3_SQL_Lab.sql',         40960,     N'2026-10-20T13:00:00'),
        (4, 2, 1, 1, N'MMT_C2_TCP_UDP.pdf',          N'/uploads/class_4/chapter_2/topic_1/MMT_C2_TCP_UDP.pdf',          3145728,   N'2026-10-06T15:00:00'),
        (5, 2, 1, 1, N'MS_C2_MachCong_MoPhong.mp4',  N'/uploads/class_5/chapter_2/topic_1/MS_C2_MachCong_MoPhong.mp4',  157286400, N'2026-10-14T16:20:00'),
        (7, 1, 1, 1, N'CNHH_C1_NhietDongHoc.pdf',    N'/uploads/class_7/chapter_1/topic_1/CNHH_C1_NhietDongHoc.pdf',    2097152,   N'2025-02-12T08:00:00'),
        (8, 1, 1, 1, N'QTVH_DeCuongMonHoc.pdf',      N'/uploads/class_8/chapter_1/topic_1/QTVH_DeCuongMonHoc.pdf',      307200,    N'2026-11-05T10:00:00');

    COMMIT TRANSACTION;
    PRINT N'TV3: Da insert thanh cong du lieu mau cho 7 bang: [SEMESTER], [STATUS], [CLASS], [ENROLLS], [CHAPTER], [TOPIC], [FILE].';
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
    IF @identity_on = N'SEMESTER' SET IDENTITY_INSERT dbo.[SEMESTER] OFF;
    IF @identity_on = N'STATUS'   SET IDENTITY_INSERT dbo.[STATUS] OFF;
    IF @identity_on = N'CLASS'    SET IDENTITY_INSERT dbo.[CLASS] OFF;
    THROW;
END CATCH;
GO

-- =================================================================================
-- PHẦN CỦA TV4: CỤM 3 - KIỂM TRA & NGÂN HÀNG CÂU HỎI
-- Bảng: [TEST], [QUESTION], [CHOICE], [CONTAINS_QUESTION]
-- Quy ước: TV4 CHỈ VIẾT TRONG KHUNG NÀY, KHÔNG SỬA RA NGOÀI KHUNG
-- =================================================================================
-- TODO
GO

-- =================================================================================
-- PHẦN CỦA TV5: CỤM 4 - LÀM BÀI KIỂM TRA & DIỄN ĐÀN THẢO LUẬN
-- Bảng: [TAKES_TEST], [ATTEMPT], [STUDENT_ANSWER], [POST], [COMMENT]
-- Quy ước: TV5 CHỈ VIẾT TRONG KHUNG NÀY, KHÔNG SỬA RA NGOÀI KHUNG
-- =================================================================================
-- TODO
GO
