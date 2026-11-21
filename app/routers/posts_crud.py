from fastapi import APIRouter, Query
from pydantic import BaseModel

from app.db import api_error

router = APIRouter(prefix="/api/posts", tags=["Posts CRUD (Mục 3.1)"])


class PostCreateRequest(BaseModel):
    post_name: str
    ua_id: int
    post_description: str | None = None
    class_id: int | None = None


class PostUpdateRequest(BaseModel):
    requester_ua_id: int
    post_name: str
    post_description: str | None = None


@router.post("")
def create_post(payload: PostCreateRequest):
    # TODO (Phạm Hoàng Hà - Giai đoạn 2):
    # Gọi EXEC dbo.usp_Post_Insert @PostName=?, @UaId=?, @PostDescription=?, @ClassId=?
    # bằng execute_sp() và bắt pyodbc.Error bằng handle_sql_error()
    return api_error(
        message="TODO",
        error_code=501,
        status_code=501,
    )


@router.put("/{post_id}")
def update_post(post_id: int, payload: PostUpdateRequest):
    # TODO (Phạm Hoàng Hà - Giai đoạn 2):
    # Gọi EXEC dbo.usp_Post_Update @PostId=?, @RequesterUaId=?, @PostName=?, @PostDescription=?
    return api_error(
        message="TODO",
        error_code=501,
        status_code=501,
    )


@router.delete("/{post_id}")
def delete_post(post_id: int, requester_ua_id: int = Query(...)):
    # TODO (Phạm Hoàng Hà - Giai đoạn 2):
    # Gọi EXEC dbo.usp_Post_Delete @PostId=?, @RequesterUaId=?
    return api_error(
        message="TODO",
        error_code=501,
        status_code=501,
    )