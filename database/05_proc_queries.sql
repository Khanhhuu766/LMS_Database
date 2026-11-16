-- =================================================================================
-- MỤC 2.3: VIẾT 2 THỦ TỤC TRUY VẤN HIỂN THỊ DỮ LIỆU
-- Người phụ trách Thủ tục 1 : Trần Minh Nhật (TV4)
-- Người phụ trách Thủ tục 2 : Trần Minh Nhật (TV4)
-- Yêu cầu đề bài :
--   - Chỉ chứa các câu truy vấn hiển thị dữ liệu, tham số đầu vào truyền vào mệnh đề
--     WHERE và/hoặc HAVING.
--   - Thủ tục 1: Truy vấn từ 2 bảng trở lên, có mệnh đề WHERE và ORDER BY.
--   - Thủ tục 2: Truy vấn liên kết từ 2 bảng trở lên, có Aggregate Function,
--                GROUP BY, HAVING, WHERE và ORDER BY.
--   - Bắt buộc có ít nhất 1 thủ tục liên quan đến bảng dữ liệu đã chọn ở mục 2.1.
-- =================================================================================

USE [LMS_DB];
GO

-- ---------------------------------------------------------------------------------
-- THỦ TỤC 1: dbo.usp_Test_Search - Tìm kiếm bài kiểm tra
--   Bảng chính: TEST. Nối: CLASS, SUBJECT, CHAPTER, CONTAINS_QUESTION, QUESTION.
--   Có WHERE + ORDER BY. Tham số NULL = không lọc theo tiêu chí đó.
--   Hiển thị kèm số câu hỏi và tổng điểm tối đa của bài (ưu tiên custom_score
--   nếu có, ngược lại dùng max_score mặc định của câu hỏi).
-- ---------------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE dbo.usp_Test_Search
    @class_id        INT           = NULL,   -- lọc theo lớp học
    @test_type       NVARCHAR(30)  = NULL,   -- ONLINE / FILE_SUBMISSION
    @grading_method  NVARCHAR(10)  = NULL,   -- HIGHEST / AVERAGE / FIRST / LATEST
    @from_date       DATETIME      = NULL,   -- bài có test_start >= mốc này
    @to_date         DATETIME      = NULL,   -- bài có test_start trong ngày này trở về trước
    @keyword         NVARCHAR(200) = NULL    -- tìm trong tên bài kiểm tra
AS
BEGIN
    SET NOCOUNT ON;

    SELECT  t.test_id,
            t.test_name,
            t.test_type,
            c.class_name,
            s.subject_name,
            ch.chapter_name,
            t.test_start,
            t.test_end,
            t.test_timer,
            t.max_attempts,
            t.grading_method,
            qs.so_cau_hoi,
            qs.tong_diem_toi_da
    FROM [TEST] AS t
         LEFT JOIN [CLASS]   AS c  ON c.class_id   = t.class_id
         LEFT JOIN [SUBJECT] AS s  ON s.subject_id = c.subject_id
         LEFT JOIN [CHAPTER] AS ch ON ch.class_id   = t.class_id
                                  AND ch.chapter_id = t.chapter_id
         OUTER APPLY (
             SELECT COUNT(*) AS so_cau_hoi,
                    SUM(COALESCE(cq.custom_score, q.max_score)) AS tong_diem_toi_da
             FROM [CONTAINS_QUESTION] AS cq
                  JOIN [QUESTION] AS q ON q.question_id = cq.question_id
             WHERE cq.test_id = t.test_id
         ) AS qs
    WHERE (@class_id       IS NULL OR t.class_id       = @class_id)
      AND (@test_type      IS NULL OR t.test_type      = @test_type)
      AND (@grading_method IS NULL OR t.grading_method = @grading_method)
      AND (@from_date      IS NULL OR t.test_start    >= @from_date)
      AND (@to_date        IS NULL OR t.test_start     < DATEADD(DAY, 1, @to_date))
      AND (@keyword        IS NULL OR t.test_name   LIKE N'%' + @keyword + N'%')
    ORDER BY t.test_start DESC, t.test_id;
END;
GO

-- ---------------------------------------------------------------------------------
-- THỦ TỤC 2: dbo.usp_Test_ScoreStatistics - Thống kê kết quả làm bài theo bài kiểm tra
--   Nối: TEST - ATTEMPT - CLASS. Có Aggregate (COUNT, AVG, MAX, MIN), WHERE,
--   GROUP BY, HAVING, ORDER BY. Chỉ tính các lần làm đã nộp (end_time khác NULL)
--   và đã có điểm. Tham số HAVING: số lần làm tối thiểu, điểm trung bình tối thiểu.
-- ---------------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE dbo.usp_Test_ScoreStatistics
    @class_id         INT           = NULL,   -- lọc theo lớp học
    @from_date        DATETIME      = NULL,   -- bài có test_start >= mốc này
    @to_date          DATETIME      = NULL,   -- bài có test_start trong ngày này trở về trước
    @min_attempts     INT           = 1,      -- HAVING: số lần làm tối thiểu
    @min_avg_score    DECIMAL(5,2)  = NULL    -- HAVING: điểm trung bình tối thiểu
AS
BEGIN
    SET NOCOUNT ON;

    SELECT  t.test_id,
            t.test_name,
            c.class_name,
            t.grading_method,
            COUNT(*)                                          AS so_lan_lam,
            COUNT(DISTINCT a.student_id)                      AS so_sinh_vien,
            CAST(AVG(a.score) AS DECIMAL(5,2))                AS diem_trung_binh,
            MAX(a.score)                                      AS diem_cao_nhat,
            MIN(a.score)                                      AS diem_thap_nhat,
            AVG(DATEDIFF(MINUTE, a.start_time, a.end_time))   AS phut_lam_bai_tb
    FROM [TEST] AS t
         JOIN [ATTEMPT] AS a ON a.test_id = t.test_id
         LEFT JOIN [CLASS] AS c ON c.class_id = t.class_id
    WHERE a.end_time IS NOT NULL
      AND a.score    IS NOT NULL
      AND (@class_id  IS NULL OR t.class_id    = @class_id)
      AND (@from_date IS NULL OR t.test_start >= @from_date)
      AND (@to_date   IS NULL OR t.test_start  < DATEADD(DAY, 1, @to_date))
    GROUP BY t.test_id, t.test_name, c.class_name, t.grading_method
    HAVING COUNT(*) >= @min_attempts
       AND (@min_avg_score IS NULL OR AVG(a.score) >= @min_avg_score)
    ORDER BY AVG(a.score) DESC, t.test_id;
END;
GO
