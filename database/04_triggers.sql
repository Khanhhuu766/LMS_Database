-- =================================================================================
-- MỤC 2.2: VIẾT 2 TRIGGER KIỂM TRA NGHIỆP VỤ VÀ TÍNH THUỘC TÍNH DẪN XUẤT
-- Người phụ trách Trigger 2.2.1 : [Điền tên thành viên]
-- Người phụ trách Trigger 2.2.2 : [Điền tên thành viên]
-- Yêu cầu đề bài :
--   [2.2.1] Ràng buộc nghiệp vụ:
--     - Chọn 1 ràng buộc nghiệp vụ không thể kiểm tra bằng lệnh CREATE TABLE (CHECK).
--     - Xác định rõ các thao tác DML (INSERT, UPDATE, DELETE) có thể gây vi phạm.
--     - Viết (các) trigger kiểm tra ràng buộc đó.
--   [2.2.2] Thuộc tính dẫn xuất:
--     - Chọn 1 thuộc tính dẫn xuất và xác định các thao tác DML làm thay đổi giá trị.
--     - Viết (các) trigger tự động tính toán và cập nhật giá trị cho thuộc tính này.
--     - Lưu ý: Nếu tính thuộc tính A có dùng thuộc tính dẫn xuất B thì phải tính B trước.
-- =================================================================================

-- =================================================================================
-- PHẦN CỦA TV2: MỤC 2.2.1 - TRIGGER KIỂM TRA RÀNG BUỘC NGHIỆP VỤ
-- Quy ước: TV2 CHỈ VIẾT TRONG KHUNG NÀY, KHÔNG SỬA RA NGOÀI KHUNG
-- =================================================================================
-- TODO
  USE [LMS_DB];
    GO

    CREATE OR ALTER TRIGGER dbo.trg_tv2_rb18_attempt_limit
    ON dbo.[ATTEMPT]
    AFTER INSERT, UPDATE
    AS
    BEGIN
        SET NOCOUNT ON;

        IF NOT EXISTS (SELECT 1 FROM inserted)
            RETURN;

        IF EXISTS
        (
            SELECT 1
            FROM
            (
                SELECT DISTINCT student_id, test_id
                FROM inserted
                WHERE student_id IS NOT NULL
                AND test_id IS NOT NULL
            ) AS affected
            INNER JOIN dbo.[TEST] AS t
                ON t.test_id = affected.test_id
            CROSS APPLY
            (
                SELECT COUNT_BIG(*) AS attempt_count
                FROM dbo.[ATTEMPT] AS a WITH (UPDLOCK, HOLDLOCK)
                WHERE a.student_id = affected.student_id
                AND a.test_id = affected.test_id
            ) AS counted
            WHERE counted.attempt_count > t.max_attempts
        )
        BEGIN
            THROW 50018,
                N'RB18: Sinh vien da vuot qua so lan lam bai toi da cua bai kiem tra.',
                1;
        END
    END;
    GO

    CREATE OR ALTER TRIGGER dbo.trg_tv2_rb18_test_max_attempts
    ON dbo.[TEST]
    AFTER UPDATE
    AS
    BEGIN
        SET NOCOUNT ON;

        IF NOT UPDATE(max_attempts)
            RETURN;

        IF EXISTS
        (
            SELECT 1
            FROM inserted AS t
            INNER JOIN dbo.[ATTEMPT] AS a WITH (UPDLOCK, HOLDLOCK)
                ON a.test_id = t.test_id
            WHERE a.student_id IS NOT NULL
            GROUP BY t.test_id, a.student_id, t.max_attempts
            HAVING COUNT_BIG(*) > t.max_attempts
        )
        BEGIN
            THROW 50019,
                N'RB18: Khong the giam max_attempts thap hon so lan lam bai da ton tai.',
                1;
        END
    END;
    GO

    SELECT name, is_disabled
    FROM sys.triggers
    WHERE name IN
    (
        N'trg_tv2_rb18_attempt_limit',
        N'trg_tv2_rb18_test_max_attempts'
    )
    ORDER BY name;
    GO


