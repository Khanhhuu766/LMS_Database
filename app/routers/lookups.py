import pyodbc
from fastapi import APIRouter

from app.db import api_error, api_ok, fetch_all, fetch_one, handle_sql_error

router = APIRouter(prefix="/api/lookups", tags=["Lookups"])


@router.get("/classes")
def get_classes():
    sql = """
        SELECT
            c.class_id,
            c.class_name,
            s.subject_name,
            c.semester_id,
            st.status_display,
            c.lecturer_id,
            CONCAT(u.last_name, N' ', COALESCE(u.middle_name + N' ', N''), u.first_name) AS lecturer_name
        FROM dbo.[CLASS] AS c
        LEFT JOIN dbo.[SUBJECT] AS s  ON s.subject_id = c.subject_id
        LEFT JOIN dbo.[STATUS]  AS st ON st.status_id = c.status_id
        LEFT JOIN dbo.[USER]    AS u  ON u.user_id    = c.lecturer_id
        ORDER BY c.class_id ASC;
    """
    try:
        return api_ok(fetch_all(sql))
    except pyodbc.Error as exc:
        return handle_sql_error(exc)


@router.get("/users")
def get_users():
    sql = """
        SELECT
            u.user_id,
            u.ua_id,
            u.ua_username,
            CONCAT(u.last_name, N' ', COALESCE(u.middle_name + N' ', N''), u.first_name) AS full_name,
            CASE
                WHEN l.user_id  IS NOT NULL THEN N'Giảng viên'
                WHEN st.user_id IS NOT NULL THEN N'Sinh viên'
                WHEN ad.user_id IS NOT NULL THEN N'Quản trị viên'
                ELSE N'Người dùng'
            END AS role_name
        FROM dbo.[USER] AS u
        LEFT JOIN dbo.[LECTURER] AS l  ON l.user_id  = u.user_id
        LEFT JOIN dbo.[STUDENT]  AS st ON st.user_id = u.user_id
        LEFT JOIN dbo.[ADMIN]    AS ad ON ad.user_id = u.user_id
        ORDER BY u.ua_id ASC;
    """
    try:
        return api_ok(fetch_all(sql))
    except pyodbc.Error as exc:
        return handle_sql_error(exc)


@router.get("/students")
def get_students():
    sql = """
        SELECT
            st.user_id AS student_id,
            st.student_code,
            st.enrollment_year,
            u.ua_id,
            u.email,
            CONCAT(u.last_name, N' ', COALESCE(u.middle_name + N' ', N''), u.first_name) AS full_name
        FROM dbo.[STUDENT] AS st
        INNER JOIN dbo.[USER] AS u ON u.user_id = st.user_id
        ORDER BY st.user_id ASC;
    """
    try:
        return api_ok(fetch_all(sql))
    except pyodbc.Error as exc:
        return handle_sql_error(exc)


@router.get("/tests")
def get_tests():
    sql = """
        SELECT
            t.test_id,
            t.test_name,
            t.test_type,
            t.grading_method,
            t.max_attempts,
            t.class_id,
            c.class_name
        FROM dbo.[TEST] AS t
        LEFT JOIN dbo.[CLASS] AS c ON c.class_id = t.class_id
        ORDER BY t.test_id ASC;
    """
    try:
        return api_ok(fetch_all(sql))
    except pyodbc.Error as exc:
        return handle_sql_error(exc)


@router.get("/semesters")
def get_semesters():
    sql = """
        SELECT
            semester_id,
            semester_start,
            semester_end
        FROM dbo.[SEMESTER]
        ORDER BY semester_id ASC;
    """
    try:
        return api_ok(fetch_all(sql))
    except pyodbc.Error as exc:
        return handle_sql_error(exc)


@router.get("/posts/{post_id}")
def get_post_detail(post_id: int):
    sql = """
        SELECT
            p.post_id,
            p.post_name,
            p.post_description,
            p.post_start,
            p.ua_id,
            p.class_id
        FROM dbo.[POST] AS p
        WHERE p.post_id = ?;
    """
    try:
        post = fetch_one(sql, (post_id,))
        if not post:
            return api_error(
                message=f"Không tìm thấy bài đăng có post_id = {post_id}.",
                error_code=404,
                status_code=404,
            )
        return api_ok(post)
    except pyodbc.Error as exc:
        return handle_sql_error(exc)