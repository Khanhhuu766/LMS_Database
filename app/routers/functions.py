import pyodbc
from fastapi import APIRouter, Query

from app.db import api_ok, fetch_all, fetch_one, handle_sql_error

router = APIRouter(prefix="/api/functions", tags=["Cursor Functions (Mục 3.3)"])


@router.get("/test-score")
def calculate_student_test_score(
    student_id: int = Query(..., description="Mã sinh viên (STUDENT.user_id)"),
    test_id: int = Query(..., description="Mã bài kiểm tra (TEST.test_id)"),
):
    """
    Gọi Scalar Function dbo.fn_CalculateStudentTestScore(@StudentId, @TestId)
    và trả kèm thông tin chi tiết các lần làm bài (ATTEMPT) để đối chiếu trên UI.
    """
    try:
        fn_row = fetch_one(
            "SELECT dbo.fn_CalculateStudentTestScore(?, ?) AS final_score;",
            (student_id, test_id),
        )
        raw_score = fn_row["final_score"] if fn_row else None

        student_info = (
            fetch_one(
                """
                SELECT st.user_id AS student_id, st.student_code,
                       CONCAT(u.last_name, N' ', COALESCE(u.middle_name + N' ', N''), u.first_name) AS full_name
                FROM dbo.[STUDENT] AS st
                INNER JOIN dbo.[USER] AS u ON u.user_id = st.user_id
                WHERE st.user_id = ?;
                """,
                (student_id,),
            )
            if student_id > 0
            else None
        )

        test_info = (
            fetch_one(
                """
                SELECT t.test_id, t.test_name, t.grading_method, t.max_attempts,
                       c.class_id, c.class_name
                FROM dbo.[TEST] AS t
                LEFT JOIN dbo.[CLASS] AS c ON c.class_id = t.class_id
                WHERE t.test_id = ?;
                """,
                (test_id,),
            )
            if test_id > 0
            else None
        )

        attempts = []
        if raw_score is not None and raw_score >= 0:
            attempts = fetch_all(
                """
                SELECT attempt_id, attempt_index, start_time, end_time, score
                FROM dbo.[ATTEMPT]
                WHERE student_id = ? AND test_id = ?
                ORDER BY attempt_index ASC;
                """,
                (student_id, test_id),
            )

        if raw_score == -1.0:
            status = "INVALID_PARAM"
            status_label = "Tham số không hợp lệ (-1.00)"
            explanation = (
                "Mã sinh viên hoặc mã bài kiểm tra phải là số nguyên dương "
                "và tồn tại trong hệ thống."
            )
        elif raw_score == -2.0:
            status = "NOT_ENROLLED"
            status_label = "Vi phạm RB3: Chưa đăng ký lớp (-2.00)"
            explanation = (
                "Bài kiểm tra thuộc lớp học mà sinh viên chưa đăng ký trong bảng ENROLLS."
            )
        elif raw_score is None:
            status = "NO_ATTEMPT"
            status_label = "Chưa có bài làm được chấm điểm (NULL)"
            explanation = (
                "Sinh viên đã đăng ký hợp lệ nhưng chưa thực hiện hoặc chưa có điểm cho bài kiểm tra này."
            )
        else:
            status = "OK"
            status_label = "Tính điểm hợp lệ"
            method = test_info["grading_method"] if test_info else ""
            explanation = (
                f"Đã duyệt {len(attempts)} lần làm bài bằng CURSOR và tính theo phương thức {method}."
            )

        return api_ok(
            {
                "student_id": student_id,
                "test_id": test_id,
                "final_score": raw_score,
                "status": status,
                "status_label": status_label,
                "explanation": explanation,
                "student": student_info,
                "test": test_info,
                "attempts": attempts,
            }
        )
    except pyodbc.Error as exc:
        return handle_sql_error(exc)


