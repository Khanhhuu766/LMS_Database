-- =====================================================================
-- BTL2 - He CSDL | De tai: He thong quan ly hoc tap (LMS)
-- File : database/01_schema_tables.sql
-- DBMS : Microsoft SQL Server 2016+ (T-SQL; DATEDIFF_BIG)
-- Noi dung: tao 25 bang theo luoc do quan he (PK, FK, UNIQUE,
--           NOT NULL, CHECK), phu hop SQL Server va phu luc BTL2.
-- Database muc tieu: LMS_DB (duoc tao boi 00_create_database.sql).
-- Yeu cau: chay 00_create_database.sql truoc file nay.
--
-- Quy uoc ON DELETE / ON UPDATE:
--   * CASCADE   : thuc the yeu, lop con, bang N:M, FK tham gia toan bo
--   * SET NULL  : FK tham gia tung phan (EERD)
--   * NO ACTION : tuong duong RESTRICT trong SQL Server; duoc dung cho ON UPDATE
--                 de tranh multiple cascade paths (loi 1785) tren SQL Server.
-- SQL Server khong co REGEXP trong CHECK; email duoc rang buoc theo dinh dang
-- co ban va mien @hcmut.edu.vn bang LIKE/PATINDEX.
-- SQL Server: cac FK dung ON UPDATE NO ACTION de tranh loi 1785 (multiple
-- cascade paths). Cac khoa tham chieu la khoa dinh danh/ma lien ket nen khong
-- cap nhat khoa cha truc tiep; neu can doi khoa, phai cap nhat co kiem soat.
-- ON DELETE van giu theo nghiep vu; voi FK NO ACTION, xu ly ban ghi con truoc
-- khi xoa ban ghi cha trong cung transaction.
--
-- Don vi file_size: byte. Gioi han 200 MB = 200 * 1024 * 1024 byte.
-- test_timer: phut; khong vuot qua khoang thoi gian test_start -> test_end.
-- uq_attempt duoc tao bang filtered unique index de cho phep nhieu NULL
-- tuong tu UNIQUE cua MySQL khi student_id/test_id chua co gia tri.
-- Rang buoc khong the viet bang CHECK (lien quan nhieu bang) -> trigger,
-- xem 04_triggers.sql, vi du: lop con User roi nhau + toan bo, so lan lam
-- bai khong vuot max_attempts, sinh vien phai duoc phep thao luan...
-- =====================================================================

-- File 00_create_database.sql chiu trach nhiem tao database LMS_DB.
-- File nay chi tao bang trong database da duoc khoi tao.
USE [LMS_DB];
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

-- ---------------------------------------------------------------------
-- 1. NGUOI DUNG  (User gop User_acc vi HAS_ACC la 1:1, hai phia toan bo)
-- ---------------------------------------------------------------------
CREATE TABLE [USER] (
    user_id      INT IDENTITY(1,1) NOT NULL,
    first_name   NVARCHAR(50)  NOT NULL,
    middle_name  NVARCHAR(50)  NULL,
    last_name    NVARCHAR(50)  NOT NULL,
    sex          NVARCHAR(10)  NULL,
    email        NVARCHAR(100) NOT NULL,
    birthday     DATE         NULL,
    nationality  NVARCHAR(50)  NULL,
    -- cac cot cua User_acc
    ua_id        INT          NOT NULL,           -- gan thu cong (hoac = user_id)
    ua_username  NVARCHAR(50)  NOT NULL,
    ua_password  NVARCHAR(255) NOT NULL,           -- luu ma bam, khong luu mat khau tho
    ua_image     NVARCHAR(255) NULL,
    CONSTRAINT pk_user PRIMARY KEY (user_id),
    CONSTRAINT uq_user_email UNIQUE (email),
    CONSTRAINT uq_user_ua_id UNIQUE (ua_id),
    CONSTRAINT uq_user_username UNIQUE (ua_username),
    CONSTRAINT ck_user_sex CHECK (sex IS NULL OR sex IN ('Male','Female','Other')),
    CONSTRAINT ck_user_email CHECK (
        LEN(email) > LEN(N'@hcmut.edu.vn')
        AND LOWER(RIGHT(email, LEN(N'@hcmut.edu.vn'))) = N'@hcmut.edu.vn'
        AND email NOT LIKE N'%@%@%'
        AND email NOT LIKE N'% %'
        AND email NOT LIKE N'%.@%'
        AND email NOT LIKE N'%..%'
        AND LEFT(email, 1) <> N'.'
        AND PATINDEX(N'%[^A-Za-z0-9._%+@-]%', email) = 0
    ),
    CONSTRAINT ck_user_birthday CHECK (birthday IS NULL OR birthday >= '1900-01-01'),
    CONSTRAINT ck_user_username CHECK (DATALENGTH(ua_username) / 2 >= 3)
);

