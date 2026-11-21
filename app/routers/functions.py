from fastapi import APIRouter, Query

from app.db import api_error

router = APIRouter(prefix="/api/functions", tags=["Cursor Functions (Mục 3.3)"])


@router.get("/test-score")
def calculate_student_test_score(
    student_id: int = Query(...),
    test_id: int = Query(...),
):
    # TODO (Nguyễn Hữu Khánh - Giai đoạn 2):
    # Gọi SELECT dbo.fn_CalculateStudentTestScore(?, ?) AS final_score
    # Diễn giải mã đặc biệt: NULL (chưa làm bài), -1.00 (tham số sai), -2.00 (chưa đăng ký lớp RB3)
    return api_error(
        message="TODO",
        error_code=501,
        status_code=501,
    )


@router.get("/engagement-score")
def calculate_student_engagement_score(
    student_id: int = Query(...),
    semester_id: int = Query(...),
):
    # TODO (Nguyễn Hữu Khánh - Giai đoạn 2):
    # Gọi SELECT dbo.fn_CalculateStudentEngagementScore(?, ?) AS engagement_score
    # Diễn giải mã đặc biệt: -1.00 (tham số sai), 0.00 (chưa đăng ký lớp trong kỳ)
    return api_error(
        message="TODO",
        error_code=501,
        status_code=501,
    )