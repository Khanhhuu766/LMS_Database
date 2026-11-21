// ============================================================================
// core.js - Tiện ích dùng chung & Khởi tạo dữ liệu nền (Giai đoạn 1)
// ============================================================================

window.LMS_LOOKUPS = {
    classes: [],
    users: [],
    students: [],
    tests: [],
    semesters: [],
};

function escapeHtml(value) {
    if (value === null || value === undefined) return "";
    return String(value)
        .replace(/&/g, "&amp;")
        .replace(/</g, "&lt;")
        .replace(/>/g, "&gt;")
        .replace(/"/g, "&quot;")
        .replace(/'/g, "&#039;");
}

function formatDateTime(isoStr) {
    if (!isoStr) return "—";
    const d = new Date(isoStr);
    if (Number.isNaN(d.getTime())) return escapeHtml(isoStr);
    return d.toLocaleString("vi-VN", {
        year: "numeric",
        month: "2-digit",
        day: "2-digit",
        hour: "2-digit",
        minute: "2-digit",
    });
}

function showAlert(message, type = "danger", errorCode = null) {
    const container = document.getElementById("global-alert-container");
    if (!container) return;

    const codePrefix = errorCode ? `<strong>[Mã lỗi ${escapeHtml(errorCode)}]</strong> ` : "";
    const icon = type === "success" ? "bi-check-circle-fill" : "bi-exclamation-triangle-fill";

    container.innerHTML = `
        <div class="alert alert-${type} alert-dismissible fade show shadow-sm" role="alert">
            <i class="bi ${icon} me-2"></i>${codePrefix}${escapeHtml(message)}
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    `;
}

async function apiRequest(url, options = {}) {
    const defaultHeaders = { "Content-Type": "application/json" };
    const config = {
        ...options,
        headers: { ...defaultHeaders, ...(options.headers || {}) },
    };

    try {
        const res = await fetch(url, config);
        const payload = await res.json();
        return payload;
    } catch (err) {
        return {
            success: false,
            error_code: "NETWORK_ERROR",
            message: "Không thể kết nối đến máy chủ FastAPI: " + err.message,
        };
    }
}

async function checkDatabaseHealth() {
    const badge = document.getElementById("db-status-badge");
    const res = await apiRequest("/api/health");

    if (res.success && res.data) {
        badge.className = "badge bg-success px-3 py-2";
        badge.innerHTML = `<i class="bi bi-database-check me-1"></i>Đã kết nối: ${escapeHtml(res.data.database_name)} (${res.data.post_count} bài đăng • ${res.data.class_count} lớp)`;
    } else {
        badge.className = "badge bg-danger px-3 py-2";
        badge.innerHTML = `<i class="bi bi-database-x me-1"></i>Mất kết nối CSDL`;
        showAlert(res.message || "Không thể kết nối tới LMS_DB.", "danger", res.error_code);
    }
}

async function loadAllLookups() {
    const [clsRes, usrRes, stuRes, tstRes, semRes] = await Promise.all([
        apiRequest("/api/lookups/classes"),
        apiRequest("/api/lookups/users"),
        apiRequest("/api/lookups/students"),
        apiRequest("/api/lookups/tests"),
        apiRequest("/api/lookups/semesters"),
    ]);

    if (clsRes.success) window.LMS_LOOKUPS.classes = clsRes.data || [];
    if (usrRes.success) window.LMS_LOOKUPS.users = usrRes.data || [];
    if (stuRes.success) window.LMS_LOOKUPS.students = stuRes.data || [];
    if (tstRes.success) window.LMS_LOOKUPS.tests = tstRes.data || [];
    if (semRes.success) window.LMS_LOOKUPS.semesters = semRes.data || [];

    document.dispatchEvent(new CustomEvent("lms:lookups-ready", { detail: window.LMS_LOOKUPS }));
}

document.addEventListener("DOMContentLoaded", async () => {
    await checkDatabaseHealth();
    await loadAllLookups();
});