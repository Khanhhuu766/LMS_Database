from typing import Annotated, Any

import pyodbc
from fastapi import APIRouter, Path, Query
from pydantic import BaseModel, Field

from app.db import api_ok, execute_sp, handle_sql_error
from app.routers.lookups import get_post_detail

router = APIRouter(prefix="/api/posts", tags=["Posts CRUD (Mục 3.1)"])

SQL_INT_MIN = -(2**31)
SQL_INT_MAX = 2**31 - 1
SqlInt = Annotated[int, Field(strict=True, ge=SQL_INT_MIN, le=SQL_INT_MAX)]
PostId = Annotated[int, Path(ge=SQL_INT_MIN, le=SQL_INT_MAX)]


class PostCreateRequest(BaseModel):
    post_name: str
    ua_id: SqlInt
    post_description: str | None = None
    class_id: SqlInt | None = None


class PostUpdateRequest(BaseModel):
    requester_ua_id: SqlInt
    post_name: str
    post_description: str | None = None


def _mutate_post(sql: str, params: tuple[Any, ...], status_code: int = 200):
    try:
        result = execute_sp(sql, params)
        return api_ok(result[0], status_code=status_code)
    except pyodbc.Error as exc:
        return handle_sql_error(exc)


@router.get("/{post_id}")
def read_post(post_id: Annotated[int, Path(gt=0, le=SQL_INT_MAX)]):
    return get_post_detail(post_id)


@router.post("", status_code=201)
def create_post(payload: PostCreateRequest):
    return _mutate_post(
        "EXEC dbo.usp_Post_Insert @PostName=?, @UaId=?, @PostDescription=?, @ClassId=?",
        (
            payload.post_name.strip(),
            payload.ua_id,
            payload.post_description,
            payload.class_id,
        ),
        status_code=201,
    )


@router.put("/{post_id}")
def update_post(post_id: PostId, payload: PostUpdateRequest):
    return _mutate_post(
        "EXEC dbo.usp_Post_Update @PostId=?, @RequesterUaId=?, @PostName=?, @PostDescription=?",
        (
            post_id,
            payload.requester_ua_id,
            payload.post_name.strip(),
            payload.post_description,
        ),
    )


@router.delete("/{post_id}")
def delete_post(
    post_id: PostId,
    requester_ua_id: Annotated[int, Query(ge=SQL_INT_MIN, le=SQL_INT_MAX)],
):
    return _mutate_post(
        "EXEC dbo.usp_Post_Delete @PostId=?, @RequesterUaId=?",
        (post_id, requester_ua_id),
    )
