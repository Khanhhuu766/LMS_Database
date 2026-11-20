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
USE [LMS_DB];
GO
SET NOCOUNT ON;

PRINT N'=== [TV1 - MỤC 2.1] BẮT ĐẦU KIỂM THỬ CRUD TRÊN BẢNG [POST] ===';

DECLARE @demo_post_id INT = NULL;

BEGIN TRY
    -- 1. Kiểm tra INSERT thất bại: Tên bài đăng để trống (lỗi 51001)
    BEGIN TRY
        EXEC dbo.usp_Post_Insert @PostName = N'   ', @UaId = 1001, @PostDescription = N'Test', @ClassId = 3;
        THROW 51090, N'FAIL 1: Khong chan ten bai dang rong.', 1;
    END TRY
    BEGIN CATCH
        IF ERROR_NUMBER() = 51001
            PRINT N'PASS 1: Chan ten bai dang rong (51001): ' + ERROR_MESSAGE();
        ELSE THROW;
    END CATCH;

    -- 2. Kiểm tra INSERT thất bại: Người dùng không tồn tại (lỗi 51004)
    BEGIN TRY
        EXEC dbo.usp_Post_Insert @PostName = N'Test user', @UaId = 99999, @PostDescription = N'Test', @ClassId = 3;
        THROW 51091, N'FAIL 2: Khong chan ua_id khong ton tai.', 1;
    END TRY
    BEGIN CATCH
        IF ERROR_NUMBER() = 51004
            PRINT N'PASS 2: Chan ua_id khong ton tai (51004): ' + ERROR_MESSAGE();
        ELSE THROW;
    END CATCH;

    -- 3. Kiểm tra INSERT thất bại: SV4 (ua_id = 1004) bị khóa thảo luận ở lớp 2 (lỗi 51007)
    BEGIN TRY
        EXEC dbo.usp_Post_Insert @PostName = N'Test bi khoa thao luan', @UaId = 1004, @PostDescription = N'Test', @ClassId = 2;
        THROW 51092, N'FAIL 3: Khong chan SV bi khoa thao luan trong lop 2.', 1;
    END TRY
    BEGIN CATCH
        IF ERROR_NUMBER() = 51007
            PRINT N'PASS 3: Chan SV4 dang bai trong lop 2 do is_allowed_to_discuss = 0 (51007).';
        ELSE THROW;
    END CATCH;

    -- 4. Kiểm tra INSERT thành công: SV1 (ua_id = 1001) đăng bài vào lớp 3
    DECLARE @ins_out TABLE (post_id INT, result_message NVARCHAR(200));
    INSERT INTO @ins_out
    EXEC dbo.usp_Post_Insert
        @PostName        = N'TV1 Demo - Thao luan BTL2',
        @UaId            = 1001,
        @PostDescription = N'Noi dung bai dang demo cua TV1.',
        @ClassId         = 3;

    SELECT TOP (1) @demo_post_id = post_id FROM @ins_out;
    IF @demo_post_id IS NOT NULL
        PRINT N'PASS 4: INSERT thanh cong bai dang moi (post_id = ' + CAST(@demo_post_id AS NVARCHAR(20)) + N').';
    ELSE
        THROW 51093, N'FAIL 4: INSERT khong tra ve post_id.', 1;

    -- 5. Kiểm tra UPDATE thất bại: Người khác (ua_id = 1002) sửa bài của 1001 (lỗi 51017)
    BEGIN TRY
        EXEC dbo.usp_Post_Update
            @PostId          = @demo_post_id,
            @RequesterUaId   = 1002,
            @PostName        = N'Sua trai phep',
            @PostDescription = N'Test';
        THROW 51094, N'FAIL 5: Khong chan nguoi khac sua bai dang.', 1;
    END TRY
    BEGIN CATCH
        IF ERROR_NUMBER() = 51017
            PRINT N'PASS 5: Chan nguoi khong phai tac gia sua bai (51017).';
        ELSE THROW;
    END CATCH;

    -- 6. Kiểm tra UPDATE thành công: Chính tác giả (ua_id = 1001) cập nhật bài
    DECLARE @upd_out TABLE (post_id INT, result_message NVARCHAR(200));
    INSERT INTO @upd_out
    EXEC dbo.usp_Post_Update
        @PostId          = @demo_post_id,
        @RequesterUaId   = 1001,
        @PostName        = N'TV1 Demo - Thao luan BTL2 (Da cap nhat)',
        @PostDescription = N'Noi dung da duoc tac gia cap nhat.';
    PRINT N'PASS 6: UPDATE thanh cong boi chinh tac gia.';

    -- 7. Kiểm tra DELETE thất bại: Không cho xóa bài đã có bình luận (post_id = 1 của 1011, lỗi 51026)
    BEGIN TRY
        EXEC dbo.usp_Post_Delete @PostId = 1, @RequesterUaId = 1011;
        THROW 51095, N'FAIL 7: Khong chan xoa bai dang da co binh luan.', 1;
    END TRY
    BEGIN CATCH
        IF ERROR_NUMBER() = 51026
            PRINT N'PASS 7: Chan xoa bai dang da co binh luan de bao toan lich su (51026).';
        ELSE THROW;
    END CATCH;

    -- 8. Kiểm tra DELETE thành công: Tác giả (ua_id = 1001) xóa bài demo vừa tạo (chưa có bình luận)
    DECLARE @del_out TABLE (post_id INT, result_message NVARCHAR(200));
    INSERT INTO @del_out
    EXEC dbo.usp_Post_Delete @PostId = @demo_post_id, @RequesterUaId = 1001;
    SET @demo_post_id = NULL;
    PRINT N'PASS 8: DELETE thanh cong bai dang chua co binh luan (da don sach du lieu demo).';

    PRINT N'=== [TV1 - MỤC 2.1] HOÀN TẤT KIỂM THỬ 8/8 CASE THÀNH CÔNG ===';
