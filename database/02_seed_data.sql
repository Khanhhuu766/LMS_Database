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
        (1, N'An', N'Văn', N'Nguyễn', N'Nam', N'sv01@hcmut.edu.vn', N'2005-02-03', N'Việt Nam', 1001, N'student01', N'NO_LOGIN_DEMO_STUDENT_01', NULL),
        (2, N'Bình', N'Thị', N'Trần', N'Nữ', N'sv02@hcmut.edu.vn', N'2005-06-14', N'Việt Nam', 1002, N'student02', N'NO_LOGIN_DEMO_STUDENT_02', NULL),
        (3, N'Chi', N'Ngọc', N'Lê', N'Nữ', N'sv03@hcmut.edu.vn', N'2004-08-22', N'Việt Nam', 1003, N'student03', N'NO_LOGIN_DEMO_STUDENT_03', NULL),
        (4, N'Dũng', N'Minh', N'Phạm', N'Nam', N'sv04@hcmut.edu.vn', N'2005-11-07', N'Việt Nam', 1004, N'student04', N'NO_LOGIN_DEMO_STUDENT_04', NULL),
        (5, N'Hà', N'Thanh', N'Võ', N'Nữ', N'sv05@hcmut.edu.vn', N'2006-04-17', N'Việt Nam', 1005, N'student05', N'NO_LOGIN_DEMO_STUDENT_05', NULL),
        (6, N'Khoa', N'Văn', N'Đặng', N'Nam', N'admin01@hcmut.edu.vn', N'1980-03-09', N'Việt Nam', 1006, N'admin01', N'NO_LOGIN_DEMO_ADMIN_01', NULL),
        (7, N'Linh', N'Thị', N'Ngô', N'Nữ', N'admin02@hcmut.edu.vn', N'1983-09-25', N'Việt Nam', 1007, N'admin02', N'NO_LOGIN_DEMO_ADMIN_02', NULL),
        (8, N'Minh', N'Hoàng', N'Bùi', N'Nam', N'admin03@hcmut.edu.vn', N'1979-01-17', N'Việt Nam', 1008, N'admin03', N'NO_LOGIN_DEMO_ADMIN_03', NULL),
        (9, N'Ngân', N'Thu', N'Đỗ', N'Nữ', N'admin04@hcmut.edu.vn', N'1985-12-30', N'Việt Nam', 1009, N'admin04', N'NO_LOGIN_DEMO_ADMIN_04', NULL),
        (10, N'Phúc', N'Đức', N'Huỳnh', N'Nam', N'admin05@hcmut.edu.vn', N'1984-05-11', N'Việt Nam', 1010, N'admin05', N'NO_LOGIN_DEMO_ADMIN_05', NULL),
        (11, N'Quân', N'Hải', N'Nguyễn', N'Nam', N'gv01@hcmut.edu.vn', N'1975-10-19', N'Việt Nam', 1011, N'lecturer01', N'NO_LOGIN_DEMO_LECTURER_01', NULL),
        (12, N'Thảo', N'Kim', N'Trần', N'Nữ', N'gv02@hcmut.edu.vn', N'1982-02-28', N'Việt Nam', 1012, N'lecturer02', N'NO_LOGIN_DEMO_LECTURER_02', NULL),
        (13, N'Tuấn', N'Anh', N'Lê', N'Nam', N'gv03@hcmut.edu.vn', N'1977-07-09', N'Việt Nam', 1013, N'lecturer03', N'NO_LOGIN_DEMO_LECTURER_03', NULL),
        (14, N'Uyên', N'Phương', N'Phạm', N'Nữ', N'gv04@hcmut.edu.vn', N'1981-09-02', N'Việt Nam', 1014, N'lecturer04', N'NO_LOGIN_DEMO_LECTURER_04', NULL),
        (15, N'Vinh', N'Quốc', N'Võ', N'Nam', N'gv05@hcmut.edu.vn', N'1978-12-18', N'Việt Nam', 1015, N'lecturer05', N'NO_LOGIN_DEMO_LECTURER_05', NULL);
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
    PRINT N'TV2: Da insert thanh cong du lieu mau cho 9 bang.';
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
