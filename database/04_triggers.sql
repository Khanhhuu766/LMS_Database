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
-- TODO
GO
