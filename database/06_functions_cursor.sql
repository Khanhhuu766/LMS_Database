-- =================================================================================
-- MỤC 2.4: VIẾT 2 HÀM (FUNCTION) TÍNH TOÁN SỬ DỤNG CON TRỎ
-- Người phụ trách Hàm 1 : TV5
-- Người phụ trách Hàm 2 : TV5
-- Yêu cầu đề bài :
--   1. Có tham số đầu vào và thực hiện kiểm tra tham số đầu vào hợp lệ.
--   2. Chứa câu lệnh truy vấn dữ liệu để lấy dữ liệu phục vụ tính toán.
--   3. Bắt buộc sử dụng CON TRỎ (CURSOR) kết hợp câu lệnh IF và/hoặc vòng lặp (LOOP/WHILE)
--      để duyệt và tính toán dữ liệu.
-- =================================================================================

USE [LMS_DB];
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

-- ---------------------------------------------------------------------------------
-- HÀM 1: Tính điểm số chung cuộc (final_score) của sinh viên cho một bài kiểm tra
-- (Hiện thực công thức RB26 theo TEST.grading_method: HIGHEST, AVERAGE, FIRST, LATEST)
-- Quy ước giá trị trả về:
--   * >= 0.00 : Điểm chung cuộc hợp lệ
--   * NULL    : Sinh viên hợp lệ nhưng chưa có lần làm bài nào được chấm điểm
--   * -1.00   : Tham số đầu vào không hợp lệ (NULL, <= 0, hoặc không tồn tại)
--   * -2.00   : Vi phạm RB3 (bài kiểm tra thuộc lớp mà sinh viên chưa đăng ký)
-- ---------------------------------------------------------------------------------
CREATE OR ALTER FUNCTION dbo.fn_CalculateStudentTestScore
(
    @StudentId INT,
    @TestId    INT
)
RETURNS DECIMAL(5, 2)
AS
BEGIN
    -- 1. Kiểm tra tham số đầu vào hợp lệ
    IF @StudentId IS NULL OR @StudentId <= 0 OR @TestId IS NULL OR @TestId <= 0
        RETURN -1.00;

    IF NOT EXISTS (SELECT 1 FROM dbo.[STUDENT] WHERE user_id = @StudentId)
       OR NOT EXISTS (SELECT 1 FROM dbo.[TEST] WHERE test_id = @TestId)
        RETURN -1.00;

    -- Truy vấn thông tin bài kiểm tra
    DECLARE @ClassId       INT;
    DECLARE @GradingMethod NVARCHAR(10);

    SELECT
        @ClassId       = class_id,
        @GradingMethod = grading_method
    FROM dbo.[TEST]
    WHERE test_id = @TestId;

    -- Kiểm tra RB3: Nếu đề thi gắn với lớp học, sinh viên phải có tên trong ENROLLS
    IF @ClassId IS NOT NULL
       AND NOT EXISTS (
           SELECT 1
           FROM dbo.[ENROLLS]
           WHERE student_id = @StudentId
             AND class_id   = @ClassId
       )
        RETURN -2.00;

    -- 2. Khai báo biến tính toán và Con trỏ duyệt các lần làm bài hợp lệ
    DECLARE @AttemptCount INT = 0;
    DECLARE @SumScore     DECIMAL(10, 2) = 0.00;
    DECLARE @FinalScore   DECIMAL(5, 2)  = NULL;
    DECLARE @AttemptIndex INT;
    DECLARE @CurrentScore DECIMAL(5, 2);

    DECLARE cur_Attempts CURSOR LOCAL FAST_FORWARD FOR
        SELECT attempt_index, score
        FROM dbo.[ATTEMPT]
        WHERE student_id = @StudentId
          AND test_id    = @TestId
          AND score IS NOT NULL
        ORDER BY attempt_index ASC;

    -- 3. Mở con trỏ, kết hợp WHILE và IF tính điểm theo grading_method
    OPEN cur_Attempts;
    FETCH NEXT FROM cur_Attempts INTO @AttemptIndex, @CurrentScore;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @AttemptCount = @AttemptCount + 1;

        IF @GradingMethod = N'FIRST'
        BEGIN
            IF @AttemptCount = 1
                SET @FinalScore = @CurrentScore;
        END
        ELSE IF @GradingMethod = N'LATEST'
        BEGIN
            SET @FinalScore = @CurrentScore;
        END
        ELSE IF @GradingMethod = N'HIGHEST'
        BEGIN
            IF @FinalScore IS NULL OR @CurrentScore > @FinalScore
                SET @FinalScore = @CurrentScore;
        END
        ELSE IF @GradingMethod = N'AVERAGE'
        BEGIN
            SET @SumScore = @SumScore + @CurrentScore;
        END;

        FETCH NEXT FROM cur_Attempts INTO @AttemptIndex, @CurrentScore;
    END;

    CLOSE cur_Attempts;
    DEALLOCATE cur_Attempts;

    IF @AttemptCount = 0
        RETURN NULL;

    IF @GradingMethod = N'AVERAGE'
        SET @FinalScore = CONVERT(DECIMAL(5, 2), ROUND(@SumScore / @AttemptCount, 2));

    RETURN @FinalScore;
END;
GO

