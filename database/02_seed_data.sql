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
    SELECT N'USER' AS ten_bang, COUNT(*) AS so_dong FROM dbo.[USER]
    UNION ALL SELECT N'USER_SESSION',    COUNT(*) FROM dbo.[USER_SESSION]
    UNION ALL SELECT N'STUDENT',         COUNT(*) FROM dbo.[STUDENT]
    UNION ALL SELECT N'LECTURER',        COUNT(*) FROM dbo.[LECTURER]
    UNION ALL SELECT N'LECTURER_DEGREE', COUNT(*) FROM dbo.[LECTURER_DEGREE]
    UNION ALL SELECT N'ADMIN',           COUNT(*) FROM dbo.[ADMIN]
    UNION ALL SELECT N'FACULTY',         COUNT(*) FROM dbo.[FACULTY]
    UNION ALL SELECT N'SUBJECT',         COUNT(*) FROM dbo.[SUBJECT]
    UNION ALL SELECT N'PREREQUISITE',    COUNT(*) FROM dbo.[PREREQUISITE];
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
    SELECT N'SEMESTER' AS ten_bang, COUNT(*) AS so_dong FROM dbo.[SEMESTER]
    UNION ALL SELECT N'STATUS',   COUNT(*) FROM dbo.[STATUS]
    UNION ALL SELECT N'CLASS',    COUNT(*) FROM dbo.[CLASS]
    UNION ALL SELECT N'ENROLLS',  COUNT(*) FROM dbo.[ENROLLS]
    UNION ALL SELECT N'CHAPTER',  COUNT(*) FROM dbo.[CHAPTER]
    UNION ALL SELECT N'TOPIC',    COUNT(*) FROM dbo.[TOPIC]
    UNION ALL SELECT N'FILE',     COUNT(*) FROM dbo.[FILE];
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
IF EXISTS (SELECT 1 FROM [TEST]) OR EXISTS (SELECT 1 FROM [QUESTION])
BEGIN
    PRINT N'[TV4] TEST / QUESTION da co du lieu -> bo qua, khong chen lai.';
    RETURN;
END;

DECLARE @c1 INT = (SELECT class_id FROM [CLASS] ORDER BY class_id OFFSET 0 ROWS FETCH NEXT 1 ROWS ONLY);
DECLARE @c2 INT = (SELECT class_id FROM [CLASS] ORDER BY class_id OFFSET 1 ROWS FETCH NEXT 1 ROWS ONLY);
DECLARE @c3 INT = (SELECT class_id FROM [CLASS] ORDER BY class_id OFFSET 2 ROWS FETCH NEXT 1 ROWS ONLY);

IF @c3 IS NULL
BEGIN
    RAISERROR(N'[TV4] Bang CLASS can it nhat 3 dong (Section TV3 chua chay).', 16, 1);
    RETURN;
END;

-- Chuong dau tien / thu hai cua lop 1, chuong dau tien cua lop 3 (NULL neu chua co)
DECLARE @c1ch1 INT = (SELECT MIN(chapter_id) FROM [CHAPTER] WHERE class_id = @c1);
DECLARE @c1ch2 INT = (SELECT MIN(chapter_id) FROM [CHAPTER] WHERE class_id = @c1 AND chapter_id > @c1ch1);
DECLARE @c3ch1 INT = (SELECT MIN(chapter_id) FROM [CHAPTER] WHERE class_id = @c3);

BEGIN TRANSACTION;

