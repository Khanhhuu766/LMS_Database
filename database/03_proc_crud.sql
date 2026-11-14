-- ============================================================================
-- BTL2 - He CSDL | De tai: He thong quan ly hoc tap (LMS)
-- File : database/03_proc_crud.sql
-- DBMS : Microsoft SQL Server (T-SQL)
-- TV1  : Hoang Ha
-- Muc  : 2.1 - INSERT / UPDATE / DELETE tren bang [POST]
--
-- Chinh sach nghiep vu duoc ap dung:
--   1. Nguoi tao bai dang phai la USER ton tai (tham so ua_id).
--   2. Neu bai dang gan voi mot CLASS, nguoi tao phai la giang vien
--      duoc phan cong lop do hoac sinh vien da dang ky lop va duoc phep
--      thao luan (ENROLLS.is_allowed_to_discuss = 1).
--   3. Chi nguoi tao bai dang moi duoc UPDATE / DELETE qua cac procedure nay.
--   4. Chi cho phep DELETE bai dang khi bai dang chua co COMMENT, de bao toan
--      lich su thao luan. FK fk_comment_post cung chan xoa truc tiep neu con comment.
--   5. UPDATE chi sua noi dung bai dang; khong doi tac gia, lop hoc hoac thoi diem tao.
--
-- Luu y:
--   - post_start duoc de SQL Server tu gan theo DEFAULT (GETDATE()).
--   - class_id = NULL duoc xem la bai dang chung, khong gan voi lop hoc.
--   - Goi cac procedure bang EXEC; ket qua tra ve qua mot result set.
-- ============================================================================

USE [LMS_DB];
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

-- ----------------------------------------------------------------------------
-- 1. INSERT: Tao bai dang moi
-- ----------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE dbo.usp_Post_Insert
    @PostName        NVARCHAR(MAX),
    @UaId            INT,
    @PostDescription NVARCHAR(MAX) = NULL,
    @ClassId         INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @CleanPostName NVARCHAR(MAX) = NULLIF(LTRIM(RTRIM(@PostName)), N'');
    DECLARE @CleanDescription NVARCHAR(MAX) = NULLIF(LTRIM(RTRIM(@PostDescription)), N'');
    DECLARE @UserId INT = NULL;
    DECLARE @NewPostId INT;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Validate ten bai dang (POST.post_name NVARCHAR(200) NOT NULL).
        IF @CleanPostName IS NULL
            THROW 51001, N'Ten bai dang khong duoc de trong.', 1;

        IF LEN(@CleanPostName) > 200
            THROW 51002, N'Ten bai dang khong duoc vuot qua 200 ky tu.', 1;

        -- Validate tac gia.
        IF @UaId IS NULL OR @UaId <= 0
            THROW 51003, N'ua_id phai la so nguyen duong va phai duoc cung cap.', 1;

        SELECT @UserId = u.user_id
        FROM dbo.[USER] AS u
        WHERE u.ua_id = @UaId;

        IF @UserId IS NULL
            THROW 51004, N'Khong tim thay nguoi dung tuong ung voi ua_id da cung cap.', 1;

        -- Neu gan bai dang vao lop, tac gia phai co quyen tham gia lop do.
        IF @ClassId IS NOT NULL
        BEGIN
            IF @ClassId <= 0
                THROW 51005, N'class_id phai la so nguyen duong hoac NULL.', 1;

            IF NOT EXISTS (
                SELECT 1
                FROM dbo.[CLASS] AS c
                WHERE c.class_id = @ClassId
            )
                THROW 51006, N'Lop hoc khong ton tai; khong the tao bai dang cho lop nay.', 1;

            IF NOT EXISTS (
                SELECT 1
                FROM dbo.[CLASS] AS c
                WHERE c.class_id = @ClassId
                  AND (
                        c.lecturer_id = @UserId
                        OR EXISTS (
                            SELECT 1
                            FROM dbo.[ENROLLS] AS e
                            WHERE e.class_id = c.class_id
                              AND e.student_id = @UserId
                              AND e.is_allowed_to_discuss = 1
                        )
                  )
            )
                THROW 51007, N'Nguoi dung khong co quyen tao bai dang trong lop hoc nay. Sinh vien phai dang ky lop va duoc phep thao luan; giang vien phai duoc phan cong lop.', 1;
        END;

        INSERT INTO dbo.[POST]
            (post_name, post_description, ua_id, class_id)
        VALUES
            (@CleanPostName, @CleanDescription, @UaId, @ClassId);

        SET @NewPostId = CONVERT(INT, SCOPE_IDENTITY());

        COMMIT TRANSACTION;

        SELECT
            @NewPostId AS post_id,
            N'Tao bai dang thanh cong.' AS result_message;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