CREATE TABLE [STUDENT] (
    user_id          INT         NOT NULL,
    student_code     NVARCHAR(20) NOT NULL,
    enrollment_year  SMALLINT    NULL,
    CONSTRAINT pk_student PRIMARY KEY (user_id),
    CONSTRAINT uq_student_code UNIQUE (student_code),
    CONSTRAINT fk_student_user FOREIGN KEY (user_id) REFERENCES [USER](user_id)
        ON DELETE CASCADE ON UPDATE NO ACTION,
    CONSTRAINT ck_student_year CHECK (enrollment_year IS NULL OR enrollment_year BETWEEN 1990 AND 2100)
);

CREATE TABLE [ADMIN] (
    user_id      INT         NOT NULL,
    admin_code   NVARCHAR(20) NOT NULL,
    office_room  NVARCHAR(30) NULL,
    CONSTRAINT pk_admin PRIMARY KEY (user_id),
    CONSTRAINT uq_admin_code UNIQUE (admin_code),
    CONSTRAINT fk_admin_user FOREIGN KEY (user_id) REFERENCES [USER](user_id)
        ON DELETE CASCADE ON UPDATE NO ACTION
);

-- MANAGES (Admin 1 - 1 Faculty, Faculty toan phan) -> FK + UNIQUE + NOT NULL o FACULTY
CREATE TABLE [FACULTY] (
    faculty_id    INT IDENTITY(1,1) NOT NULL,
    faculty_name  NVARCHAR(100) NOT NULL,
    admin_id      INT          NOT NULL,
    CONSTRAINT pk_faculty PRIMARY KEY (faculty_id),
    CONSTRAINT uq_faculty_admin UNIQUE (admin_id),
    CONSTRAINT fk_faculty_admin FOREIGN KEY (admin_id) REFERENCES [ADMIN](user_id)
        ON DELETE NO ACTION ON UPDATE NO ACTION
);

CREATE TABLE [LECTURER] (
    user_id        INT         NOT NULL,
    lecturer_code  NVARCHAR(20) NOT NULL,
    academic_rank  NVARCHAR(50) NULL,
    faculty_id     INT         NULL,                 -- BELONGS_TO
    CONSTRAINT pk_lecturer PRIMARY KEY (user_id),
    CONSTRAINT uq_lecturer_code UNIQUE (lecturer_code),
    CONSTRAINT fk_lecturer_user FOREIGN KEY (user_id) REFERENCES [USER](user_id)
        ON DELETE CASCADE ON UPDATE NO ACTION,
    CONSTRAINT fk_lecturer_faculty FOREIGN KEY (faculty_id) REFERENCES [FACULTY](faculty_id)
        ON DELETE SET NULL ON UPDATE NO ACTION
);

-- Thuoc tinh da tri degrees cua Lecturer
CREATE TABLE [LECTURER_DEGREE] (
    lecturer_id  INT         NOT NULL,
    degree       NVARCHAR(50) NOT NULL,
    CONSTRAINT pk_lecturer_degree PRIMARY KEY (lecturer_id, degree),
    CONSTRAINT fk_degree_lecturer FOREIGN KEY (lecturer_id) REFERENCES [LECTURER](user_id)
        ON DELETE CASCADE ON UPDATE NO ACTION
);

CREATE TABLE [USER_SESSION] (
    session_id  INT IDENTITY(1,1) NOT NULL,
    login_time  DATETIME    NOT NULL DEFAULT (GETDATE()),
    ip_address  NVARCHAR(45) NULL,
    ua_id       INT         NOT NULL,                -- HAS_SESSION (toan bo)
    CONSTRAINT pk_session PRIMARY KEY (session_id),
    CONSTRAINT fk_session_user FOREIGN KEY (ua_id) REFERENCES [USER](ua_id)
        ON DELETE CASCADE ON UPDATE NO ACTION
);