END TRY
BEGIN CATCH
    PRINT N'DEMO TV1 GAP LOI: ' + ERROR_MESSAGE();
    IF XACT_STATE() <> 0 ROLLBACK TRANSACTION;
    IF @demo_post_id IS NOT NULL
        DELETE FROM dbo.[POST] WHERE post_id = @demo_post_id;
    THROW;
END CATCH;
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
-- Điều kiện: đã chạy 01, 02 và 04 (Section TV3 tạo 3 trigger + hàm dbo.fn_tv3_ComputeFinalScore).
-- Kịch bản tự tạo 1 bài kiểm tra + 2 câu hỏi riêng, chạy các thao tác DML rồi kiểm tra
-- ATTEMPT.score (RB25) và TAKES_TEST.final_score (RB26) được trigger tính đúng.
-- Cuối kịch bản xóa toàn bộ dữ liệu demo, không ảnh hưởng dữ liệu mẫu và các Section khác.
USE [LMS_DB];
GO
SET NOCOUNT ON;

PRINT N'=== [TV3 - MỤC 2.2.2] BẮT ĐẦU KIỂM THỬ TRIGGER THUỘC TÍNH DẪN XUẤT ===';

DECLARE @student_id INT, @class_id INT;
DECLARE @test_id INT = NULL, @q1 INT = NULL, @q2 INT = NULL;
DECLARE @a1 INT = NULL, @a2 INT = NULL, @ans_q1_a2 INT = NULL;
DECLARE @score DECIMAL(5,2), @final DECIMAL(5,2);

-- Lấy 1 sinh viên đã đăng ký lớp để bài kiểm tra demo thuộc đúng lớp của sinh viên (RB3)
SELECT TOP (1) @student_id = e.student_id, @class_id = e.class_id
FROM dbo.[ENROLLS] AS e
ORDER BY e.student_id, e.class_id;

IF @student_id IS NULL
    THROW 52000, N'Can it nhat 1 dong ENROLLS de chay demo TV3.', 1;