@router.get("/engagement-score")
def calculate_student_engagement_score(
    student_id: int = Query(..., description="Mã sinh viên (STUDENT.user_id)"),
    semester_id: int = Query(..., description="Mã học kỳ (SEMESTER.semester_id)"),
):
    """
    Gọi Scalar Function dbo.fn_CalculateStudentEngagementScore(@StudentId, @SemesterId)
    và trả kèm chi tiết từng lớp học trong học kỳ để giải thích điểm thành phần.
    """
    try:
        fn_row = fetch_one(
            "SELECT dbo.fn_CalculateStudentEngagementScore(?, ?) AS engagement_score;",
            (student_id, semester_id),
        )
        raw_score = fn_row["engagement_score"] if fn_row else None

        student_info = (
            fetch_one(
                """
                SELECT st.user_id AS student_id, st.student_code, u.ua_id,
                       CONCAT(u.last_name, N' ', COALESCE(u.middle_name + N' ', N''), u.first_name) AS full_name
                FROM dbo.[STUDENT] AS st
                INNER JOIN dbo.[USER] AS u ON u.user_id = st.user_id
                WHERE st.user_id = ?;
                """,
                (student_id,),
            )
            if student_id > 0
            else None
        )

        semester_info = (
            fetch_one(
                """
                SELECT semester_id, semester_start, semester_end
                FROM dbo.[SEMESTER]
                WHERE semester_id = ?;
                """,
                (semester_id,),
            )
            if semester_id > 0
            else None
        )

        classes_breakdown = []
        if raw_score is not None and raw_score >= 0 and student_info is not None:
            ua_id = student_info["ua_id"]
            classes_breakdown = fetch_all(
                """
                SELECT
                    c.class_id,
                    c.class_name,
                    e.is_allowed_to_discuss,
                    (
                        SELECT COUNT(*)
                        FROM dbo.[POST] AS p
                        WHERE p.class_id = c.class_id AND p.ua_id = ?
                    ) AS post_count,
                    (
                        SELECT COUNT(*)
                        FROM dbo.[COMMENT] AS cm
                        INNER JOIN dbo.[POST] AS p ON cm.post_id = p.post_id
                        WHERE p.class_id = c.class_id AND cm.ua_id = ?
                    ) AS comment_count,
                    (
                        SELECT COUNT(*)
                        FROM dbo.[TEST] AS t
                        WHERE t.class_id = c.class_id
                    ) AS total_tests,
                    (
                        SELECT COUNT(DISTINCT a.test_id)
                        FROM dbo.[ATTEMPT] AS a
                        WHERE a.student_id = ?
                          AND a.score IS NOT NULL
                          AND a.test_id IN (SELECT t.test_id FROM dbo.[TEST] AS t WHERE t.class_id = c.class_id)
                    ) AS completed_tests
                FROM dbo.[ENROLLS] AS e
                INNER JOIN dbo.[CLASS] AS c ON e.class_id = c.class_id
                WHERE e.student_id = ? AND c.semester_id = ?
                ORDER BY c.class_id ASC;
                """,
                (ua_id, ua_id, student_id, student_id, semester_id),
            )

        if raw_score == -1.0:
            status = "INVALID_PARAM"
            status_label = "Tham số không hợp lệ (-1.00)"
            explanation = (
                "Mã sinh viên hoặc mã học kỳ phải là số nguyên dương "
                "và tồn tại trong hệ thống."
            )
        elif raw_score == 0.0 and len(classes_breakdown) == 0:
            status = "NO_CLASSES"
            status_label = "Chưa đăng ký lớp trong học kỳ (0.00)"
            explanation = (
                "Sinh viên hợp lệ nhưng không đăng ký lớp học nào thuộc học kỳ này."
            )
        else:
            status = "OK"
            status_label = "Tính điểm tích cực thành công"
            explanation = (
                f"Đã duyệt qua {len(classes_breakdown)} lớp học trong học kỳ bằng CURSOR (thang tối đa 100.00)."
            )

        return api_ok(
            {
                "student_id": student_id,
                "semester_id": semester_id,
                "engagement_score": raw_score,
                "status": status,
                "status_label": status_label,
                "explanation": explanation,
                "student": student_info,
                "semester": semester_info,
                "classes_breakdown": classes_breakdown,
            }
        )
    except pyodbc.Error as exc:
        return handle_sql_error(exc)
