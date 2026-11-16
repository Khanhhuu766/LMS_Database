-- =================================================================================
-- KỊCH BẢN KIỂM THỬ & MINH HỌA KHI BÁO CÁO (DEMO TEST CASES)
-- Yêu cầu đề bài :
--   - Chuẩn bị sẵn các câu lệnh và dữ liệu minh họa cho việc kiểm tra Trigger (2.2),
--     gọi Thủ tục (2.1, 2.3) và gọi Hàm (2.4) khi báo cáo trực tiếp với giảng viên.
--   - Bao gồm cả trường hợp chạy thành công (hợp lệ) và trường hợp bị chặn lỗi (vi phạm).
-- =================================================================================

-- =================================================================================
-- PHẦN CỦA TV1: KIỂM THỬ MỤC 2.1 - 3 THỦ TỤC THÊM (INSERT), SỬA (UPDATE), XÓA (DELETE)
-- Quy ước: TV1 CHỈ VIẾT TRONG KHUNG NÀY, KHÔNG SỬA RA NGOÀI KHUNG
-- =================================================================================
-- TODO
GO

-- =================================================================================
-- PHẦN CỦA TV2: KIỂM THỬ MỤC 2.2.1 - TRIGGER KIỂM TRA RÀNG BUỘC NGHIỆP VỤ
-- Quy ước: TV2 CHỈ VIẾT TRONG KHUNG NÀY, KHÔNG SỬA RA NGOÀI KHUNG
-- =================================================================================
-- TODO
USE [LMS_DB];
GO
SET NOCOUNT ON;

DECLARE @student_id INT;
DECLARE @test_id INT = NULL;
DECLARE @attempt_count BIGINT;

SELECT TOP (1) @student_id = user_id
FROM dbo.[STUDENT]
ORDER BY user_id;

IF @student_id IS NULL
    THROW 50090, N'Can co it nhat 1 STUDENT de chay demo RB18.', 1;

BEGIN TRY
    INSERT INTO dbo.[TEST]
        (test_name, test_type, test_start, test_end, test_timer, max_attempts, grading_method)
    VALUES
        (N'TV2 RB18 demo - attempt limit', N'ONLINE',
         DATEADD(HOUR, -1, GETDATE()), DATEADD(HOUR, 2, GETDATE()),
         30, 2, N'HIGHEST');

    SET @test_id = CONVERT(INT, SCOPE_IDENTITY());

    INSERT INTO dbo.[ATTEMPT] (attempt_index, start_time, student_id, test_id)
    VALUES (1, GETDATE(), @student_id, @test_id),
           (2, GETDATE(), @student_id, @test_id);

    SELECT @attempt_count = COUNT_BIG(*)
    FROM dbo.[ATTEMPT]
    WHERE student_id = @student_id AND test_id = @test_id;

    IF @attempt_count = 2
        PRINT N'PASS 1: Sinh vien duoc lam 2 lan khi max_attempts = 2.';
    ELSE
        THROW 50091, N'FAIL 1: So lan lam bai khong phai 2.', 1;

    BEGIN TRY
        INSERT INTO dbo.[ATTEMPT] (attempt_index, start_time, student_id, test_id)
        VALUES (3, GETDATE(), @student_id, @test_id);
        PRINT N'FAIL 2: Lan thu 3 da duoc insert.';
    END TRY
    BEGIN CATCH
        IF ERROR_NUMBER() = 50018
            PRINT N'PASS 2: Trigger chan lan lam bai thu 3.';
        ELSE
            THROW;
    END CATCH;

    SELECT @attempt_count = COUNT_BIG(*)
    FROM dbo.[ATTEMPT]
    WHERE student_id = @student_id AND test_id = @test_id;

    IF @attempt_count = 2
        PRINT N'PASS 3: Sau khi bi chan, so lan lam van bang 2.';
    ELSE
        THROW 50092, N'FAIL 3: So lan lam da bi thay doi.', 1;

    BEGIN TRY
        UPDATE dbo.[TEST]
        SET max_attempts = 1
        WHERE test_id = @test_id;
        PRINT N'FAIL 4: Da giam max_attempts xuong 1.';
    END TRY
    BEGIN CATCH
        IF ERROR_NUMBER() = 50019
            PRINT N'PASS 4: Trigger chan viec giam max_attempts xuong 1.';
        ELSE
            THROW;
    END CATCH;

    UPDATE dbo.[TEST]
    SET max_attempts = 3
    WHERE test_id = @test_id;

    INSERT INTO dbo.[ATTEMPT] (attempt_index, start_time, student_id, test_id)
    VALUES (3, GETDATE(), @student_id, @test_id);

    SELECT @attempt_count = COUNT_BIG(*)
    FROM dbo.[ATTEMPT]
    WHERE student_id = @student_id AND test_id = @test_id;

    IF @attempt_count = 3
        PRINT N'PASS 5: Nang max_attempts len 3 thi lan thu 3 duoc phep.';
    ELSE
        THROW 50093, N'FAIL 5: Sau khi tang gioi han, chua tao duoc lan thu 3.', 1;

    SELECT @test_id AS demo_test_id,
           @student_id AS demo_student_id,
           (SELECT max_attempts FROM dbo.[TEST] WHERE test_id = @test_id) AS max_attempts,
           @attempt_count AS attempt_count;

    DELETE FROM dbo.[ATTEMPT]
    WHERE test_id = @test_id;
    DELETE FROM dbo.[TEST]
    WHERE test_id = @test_id;
    SET @test_id = NULL;

    PRINT N'DEMO HOAN TAT: Da xoa du lieu TEST/ATTEMPT duoc tao trong demo.';