BEGIN TRY
    -- Chuẩn bị: bài kiểm tra HIGHEST, tối đa 3 lần làm, và 2 câu hỏi tự luận
    INSERT INTO dbo.[TEST] (test_name, test_type, test_start, test_end, test_timer,
                            max_attempts, grading_method, class_id)
    VALUES (N'TV3 demo - thuoc tinh dan xuat', N'ONLINE',
            DATEADD(HOUR, -2, GETDATE()), DATEADD(HOUR, 2, GETDATE()), 60, 3, N'HIGHEST', @class_id);
    SET @test_id = CONVERT(INT, SCOPE_IDENTITY());

    INSERT INTO dbo.[QUESTION] (question_type, question_content, max_score)
    VALUES (N'ESSAY', N'TV3 demo - cau hoi 1', 5.00);
    SET @q1 = CONVERT(INT, SCOPE_IDENTITY());

    INSERT INTO dbo.[QUESTION] (question_type, question_content, max_score)
    VALUES (N'ESSAY', N'TV3 demo - cau hoi 2', 5.00);
    SET @q2 = CONVERT(INT, SCOPE_IDENTITY());

    INSERT INTO dbo.[CONTAINS_QUESTION] (test_id, question_id) VALUES (@test_id, @q1), (@test_id, @q2);

    -- CASE 1: Thêm lần làm 1 và cố ý nhập tay score = 9.99
    --         -> trigger đưa score về tổng câu trả lời (chưa có câu nào -> NULL)
    --         -> tự tạo dòng TAKES_TEST với final_score = NULL
    INSERT INTO dbo.[ATTEMPT] (attempt_index, start_time, score, student_id, test_id)
    VALUES (1, DATEADD(MINUTE, -90, GETDATE()), 9.99, @student_id, @test_id);
    SET @a1 = CONVERT(INT, SCOPE_IDENTITY());

    SELECT @score = score FROM dbo.[ATTEMPT] WHERE attempt_id = @a1;
    IF @score IS NULL
       AND EXISTS (SELECT 1 FROM dbo.[TAKES_TEST]
                   WHERE student_id = @student_id AND test_id = @test_id AND final_score IS NULL)
        PRINT N'PASS 1: Nhap tay score bi bo qua (NULL), TAKES_TEST tu tao voi final_score = NULL.';
    ELSE
        THROW 52001, N'FAIL 1: ATTEMPT.score / TAKES_TEST chua dung sau khi them lan lam.', 1;

    -- CASE 2: Chấm 2 câu của lần 1 (2.00 + 3.50) -> score = 5.50, final (HIGHEST) = 5.50
    INSERT INTO dbo.[STUDENT_ANSWER] (answer_text, upload_time, score_awarded, attempt_id, question_id)
    VALUES (N'Bai lam lan 1 - cau 1', DATEADD(MINUTE, -85, GETDATE()), 2.00, @a1, @q1),
           (N'Bai lam lan 1 - cau 2', DATEADD(MINUTE, -80, GETDATE()), 3.50, @a1, @q2);
    UPDATE dbo.[ATTEMPT] SET end_time = DATEADD(MINUTE, -75, GETDATE()) WHERE attempt_id = @a1;

    SELECT @score = score FROM dbo.[ATTEMPT] WHERE attempt_id = @a1;
    SELECT @final = final_score FROM dbo.[TAKES_TEST] WHERE student_id = @student_id AND test_id = @test_id;
    IF @score = 5.50 AND @final = 5.50
        PRINT N'PASS 2: INSERT cau tra loi -> ATTEMPT.score = 5.50, final_score (HIGHEST) = 5.50.';
    ELSE
        THROW 52002, N'FAIL 2: Ky vong score = 5.50 va final_score = 5.50.', 1;

    -- CASE 3: Lần làm 2 được 4.00 + 4.00 = 8.00 -> final (HIGHEST) = 8.00
    INSERT INTO dbo.[ATTEMPT] (attempt_index, start_time, student_id, test_id)
    VALUES (2, DATEADD(MINUTE, -60, GETDATE()), @student_id, @test_id);
    SET @a2 = CONVERT(INT, SCOPE_IDENTITY());

    INSERT INTO dbo.[STUDENT_ANSWER] (answer_text, upload_time, score_awarded, attempt_id, question_id)
    VALUES (N'Bai lam lan 2 - cau 1', DATEADD(MINUTE, -55, GETDATE()), 4.00, @a2, @q1);
    SET @ans_q1_a2 = CONVERT(INT, SCOPE_IDENTITY());
    INSERT INTO dbo.[STUDENT_ANSWER] (answer_text, upload_time, score_awarded, attempt_id, question_id)
    VALUES (N'Bai lam lan 2 - cau 2', DATEADD(MINUTE, -50, GETDATE()), 4.00, @a2, @q2);

    SELECT @score = score FROM dbo.[ATTEMPT] WHERE attempt_id = @a2;
    SELECT @final = final_score FROM dbo.[TAKES_TEST] WHERE student_id = @student_id AND test_id = @test_id;
    IF @score = 8.00 AND @final = 8.00
        PRINT N'PASS 3: Lan 2 = 8.00 -> final_score (HIGHEST) = MAX(5.50, 8.00) = 8.00.';
    ELSE
        THROW 52003, N'FAIL 3: Ky vong score lan 2 = 8.00 va final_score = 8.00.', 1;

    -- CASE 4: Giảng viên chấm lại câu 1 của lần 2: 4.00 -> 1.00
    --         -> lần 2 = 5.00, final (HIGHEST) = MAX(5.50, 5.00) = 5.50
    UPDATE dbo.[STUDENT_ANSWER] SET score_awarded = 1.00 WHERE ans_id = @ans_q1_a2;

    SELECT @score = score FROM dbo.[ATTEMPT] WHERE attempt_id = @a2;
    SELECT @final = final_score FROM dbo.[TAKES_TEST] WHERE student_id = @student_id AND test_id = @test_id;
    IF @score = 5.00 AND @final = 5.50
        PRINT N'PASS 4: UPDATE score_awarded -> lan 2 = 5.00, final_score quay ve 5.50.';
    ELSE
        THROW 52004, N'FAIL 4: Ky vong score lan 2 = 5.00 va final_score = 5.50.', 1;

    -- CASE 5: Cố ý sửa tay ATTEMPT.score = 10.00 -> trigger đưa về 5.00, final không đổi
    UPDATE dbo.[ATTEMPT] SET score = 10.00 WHERE attempt_id = @a2;

    SELECT @score = score FROM dbo.[ATTEMPT] WHERE attempt_id = @a2;
    SELECT @final = final_score FROM dbo.[TAKES_TEST] WHERE student_id = @student_id AND test_id = @test_id;
    IF @score = 5.00 AND @final = 5.50
        PRINT N'PASS 5: Sua tay ATTEMPT.score bi tinh lai = 5.00 (khong nhap truc tiep duoc).';
    ELSE
        THROW 52005, N'FAIL 5: ATTEMPT.score bi sua tay ma khong duoc tinh lai.', 1;

    -- CASE 6: Đổi grading_method -> final_score tính lại theo phương thức mới
    --         (lần 1 = 5.50, lần 2 = 5.00)
    UPDATE dbo.[TEST] SET grading_method = N'AVERAGE' WHERE test_id = @test_id;
    SELECT @final = final_score FROM dbo.[TAKES_TEST] WHERE student_id = @student_id AND test_id = @test_id;
    IF @final = 5.25 PRINT N'PASS 6a: AVERAGE -> (5.50 + 5.00) / 2 = 5.25.';
    ELSE THROW 52006, N'FAIL 6a: Ky vong final_score AVERAGE = 5.25.', 1;

    UPDATE dbo.[TEST] SET grading_method = N'FIRST' WHERE test_id = @test_id;
    SELECT @final = final_score FROM dbo.[TAKES_TEST] WHERE student_id = @student_id AND test_id = @test_id;
    IF @final = 5.50 PRINT N'PASS 6b: FIRST -> lan 1 = 5.50.';
    ELSE THROW 52007, N'FAIL 6b: Ky vong final_score FIRST = 5.50.', 1;

    UPDATE dbo.[TEST] SET grading_method = N'LATEST' WHERE test_id = @test_id;
    SELECT @final = final_score FROM dbo.[TAKES_TEST] WHERE student_id = @student_id AND test_id = @test_id;
    IF @final = 5.00 PRINT N'PASS 6c: LATEST -> lan 2 = 5.00.';
    ELSE THROW 52008, N'FAIL 6c: Ky vong final_score LATEST = 5.00.', 1;

    -- CASE 7: Xóa 1 câu trả lời của lần 2 (câu 2 = 4.00) -> lần 2 = 1.00, final (LATEST) = 1.00
    DELETE FROM dbo.[STUDENT_ANSWER] WHERE attempt_id = @a2 AND question_id = @q2;

    SELECT @score = score FROM dbo.[ATTEMPT] WHERE attempt_id = @a2;
    SELECT @final = final_score FROM dbo.[TAKES_TEST] WHERE student_id = @student_id AND test_id = @test_id;
    IF @score = 1.00 AND @final = 1.00
        PRINT N'PASS 7: DELETE cau tra loi -> lan 2 = 1.00, final_score (LATEST) = 1.00.';
    ELSE
        THROW 52009, N'FAIL 7: Ky vong score lan 2 = 1.00 va final_score = 1.00.', 1;

    -- Bảng minh họa trực quan trước khi xóa lần làm 2
    SELECT a.attempt_id, a.attempt_index, a.score AS attempt_score,
           (SELECT SUM(sa.score_awarded) FROM dbo.[STUDENT_ANSWER] AS sa
            WHERE sa.attempt_id = a.attempt_id) AS tong_diem_cau_tra_loi
    FROM dbo.[ATTEMPT] AS a
    WHERE a.test_id = @test_id
    ORDER BY a.attempt_index;

    -- CASE 8: Xóa lần làm 2 -> chỉ còn lần 1, final (LATEST) = 5.50
    DELETE FROM dbo.[STUDENT_ANSWER] WHERE attempt_id = @a2;
    DELETE FROM dbo.[ATTEMPT] WHERE attempt_id = @a2;
    SET @a2 = NULL;

    SELECT @final = final_score FROM dbo.[TAKES_TEST] WHERE student_id = @student_id AND test_id = @test_id;
    IF @final = 5.50
        PRINT N'PASS 8: DELETE lan lam 2 -> final_score (LATEST) = lan 1 = 5.50.';
    ELSE
        THROW 52010, N'FAIL 8: Ky vong final_score = 5.50 sau khi xoa lan 2.', 1;

    SELECT tt.student_id, tt.test_id, t.grading_method, tt.final_score
    FROM dbo.[TAKES_TEST] AS tt
    INNER JOIN dbo.[TEST] AS t ON t.test_id = tt.test_id
    WHERE tt.test_id = @test_id;

    -- Dọn dữ liệu demo (TAKES_TEST, CONTAINS_QUESTION tự xóa theo ON DELETE CASCADE của TEST/QUESTION)
    DELETE FROM dbo.[STUDENT_ANSWER] WHERE question_id IN (@q1, @q2);
    DELETE FROM dbo.[ATTEMPT] WHERE test_id = @test_id;
    DELETE FROM dbo.[TAKES_TEST] WHERE test_id = @test_id;
    DELETE FROM dbo.[TEST] WHERE test_id = @test_id;
    DELETE FROM dbo.[QUESTION] WHERE question_id IN (@q1, @q2);
    SET @test_id = NULL;

    PRINT N'=== [TV3 - MỤC 2.2.2] HOAN TAT: 8/8 PASS, da xoa du lieu demo. ===';