-- ---------------------------------------------------------------------------------
-- HÀM 2: Tính Điểm tích cực học tập & thảo luận (thang 100.00) của sinh viên trong học kỳ
-- Quy tắc tính cho từng lớp sinh viên đã đăng ký trong học kỳ:
--   * Cơ sở đăng ký lớp                   : +10.00 điểm
--   * Nếu is_allowed_to_discuss = 1       : +5.00/bài đăng + 2.00/bình luận (tối đa +20.00/lớp)
--   * Nếu is_allowed_to_discuss = 0       : -5.00 điểm kỷ luật
--   * Hoàn thành 100% bài test của lớp    : +15.00 điểm (hoàn thành một phần: +8.00 điểm)
--   * Tổng điểm toàn học kỳ được chuẩn hóa về đoạn [0.00, 100.00]
-- Quy ước giá trị trả về:
--   * 0.00 .. 100.00 : Điểm tích cực hợp lệ (0.00 nếu chưa đăng ký lớp nào trong kỳ)
--   * -1.00          : Tham số đầu vào không hợp lệ (NULL, <= 0, hoặc không tồn tại)
-- ---------------------------------------------------------------------------------
CREATE OR ALTER FUNCTION dbo.fn_CalculateStudentEngagementScore
(
    @StudentId  INT,
    @SemesterId INT
)
RETURNS DECIMAL(6, 2)
AS
BEGIN
    -- 1. Kiểm tra tham số đầu vào hợp lệ
    IF @StudentId IS NULL OR @StudentId <= 0 OR @SemesterId IS NULL OR @SemesterId <= 0
        RETURN -1.00;

    IF NOT EXISTS (SELECT 1 FROM dbo.[STUDENT] WHERE user_id = @StudentId)
       OR NOT EXISTS (SELECT 1 FROM dbo.[SEMESTER] WHERE semester_id = @SemesterId)
        RETURN -1.00;

    DECLARE @UaId INT;
    SELECT @UaId = ua_id
    FROM dbo.[USER]
    WHERE user_id = @StudentId;

    IF NOT EXISTS (
        SELECT 1
        FROM dbo.[ENROLLS] AS e
        INNER JOIN dbo.[CLASS] AS c ON e.class_id = c.class_id
        WHERE e.student_id  = @StudentId
          AND c.semester_id = @SemesterId
    )
        RETURN 0.00;

    -- 2. Khai báo biến tích lũy và Con trỏ duyệt qua từng lớp sinh viên học trong học kỳ
    DECLARE @TotalEngagementScore DECIMAL(8, 2) = 0.00;
    DECLARE @ClassId              INT;
    DECLARE @IsAllowedToDiscuss   BIT;
    DECLARE @ClassScore           DECIMAL(6, 2);
    DECLARE @PostCount            INT;
    DECLARE @CommentCount         INT;
    DECLARE @DiscussionScore      DECIMAL(6, 2);
    DECLARE @TotalTests           INT;
    DECLARE @CompletedTests       INT;

    DECLARE cur_Classes CURSOR LOCAL FAST_FORWARD FOR
        SELECT c.class_id, e.is_allowed_to_discuss
        FROM dbo.[ENROLLS] AS e
        INNER JOIN dbo.[CLASS] AS c ON e.class_id = c.class_id
        WHERE e.student_id  = @StudentId
          AND c.semester_id = @SemesterId
        ORDER BY c.class_id ASC;

    -- 3. Mở con trỏ, lặp qua từng lớp để tính điểm thành phần bằng IF/ELSE
    OPEN cur_Classes;
    FETCH NEXT FROM cur_Classes INTO @ClassId, @IsAllowedToDiscuss;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @ClassScore = 10.00;

        IF @IsAllowedToDiscuss = 1
        BEGIN
            SELECT @PostCount = COUNT(*)
            FROM dbo.[POST]
            WHERE class_id = @ClassId
              AND ua_id    = @UaId;

            SELECT @CommentCount = COUNT(*)
            FROM dbo.[COMMENT] AS cm
            INNER JOIN dbo.[POST] AS p ON cm.post_id = p.post_id
            WHERE p.class_id = @ClassId
              AND cm.ua_id   = @UaId;

            SET @DiscussionScore = (@PostCount * 5.00) + (@CommentCount * 2.00);
            IF @DiscussionScore > 20.00
                SET @DiscussionScore = 20.00;

            SET @ClassScore = @ClassScore + @DiscussionScore;
        END
        ELSE
        BEGIN
            SET @ClassScore = @ClassScore - 5.00;
        END;

        SELECT @TotalTests = COUNT(*)
        FROM dbo.[TEST]
        WHERE class_id = @ClassId;

        SELECT @CompletedTests = COUNT(DISTINCT a.test_id)
        FROM dbo.[ATTEMPT] AS a
        WHERE a.student_id = @StudentId
          AND a.score IS NOT NULL
          AND a.test_id IN (
              SELECT t.test_id
              FROM dbo.[TEST] AS t
              WHERE t.class_id = @ClassId
          );

        IF @TotalTests > 0
        BEGIN
            IF @CompletedTests = @TotalTests
                SET @ClassScore = @ClassScore + 15.00;
            ELSE IF @CompletedTests > 0
                SET @ClassScore = @ClassScore + 8.00;
        END;

        SET @TotalEngagementScore = @TotalEngagementScore + @ClassScore;

        FETCH NEXT FROM cur_Classes INTO @ClassId, @IsAllowedToDiscuss;
    END;

    CLOSE cur_Classes;
    DEALLOCATE cur_Classes;

    IF @TotalEngagementScore > 100.00
        SET @TotalEngagementScore = 100.00;
    ELSE IF @TotalEngagementScore < 0.00
        SET @TotalEngagementScore = 0.00;

    RETURN CONVERT(DECIMAL(6, 2), @TotalEngagementScore);
END;
GO