-- ----------------------------------------------------------------------------
-- 2. UPDATE: Sua noi dung bai dang do chinh tac gia tao
-- ----------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE dbo.usp_Post_Update
    @PostId          INT,
    @RequesterUaId   INT,
    @PostName        NVARCHAR(MAX),
    @PostDescription NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @CleanPostName NVARCHAR(MAX) = NULLIF(LTRIM(RTRIM(@PostName)), N'');
    DECLARE @CleanDescription NVARCHAR(MAX) = NULLIF(LTRIM(RTRIM(@PostDescription)), N'');
    DECLARE @AuthorUaId INT = NULL;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF @PostId IS NULL OR @PostId <= 0
            THROW 51011, N'post_id phai la so nguyen duong.', 1;

        IF @RequesterUaId IS NULL OR @RequesterUaId <= 0
            THROW 51012, N'ua_id cua nguoi yeu cau phai la so nguyen duong.', 1;

        IF @CleanPostName IS NULL
            THROW 51013, N'Ten bai dang khong duoc de trong.', 1;

        IF LEN(@CleanPostName) > 200
            THROW 51014, N'Ten bai dang khong duoc vuot qua 200 ky tu.', 1;

        IF NOT EXISTS (
            SELECT 1
            FROM dbo.[POST]
            WHERE post_id = @PostId
        )
            THROW 51015, N'Bai dang khong ton tai; khong the cap nhat.', 1;

        SELECT @AuthorUaId = p.ua_id
        FROM dbo.[POST] AS p
        WHERE p.post_id = @PostId;

        IF @AuthorUaId IS NULL
            THROW 51016, N'Bai dang khong con tac gia hop le; khong the cap nhat bang tai khoan nguoi dung.', 1;

        IF @AuthorUaId <> @RequesterUaId
            THROW 51017, N'Ban khong phai tac gia cua bai dang; khong co quyen cap nhat.', 1;

        -- Chi cap nhat noi dung. Tac gia, lop hoc va thoi diem tao duoc giu nguyen.
        UPDATE dbo.[POST]
        SET post_name = @CleanPostName,
            post_description = @CleanDescription
        WHERE post_id = @PostId;

        COMMIT TRANSACTION;

        SELECT
            @PostId AS post_id,
            N'Cap nhat bai dang thanh cong.' AS result_message;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

-- ----------------------------------------------------------------------------
-- 3. DELETE: Xoa bai dang khi nguoi goi la tac gia va bai dang chua co comment
-- ----------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE dbo.usp_Post_Delete
    @PostId        INT,
    @RequesterUaId INT
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @AuthorUaId INT = NULL;

    BEGIN TRY
        BEGIN TRANSACTION;

        IF @PostId IS NULL OR @PostId <= 0
            THROW 51021, N'post_id phai la so nguyen duong.', 1;

        IF @RequesterUaId IS NULL OR @RequesterUaId <= 0
            THROW 51022, N'ua_id cua nguoi yeu cau phai la so nguyen duong.', 1;

        IF NOT EXISTS (
            SELECT 1
            FROM dbo.[POST]
            WHERE post_id = @PostId
        )
            THROW 51023, N'Bai dang khong ton tai; khong the xoa.', 1;

        SELECT @AuthorUaId = p.ua_id
        FROM dbo.[POST] AS p
        WHERE p.post_id = @PostId;

        IF @AuthorUaId IS NULL
            THROW 51024, N'Bai dang khong con tac gia hop le; khong the xoa bang tai khoan nguoi dung.', 1;

        IF @AuthorUaId <> @RequesterUaId
            THROW 51025, N'Ban khong phai tac gia cua bai dang; khong co quyen xoa.', 1;

        -- Bao toan lich su thao luan: khong xoa bai dang da co binh luan.
        -- HOLDLOCK giu khoa den het transaction, giam nguy co co comment moi
        -- chen vao giua luc kiem tra va luc xoa bai dang.
        IF EXISTS (
            SELECT 1
            FROM dbo.[COMMENT] WITH (UPDLOCK, HOLDLOCK)
            WHERE post_id = @PostId
        )
            THROW 51026, N'Khong the xoa bai dang vi da co binh luan. Hay giu lai bai dang de bao toan lich su thao luan.', 1;

        DELETE FROM dbo.[POST]
        WHERE post_id = @PostId;

        COMMIT TRANSACTION;

        SELECT
            @PostId AS post_id,
            N'Xoa bai dang thanh cong.' AS result_message;
    END TRY
    BEGIN CATCH
        IF XACT_STATE() <> 0
            ROLLBACK TRANSACTION;
        THROW;
    END CATCH;
END;
GO

-- ============================================================================
-- Huong dan goi thu (chi chay sau khi da co USER / CLASS / ENROLLS phu hop):
--
-- INSERT:
-- EXEC dbo.usp_Post_Insert
--     @PostName = N'Thong bao tu lop hoc',
--     @UaId = 1001,
--     @PostDescription = N'Noi dung bai dang',
--     @ClassId = 1;
--
-- UPDATE (truyen NULL neu muon xoa mo ta):
-- EXEC dbo.usp_Post_Update
--     @PostId = 1,
--     @RequesterUaId = 1001,
--     @PostName = N'Ten bai dang moi',
--     @PostDescription = N'Mo ta moi';
--
-- DELETE (chi thanh cong neu bai dang chua co COMMENT):
-- EXEC dbo.usp_Post_Delete
--     @PostId = 1,
--     @RequesterUaId = 1001;
-- ============================================================================