-- ---------------------------------------------------------------------
-- QUESTION (12 cau): trac nghiem, dung/sai, tu luan.
-- Gan id thu cong de CHOICE / CONTAINS_QUESTION / demo tham chieu on dinh.
-- ---------------------------------------------------------------------
SET IDENTITY_INSERT [QUESTION] ON;
INSERT INTO [QUESTION] (question_id, question_type, question_content, max_score) VALUES
 (1,  N'MULTIPLE_CHOICE', N'Thuộc tính khóa chính của một quan hệ phải thỏa tính chất nào sau đây?', 1.00),
 (2,  N'MULTIPLE_CHOICE', N'Phép toán nào trong đại số quan hệ dùng để chọn các bộ thỏa một điều kiện?', 1.00),
 (3,  N'TRUE_FALSE',      N'Một bảng có thể có nhiều khóa chính.', 1.00),
 (4,  N'TRUE_FALSE',      N'Khóa ngoại có thể nhận giá trị NULL khi thực thể tham gia từng phần vào liên kết.', 1.00),
 (5,  N'MULTIPLE_CHOICE', N'Quan hệ đã ở dạng chuẩn 2NF, để đạt 3NF cần loại bỏ loại phụ thuộc nào?', 2.00),
 (6,  N'MULTIPLE_CHOICE', N'Mệnh đề nào dùng để lọc các nhóm sau khi đã GROUP BY?', 1.00),
 (7,  N'ESSAY',           N'Trình bày sự khác nhau giữa thực thể mạnh và thực thể yếu trong mô hình ER.', 3.00),
 (8,  N'ESSAY',           N'Nêu các bước ánh xạ một liên kết N:M từ ERD sang lược đồ quan hệ.', 3.00),
 (9,  N'MULTIPLE_CHOICE', N'Lệnh nào xóa toàn bộ dòng của bảng nhưng vẫn giữ lại cấu trúc bảng?', 1.00),
 (10, N'TRUE_FALSE',      N'Trigger AFTER INSERT được thực thi trước khi dòng dữ liệu mới được thêm vào bảng.', 1.00),
 (11, N'MULTIPLE_CHOICE', N'Ràng buộc nào bảo đảm giá trị của một cột phải tồn tại trong bảng được tham chiếu?', 1.00),
 (12, N'ESSAY',           N'Giải thích thuộc tính dẫn xuất và cho một ví dụ trong hệ thống quản lý học tập.', 2.00);
SET IDENTITY_INSERT [QUESTION] OFF;

-- ---------------------------------------------------------------------
-- CHOICE (30 dong). Moi cau trac nghiem / dung-sai co dung 1 dap an dung
-- (rang buoc ngu nghia 19). Cau tu luan (7, 8, 12) khong co lua chon.
-- ---------------------------------------------------------------------
INSERT INTO [CHOICE] (choice_content, is_true, question_id) VALUES
 -- Q1
 (N'Giá trị duy nhất và không được NULL', 1, 1),
 (N'Có thể trùng giữa các bộ',            0, 1),
 (N'Luôn phải là kiểu số nguyên',         0, 1),
 (N'Được phép nhận giá trị NULL',         0, 1),
 -- Q2
 (N'Phép chọn (σ)',                       1, 2),
 (N'Phép chiếu (π)',                      0, 2),
 (N'Phép hợp (∪)',                        0, 2),
 (N'Phép tích Descartes (×)',             0, 2),
 -- Q3 (dung/sai)
 (N'Đúng', 0, 3),
 (N'Sai',  1, 3),
 -- Q4 (dung/sai)
 (N'Đúng', 1, 4),
 (N'Sai',  0, 4),
 -- Q5
 (N'Phụ thuộc bắc cầu',                   1, 5),
 (N'Phụ thuộc hàm riêng phần',            0, 5),
 (N'Phụ thuộc đa trị',                    0, 5),
 (N'Phụ thuộc hàm tầm thường',            0, 5),
 -- Q6
 (N'HAVING',                              1, 6),
 (N'WHERE',                               0, 6),
 (N'ORDER BY',                            0, 6),
 (N'DISTINCT',                            0, 6),
 -- Q9
 (N'TRUNCATE TABLE',                      1, 9),
 (N'DROP TABLE',                          0, 9),
 (N'ALTER TABLE',                         0, 9),
 (N'DROP DATABASE',                       0, 9),
 -- Q10 (dung/sai)
 (N'Đúng', 0, 10),
 (N'Sai',  1, 10),
 -- Q11
 (N'FOREIGN KEY',                         1, 11),
 (N'UNIQUE',                              0, 11),
 (N'CHECK',                               0, 11),
 (N'DEFAULT',                             0, 11);