END TRY
BEGIN CATCH
    PRINT N'DEMO GAP LOI: ' + ERROR_MESSAGE();
    IF XACT_STATE() = -1
        ROLLBACK TRANSACTION;

    IF XACT_STATE() = 0 AND @test_id IS NOT NULL
    BEGIN
        DELETE FROM dbo.[ATTEMPT] WHERE test_id = @test_id;
        DELETE FROM dbo.[TEST] WHERE test_id = @test_id;
    END;
    THROW;
END CATCH;
GO


-- =================================================================================
-- PHẦN CỦA TV3: KIỂM THỬ MỤC 2.2.2 - TRIGGER TÍNH THUỘC TÍNH DẪN XUẤT
-- Quy ước: TV3 CHỈ VIẾT TRONG KHUNG NÀY, KHÔNG SỬA RA NGOÀI KHUNG
-- =================================================================================
-- TODO
GO

-- =================================================================================
-- PHẦN CỦA TV4: KIỂM THỬ MỤC 2.3 - 2 THỦ TỤC TRUY VẤN DỮ LIỆU
-- Quy ước: TV4 CHỈ VIẾT TRONG KHUNG NÀY, KHÔNG SỬA RA NGOÀI KHUNG
-- =================================================================================
-- TODO
GO

-- =================================================================================
-- PHẦN CỦA TV5: KIỂM THỬ MỤC 2.4 - 2 HÀM TÍNH TOÁN SỬ DỤNG CON TRỎ (CURSOR)
-- Quy ước: TV5 CHỈ VIẾT TRONG KHUNG NÀY, KHÔNG SỬA RA NGOÀI KHUNG
-- =================================================================================
USE [LMS_DB];
GO
SET NOCOUNT ON;

PRINT N'=== [TV5 - MỤC 2.4] BẮT ĐẦU KIỂM THỬ 2 HÀM CURSOR ===';