-- ---------------------------------------------------------------------
-- 2. TO CHUC HOC THUAT
-- ---------------------------------------------------------------------
CREATE TABLE [SUBJECT] (
    subject_id    INT IDENTITY(1,1) NOT NULL,
    subject_name  NVARCHAR(150) NOT NULL,
    credit        SMALLINT     NOT NULL,
    faculty_id    INT          NULL,                 -- OFFERS
    CONSTRAINT pk_subject PRIMARY KEY (subject_id),
    CONSTRAINT fk_subject_faculty FOREIGN KEY (faculty_id) REFERENCES [FACULTY](faculty_id)
        ON DELETE SET NULL ON UPDATE NO ACTION,
    CONSTRAINT ck_subject_credit CHECK (credit BETWEEN 1 AND 10)
);

-- PREREQUISITE: N:M de quy tren SUBJECT.
-- NO ACTION de khong xoa mon hoc dang duoc khai bao la tien quyet.
CREATE TABLE [PREREQUISITE] (
    subject_id         INT NOT NULL,
    prereq_subject_id  INT NOT NULL,
    CONSTRAINT pk_prereq PRIMARY KEY (subject_id, prereq_subject_id),
    CONSTRAINT fk_prereq_subject FOREIGN KEY (subject_id) REFERENCES [SUBJECT](subject_id)
        ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT fk_prereq_prereq FOREIGN KEY (prereq_subject_id) REFERENCES [SUBJECT](subject_id)
        ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT ck_prereq_self CHECK (subject_id <> prereq_subject_id)
);

CREATE TABLE [SEMESTER] (
    semester_id     INT IDENTITY(1,1) NOT NULL,
    semester_start  DATE NOT NULL,
    semester_end    DATE NOT NULL,
    CONSTRAINT pk_semester PRIMARY KEY (semester_id),
    CONSTRAINT ck_semester_dates CHECK (semester_end > semester_start)
);

CREATE TABLE [STATUS] (
    status_id       INT IDENTITY(1,1) NOT NULL,
    status_display  NVARCHAR(50) NOT NULL,
    CONSTRAINT pk_status PRIMARY KEY (status_id)
);

CREATE TABLE [CLASS] (
    class_id     INT IDENTITY(1,1) NOT NULL,
    class_name   NVARCHAR(100) NOT NULL,
    subject_id   INT          NULL,                  -- OF_SUBJECT
    semester_id  INT          NULL,                  -- HELD_IN
    status_id    INT          NULL,                  -- HAS_STATUS
    lecturer_id  INT          NOT NULL,              -- TEACHES (Class toan bo)
    CONSTRAINT pk_class PRIMARY KEY (class_id),
    CONSTRAINT fk_class_subject FOREIGN KEY (subject_id) REFERENCES [SUBJECT](subject_id)
        ON DELETE SET NULL ON UPDATE NO ACTION,
    CONSTRAINT fk_class_semester FOREIGN KEY (semester_id) REFERENCES [SEMESTER](semester_id)
        ON DELETE SET NULL ON UPDATE NO ACTION,
    CONSTRAINT fk_class_status FOREIGN KEY (status_id) REFERENCES [STATUS](status_id)
        ON DELETE SET NULL ON UPDATE NO ACTION,
    CONSTRAINT fk_class_lecturer FOREIGN KEY (lecturer_id) REFERENCES [LECTURER](user_id)
        ON DELETE NO ACTION ON UPDATE NO ACTION
);

CREATE TABLE [ENROLLS] (
    student_id             INT        NOT NULL,
    class_id               INT        NOT NULL,
    is_allowed_to_discuss  BIT    NOT NULL DEFAULT (1),
    CONSTRAINT pk_enrolls PRIMARY KEY (student_id, class_id),
    CONSTRAINT fk_enrolls_student FOREIGN KEY (student_id) REFERENCES [STUDENT](user_id)
        ON DELETE CASCADE ON UPDATE NO ACTION,
    CONSTRAINT fk_enrolls_class FOREIGN KEY (class_id) REFERENCES [CLASS](class_id)
        ON DELETE CASCADE ON UPDATE NO ACTION
);