-- ---------------------------------------------------------------------
-- TEST (6 bai): 4 phuong thuc tinh diem, co bai gan chuong, co bai nop tap tin.
-- Dung gia tri khop CHECK: test_end > test_start; test_timer (phut) *60
-- khong vuot khoang mo de -> dong de. Bai nop tap tin: test_timer = NULL.
-- ---------------------------------------------------------------------
SET IDENTITY_INSERT [TEST] ON;
INSERT INTO [TEST] (test_id, test_name, test_type, test_start, test_end, test_timer,
                    max_attempts, grading_method, class_id, chapter_id) VALUES
 (1, N'Quiz chương 1 - Tổng quan CSDL',      N'ONLINE',          '2026-09-21T08:00:00', '2026-09-21T23:59:00', 30,   2, 'HIGHEST', @c1, @c1ch1),
 (2, N'Quiz chương 2 - Mô hình ER',          N'ONLINE',          '2026-10-05T08:00:00', '2026-10-12T23:59:00', 20,   3, 'AVERAGE', @c1, @c1ch2),
 (3, N'Kiểm tra giữa kỳ',                    N'ONLINE',          '2026-10-20T13:00:00', '2026-10-20T15:00:00', 60,   1, 'FIRST',   @c2, NULL),
 (4, N'Nộp bài tập lớn 1',                   N'FILE_SUBMISSION', '2026-11-01T00:00:00', '2026-11-15T23:59:00', NULL, 1, 'LATEST',  @c2, NULL),
 (5, N'Quiz chương 4 - Đại số quan hệ',      N'ONLINE',          '2026-11-10T09:00:00', '2026-11-10T17:00:00', 45,   2, 'LATEST',  @c3, @c3ch1),
 (6, N'Kiểm tra cuối kỳ',                    N'ONLINE',          '2026-12-20T07:30:00', '2026-12-20T11:30:00', 90,   1, 'HIGHEST', @c3, NULL);
SET IDENTITY_INSERT [TEST] OFF;

-- ---------------------------------------------------------------------
-- CONTAINS_QUESTION: moi bai >= 1 cau (rang buoc 17); mot cau xuat hien
-- o nhieu bai (N:M); custom_score ghi de diem mac dinh (NULL = dung max_score).
-- ---------------------------------------------------------------------
INSERT INTO [CONTAINS_QUESTION] (test_id, question_id, custom_score) VALUES
 (1, 1, NULL), (1, 2, 1.50), (1, 3, NULL), (1, 6, NULL),
 (2, 4, NULL), (2, 5, 2.50), (2, 9, NULL), (2, 11, NULL),
 (3, 1, NULL), (3, 2, NULL), (3, 5, NULL), (3, 6, NULL), (3, 7, 4.00), (3, 8, NULL),
 (4, 12, NULL),
 (5, 3, NULL), (5, 4, NULL), (5, 10, 0.50), (5, 11, NULL),
 (6, 1, NULL), (6, 5, NULL), (6, 6, NULL), (6, 7, NULL), (6, 8, 4.00), (6, 9, NULL), (6, 12, NULL);

COMMIT TRANSACTION;

-- Kiem tra nhanh so dong da chen
SELECT N'QUESTION' AS bang, COUNT(*) AS so_dong FROM [QUESTION]
UNION ALL SELECT N'CHOICE',            COUNT(*) FROM [CHOICE]
UNION ALL SELECT N'TEST',              COUNT(*) FROM [TEST]
UNION ALL SELECT N'CONTAINS_QUESTION', COUNT(*) FROM [CONTAINS_QUESTION];
GO
-- =================================================================================
-- PHẦN CỦA TV5: CỤM 4 - LÀM BÀI KIỂM TRA & DIỄN ĐÀN THẢO LUẬN
-- Bảng: [TAKES_TEST], [ATTEMPT], [STUDENT_ANSWER], [POST], [COMMENT]
-- Quy ước: TV5 CHỈ VIẾT TRONG KHUNG NÀY, KHÔNG SỬA RA NGOÀI KHUNG
-- =================================================================================
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
SET NOCOUNT ON;
SET XACT_ABORT ON;