-- ---------------------------------------------------------------------------------
-- 1. KIỂM THỬ HÀM 1: dbo.fn_CalculateStudentTestScore(@StudentId, @TestId)
-- ---------------------------------------------------------------------------------
DECLARE @f1_c1 DECIMAL(5,2) = dbo.fn_CalculateStudentTestScore(1, 1);     -- HIGHEST -> 4.50
DECLARE @f1_c2 DECIMAL(5,2) = dbo.fn_CalculateStudentTestScore(1, 2);     -- AVERAGE -> 3.75
DECLARE @f1_c3 DECIMAL(5,2) = dbo.fn_CalculateStudentTestScore(2, 3);     -- FIRST   -> 11.00
DECLARE @f1_c4 DECIMAL(5,2) = dbo.fn_CalculateStudentTestScore(4, 5);     -- LATEST  -> 3.50
DECLARE @f1_c5 DECIMAL(5,2) = dbo.fn_CalculateStudentTestScore(4, 6);     -- Chưa làm bài -> NULL
DECLARE @f1_c6 DECIMAL(5,2) = dbo.fn_CalculateStudentTestScore(3, 1);     -- Chưa đăng ký lớp (RB3) -> -2.00
DECLARE @f1_c7 DECIMAL(5,2) = dbo.fn_CalculateStudentTestScore(-1, 1);    -- Tham số <= 0 -> -1.00
DECLARE @f1_c8 DECIMAL(5,2) = dbo.fn_CalculateStudentTestScore(NULL, 1);  -- Tham số NULL -> -1.00
DECLARE @f1_c9 DECIMAL(5,2) = dbo.fn_CalculateStudentTestScore(999, 1);   -- Không tồn tại -> -1.00

IF @f1_c1 = 4.50  PRINT N'PASS [Hàm 1 - Case 1]: SV1, Test 1 (HIGHEST) = 4.50';      ELSE THROW 54001, N'FAIL [Hàm 1 - Case 1]: Sai kết quả HIGHEST.', 1;
IF @f1_c2 = 3.75  PRINT N'PASS [Hàm 1 - Case 2]: SV1, Test 2 (AVERAGE) = 3.75';      ELSE THROW 54002, N'FAIL [Hàm 1 - Case 2]: Sai kết quả AVERAGE.', 1;
IF @f1_c3 = 11.00 PRINT N'PASS [Hàm 1 - Case 3]: SV2, Test 3 (FIRST) = 11.00';       ELSE THROW 54003, N'FAIL [Hàm 1 - Case 3]: Sai kết quả FIRST.', 1;
IF @f1_c4 = 3.50  PRINT N'PASS [Hàm 1 - Case 4]: SV4, Test 5 (LATEST) = 3.50';       ELSE THROW 54004, N'FAIL [Hàm 1 - Case 4]: Sai kết quả LATEST.', 1;
IF @f1_c5 IS NULL PRINT N'PASS [Hàm 1 - Case 5]: SV4, Test 6 (Chưa làm) = NULL';     ELSE THROW 54005, N'FAIL [Hàm 1 - Case 5]: Kỳ vọng NULL khi chưa làm bài.', 1;
IF @f1_c6 = -2.00 PRINT N'PASS [Hàm 1 - Case 6]: SV3, Test 1 (Chưa đăng ký) = -2.00'; ELSE THROW 54006, N'FAIL [Hàm 1 - Case 6]: Kỳ vọng -2.00 khi vi phạm RB3.', 1;
IF @f1_c7 = -1.00 AND @f1_c8 = -1.00 AND @f1_c9 = -1.00
    PRINT N'PASS [Hàm 1 - Case 7]: Tham số không hợp lệ (-1, NULL, 999) đều trả về -1.00';
ELSE
    THROW 54007, N'FAIL [Hàm 1 - Case 7]: Xử lý tham số không hợp lệ chưa đúng.', 1;

-- Bảng đối chiếu trực quan Hàm 1 với bảng TAKES_TEST
SELECT
    tt.student_id,
    tt.test_id,
    t.grading_method,
    tt.final_score AS expected_final_score,
    dbo.fn_CalculateStudentTestScore(tt.student_id, tt.test_id) AS function_result
FROM dbo.[TAKES_TEST] AS tt
INNER JOIN dbo.[TEST] AS t ON tt.test_id = t.test_id
ORDER BY tt.student_id, tt.test_id;

