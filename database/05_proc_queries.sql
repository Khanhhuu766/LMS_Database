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
--   - Bắt buộc có ít nhất 1 thủ tục liên quan đến bảng dữ liệu đã chọn ở mục 2.1 (bảng POST).
-- =================================================================================

USE [LMS_DB];
GO

-- ---------------------------------------------------------------------------------
-- THỦ TỤC 1: dbo.usp_Post_Search - Tìm kiếm bài đăng trong diễn đàn lớp học
--   Liên quan bảng đã chọn ở Mục 2.1: [POST].
--   Nối: POST - USER (tác giả) - CLASS - STUDENT/LECTURER/ADMIN (vai trò tác giả)
--        và COMMENT (đếm bình luận). Có WHERE + ORDER BY.
--   Tham số NULL = không lọc theo tiêu chí đó.
-- ---------------------------------------------------------------------------------
CREATE OR ALTER PROCEDURE dbo.usp_Post_Search
    @class_id       INT           = NULL,   -- lọc theo lớp học
    @keyword        NVARCHAR(200) = NULL,   -- tìm trong tiêu đề hoặc nội dung bài đăng
    @author         NVARCHAR(100) = NULL,   -- tìm theo họ tên hoặc tên đăng nhập của tác giả
    @from_date      DATETIME      = NULL,   -- bài đăng từ thời điểm này
    @to_date        DATETIME      = NULL,   -- bài đăng đến hết ngày này
    @min_comments   INT           = NULL    -- chỉ lấy bài có ít nhất ngần này bình luận
AS
BEGIN
    SET NOCOUNT ON;

    SELECT  p.post_id,
            p.post_name,
            CAST(LEFT(p.post_description, 100) AS NVARCHAR(100)) AS noi_dung_tom_tat,
            p.post_start,
            c.class_name,
            u.ua_username,
            CONCAT(u.last_name, N' ', COALESCE(u.middle_name + N' ', N''), u.first_name) AS tac_gia,
            CASE WHEN l.user_id  IS NOT NULL THEN N'Giảng viên'
                 WHEN st.user_id IS NOT NULL THEN N'Sinh viên'
                 WHEN ad.user_id IS NOT NULL THEN N'Quản trị viên'
                 ELSE N'Không xác định' END                       AS vai_tro,
            qs.so_binh_luan,
            qs.binh_luan_moi_nhat
    FROM [POST] AS p
         LEFT JOIN [USER]     AS u  ON u.ua_id   = p.ua_id
         LEFT JOIN [CLASS]    AS c  ON c.class_id = p.class_id
         LEFT JOIN [STUDENT]  AS st ON st.user_id = u.user_id
         LEFT JOIN [LECTURER] AS l  ON l.user_id  = u.user_id
         LEFT JOIN [ADMIN]    AS ad ON ad.user_id = u.user_id
         OUTER APPLY (
             SELECT COUNT(*)              AS so_binh_luan,
                    MAX(cm.comment_start) AS binh_luan_moi_nhat
             FROM [COMMENT] AS cm
             WHERE cm.post_id = p.post_id
         ) AS qs
    WHERE (@class_id     IS NULL OR p.class_id = @class_id)
      AND (@keyword      IS NULL OR p.post_name        LIKE N'%' + @keyword + N'%'
                                 OR p.post_description LIKE N'%' + @keyword + N'%')
      AND (@author       IS NULL OR u.ua_username LIKE N'%' + @author + N'%'
                                 OR CONCAT(u.last_name, N' ', COALESCE(u.middle_name + N' ', N''), u.first_name)
                                        LIKE N'%' + @author + N'%')
      AND (@from_date    IS NULL OR p.post_start >= @from_date)
      AND (@to_date      IS NULL OR p.post_start  < DATEADD(DAY, 1, @to_date))
      AND (@min_comments IS NULL OR qs.so_binh_luan >= @min_comments)
    ORDER BY p.post_start DESC, p.post_id;
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