DECLARE @identity_on SYSNAME = NULL;
BEGIN TRY
    BEGIN TRANSACTION;

    IF NOT EXISTS (SELECT 1 FROM dbo.[POST])
    BEGIN
        -- -------------------------------------------------------------------------
        -- POST (6 hàng)
        -- Tuân thủ RB3, RB28: Chỉ Giảng viên dạy lớp đó hoặc Sinh viên đã đăng ký lớp
        -- và có is_allowed_to_discuss = 1 trong ENROLLS mới được đăng bài;
        -- thời gian đăng bài (post_start) nằm trong học kỳ của lớp.
        -- -------------------------------------------------------------------------
        SET IDENTITY_INSERT dbo.[POST] ON;
        SET @identity_on = N'POST';
        INSERT INTO dbo.[POST] ([post_id], [post_name], [post_description], [post_start], [ua_id], [class_id])
        VALUES
            (1, N'Thông báo quy định làm Bài tập lớn môn Cơ sở dữ liệu',
                N'Các nhóm lưu ý giữ nguyên 25 bảng từ BTL1, kiểm tra kỹ các ràng buộc toàn vẹn bằng CHECK trước khi viết Trigger.',
                N'2026-09-10T09:00:00', 1011, 3),
            (2, N'Thắc mắc về chuyển đổi thực thể yếu CHAPTER và TOPIC sang lược đồ quan hệ',
                N'Thầy và các bạn cho em hỏi khóa chính của TOPIC gồm những thuộc tính nào khi ánh xạ từ EERD sang bảng ạ?',
                N'2026-09-23T14:15:00', 1001, 3),
            (3, N'Hỏi về sự khác biệt giữa kiểm soát luồng và kiểm soát tắc nghẽn trong TCP',
                N'Mình đang đọc slide Chương 2 nhưng chưa phân biệt rõ cửa sổ nhận (rwnd) và cửa sổ tắc nghẽn (cwnd).',
                N'2026-10-07T10:30:00', 1004, 4),
            (4, N'Hướng dẫn cài đặt phần mềm mô phỏng mạch logic Chương 2',
                N'Các em tải file mô phỏng mạch cộng đã đính kèm trong Topic 1 của Chương 2 và chạy thử trước buổi học tuần tới.',
                N'2026-10-15T08:00:00', 1012, 5),
            (5, N'Lỗi tràn ngăn xếp khi gọi hàm đệ quy không có điều kiện dừng',
                N'Khi em chạy bài tập tính giai thừa bằng đệ quy với n âm thì chương trình bị dừng đột ngột, nhờ thầy và các bạn giải thích giúp ạ.',
                N'2025-09-21T19:00:00', 1002, 1),
            (6, N'So sánh độ phức tạp chèn đầu và chèn cuối trong danh sách liên kết đơn',
                N'Nếu chỉ quản lý con trỏ head mà không có con trỏ tail thì thao tác chèn cuối tốn O(n) đúng không ạ?',
                N'2026-02-26T15:20:00', 1001, 2);
        SET IDENTITY_INSERT dbo.[POST] OFF;
        SET @identity_on = NULL;

        -- -------------------------------------------------------------------------
        -- COMMENT (10 hàng)
        -- Tuân thủ RB3, RB28 & RB29:
        --   - Người bình luận phải thuộc lớp của bài đăng và có quyền thảo luận
        --     (Lưu ý: SV4 / ua_id = 1004 bị khóa thảo luận ở lớp 2 nên không bình luận ở lớp 2).
        --   - comment_start >= post_start (và >= comment_start của bình luận cha).
        --   - Bình luận phản hồi (parent_comment_id) phải thuộc cùng post_id với bình luận gốc.
        -- -------------------------------------------------------------------------
        SET IDENTITY_INSERT dbo.[COMMENT] ON;
        SET @identity_on = N'COMMENT';
        INSERT INTO dbo.[COMMENT] ([comment_id], [comment_content], [comment_start], [post_id], [ua_id], [parent_comment_id])
        VALUES
            (1,  N'Dạ thầy cho em hỏi mỗi bảng cần tối thiểu bao nhiêu dòng dữ liệu mẫu ạ?',
                 N'2026-09-10T09:30:00', 1, 1001, NULL),
            (2,  N'Mỗi bảng cần tối thiểu 5 dòng dữ liệu có ý nghĩa thực tế nhé An.',
                 N'2026-09-10T09:45:00', 1, 1011, 1),
            (3,  N'Dạ nhóm em đã nắm rõ thông tin, cảm ơn thầy ạ!',
                 N'2026-09-10T10:10:00', 1, 1002, 2),
            (4,  N'Vì TOPIC là thực thể yếu phụ thuộc vào CHAPTER nên khóa chính sẽ là (class_id, chapter_id, topic_id) đó bạn.',
                 N'2026-09-23T14:40:00', 2, 1004, NULL),
            (5,  N'Bạn Dũng trả lời chính xác rồi, các em nhớ khai báo khóa ngoại tổ hợp tham chiếu về CHAPTER nhé.',
                 N'2026-09-23T15:05:00', 2, 1011, 4),
            (6,  N'Kiểm soát luồng bảo vệ bộ đệm của bên nhận (dùng rwnd), còn kiểm soát tắc nghẽn bảo vệ mạng khỏi quá tải (dùng cwnd).',
                 N'2026-10-07T11:00:00', 3, 1011, NULL),
            (7,  N'Vậy lượng dữ liệu gửi đi tối đa tại một thời điểm sẽ bằng min(rwnd, cwnd) đúng không thầy?',
                 N'2026-10-07T11:25:00', 3, 1001, 6),
            (8,  N'Dạ cô ơi em đã tải file mô phỏng mạch cộng 4-bit về và chạy thử thành công rồi ạ.',
                 N'2026-10-15T09:15:00', 4, 1003, NULL),
            (9,  N'Bạn cần kiểm tra điều kiện n >= 0 trước khi gọi đệ quy, nếu chỉ dừng ở n == 0 thì với n âm hàm sẽ gọi vô hạn.',
                 N'2025-09-21T19:30:00', 5, 1005, NULL),
            (10, N'Đúng rồi bạn, vì phải duyệt từ head đến nút cuối cùng mới nối nút mới vào được.',
                 N'2026-02-26T16:00:00', 6, 1002, NULL);
        SET IDENTITY_INSERT dbo.[COMMENT] OFF;
        SET @identity_on = NULL;
    END;

    IF NOT EXISTS (SELECT 1 FROM dbo.[TAKES_TEST])
    BEGIN
        -- -------------------------------------------------------------------------
        -- TAKES_TEST (7 hàng)
        -- Tuân thủ RB3 & RB26:
        --   - Sinh viên phải thuộc lớp của bài kiểm tra (ENROLLS).
        --   - final_score được tính chuẩn xác từ ATTEMPT.score theo TEST.grading_method:
        --     * Test 1 (HIGHEST): SV1 = MAX(3.00, 4.50) = 4.50; SV2 = 3.50
        --     * Test 2 (AVERAGE): SV1 = AVG(3.00, 4.50) = 3.75; SV5 = 5.50
        --     * Test 3 (FIRST)  : SV2 = 11.00
        --     * Test 4 (LATEST) : SV1 = 2.00
        --     * Test 5 (LATEST) : SV4 = 3.50
        -- -------------------------------------------------------------------------
        INSERT INTO dbo.[TAKES_TEST] ([student_id], [test_id], [final_score])
        VALUES
            (1, 1, 4.50),
            (2, 1, 3.50),
            (1, 2, 3.75),
            (5, 2, 5.50),
            (2, 3, 11.00),
            (1, 4, 2.00),
            (4, 5, 3.50);

        -- -------------------------------------------------------------------------
        -- ATTEMPT (7 hàng)
        -- Tuân thủ RB17, RB18, RB19, RB20, RB21, RB25:
        --   - attempt_index tăng tuần tự 1, 2... và <= TEST.max_attempts.
        --   - start_time và end_time nằm trong khoảng [test_start, test_end] của TEST.
        --   - Thời gian làm bài (end_time - start_time) <= TEST.test_timer.
        --   - score bằng đúng tổng score_awarded của các câu trả lời trong STUDENT_ANSWER.
        -- -------------------------------------------------------------------------
        SET IDENTITY_INSERT dbo.[ATTEMPT] ON;
        SET @identity_on = N'ATTEMPT';
        INSERT INTO dbo.[ATTEMPT] ([attempt_id], [attempt_index], [start_time], [end_time], [score], [student_id], [test_id])
        VALUES
            (1, 1, N'2026-09-21T08:10:00', N'2026-09-21T08:32:00', 3.00,  1, 1),
            (2, 2, N'2026-09-21T14:00:00', N'2026-09-21T14:20:00', 4.50,  1, 1),
            (3, 1, N'2026-09-21T09:00:00', N'2026-09-21T09:25:00', 3.50,  2, 1),
            (4, 1, N'2026-10-06T10:00:00', N'2026-10-06T10:15:00', 3.00,  1, 2),
            (5, 2, N'2026-10-08T15:00:00', N'2026-10-08T15:18:00', 4.50,  1, 2),
            (6, 1, N'2026-10-07T20:00:00', N'2026-10-07T20:16:00', 5.50,  5, 2),
            (7, 1, N'2026-10-20T13:05:00', N'2026-10-20T13:55:00', 11.00, 2, 3),
            (8, 1, N'2026-11-12T20:00:00', N'2026-11-12T20:30:00', 2.00,  1, 4),
            (9, 1, N'2026-11-10T09:30:00', N'2026-11-10T10:00:00', 3.50,  4, 5);
        SET IDENTITY_INSERT dbo.[ATTEMPT] OFF;
        SET @identity_on = NULL;

        -- -------------------------------------------------------------------------
        -- STUDENT_ANSWER (35 hàng)
        -- Tuân thủ RB22, RB24, RB25:
        --   - upload_time nằm trong khoảng [start_time, end_time] của ATTEMPT.
        --   - Câu hỏi thuộc đúng đề thi (CONTAINS_QUESTION).
        --   - Câu trắc nghiệm có choice_id thuộc đúng question_id; câu tự luận có choice_id = NULL
        --     và 0 <= score_awarded <= điểm tối đa của câu hỏi trong đề thi.
        -- -------------------------------------------------------------------------
        DECLARE @q1_true  INT = (SELECT MIN(choice_id) FROM dbo.[CHOICE] WHERE question_id = 1  AND is_true = 1);
        DECLARE @q2_true  INT = (SELECT MIN(choice_id) FROM dbo.[CHOICE] WHERE question_id = 2  AND is_true = 1);
        DECLARE @q2_false INT = (SELECT MIN(choice_id) FROM dbo.[CHOICE] WHERE question_id = 2  AND is_true = 0);
        DECLARE @q3_true  INT = (SELECT MIN(choice_id) FROM dbo.[CHOICE] WHERE question_id = 3  AND is_true = 1);
        DECLARE @q3_false INT = (SELECT MIN(choice_id) FROM dbo.[CHOICE] WHERE question_id = 3  AND is_true = 0);
        DECLARE @q4_true  INT = (SELECT MIN(choice_id) FROM dbo.[CHOICE] WHERE question_id = 4  AND is_true = 1);
        DECLARE @q5_true  INT = (SELECT MIN(choice_id) FROM dbo.[CHOICE] WHERE question_id = 5  AND is_true = 1);
        DECLARE @q5_false INT = (SELECT MIN(choice_id) FROM dbo.[CHOICE] WHERE question_id = 5  AND is_true = 0);
        DECLARE @q6_true  INT = (SELECT MIN(choice_id) FROM dbo.[CHOICE] WHERE question_id = 6  AND is_true = 1);
        DECLARE @q9_true  INT = (SELECT MIN(choice_id) FROM dbo.[CHOICE] WHERE question_id = 9  AND is_true = 1);
        DECLARE @q10_true INT = (SELECT MIN(choice_id) FROM dbo.[CHOICE] WHERE question_id = 10 AND is_true = 1);
        DECLARE @q11_true INT = (SELECT MIN(choice_id) FROM dbo.[CHOICE] WHERE question_id = 11 AND is_true = 1);
        DECLARE @q11_false INT = (SELECT MIN(choice_id) FROM dbo.[CHOICE] WHERE question_id = 11 AND is_true = 0);

        SET IDENTITY_INSERT dbo.[STUDENT_ANSWER] ON;
        SET @identity_on = N'STUDENT_ANSWER';
        INSERT INTO dbo.[STUDENT_ANSWER] ([ans_id], [answer_text], [file_submission_path], [upload_time], [score_awarded], [attempt_id], [question_id], [choice_id])
        VALUES
            -- Attempt 1 (SV1, Test 1: q1=1.0, q2=0.0, q3=1.0, q6=1.0 -> Tổng = 3.00)
            (1,  NULL, NULL, N'2026-09-21T08:15:00', 1.00, 1, 1, @q1_true),
            (2,  NULL, NULL, N'2026-09-21T08:20:00', 0.00, 1, 2, @q2_false),
            (3,  NULL, NULL, N'2026-09-21T08:25:00', 1.00, 1, 3, @q3_true),
            (4,  NULL, NULL, N'2026-09-21T08:30:00', 1.00, 1, 6, @q6_true),

            -- Attempt 2 (SV1, Test 1: q1=1.0, q2=1.5, q3=1.0, q6=1.0 -> Tổng = 4.50)
            (5,  NULL, NULL, N'2026-09-21T14:05:00', 1.00, 2, 1, @q1_true),
            (6,  NULL, NULL, N'2026-09-21T14:10:00', 1.50, 2, 2, @q2_true),
            (7,  NULL, NULL, N'2026-09-21T14:14:00', 1.00, 2, 3, @q3_true),
            (8,  NULL, NULL, N'2026-09-21T14:18:00', 1.00, 2, 6, @q6_true),

            -- Attempt 3 (SV2, Test 1: q1=1.0, q2=1.5, q3=0.0, q6=1.0 -> Tổng = 3.50)
            (9,  NULL, NULL, N'2026-09-21T09:05:00', 1.00, 3, 1, @q1_true),
            (10, NULL, NULL, N'2026-09-21T09:12:00', 1.50, 3, 2, @q2_true),
            (11, NULL, NULL, N'2026-09-21T09:18:00', 0.00, 3, 3, @q3_false),
            (12, NULL, NULL, N'2026-09-21T09:23:00', 1.00, 3, 6, @q6_true),

            -- Attempt 4 (SV1, Test 2: q4=1.0, q5=0.0, q9=1.0, q11=1.0 -> Tổng = 3.00)
            (13, NULL, NULL, N'2026-10-06T10:03:00', 1.00, 4, 4,  @q4_true),
            (14, NULL, NULL, N'2026-10-06T10:07:00', 0.00, 4, 5,  @q5_false),
            (15, NULL, NULL, N'2026-10-06T10:11:00', 1.00, 4, 9,  @q9_true),
            (16, NULL, NULL, N'2026-10-06T10:14:00', 1.00, 4, 11, @q11_true),

            -- Attempt 5 (SV1, Test 2: q4=1.0, q5=2.5, q9=1.0, q11=0.0 -> Tổng = 4.50)
            (17, NULL, NULL, N'2026-10-08T15:04:00', 1.00, 5, 4,  @q4_true),
            (18, NULL, NULL, N'2026-10-08T15:09:00', 2.50, 5, 5,  @q5_true),
            (19, NULL, NULL, N'2026-10-08T15:13:00', 1.00, 5, 9,  @q9_true),
            (20, NULL, NULL, N'2026-10-08T15:17:00', 0.00, 5, 11, @q11_false),

            -- Attempt 6 (SV5, Test 2: q4=1.0, q5=2.5, q9=1.0, q11=1.0 -> Tổng = 5.50)
            (21, NULL, NULL, N'2026-10-07T20:03:00', 1.00, 6, 4,  @q4_true),
            (22, NULL, NULL, N'2026-10-07T20:08:00', 2.50, 6, 5,  @q5_true),
            (23, NULL, NULL, N'2026-10-07T20:12:00', 1.00, 6, 9,  @q9_true),
            (24, NULL, NULL, N'2026-10-07T20:15:00', 1.00, 6, 11, @q11_true),

            -- Attempt 7 (SV2, Test 3: q1=1.0, q2=1.0, q5=2.0, q6=1.0, q7=3.5, q8=2.5 -> Tổng = 11.00)
            (25, NULL, NULL, N'2026-10-20T13:10:00', 1.00, 7, 1, @q1_true),
            (26, NULL, NULL, N'2026-10-20T13:15:00', 1.00, 7, 2, @q2_true),
            (27, NULL, NULL, N'2026-10-20T13:20:00', 2.00, 7, 5, @q5_true),
            (28, NULL, NULL, N'2026-10-20T13:25:00', 1.00, 7, 6, @q6_true),
            (29, N'Thực thể mạnh có khóa chính độc lập, thực thể yếu phụ thuộc vào thực thể chủ và dùng khóa riêng phần kết hợp khóa chủ.',
                 NULL, N'2026-10-20T13:40:00', 3.50, 7, 7, NULL),
            (30, N'Tạo quan hệ mới có khóa chính là tổ hợp khóa chính của hai thực thể tham gia liên kết kèm các thuộc tính của liên kết.',
                 NULL, N'2026-10-20T13:52:00', 2.50, 7, 8, NULL),

            -- Attempt 8 (SV1, Test 4 - FILE_SUBMISSION: q12=2.0 -> Tổng = 2.00)
            (31, N'Thuộc tính dẫn xuất được tính từ các thuộc tính khác, ví dụ final_score trong TAKES_TEST được tính từ score của bảng ATTEMPT.',
                 N'/submissions/test_4/sv1_btl1.pdf', N'2026-11-12T20:25:00', 2.00, 8, 12, NULL),

            -- Attempt 9 (SV4, Test 5: q3=1.0, q4=1.0, q10=0.5, q11=1.0 -> Tổng = 3.50)
            (32, NULL, NULL, N'2026-11-10T09:35:00', 1.00, 9, 3,  @q3_true),
            (33, NULL, NULL, N'2026-11-10T09:42:00', 1.00, 9, 4,  @q4_true),
            (34, NULL, NULL, N'2026-11-10T09:50:00', 0.50, 9, 10, @q10_true),
            (35, NULL, NULL, N'2026-11-10T09:58:00', 1.00, 9, 11, @q11_true);
        SET IDENTITY_INSERT dbo.[STUDENT_ANSWER] OFF;
        SET @identity_on = NULL;
    END;

    COMMIT TRANSACTION;
    SELECT N'TAKES_TEST' AS ten_bang, COUNT(*) AS so_dong FROM dbo.[TAKES_TEST]
    UNION ALL SELECT N'ATTEMPT',        COUNT(*) FROM dbo.[ATTEMPT]
    UNION ALL SELECT N'STUDENT_ANSWER', COUNT(*) FROM dbo.[STUDENT_ANSWER]
    UNION ALL SELECT N'POST',           COUNT(*) FROM dbo.[POST]
    UNION ALL SELECT N'COMMENT',        COUNT(*) FROM dbo.[COMMENT];
END TRY
BEGIN CATCH
    IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
    IF @identity_on = N'POST'           SET IDENTITY_INSERT dbo.[POST] OFF;
    IF @identity_on = N'COMMENT'        SET IDENTITY_INSERT dbo.[COMMENT] OFF;
    IF @identity_on = N'ATTEMPT'        SET IDENTITY_INSERT dbo.[ATTEMPT] OFF;
    IF @identity_on = N'STUDENT_ANSWER' SET IDENTITY_INSERT dbo.[STUDENT_ANSWER] OFF;
    THROW;
END CATCH;
GO