END TRY
BEGIN CATCH
    PRINT N'DEMO TV3 GAP LOI: ' + ERROR_MESSAGE();
    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;

    IF @q1 IS NOT NULL OR @q2 IS NOT NULL
        DELETE FROM dbo.[STUDENT_ANSWER] WHERE question_id IN (@q1, @q2);
    IF @test_id IS NOT NULL
    BEGIN
        DELETE FROM dbo.[ATTEMPT] WHERE test_id = @test_id;
        DELETE FROM dbo.[TAKES_TEST] WHERE test_id = @test_id;
        DELETE FROM dbo.[TEST] WHERE test_id = @test_id;
    END;
    IF @q1 IS NOT NULL OR @q2 IS NOT NULL
        DELETE FROM dbo.[QUESTION] WHERE question_id IN (@q1, @q2);
    THROW;
END CATCH;
GO

-- =================================================================================
-- PHẦN CỦA TV4: KIỂM THỬ MỤC 2.3 - 2 THỦ TỤC TRUY VẤN DỮ LIỆU
-- Quy ước: TV4 CHỈ VIẾT TRONG KHUNG NÀY, KHÔNG SỬA RA NGOÀI KHUNG
-- =================================================================================
USE [LMS_DB];
GO
SET NOCOUNT ON;