-- ---------------------------------------------------------------------
-- 3. THAO LUAN
-- ---------------------------------------------------------------------
CREATE TABLE [POST] (
    post_id           INT IDENTITY(1,1) NOT NULL,
    post_name         NVARCHAR(200) NOT NULL,
    post_description  NVARCHAR(MAX)         NULL,
    post_start        DATETIME     NOT NULL DEFAULT (GETDATE()),
    ua_id             INT          NULL,             -- CREATES
    class_id          INT          NULL,             -- HAS_POST
    CONSTRAINT pk_post PRIMARY KEY (post_id),
    CONSTRAINT fk_post_user FOREIGN KEY (ua_id) REFERENCES [USER](ua_id)
        ON DELETE SET NULL ON UPDATE NO ACTION,
    CONSTRAINT fk_post_class FOREIGN KEY (class_id) REFERENCES [CLASS](class_id)
        ON DELETE SET NULL ON UPDATE NO ACTION
);

CREATE TABLE [COMMENT] (
    comment_id         INT IDENTITY(1,1) NOT NULL,
    comment_content    NVARCHAR(MAX)     NOT NULL,
    comment_start      DATETIME NOT NULL DEFAULT (GETDATE()),
    post_id            INT      NOT NULL,            -- HAS_COMMENT (toan bo)
    ua_id              INT      NULL,                -- WRITES
    parent_comment_id  INT      NULL,                -- REPLIES_TO (de quy)
    CONSTRAINT pk_comment PRIMARY KEY (comment_id),
    CONSTRAINT fk_comment_post FOREIGN KEY (post_id) REFERENCES [POST](post_id)
        ON DELETE NO ACTION ON UPDATE NO ACTION, -- xoa COMMENT truoc khi xoa POST
    CONSTRAINT fk_comment_user FOREIGN KEY (ua_id) REFERENCES [USER](ua_id)
        ON DELETE SET NULL ON UPDATE NO ACTION,
    CONSTRAINT fk_comment_parent FOREIGN KEY (parent_comment_id) REFERENCES [COMMENT](comment_id)
        ON DELETE NO ACTION ON UPDATE NO ACTION -- cap nhat parent_comment_id truoc khi xoa comment cha
);

-- ---------------------------------------------------------------------
-- 4. NOI DUNG HOC TAP (thuc the yeu: khoa chinh to hop)
--    chapter_id / topic_id / file_id la khoa tung phan: gan thu cong
--    1,2,3... trong pham vi chu so huu.
-- ---------------------------------------------------------------------
CREATE TABLE [CHAPTER] (
    class_id      INT          NOT NULL,
    chapter_id    INT          NOT NULL,
    chapter_name  NVARCHAR(200) NOT NULL,
    CONSTRAINT pk_chapter PRIMARY KEY (class_id, chapter_id),
    CONSTRAINT fk_chapter_class FOREIGN KEY (class_id) REFERENCES [CLASS](class_id)
        ON DELETE CASCADE ON UPDATE NO ACTION
);

CREATE TABLE [TOPIC] (
    class_id       INT          NOT NULL,
    chapter_id     INT          NOT NULL,
    topic_id       INT          NOT NULL,
    topic_name     NVARCHAR(200) NOT NULL,
    topic_content  NVARCHAR(MAX)         NULL,
    CONSTRAINT pk_topic PRIMARY KEY (class_id, chapter_id, topic_id),
    CONSTRAINT fk_topic_chapter FOREIGN KEY (class_id, chapter_id) REFERENCES [CHAPTER](class_id, chapter_id)
        ON DELETE CASCADE ON UPDATE NO ACTION
);

CREATE TABLE [FILE] (
    class_id     INT          NOT NULL,
    chapter_id   INT          NOT NULL,
    topic_id     INT          NOT NULL,
    file_id      INT          NOT NULL,
    file_name    NVARCHAR(255) NOT NULL,
    file_path    NVARCHAR(500) NOT NULL,
    file_size    BIGINT       NULL,
    update_date  DATETIME     NULL,
    CONSTRAINT pk_file PRIMARY KEY (class_id, chapter_id, topic_id, file_id),
    CONSTRAINT fk_file_topic FOREIGN KEY (class_id, chapter_id, topic_id) REFERENCES [TOPIC](class_id, chapter_id, topic_id)
        ON DELETE CASCADE ON UPDATE NO ACTION,
    CONSTRAINT ck_file_size CHECK (
        file_size IS NULL OR file_size BETWEEN 0 AND (200 * 1024 * 1024)
    )
);