-- ---------------------------------------------------------------------------------
-- 2. KIỂM THỬ HÀM 2: dbo.fn_CalculateStudentEngagementScore(@StudentId, @SemesterId)
-- ---------------------------------------------------------------------------------
DECLARE @f2_c1 DECIMAL(6,2) = dbo.fn_CalculateStudentEngagementScore(1, 5);    -- SV1, HK5 -> 29.00
DECLARE @f2_c2 DECIMAL(6,2) = dbo.fn_CalculateStudentEngagementScore(4, 5);    -- SV4, HK5 -> 35.00
DECLARE @f2_c3 DECIMAL(6,2) = dbo.fn_CalculateStudentEngagementScore(1, 3);    -- SV1, HK3 -> 25.00
DECLARE @f2_c4 DECIMAL(6,2) = dbo.fn_CalculateStudentEngagementScore(4, 4);    -- SV4, HK4 (bị khóa thảo luận) -> 5.00
DECLARE @f2_c5 DECIMAL(6,2) = dbo.fn_CalculateStudentEngagementScore(3, 3);    -- SV3, HK3 (không học lớp nào) -> 0.00
DECLARE @f2_c6 DECIMAL(6,2) = dbo.fn_CalculateStudentEngagementScore(1, -2);   -- Tham số <= 0 -> -1.00
DECLARE @f2_c7 DECIMAL(6,2) = dbo.fn_CalculateStudentEngagementScore(1, NULL); -- Tham số NULL -> -1.00
DECLARE @f2_c8 DECIMAL(6,2) = dbo.fn_CalculateStudentEngagementScore(999, 5);  -- Không tồn tại -> -1.00

IF @f2_c1 = 29.00 PRINT N'PASS [Hàm 2 - Case 1]: SV1, HK5 = 29.00'; ELSE THROW 54011, N'FAIL [Hàm 2 - Case 1]: Sai kết quả SV1 HK5.', 1;
IF @f2_c2 = 35.00 PRINT N'PASS [Hàm 2 - Case 2]: SV4, HK5 = 35.00'; ELSE THROW 54012, N'FAIL [Hàm 2 - Case 2]: Sai kết quả SV4 HK5.', 1;
IF @f2_c3 = 25.00 PRINT N'PASS [Hàm 2 - Case 3]: SV1, HK3 = 25.00'; ELSE THROW 54013, N'FAIL [Hàm 2 - Case 3]: Sai kết quả SV1 HK3.', 1;
IF @f2_c4 = 5.00  PRINT N'PASS [Hàm 2 - Case 4]: SV4, HK4 (bị khóa thảo luận) = 5.00'; ELSE THROW 54014, N'FAIL [Hàm 2 - Case 4]: Sai kết quả SV4 HK4.', 1;
IF @f2_c5 = 0.00  PRINT N'PASS [Hàm 2 - Case 5]: SV3, HK3 (không đăng ký lớp) = 0.00'; ELSE THROW 54015, N'FAIL [Hàm 2 - Case 5]: Sai kết quả SV3 HK3.', 1;
IF @f2_c6 = -1.00 AND @f2_c7 = -1.00 AND @f2_c8 = -1.00
    PRINT N'PASS [Hàm 2 - Case 6]: Tham số không hợp lệ (-2, NULL, 999) đều trả về -1.00';
ELSE
    THROW 54016, N'FAIL [Hàm 2 - Case 6]: Xử lý tham số không hợp lệ chưa đúng.', 1;

-- Bảng đối chiếu trực quan Hàm 2 cho tất cả các kịch bản kiểm thử
SELECT TestCase, StudentId, SemesterId, ExpectedScore, ActualScore
FROM (VALUES
    (N'SV1 - HK5 (Thảo luận nhiều lớp)',         1,    5,    29.00, @f2_c1),
    (N'SV4 - HK5 (Thảo luận + làm bài test)',     4,    5,    35.00, @f2_c2),
    (N'SV1 - HK3 (Hoàn thành 100% bài test)',     1,    3,    25.00, @f2_c3),
    (N'SV4 - HK4 (Bị khóa thảo luận)',            4,    4,     5.00, @f2_c4),
    (N'SV3 - HK3 (Chưa đăng ký lớp trong kỳ)',    3,    3,     0.00, @f2_c5),
    (N'Tham số sai (SemesterId = -2)',            1,   -2,    -1.00, @f2_c6),
    (N'Tham số sai (SemesterId = NULL)',          1, NULL,    -1.00, @f2_c7),
    (N'Tham số sai (StudentId = 999)',          999,    5,    -1.00, @f2_c8)
) AS Summary(TestCase, StudentId, SemesterId, ExpectedScore, ActualScore);

PRINT N'=== [TV5 - MỤC 2.4] HOÀN TẤT KIỂM THỬ THÀNH CÔNG 100% ===';
GO