PRINT N'=== [TV4 - MỤC 2.3] BẮT ĐẦU KIỂM THỬ 2 THỦ TỤC TRUY VẤN ===';
-- Điều kiện: đã chạy 01 (tạo bảng), 02 (dữ liệu mẫu, gồm Section TV4 và TV5) và 05 (tạo thủ tục).
-- Ngày truyền theo dạng YYYYMMDD (không phụ thuộc ngôn ngữ/DATEFORMAT của SQL Server).
-- Dữ liệu bài kiểm tra lấy từ Section TV4 của 02_seed_data.sql: 6 bài, 3 lớp đầu tiên trong CLASS.
GO

-- =================================================================================
-- PHẦN 1. KIỂM THỬ TỰ ĐỘNG (PASS/FAIL) - số dòng trả về của dbo.usp_Test_Search
-- =================================================================================
IF OBJECT_ID('tempdb..#s1') IS NOT NULL DROP TABLE #s1;
CREATE TABLE #s1 (
    test_id INT, test_name NVARCHAR(200), test_type NVARCHAR(30), class_name NVARCHAR(100),
    subject_name NVARCHAR(150), chapter_name NVARCHAR(200), test_start DATETIME, test_end DATETIME,
    test_timer INT, max_attempts INT, grading_method NVARCHAR(10),
    so_cau_hoi INT, tong_diem_toi_da DECIMAL(10,2)
);

DECLARE @c1 INT = (SELECT TOP (1) class_id FROM dbo.[CLASS] ORDER BY class_id);
DECLARE @n  INT;

-- A1. Không lọc -> đủ các bài kiểm tra trong hệ thống (>= 6)
INSERT INTO #s1 EXEC dbo.usp_Test_Search;
SELECT @n = COUNT(*) FROM #s1; TRUNCATE TABLE #s1;
IF @n >= 6 PRINT N'PASS [Thủ tục 1 - A1]: Không lọc, trả về ' + CONVERT(NVARCHAR(10), @n) + N' bài kiểm tra.';
ELSE THROW 53001, N'FAIL [Thủ tục 1 - A1]: Kỳ vọng >= 6 bài kiểm tra.', 1;