-- =================================================================================
-- PHẦN CỦA TV3: MỤC 2.2.2 - TRIGGER TÍNH GIÁ TRỊ THUỘC TÍNH DẪN XUẤT
-- Quy ước: TV3 CHỈ VIẾT TRONG KHUNG NÀY, KHÔNG SỬA RA NGOÀI KHUNG
-- =================================================================================
-- Người phụ trách: TV3 (Bảo Kiệt)
-- Thuộc tính dẫn xuất được chọn:
--   * RB26: TAKES_TEST.final_score - điểm chung cuộc của sinh viên cho một bài kiểm tra,
--           tính từ ATTEMPT.score theo TEST.grading_method:
--             HIGHEST = điểm cao nhất, AVERAGE = trung bình (làm tròn 2 số),
--             FIRST   = lần làm có attempt_index nhỏ nhất, LATEST = lần lớn nhất.
--           Chỉ tính các lần làm đã có điểm (score IS NOT NULL); chưa có lần nào -> NULL.
--   * RB25: ATTEMPT.score = SUM(STUDENT_ANSWER.score_awarded) của lần làm đó.
--           final_score dùng ATTEMPT.score (cũng là thuộc tính dẫn xuất) nên phải tính
--           ATTEMPT.score TRƯỚC, sau đó mới tính final_score.
--
-- Các thao tác DML làm thay đổi giá trị và trigger xử lý:
--   [STUDENT_ANSWER] INSERT / DELETE / UPDATE(score_awarded, attempt_id)
--        -> trg_tv3_answer_attempt_score : tính lại ATTEMPT.score
--           (lệnh UPDATE này kích hoạt tiếp trigger trên ATTEMPT -> tính final_score)
--   [ATTEMPT] INSERT / DELETE / UPDATE(score, student_id, test_id, attempt_index)
--        -> trg_tv3_attempt_final_score  : (1) ghi đè score nếu bị nhập tay sai tổng
--                                          (2) tính lại TAKES_TEST.final_score; nếu sinh
--                                              viên chưa có dòng TAKES_TEST thì tạo mới
--   [TEST] UPDATE(grading_method)
--        -> trg_tv3_test_final_score     : tính lại final_score của mọi sinh viên làm bài đó
-- Công thức dùng chung đặt trong hàm nội tuyến dbo.fn_tv3_ComputeFinalScore để 3 trigger
-- tính giống nhau và khớp với dbo.fn_CalculateStudentTestScore của TV5.
USE [LMS_DB];
GO

CREATE OR ALTER FUNCTION dbo.fn_tv3_ComputeFinalScore
(
    @student_id INT,
    @test_id    INT
)
RETURNS TABLE
AS
RETURN
    SELECT
        final_score = CONVERT(DECIMAL(5, 2),
            CASE t.grading_method
                WHEN N'HIGHEST' THEN agg.max_score
                WHEN N'AVERAGE' THEN ROUND(agg.sum_score / NULLIF(agg.scored_count, 0), 2)
                WHEN N'FIRST'   THEN first_a.score
                WHEN N'LATEST'  THEN last_a.score
            END),
        agg.scored_count
    FROM dbo.[TEST] AS t
    CROSS APPLY
    (
        SELECT COUNT(*)                            AS scored_count,
               MAX(a.score)                        AS max_score,
               SUM(CONVERT(DECIMAL(10, 2), a.score)) AS sum_score
        FROM dbo.[ATTEMPT] AS a
        WHERE a.student_id = @student_id
          AND a.test_id    = @test_id
          AND a.score IS NOT NULL
    ) AS agg
    OUTER APPLY
    (
        SELECT TOP (1) a.score
        FROM dbo.[ATTEMPT] AS a
        WHERE a.student_id = @student_id
          AND a.test_id    = @test_id
          AND a.score IS NOT NULL
        ORDER BY a.attempt_index ASC, a.attempt_id ASC
    ) AS first_a
    OUTER APPLY
    (
        SELECT TOP (1) a.score
        FROM dbo.[ATTEMPT] AS a
        WHERE a.student_id = @student_id
          AND a.test_id    = @test_id
          AND a.score IS NOT NULL
        ORDER BY a.attempt_index DESC, a.attempt_id DESC
    ) AS last_a
    WHERE t.test_id = @test_id;