-- ---------------------------------------------------------------------
-- 5. KIEM TRA
-- ---------------------------------------------------------------------
-- TEST.class_id vua la FK cua HAS_TEST vua la mot nua FK to hop cua INCLUDES_TEST.
-- NO ACTION vi cac cot nay nam trong CHECK (va khong nen xoa lop/chuong dang co bai kiem tra).
CREATE TABLE [TEST] (
    test_id         INT IDENTITY(1,1) NOT NULL,
    test_name       NVARCHAR(200) NOT NULL,
    test_type       NVARCHAR(30)  NULL,
    test_start      DATETIME     NULL,
    test_end        DATETIME     NULL,
    test_timer      INT          NULL,               -- thoi gian lam bai (phut)
    max_attempts    INT          NOT NULL DEFAULT 1,
    grading_method  NVARCHAR(10)  NOT NULL DEFAULT 'HIGHEST',
    class_id        INT          NULL,               -- HAS_TEST
    chapter_id      INT          NULL,               -- INCLUDES_TEST (cung class_id)
    CONSTRAINT pk_test PRIMARY KEY (test_id),
    CONSTRAINT fk_test_class FOREIGN KEY (class_id) REFERENCES [CLASS](class_id)
        ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT fk_test_chapter FOREIGN KEY (class_id, chapter_id) REFERENCES [CHAPTER](class_id, chapter_id)
        ON DELETE NO ACTION ON UPDATE NO ACTION,
    CONSTRAINT ck_test_dates CHECK (test_start IS NULL OR test_end IS NULL OR test_end > test_start),
    CONSTRAINT ck_test_timer CHECK (test_timer IS NULL OR test_timer > 0),
    CONSTRAINT ck_test_timer_window CHECK (
        test_timer IS NULL
        OR (
            test_timer > 0
            AND test_start IS NOT NULL
            AND test_end IS NOT NULL
            AND CONVERT(BIGINT, test_timer) * 60 <= DATEDIFF_BIG(SECOND, test_start, test_end)
        )
    ),
    CONSTRAINT ck_test_attempts CHECK (max_attempts >= 1),
    CONSTRAINT ck_test_grading CHECK (grading_method IN ('HIGHEST','AVERAGE','FIRST','LATEST')),
    CONSTRAINT ck_test_chapter_class CHECK (chapter_id IS NULL OR class_id IS NOT NULL)
);

-- final_score: THUOC TINH DAN XUAT cua TAKES_TEST, luu lai de trigger 2.2.2 tinh
-- (tinh tu ATTEMPT.score theo TEST.grading_method). Xoa cot neu nhom khong dung.
CREATE TABLE [TAKES_TEST] (
    student_id   INT          NOT NULL,
    test_id      INT          NOT NULL,
    final_score  DECIMAL(5,2) NULL,
    CONSTRAINT pk_takes_test PRIMARY KEY (student_id, test_id),
    CONSTRAINT fk_takes_student FOREIGN KEY (student_id) REFERENCES [STUDENT](user_id)
        ON DELETE CASCADE ON UPDATE NO ACTION,
    CONSTRAINT fk_takes_test FOREIGN KEY (test_id) REFERENCES [TEST](test_id)
        ON DELETE CASCADE ON UPDATE NO ACTION,
    CONSTRAINT ck_takes_final CHECK (final_score IS NULL OR final_score >= 0)
);

CREATE TABLE [QUESTION] (
    question_id       INT IDENTITY(1,1) NOT NULL,
    question_type     NVARCHAR(30)  NOT NULL,
    question_content  NVARCHAR(MAX)         NOT NULL,
    max_score         DECIMAL(5,2) NOT NULL DEFAULT 1,
    CONSTRAINT pk_question PRIMARY KEY (question_id),
    CONSTRAINT ck_question_score CHECK (max_score > 0)
);

CREATE TABLE [CONTAINS_QUESTION] (
    test_id      INT          NOT NULL,
    question_id  INT          NOT NULL,
    custom_score DECIMAL(5,2) NULL,                  -- NULL = dung QUESTION.max_score
    CONSTRAINT pk_contains PRIMARY KEY (test_id, question_id),
    CONSTRAINT fk_contains_test FOREIGN KEY (test_id) REFERENCES [TEST](test_id)
        ON DELETE CASCADE ON UPDATE NO ACTION,
    CONSTRAINT fk_contains_question FOREIGN KEY (question_id) REFERENCES [QUESTION](question_id)
        ON DELETE CASCADE ON UPDATE NO ACTION,
    CONSTRAINT ck_contains_score CHECK (custom_score IS NULL OR custom_score >= 0)
);