-- A2. Lọc theo lớp đầu tiên -> 2 bài (Quiz chương 1, Quiz chương 2)
INSERT INTO #s1 EXEC dbo.usp_Test_Search @class_id = @c1;
SELECT @n = COUNT(*) FROM #s1; TRUNCATE TABLE #s1;
IF @n = 2 PRINT N'PASS [Thủ tục 1 - A2]: Lọc theo lớp -> 2 bài.';
ELSE THROW 53002, N'FAIL [Thủ tục 1 - A2]: Kỳ vọng 2 bài của lớp đầu tiên.', 1;

-- A3. Lọc theo hình thức nộp tập tin -> 1 bài
INSERT INTO #s1 EXEC dbo.usp_Test_Search @test_type = N'FILE_SUBMISSION';
SELECT @n = COUNT(*) FROM #s1; TRUNCATE TABLE #s1;
IF @n = 1 PRINT N'PASS [Thủ tục 1 - A3]: Lọc hình thức FILE_SUBMISSION -> 1 bài.';
ELSE THROW 53003, N'FAIL [Thủ tục 1 - A3]: Kỳ vọng 1 bài nộp tập tin.', 1;

-- A4. Lọc theo phương thức tính điểm AVERAGE + từ khóa "Quiz" -> 1 bài
INSERT INTO #s1 EXEC dbo.usp_Test_Search @grading_method = N'AVERAGE', @keyword = N'Quiz';
SELECT @n = COUNT(*) FROM #s1; TRUNCATE TABLE #s1;
IF @n = 1 PRINT N'PASS [Thủ tục 1 - A4]: AVERAGE + từ khóa "Quiz" -> 1 bài.';
ELSE THROW 53004, N'FAIL [Thủ tục 1 - A4]: Kỳ vọng 1 bài.', 1;

-- A5. Lọc theo khoảng thời gian 01/10/2026 - 10/11/2026 -> 4 bài (bài ngày 10/11 vẫn được tính)
INSERT INTO #s1 EXEC dbo.usp_Test_Search @from_date = '20261001', @to_date = '20261110';
SELECT @n = COUNT(*) FROM #s1; TRUNCATE TABLE #s1;
IF @n = 4 PRINT N'PASS [Thủ tục 1 - A5]: Khoảng 01/10 - 10/11/2026 -> 4 bài.';
ELSE THROW 53005, N'FAIL [Thủ tục 1 - A5]: Kỳ vọng 4 bài trong khoảng thời gian.', 1;

-- A6. Kết hợp nhiều điều kiện -> 1 bài (Quiz chương 1)
INSERT INTO #s1 EXEC dbo.usp_Test_Search
    @class_id = @c1, @test_type = N'ONLINE', @grading_method = N'HIGHEST',
    @from_date = '20260901', @to_date = '20260930';
SELECT @n = COUNT(*) FROM #s1; TRUNCATE TABLE #s1;
IF @n = 1 PRINT N'PASS [Thủ tục 1 - A6]: Kết hợp lớp + hình thức + cách tính điểm + tháng 9 -> 1 bài.';
ELSE THROW 53006, N'FAIL [Thủ tục 1 - A6]: Kỳ vọng 1 bài.', 1;

-- A7. Trường hợp biên: mã lớp không tồn tại / từ khóa không khớp -> 0 dòng, không báo lỗi
INSERT INTO #s1 EXEC dbo.usp_Test_Search @class_id = 999999;
SELECT @n = COUNT(*) FROM #s1; TRUNCATE TABLE #s1;
IF @n = 0 PRINT N'PASS [Thủ tục 1 - A7a]: Mã lớp không tồn tại -> 0 dòng.';
ELSE THROW 53007, N'FAIL [Thủ tục 1 - A7a]: Kỳ vọng 0 dòng.', 1;

INSERT INTO #s1 EXEC dbo.usp_Test_Search @keyword = N'không có bài này';
SELECT @n = COUNT(*) FROM #s1; TRUNCATE TABLE #s1;
IF @n = 0 PRINT N'PASS [Thủ tục 1 - A7b]: Từ khóa không khớp -> 0 dòng.';
ELSE THROW 53008, N'FAIL [Thủ tục 1 - A7b]: Kỳ vọng 0 dòng.', 1;