GO

-- ---------------------------------------------------------------------------------
-- Trigger 1: STUDENT_ANSWER -> ATTEMPT.score (RB25)
-- ---------------------------------------------------------------------------------
CREATE OR ALTER TRIGGER dbo.trg_tv3_answer_attempt_score
ON dbo.[STUDENT_ANSWER]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM inserted) AND NOT EXISTS (SELECT 1 FROM deleted)
        RETURN;

    -- UPDATE không đụng tới điểm hoặc lần làm thì không cần tính lại
    IF EXISTS (SELECT 1 FROM inserted) AND EXISTS (SELECT 1 FROM deleted)
       AND NOT (UPDATE(score_awarded) OR UPDATE(attempt_id))
        RETURN;

    DECLARE @attempts TABLE (attempt_id INT PRIMARY KEY);

    INSERT INTO @attempts (attempt_id)
    SELECT attempt_id FROM inserted WHERE attempt_id IS NOT NULL
    UNION
    SELECT attempt_id FROM deleted  WHERE attempt_id IS NOT NULL;

    IF NOT EXISTS (SELECT 1 FROM @attempts)
        RETURN;

    -- Lệnh UPDATE này kích hoạt trg_tv3_attempt_final_score để tính tiếp final_score
    UPDATE a
    SET a.score = s.total_score
    FROM dbo.[ATTEMPT] AS a
    INNER JOIN @attempts AS x ON x.attempt_id = a.attempt_id
    CROSS APPLY
    (
        SELECT SUM(sa.score_awarded) AS total_score
        FROM dbo.[STUDENT_ANSWER] AS sa
        WHERE sa.attempt_id = a.attempt_id
    ) AS s
    WHERE EXISTS (SELECT a.score EXCEPT SELECT s.total_score);   -- chỉ cập nhật khi khác
END;
GO

-- ---------------------------------------------------------------------------------
-- Trigger 2: ATTEMPT -> (giữ đúng ATTEMPT.score) -> TAKES_TEST.final_score (RB25, RB26)
-- ---------------------------------------------------------------------------------
CREATE OR ALTER TRIGGER dbo.trg_tv3_attempt_final_score
ON dbo.[ATTEMPT]
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT EXISTS (SELECT 1 FROM inserted) AND NOT EXISTS (SELECT 1 FROM deleted)
        RETURN;

    -- (1) score là thuộc tính dẫn xuất, không nhập tay: luôn đưa về tổng điểm câu trả lời
    UPDATE a
    SET a.score = s.total_score
    FROM dbo.[ATTEMPT] AS a
    INNER JOIN inserted AS i ON i.attempt_id = a.attempt_id
    CROSS APPLY
    (
        SELECT SUM(sa.score_awarded) AS total_score
        FROM dbo.[STUDENT_ANSWER] AS sa
        WHERE sa.attempt_id = a.attempt_id
    ) AS s
    WHERE EXISTS (SELECT a.score EXCEPT SELECT s.total_score);

    -- (2) Các cặp (sinh viên, bài kiểm tra) bị ảnh hưởng (gồm cả giá trị cũ khi UPDATE/DELETE)
    DECLARE @pairs TABLE (student_id INT NOT NULL, test_id INT NOT NULL,
                          PRIMARY KEY (student_id, test_id));

    INSERT INTO @pairs (student_id, test_id)
    SELECT student_id, test_id FROM inserted
    WHERE student_id IS NOT NULL AND test_id IS NOT NULL
    UNION
    SELECT student_id, test_id FROM deleted
    WHERE student_id IS NOT NULL AND test_id IS NOT NULL;

    IF NOT EXISTS (SELECT 1 FROM @pairs)
        RETURN;

    UPDATE tt
    SET tt.final_score = c.final_score
    FROM dbo.[TAKES_TEST] AS tt
    INNER JOIN @pairs AS p
        ON p.student_id = tt.student_id AND p.test_id = tt.test_id
    CROSS APPLY dbo.fn_tv3_ComputeFinalScore(p.student_id, p.test_id) AS c
    WHERE EXISTS (SELECT tt.final_score EXCEPT SELECT c.final_score);

    -- Sinh viên bắt đầu làm bài mà chưa có dòng TAKES_TEST -> tạo dòng mới
    INSERT INTO dbo.[TAKES_TEST] (student_id, test_id, final_score)
    SELECT p.student_id, p.test_id, c.final_score
    FROM @pairs AS p
    CROSS APPLY dbo.fn_tv3_ComputeFinalScore(p.student_id, p.test_id) AS c
    WHERE NOT EXISTS (SELECT 1 FROM dbo.[TAKES_TEST] AS tt
                      WHERE tt.student_id = p.student_id AND tt.test_id = p.test_id)
      AND EXISTS (SELECT 1 FROM dbo.[ATTEMPT] AS a
                  WHERE a.student_id = p.student_id AND a.test_id = p.test_id)
      AND EXISTS (SELECT 1 FROM dbo.[STUDENT] AS s WHERE s.user_id = p.student_id);
