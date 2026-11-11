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
-- TODO
GO
