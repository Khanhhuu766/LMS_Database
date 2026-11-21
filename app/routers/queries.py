from fastapi import APIRouter, Query

from app.db import api_error

router = APIRouter(prefix="/api", tags=["Queries & Statistics (Mục 3.2 & 3.3)"])


@router.get("/posts")
def search_posts(
    class_id: int | None = Query(default=None),
    keyword: str | None = Query(default=None),
    author: str | None = Query(default=None),
    from_date: str | None = Query(default=None),
    to_date: str | None = Query(default=None),
    min_comments: int | None = Query(default=None),
):
    # TODO (Trần Minh Nhật - Giai đoạn 2):
    # Gọi EXEC dbo.usp_Post_Search @class_id=?, @keyword=?, @author=?,
    #                              @from_date=?, @to_date=?, @min_comments=?
    # bằng fetch_all() và trả về api_ok(...)
    return api_error(
        message="TODO",
        error_code=501,
        status_code=501,
    )


@router.get("/tests/statistics")
def get_test_statistics(
    class_id: int | None = Query(default=None),
    from_date: str | None = Query(default=None),
    to_date: str | None = Query(default=None),
    min_attempts: int = Query(default=1),
    min_avg_score: float | None = Query(default=None),
):
    # TODO (Trần Minh Nhật - Giai đoạn 2):
    # Gọi EXEC dbo.usp_Test_ScoreStatistics @class_id=?, @from_date=?, @to_date=?,
    #                                         @min_attempts=?, @min_avg_score=?
    # bằng fetch_all() và trả về api_ok(...)
    return api_error(
        message="TODO",
        error_code=501,
        status_code=501,
    )