-- A8. Trường hợp biên: ngày bắt đầu sau ngày kết thúc -> 0 dòng, không báo lỗi
INSERT INTO #s1 EXEC dbo.usp_Test_Search @from_date = '20261231', @to_date = '20260101';
SELECT @n = COUNT(*) FROM #s1; TRUNCATE TABLE #s1;
IF @n = 0 PRINT N'PASS [Thủ tục 1 - A8]: Ngày đảo ngược -> 0 dòng.';
ELSE THROW 53009, N'FAIL [Thủ tục 1 - A8]: Kỳ vọng 0 dòng.', 1;

DROP TABLE #s1;
GO

-- =================================================================================
-- PHẦN 2. KIỂM THỬ TỰ ĐỘNG (PASS/FAIL) - dbo.usp_Test_ScoreStatistics
--   Phụ thuộc dữ liệu ATTEMPT của TV5. Kiểm tra theo tính chất của kết quả
--   (thang điểm mỗi bài khác nhau nên không so với một con số cố định).
-- =================================================================================
IF OBJECT_ID('tempdb..#s2') IS NOT NULL DROP TABLE #s2;
CREATE TABLE #s2 (
    test_id INT, test_name NVARCHAR(200), class_name NVARCHAR(100), grading_method NVARCHAR(10),
    so_lan_lam INT, so_sinh_vien INT, diem_trung_binh DECIMAL(5,2),
    diem_cao_nhat DECIMAL(5,2), diem_thap_nhat DECIMAL(5,2), phut_lam_bai_tb INT
);

DECLARE @c1 INT = (SELECT TOP (1) class_id FROM dbo.[CLASS] ORDER BY class_id);
DECLARE @n1 INT, @n INT;

-- B1. Mặc định: có ít nhất 1 bài có lần làm đã nộp
INSERT INTO #s2 EXEC dbo.usp_Test_ScoreStatistics;
SELECT @n1 = COUNT(*) FROM #s2;
IF @n1 >= 1 PRINT N'PASS [Thủ tục 2 - B1]: Mặc định trả về ' + CONVERT(NVARCHAR(10), @n1) + N' bài có kết quả.';
ELSE THROW 53011, N'FAIL [Thủ tục 2 - B1]: Kỳ vọng có ít nhất 1 bài (kiểm tra dữ liệu ATTEMPT của TV5).', 1;

-- B1'. Đối chiếu số liệu với phép tính thủ công trên bảng ATTEMPT (đếm, trung bình, lớn nhất, nhỏ nhất)
IF EXISTS (
    SELECT 1
    FROM #s2 AS r
    CROSS APPLY (
        SELECT COUNT(*) AS c, CAST(AVG(a.score) AS DECIMAL(5,2)) AS av, MAX(a.score) AS mx, MIN(a.score) AS mn
        FROM dbo.[ATTEMPT] AS a
        WHERE a.test_id = r.test_id AND a.end_time IS NOT NULL AND a.score IS NOT NULL
    ) AS x
    WHERE x.c <> r.so_lan_lam OR x.av <> r.diem_trung_binh OR x.mx <> r.diem_cao_nhat OR x.mn <> r.diem_thap_nhat
)
    THROW 53012, N'FAIL [Thủ tục 2 - B1]: Số liệu thống kê không khớp tính thủ công.', 1;
ELSE
    PRINT N'PASS [Thủ tục 2 - B1b]: Số lần làm, điểm TB, cao nhất, thấp nhất khớp tính thủ công.';
TRUNCATE TABLE #s2;

-- B2. Lọc theo lớp: số bài không vượt quá khi không lọc
INSERT INTO #s2 EXEC dbo.usp_Test_ScoreStatistics @class_id = @c1;
SELECT @n = COUNT(*) FROM #s2; TRUNCATE TABLE #s2;
IF @n <= @n1 PRINT N'PASS [Thủ tục 2 - B2]: Lọc theo lớp -> ' + CONVERT(NVARCHAR(10), @n) + N' bài (<= không lọc).';
ELSE THROW 53013, N'FAIL [Thủ tục 2 - B2]: Số bài lọc theo lớp vượt quá số bài khi không lọc.', 1;