END;
GO

-- ---------------------------------------------------------------------------------
-- Trigger 3: TEST.grading_method đổi -> tính lại TAKES_TEST.final_score (RB26)
-- ---------------------------------------------------------------------------------
CREATE OR ALTER TRIGGER dbo.trg_tv3_test_final_score
ON dbo.[TEST]
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF NOT UPDATE(grading_method)
        RETURN;

    DECLARE @tests TABLE (test_id INT PRIMARY KEY);

    INSERT INTO @tests (test_id)
    SELECT i.test_id
    FROM inserted AS i
    INNER JOIN deleted AS d ON d.test_id = i.test_id
    WHERE i.grading_method <> d.grading_method;

    IF NOT EXISTS (SELECT 1 FROM @tests)
        RETURN;

    UPDATE tt
    SET tt.final_score = c.final_score
    FROM dbo.[TAKES_TEST] AS tt
    INNER JOIN @tests AS x ON x.test_id = tt.test_id
    CROSS APPLY dbo.fn_tv3_ComputeFinalScore(tt.student_id, tt.test_id) AS c
    WHERE EXISTS (SELECT tt.final_score EXCEPT SELECT c.final_score);
END;
GO

-- Kiểm tra nhanh sau khi tạo: dữ liệu mẫu hiện có phải khớp công thức (kỳ vọng 0 dòng lệch)
SELECT name, is_disabled
FROM sys.triggers
WHERE name IN (N'trg_tv3_answer_attempt_score',
               N'trg_tv3_attempt_final_score',
               N'trg_tv3_test_final_score')
ORDER BY name;

SELECT N'ATTEMPT.score lệch'        AS kiem_tra, COUNT(*) AS so_dong_lech
FROM dbo.[ATTEMPT] AS a
CROSS APPLY (SELECT SUM(sa.score_awarded) AS total_score
             FROM dbo.[STUDENT_ANSWER] AS sa WHERE sa.attempt_id = a.attempt_id) AS s
WHERE EXISTS (SELECT a.score EXCEPT SELECT s.total_score)
UNION ALL
SELECT N'TAKES_TEST.final_score lệch', COUNT(*)
FROM dbo.[TAKES_TEST] AS tt
CROSS APPLY dbo.fn_tv3_ComputeFinalScore(tt.student_id, tt.test_id) AS c
WHERE EXISTS (SELECT tt.final_score EXCEPT SELECT c.final_score);
GO
