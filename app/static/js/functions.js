// ============================================================================
// functions.js - Giao diện Tab 3: Tính điểm Sinh viên bằng Hàm CURSOR (Mục 3.3)
// Người phụ trách: Nguyễn Hữu Khánh (Giai đoạn 2)
// ============================================================================

(function () {
    let isRendered = false;

    function buildStudentOptions() {
        const students = window.LMS_LOOKUPS.students || [];
        if (students.length === 0) {
            return `<option value="">-- Không có dữ liệu sinh viên --</option>`;
        }
        return students
            .map(
                (st) =>
                    `<option value="${st.student_id}" data-code="${escapeHtml(st.student_code)}">${escapeHtml(st.student_code)} - ${escapeHtml(st.full_name)}</option>`
            )
            .join("");
    }

    function buildTestOptions() {
        const tests = window.LMS_LOOKUPS.tests || [];
        if (tests.length === 0) {
            return `<option value="">-- Không có bài kiểm tra --</option>`;
        }
        return tests
            .map(
                (t) =>
                    `<option value="${t.test_id}">[ID ${t.test_id}] ${escapeHtml(t.test_name)} (${escapeHtml(t.grading_method)} - ${escapeHtml(t.class_name || "Chung")})</option>`
            )
            .join("");
    }

    function buildSemesterOptions() {
        const semesters = window.LMS_LOOKUPS.semesters || [];
        if (semesters.length === 0) {
            return `<option value="">-- Không có học kỳ --</option>`;
        }
        return semesters
            .map(
                (s) =>
                    `<option value="${s.semester_id}">Học kỳ ${s.semester_id} (${escapeHtml(s.semester_start)} → ${escapeHtml(s.semester_end)})</option>`
            )
            .join("");
    }

    function renderFunctionsUI() {
        const container = document.getElementById("cursor-functions-area");
        if (!container) return;

        const studentOpts = buildStudentOptions();
        const testOpts = buildTestOptions();
        const semesterOpts = buildSemesterOptions();

        container.classList.remove("text-muted");
        container.innerHTML = `
            <div class="row g-4">
                <!-- CARD 1: HÀM 1 - fn_CalculateStudentTestScore -->
                <div class="col-lg-6">
                    <div class="card border h-100">
                        <div class="card-header bg-light d-flex justify-content-between align-items-center">
                            <span class="fw-bold text-primary">
                                <i class="bi bi-journal-check me-1"></i>Hàm 1: Điểm chung cuộc Bài kiểm tra (RB26)
                            </span>
                            <span class="badge bg-secondary">fn_CalculateStudentTestScore</span>
                        </div>
                        <div class="card-body">
                            <form id="form-fn-test-score" class="vstack gap-3">
                                <div class="form-check form-switch">
                                    <input class="form-check-input" type="checkbox" id="fn1-manual-toggle">
                                    <label class="form-check-label small text-secondary" for="fn1-manual-toggle">
                                        Nhập ID thủ công (mặc định giữ nguyên ID đang chọn, có thể sửa tự do để test)
                                    </label>
                                </div>

                                <div id="fn1-select-group" class="vstack gap-2">
                                    <div>
                                        <label class="form-label fw-semibold mb-1">Sinh viên</label>
                                        <select class="form-select" id="fn1-student-select">${studentOpts}</select>
                                    </div>
                                    <div>
                                        <label class="form-label fw-semibold mb-1">Bài kiểm tra</label>
                                        <select class="form-select" id="fn1-test-select">${testOpts}</select>
                                    </div>
                                </div>

                                <div id="fn1-manual-group" class="row g-2 d-none">
                                    <div class="col-6">
                                        <label class="form-label fw-semibold mb-1">MSSV (student_code)</label>
                                        <input type="text" class="form-control" id="fn1-student-input" value="2410001" placeholder="VD: 2410001 hoặc 9999999">
                                        <div class="form-text">VD hợp lệ: 2410001..2510005</div>
                                    </div>
                                    <div class="col-6">
                                        <label class="form-label fw-semibold mb-1">Test ID (test_id)</label>
                                        <input type="number" class="form-control" id="fn1-test-input" value="1" placeholder="Hợp lệ: 1..6 | Sai: -1, 999">
                                        <div class="form-text">Hợp lệ: 1..6</div>
                                    </div>
                                </div>

                                <button type="submit" class="btn btn-primary w-100">
                                    <i class="bi bi-play-fill me-1"></i>Tính điểm Bài kiểm tra
                                </button>
                            </form>

                            <hr>
                            <div id="fn1-result-box" class="small text-muted">
                                Chọn sinh viên và bài kiểm tra rồi bấm nút để gọi hàm <code>CURSOR</code> từ SQL Server.
                            </div>
                        </div>
                    </div>
                </div>

                <!-- CARD 2: HÀM 2 - fn_CalculateStudentEngagementScore -->
                <div class="col-lg-6">
                    <div class="card border h-100">
                        <div class="card-header bg-light d-flex justify-content-between align-items-center">
                            <span class="fw-bold text-success">
                                <i class="bi bi-award me-1"></i>Hàm 2: Điểm tích cực Học kỳ (Thang 100)
                            </span>
                            <span class="badge bg-secondary">fn_CalculateStudentEngagementScore</span>
                        </div>
                        <div class="card-body">
                            <form id="form-fn-engagement" class="vstack gap-3">
                                <div class="form-check form-switch">
                                    <input class="form-check-input" type="checkbox" id="fn2-manual-toggle">
                                    <label class="form-check-label small text-secondary" for="fn2-manual-toggle">
                                        Nhập ID thủ công (mặc định giữ nguyên ID đang chọn, có thể sửa tự do để test)
                                    </label>
                                </div>

                                <div id="fn2-select-group" class="vstack gap-2">
                                    <div>
                                        <label class="form-label fw-semibold mb-1">Sinh viên</label>
                                        <select class="form-select" id="fn2-student-select">${studentOpts}</select>
                                    </div>
                                    <div>
                                        <label class="form-label fw-semibold mb-1">Học kỳ</label>
                                        <select class="form-select" id="fn2-semester-select">${semesterOpts}</select>
                                    </div>
                                </div>

                                <div id="fn2-manual-group" class="row g-2 d-none">
                                    <div class="col-6">
                                        <label class="form-label fw-semibold mb-1">MSSV (student_code)</label>
                                        <input type="text" class="form-control" id="fn2-student-input" value="2410001" placeholder="VD: 2410001 hoặc 9999999">
                                        <div class="form-text">VD hợp lệ: 2410001..2510005</div>
                                    </div>
                                    <div class="col-6">
                                        <label class="form-label fw-semibold mb-1">Semester ID (semester_id)</label>
                                        <input type="number" class="form-control" id="fn2-semester-input" value="1" placeholder="Hợp lệ: 1..6 | Sai: -2, 999">
                                        <div class="form-text">Hợp lệ: 1..6</div>
                                    </div>
                                </div>

                                <button type="submit" class="btn btn-success w-100">
                                    <i class="bi bi-play-fill me-1"></i>Tính điểm Tích cực
                                </button>
                            </form>

                            <hr>
                            <div id="fn2-result-box" class="small text-muted">
                                Chọn sinh viên và học kỳ rồi bấm nút để tính điểm tổng hợp theo từng lớp đã đăng ký.
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        `;

        bindEvents();
        isRendered = true;
    }

    function bindEvents() {
        const fn1Toggle = document.getElementById("fn1-manual-toggle");
        const fn1SelectGroup = document.getElementById("fn1-select-group");
        const fn1ManualGroup = document.getElementById("fn1-manual-group");

        fn1Toggle.addEventListener("change", () => {
            if (fn1Toggle.checked) {
                const sel = document.getElementById("fn1-student-select");
                const selectedOpt = sel.options[sel.selectedIndex];
                document.getElementById("fn1-student-input").value =
                    selectedOpt?.dataset?.code || "2410001";
                document.getElementById("fn1-test-input").value =
                    document.getElementById("fn1-test-select").value || "1";
            }
            fn1SelectGroup.classList.toggle("d-none", fn1Toggle.checked);
            fn1ManualGroup.classList.toggle("d-none", !fn1Toggle.checked);
        });

        const fn2Toggle = document.getElementById("fn2-manual-toggle");
        const fn2SelectGroup = document.getElementById("fn2-select-group");
        const fn2ManualGroup = document.getElementById("fn2-manual-group");

        fn2Toggle.addEventListener("change", () => {
            if (fn2Toggle.checked) {
                const sel = document.getElementById("fn2-student-select");
                const selectedOpt = sel.options[sel.selectedIndex];
                document.getElementById("fn2-student-input").value =
                    selectedOpt?.dataset?.code || "2410001";
                document.getElementById("fn2-semester-input").value =
                    document.getElementById("fn2-semester-select").value || "1";
            }
            fn2SelectGroup.classList.toggle("d-none", fn2Toggle.checked);
            fn2ManualGroup.classList.toggle("d-none", !fn2Toggle.checked);
        });

        document.getElementById("form-fn-test-score").addEventListener("submit", handleTestScoreSubmit);
        document.getElementById("form-fn-engagement").addEventListener("submit", handleEngagementSubmit);
    }

    async function handleTestScoreSubmit(event) {
        event.preventDefault();
        const resultBox = document.getElementById("fn1-result-box");
        const isManual = document.getElementById("fn1-manual-toggle").checked;

        const studentParam = isManual
            ? `student_code=${encodeURIComponent(document.getElementById("fn1-student-input").value.trim())}`
            : `student_id=${encodeURIComponent(document.getElementById("fn1-student-select").value)}`;
        const studentValueCheck = isManual
            ? document.getElementById("fn1-student-input").value.trim()
            : document.getElementById("fn1-student-select").value;
        const testId = isManual
            ? document.getElementById("fn1-test-input").value.trim()
            : document.getElementById("fn1-test-select").value;

        if (!studentValueCheck || !testId) {
            resultBox.innerHTML = `<div class="alert alert-warning mb-0">Vui lòng nhập đầy đủ MSSV và Test ID.</div>`;
            return;
        }

        resultBox.innerHTML = `<div class="text-secondary"><i class="bi bi-hourglass-split me-1"></i>Đang tính toán...</div>`;

        const res = await apiRequest(
            `/api/functions/test-score?${studentParam}&test_id=${encodeURIComponent(testId)}`
        );

        if (!res.success) {
            resultBox.innerHTML = `<div class="alert alert-danger mb-0"><strong>Lỗi (${escapeHtml(res.error_code)}):</strong> ${escapeHtml(res.message)}</div>`;
            return;
        }

        const d = res.data;
        const alertMap = {
            OK: "alert-success",
            NO_ATTEMPT: "alert-secondary",
            NOT_ENROLLED: "alert-warning",
            INVALID_PARAM: "alert-danger",
        };
        const alertClass = alertMap[d.status] || "alert-info";
        const displayScore = d.final_score === null ? "NULL" : Number(d.final_score).toFixed(2);

        let attemptsHtml = "";
        if (d.attempts && d.attempts.length > 0) {
            const rows = d.attempts
                .map(
                    (a) => `
                    <tr>
                        <td>Lần ${escapeHtml(a.attempt_index)}</td>
                        <td>${formatDateTime(a.start_time)}</td>
                        <td>${formatDateTime(a.end_time)}</td>
                        <td class="fw-bold text-end">${a.score !== null ? Number(a.score).toFixed(2) : "NULL"}</td>
                    </tr>`
                )
                .join("");
            attemptsHtml = `
                <div class="mt-3">
                    <div class="fw-semibold mb-1 text-dark">Chi tiết các lần làm bài (ATTEMPT):</div>
                    <div class="table-responsive">
                        <table class="table table-sm table-bordered mb-0 align-middle">
                            <thead class="table-light">
                                <tr>
                                    <th>Lần</th>
                                    <th>Bắt đầu</th>
                                    <th>Nộp bài</th>
                                    <th class="text-end">Điểm</th>
                                </tr>
                            </thead>
                            <tbody>${rows}</tbody>
                        </table>
                    </div>
                </div>`;
        }

        const studentMeta = d.student
            ? `${escapeHtml(d.student.full_name)} (MSSV: ${escapeHtml(d.student.student_code)})`
            : `<span class="text-danger">Không tìm thấy sinh viên (${escapeHtml(d.student_code || d.student_id)})</span>`;
        const testMeta = d.test
            ? `${escapeHtml(d.test.test_name)} — ${escapeHtml(d.test.class_name || "Chung")} [${escapeHtml(d.test.grading_method)}]`
            : `<span class="text-danger">Không tìm thấy bài kiểm tra (ID: ${escapeHtml(d.test_id)})</span>`;

        resultBox.innerHTML = `
            <div class="alert ${alertClass} mb-0">
                <div class="d-flex justify-content-between align-items-center mb-1">
                    <span class="fw-bold">${escapeHtml(d.status_label)}</span>
                    <span class="fs-4 fw-bold">${escapeHtml(displayScore)}</span>
                </div>
                <div class="small border-top border-dark border-opacity-10 pt-2 mt-1 mb-1">
                    <div><strong>Sinh viên:</strong> ${studentMeta}</div>
                    <div><strong>Bài kiểm tra:</strong> ${testMeta}</div>
                </div>
                <div class="small text-opacity-75">${escapeHtml(d.explanation)}</div>
            </div>
            ${attemptsHtml}
        `;
    }

    async function handleEngagementSubmit(event) {
        event.preventDefault();
        const resultBox = document.getElementById("fn2-result-box");
        const isManual = document.getElementById("fn2-manual-toggle").checked;

        const studentParam = isManual
            ? `student_code=${encodeURIComponent(document.getElementById("fn2-student-input").value.trim())}`
            : `student_id=${encodeURIComponent(document.getElementById("fn2-student-select").value)}`;
        const studentValueCheck = isManual
            ? document.getElementById("fn2-student-input").value.trim()
            : document.getElementById("fn2-student-select").value;
        const semesterId = isManual
            ? document.getElementById("fn2-semester-input").value.trim()
            : document.getElementById("fn2-semester-select").value;

        if (!studentValueCheck || !semesterId) {
            resultBox.innerHTML = `<div class="alert alert-warning mb-0">Vui lòng nhập đầy đủ MSSV và Semester ID.</div>`;
            return;
        }

        resultBox.innerHTML = `<div class="text-secondary"><i class="bi bi-hourglass-split me-1"></i>Đang tính toán...</div>`;

        const res = await apiRequest(
            `/api/functions/engagement-score?${studentParam}&semester_id=${encodeURIComponent(semesterId)}`
        );

        if (!res.success) {
            resultBox.innerHTML = `<div class="alert alert-danger mb-0"><strong>Lỗi (${escapeHtml(res.error_code)}):</strong> ${escapeHtml(res.message)}</div>`;
            return;
        }

        const d = res.data;
        const alertMap = {
            OK: "alert-success",
            NO_CLASSES: "alert-secondary",
            INVALID_PARAM: "alert-danger",
        };
        const alertClass = alertMap[d.status] || "alert-info";
        const scoreVal = d.engagement_score !== null ? Number(d.engagement_score) : 0;
        const displayScore = d.engagement_score === null ? "NULL" : scoreVal.toFixed(2);
        const progressPct = Math.max(0, Math.min(100, scoreVal));

        let progressHtml = "";
        if (d.status !== "INVALID_PARAM") {
            progressHtml = `
                <div class="progress mt-2" style="height: 10px;">
                    <div class="progress-bar bg-success" role="progressbar" style="width: ${progressPct}%;"
                         aria-valuenow="${progressPct}" aria-valuemin="0" aria-valuemax="100"></div>
                </div>`;
        }

        let breakdownHtml = "";
        if (d.classes_breakdown && d.classes_breakdown.length > 0) {
            const rows = d.classes_breakdown
                .map((c) => {
                    const discussBadge = c.is_allowed_to_discuss
                        ? `<span class="badge bg-success-subtle text-success border border-success-subtle">Được thảo luận</span>`
                        : `<span class="badge bg-danger-subtle text-danger border border-danger-subtle">Bị khóa (-5đ)</span>`;
                    return `
                        <tr>
                            <td>${escapeHtml(c.class_name)}</td>
                            <td>${discussBadge}</td>
                            <td class="text-center">${escapeHtml(c.post_count)} / ${escapeHtml(c.comment_count)}</td>
                            <td class="text-center">${escapeHtml(c.completed_tests)} / ${escapeHtml(c.total_tests)}</td>
                        </tr>`;
                })
                .join("");

            breakdownHtml = `
                <div class="mt-3">
                    <div class="fw-semibold mb-1 text-dark">Chi tiết các lớp đã duyệt qua bằng CURSOR:</div>
                    <div class="table-responsive">
                        <table class="table table-sm table-bordered mb-0 align-middle">
                            <thead class="table-light">
                                <tr>
                                    <th>Lớp học</th>
                                    <th>Thảo luận</th>
                                    <th class="text-center">Post / Cmt</th>
                                    <th class="text-center">Bài test</th>
                                </tr>
                            </thead>
                            <tbody>${rows}</tbody>
                        </table>
                    </div>
                </div>`;
        }

        const studentMeta = d.student
            ? `${escapeHtml(d.student.full_name)} (MSSV: ${escapeHtml(d.student.student_code)})`
            : `<span class="text-danger">Không tìm thấy sinh viên (${escapeHtml(d.student_code || d.student_id)})</span>`;
        const semesterMeta = d.semester
            ? `Học kỳ ${escapeHtml(d.semester.semester_id)} (${escapeHtml(d.semester.semester_start)} → ${escapeHtml(d.semester.semester_end)})`
            : `<span class="text-danger">Không tìm thấy học kỳ (ID: ${escapeHtml(d.semester_id)})</span>`;

        resultBox.innerHTML = `
            <div class="alert ${alertClass} mb-0">
                <div class="d-flex justify-content-between align-items-center mb-1">
                    <span class="fw-bold">${escapeHtml(d.status_label)}</span>
                    <span class="fs-4 fw-bold">${escapeHtml(displayScore)}${d.status !== "INVALID_PARAM" ? " / 100" : ""}</span>
                </div>
                <div class="small border-top border-dark border-opacity-10 pt-2 mt-1 mb-1">
                    <div><strong>Sinh viên:</strong> ${studentMeta}</div>
                    <div><strong>Học kỳ:</strong> ${semesterMeta}</div>
                </div>
                <div class="small text-opacity-75">${escapeHtml(d.explanation)}</div>
                ${progressHtml}
            </div>
            ${breakdownHtml}
        `;
    }

    document.addEventListener("lms:lookups-ready", () => {
        if (!isRendered) renderFunctionsUI();
    });

    document.addEventListener("DOMContentLoaded", () => {
        if (
            !isRendered &&
            window.LMS_LOOKUPS &&
            ((window.LMS_LOOKUPS.students || []).length > 0 ||
                (window.LMS_LOOKUPS.tests || []).length > 0)
        ) {
            renderFunctionsUI();
        }
    });
})();