-- B3. HAVING so_lan_lam >= 3: mọi dòng trả về đều có từ 3 lần làm trở lên
INSERT INTO #s2 EXEC dbo.usp_Test_ScoreStatistics @min_attempts = 3;
IF EXISTS (SELECT 1 FROM #s2 WHERE so_lan_lam < 3)
    THROW 53014, N'FAIL [Thủ tục 2 - B3]: Có bài dưới 3 lần làm vẫn được trả về.', 1;
ELSE
    PRINT N'PASS [Thủ tục 2 - B3]: HAVING số lần làm >= 3 hoạt động đúng.';
TRUNCATE TABLE #s2;

-- B4. HAVING diem_trung_binh >= 7: mọi dòng trả về đều có điểm trung bình >= 7
INSERT INTO #s2 EXEC dbo.usp_Test_ScoreStatistics @min_avg_score = 7.00;
IF EXISTS (SELECT 1 FROM #s2 WHERE diem_trung_binh < 7.00)
    THROW 53015, N'FAIL [Thủ tục 2 - B4]: Có bài điểm trung bình dưới 7 vẫn được trả về.', 1;
ELSE
    PRINT N'PASS [Thủ tục 2 - B4]: HAVING điểm trung bình >= 7 hoạt động đúng.';
TRUNCATE TABLE #s2;

-- B5. Trường hợp biên: ngưỡng quá cao -> 0 dòng, không báo lỗi
INSERT INTO #s2 EXEC dbo.usp_Test_ScoreStatistics @min_attempts = 100, @min_avg_score = 100.00;
SELECT @n = COUNT(*) FROM #s2;
IF @n = 0 PRINT N'PASS [Thủ tục 2 - B5]: Ngưỡng quá cao -> 0 dòng.';
ELSE THROW 53016, N'FAIL [Thủ tục 2 - B5]: Kỳ vọng 0 dòng.', 1;

DROP TABLE #s2;
GO

-- =================================================================================
-- PHẦN 3. MINH HỌA TRỰC QUAN KHI BÁO CÁO (chạy từng lệnh để cho giảng viên xem kết quả)
-- =================================================================================

-- ---------- THỦ TỤC 1: dbo.usp_Test_Search ----------
PRINT N'--- A1. Không lọc: tất cả bài kiểm tra, mới nhất trước ---';
EXEC dbo.usp_Test_Search;
GO

PRINT N'--- A2. Lọc theo lớp đầu tiên ---';
DECLARE @c1 INT = (SELECT TOP (1) class_id FROM dbo.[CLASS] ORDER BY class_id);
EXEC dbo.usp_Test_Search @class_id = @c1;
GO

PRINT N'--- A3. Lọc theo hình thức nộp tập tin ---';
EXEC dbo.usp_Test_Search @test_type = N'FILE_SUBMISSION';
GO

PRINT N'--- A4. Lọc theo cách tính điểm AVERAGE + từ khóa "Quiz" ---';
EXEC dbo.usp_Test_Search @grading_method = N'AVERAGE', @keyword = N'Quiz';
GO

PRINT N'--- A5. Lọc theo khoảng thời gian 01/10/2026 - 10/11/2026 ---';
EXEC dbo.usp_Test_Search @from_date = '20261001', @to_date = '20261110';
GO

PRINT N'--- A6. Kết hợp nhiều điều kiện ---';
DECLARE @c1 INT = (SELECT TOP (1) class_id FROM dbo.[CLASS] ORDER BY class_id);
EXEC dbo.usp_Test_Search @class_id = @c1, @test_type = N'ONLINE', @grading_method = N'HIGHEST',
                         @from_date = '20260901', @to_date = '20260930';
GO

PRINT N'--- A7. Trường hợp biên: không có kết quả (mã lớp không tồn tại) ---';
EXEC dbo.usp_Test_Search @class_id = 999999;
GO

-- ---------- THỦ TỤC 2: dbo.usp_Test_ScoreStatistics ----------
PRINT N'--- B1. Thống kê mặc định ---';
EXEC dbo.usp_Test_ScoreStatistics;
GO

PRINT N'--- B2. Thống kê theo lớp đầu tiên ---';
DECLARE @c1 INT = (SELECT TOP (1) class_id FROM dbo.[CLASS] ORDER BY class_id);
EXEC dbo.usp_Test_ScoreStatistics @class_id = @c1;
GO

PRINT N'--- B3. HAVING: chỉ các bài có từ 3 lần làm trở lên ---';
EXEC dbo.usp_Test_ScoreStatistics @min_attempts = 3;
GO

PRINT N'--- B4. HAVING: chỉ các bài có điểm trung bình >= 7 ---';
EXEC dbo.usp_Test_ScoreStatistics @min_avg_score = 7.00;
GO

PRINT N'--- B5. Kết hợp khoảng thời gian + HAVING ---';
EXEC dbo.usp_Test_ScoreStatistics @from_date = '20261001', @to_date = '20261231',
                                  @min_attempts = 2, @min_avg_score = 5.00;
GO

PRINT N'--- B6. Trường hợp biên: ngưỡng quá cao -> không có dòng nào ---';
EXEC dbo.usp_Test_ScoreStatistics @min_attempts = 100, @min_avg_score = 100.00;
GO

PRINT N'=== [TV4 - MỤC 2.3] HOÀN TẤT KIỂM THỬ ===';
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