CREATE TABLE [CHOICE] (
    choice_id       INT IDENTITY(1,1) NOT NULL,
    choice_content  NVARCHAR(MAX)     NOT NULL,
    is_true         BIT  NOT NULL DEFAULT (0),
    question_id     INT      NULL,                   -- HAS_CHOICE
    CONSTRAINT pk_choice PRIMARY KEY (choice_id),
    CONSTRAINT fk_choice_question FOREIGN KEY (question_id) REFERENCES [QUESTION](question_id)
        ON DELETE SET NULL ON UPDATE NO ACTION
);

-- score: THUOC TINH DAN XUAT cua ATTEMPT (tong score_awarded), luu lai de trigger tinh.
-- timer (= end_time - start_time) khong luu; tinh bang DATEDIFF/DATEADD hoac phut giua hai moc khi truy van.
CREATE TABLE [ATTEMPT] (
    attempt_id     INT IDENTITY(1,1) NOT NULL,
    attempt_index  INT          NOT NULL DEFAULT 1,
    start_time     DATETIME     NOT NULL,
    end_time       DATETIME     NULL,
    score          DECIMAL(5,2) NULL,
    student_id     INT          NULL,                -- MAKES
    test_id        INT          NULL,                -- HAS_ATTEMPT
    CONSTRAINT pk_attempt PRIMARY KEY (attempt_id),
    CONSTRAINT fk_attempt_student FOREIGN KEY (student_id) REFERENCES [STUDENT](user_id)
        ON DELETE SET NULL ON UPDATE NO ACTION,
    CONSTRAINT fk_attempt_test FOREIGN KEY (test_id) REFERENCES [TEST](test_id)
        ON DELETE SET NULL ON UPDATE NO ACTION,
    CONSTRAINT ck_attempt_index CHECK (attempt_index >= 1),
    CONSTRAINT ck_attempt_time CHECK (end_time IS NULL OR end_time >= start_time),
    CONSTRAINT ck_attempt_score CHECK (score IS NULL OR score >= 0)
);

-- Filtered unique index: keep MySQL's behavior when student_id or test_id is NULL.
CREATE UNIQUE INDEX uq_attempt
    ON [ATTEMPT] (student_id, test_id, attempt_index)
    WHERE student_id IS NOT NULL AND test_id IS NOT NULL;

CREATE TABLE [STUDENT_ANSWER] (
    ans_id                INT IDENTITY(1,1) NOT NULL,
    answer_text           NVARCHAR(MAX)         NULL,
    file_submission_path  NVARCHAR(500) NULL,
    upload_time           DATETIME     NULL,
    score_awarded         DECIMAL(5,2) NULL,
    attempt_id            INT          NULL,         -- HAS_ANSWER
    question_id           INT          NULL,         -- ANSWERS
    choice_id             INT          NULL,         -- SELECTS (NULL voi cau tu luan)
    CONSTRAINT pk_answer PRIMARY KEY (ans_id),
    CONSTRAINT fk_answer_attempt FOREIGN KEY (attempt_id) REFERENCES [ATTEMPT](attempt_id)
        ON DELETE SET NULL ON UPDATE NO ACTION,
    CONSTRAINT fk_answer_question FOREIGN KEY (question_id) REFERENCES [QUESTION](question_id)
        ON DELETE SET NULL ON UPDATE NO ACTION,
    CONSTRAINT fk_answer_choice FOREIGN KEY (choice_id) REFERENCES [CHOICE](choice_id)
        ON DELETE NO ACTION ON UPDATE NO ACTION, -- khong xoa CHOICE khi da duoc STUDENT_ANSWER tham chieu
    CONSTRAINT ck_answer_score CHECK (score_awarded IS NULL OR score_awarded >= 0)
);

-- =====================================================================
-- KET QUA DOI CHIEU THEO PHU LUC BTL2:
--   * 25 bang; PK/FK theo luoc do quan he.
--   * UNIQUE: email, ua_id, ua_username, student_code, lecturer_code,
--             admin_code, faculty.admin_id va (student_id, test_id, attempt_index).
--   * CHECK: mien gia tri, ngay thang, email @hcmut.edu.vn, gioi han file
--            200 MB, test_timer va grading_method.
--   * Cac rang buoc lien bang/nhieu dong (RB2, RB3, RB5, RB6, ...) van can
--     duoc xu ly tai Trigger/Procedure theo phan cong BTL2; CHECK khong thay the duoc.
-- =====================================================================
