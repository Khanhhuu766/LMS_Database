# Phụ lục A – Danh sách 25 bảng từ BTL1 (Giữ nguyên tên bảng & cột)

> **Lưu ý quan trọng khi viết `database/01_schema_tables.sql` và `database/02_seed_data.sql`:**
> - **Không** đổi tên 25 bảng hay tên cột của BTL1.
> - Với các bảng trùng từ khóa của MS SQL Server như `USER`, `FILE`, `COMMENT`, `STATUS`, khi viết lệnh T-SQL các thành viên đặt trong cặp ngoặc vuông: `[USER]`, `[FILE]`, `[COMMENT]`, `[STATUS]`.

## Danh sách chi tiết 25 bảng (36 khóa ngoại)

1. **`[USER]`** (`user_id` PK, `first_name`, `middle_name`, `last_name`, `sex`, `email` UNIQUE, `birthday`, `nationality`, `ua_id` UNIQUE, `ua_username` UNIQUE, `ua_password`, `ua_image`)
2. **`[USER_SESSION]`** (`session_id` PK, `login_time`, `ip_address`, `ua_id` FK $\rightarrow$ `USER(ua_id)`)
3. **`[STUDENT]`** (`user_id` PK/FK $\rightarrow$ `USER`, `student_code` UNIQUE, `enrollment_year`)
4. **`[LECTURER]`** (`user_id` PK/FK $\rightarrow$ `USER`, `lecturer_code` UNIQUE, `academic_rank`, `faculty_id` FK $\rightarrow$ `FACULTY`)
5. **`[LECTURER_DEGREE]`** (`lecturer_id` PK/FK $\rightarrow$ `LECTURER`, `degree` PK)
6. **`[ADMIN]`** (`user_id` PK/FK $\rightarrow$ `USER`, `admin_code` UNIQUE, `office_room`)
7. **`[FACULTY]`** (`faculty_id` PK, `faculty_name`, `admin_id` UNIQUE FK $\rightarrow$ `ADMIN`)
8. **`[SUBJECT]`** (`subject_id` PK, `subject_name`, `credit`, `faculty_id` FK $\rightarrow$ `FACULTY`)
9. **`[PREREQUISITE]`** (`subject_id` PK/FK $\rightarrow$ `SUBJECT`, `prereq_subject_id` PK/FK $\rightarrow$ `SUBJECT`)
10. **`[SEMESTER]`** (`semester_id` PK, `semester_start`, `semester_end`)
11. **`[STATUS]`** (`status_id` PK, `status_display`)
12. **`[CLASS]`** (`class_id` PK, `class_name`, `subject_id` FK, `semester_id` FK, `status_id` FK, `lecturer_id` FK)
13. **`[ENROLLS]`** (`student_id` PK/FK, `class_id` PK/FK, `is_allowed_to_discuss`)
14. **`[CHAPTER]`** (`class_id` PK/FK, `chapter_id` PK, `chapter_name`)
15. **`[TOPIC]`** (`class_id` PK/FK, `chapter_id` PK/FK, `topic_id` PK, `topic_name`, `topic_content`)
16. **`[FILE]`** (`class_id` PK/FK, `chapter_id` PK/FK, `topic_id` PK/FK, `file_id` PK, `file_name`, `file_path`, `file_size`, `update_date`)
17. **`[TEST]`** (`test_id` PK, `test_name`, `test_type`, `test_start`, `test_end`, `test_timer`, `max_attempts`, `grading_method`, `class_id` FK, `chapter_id` FK)
18. **`[QUESTION]`** (`question_id` PK, `question_type`, `question_content`, `max_score`)
19. **`[CHOICE]`** (`choice_id` PK, `choice_content`, `is_true`, `question_id` FK)
20. **`[CONTAINS_QUESTION]`** (`test_id` PK/FK, `question_id` PK/FK, `custom_score`)
21. **`[TAKES_TEST]`** (`student_id` PK/FK, `test_id` PK/FK)
    *(Lưu ý: Nhóm tự quyết định thêm cột thuộc tính dẫn xuất như `final_score` nếu chọn bảng này cho Trigger mục 2.2.2)*
22. **`[ATTEMPT]`** (`attempt_id` PK, `attempt_index`, `start_time`, `end_time`, `student_id` FK, `test_id` FK)
    *(Lưu ý: Nhóm tự quyết định thêm cột thuộc tính dẫn xuất như `score` hoặc `timer` nếu chọn bảng này cho Trigger mục 2.2.2)*
23. **`[STUDENT_ANSWER]`** (`ans_id` PK, `answer_text`, `file_submission_path`, `upload_time`, `score_awarded`, `attempt_id` FK, `question_id` FK, `choice_id` FK)
24. **`[POST]`** (`post_id` PK, `post_name`, `post_description`, `post_start`, `ua_id` FK $\rightarrow$ `USER(ua_id)`, `class_id` FK)
25. **`[COMMENT]`** (`comment_id` PK, `comment_content`, `comment_start`, `post_id` FK, `ua_id` FK $\rightarrow$ `USER(ua_id)`, `parent_comment_id` FK $\rightarrow$ `COMMENT`)
