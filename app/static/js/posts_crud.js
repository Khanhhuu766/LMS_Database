(() => {
    const byId = (id) => document.getElementById(id);
    const dialog = byId("post-crud-modal");
    const modal = bootstrap.Modal.getOrCreateInstance(dialog);
    const form = byId("post-crud-form");
    const title = byId("post-crud-title");
    const feedback = byId("post-crud-feedback");
    const lookup = byId("post-crud-lookup");
    const postIdInput = byId("post-crud-id");
    const loadButton = byId("post-crud-load");
    const summary = byId("post-crud-summary");
    const confirmation = byId("post-crud-delete-confirmation");
    const fields = byId("post-crud-fields");
    const contentFields = byId("post-crud-content");
    const nameInput = byId("post-crud-name");
    const descriptionInput = byId("post-crud-description");
    const account = byId("post-crud-account");
    const accountLabel = byId("post-crud-account-label");
    const classField = byId("post-crud-class-field");
    const classSelect = byId("post-crud-class");
    const submitButton = byId("post-crud-submit");

    const actions = {
        create: { title: "Tạo bài đăng mới", button: "Tạo bài đăng", success: "Đã tạo bài đăng" },
        edit: { title: "Sửa bài đăng", button: "Lưu thay đổi", success: "Đã cập nhật bài đăng" },
        delete: { title: "Xác nhận xóa bài đăng", button: "Xác nhận xóa", success: "Đã xóa bài đăng" },
    };

    let mode = "create";
    let post = null;
    let pending = false;
    let opener = null;

    function readId(value) {
        const id = Number(value);
        return /^\d+$/.test(value) && id > 0 && id <= 2147483647 ? id : null;
    }

    function setFeedback(message = "", errorCode = null) {
        feedback.textContent = errorCode ? `[Mã lỗi ${errorCode}] ${message}` : message;
        feedback.hidden = !message;
    }

    function fillOptions(select, placeholder, records, valueOf, labelOf) {
        const previousValue = select.value;
        select.replaceChildren(new Option(placeholder, ""));
        for (const record of records) {
            select.add(new Option(labelOf(record), valueOf(record)));
        }
        select.value = previousValue;
        if (select.selectedIndex === -1) select.selectedIndex = 0;
    }

    function fillLookups() {
        const { users, classes } = window.LMS_LOOKUPS;
        fillOptions(account, "Chọn tài khoản", users, (user) => user.ua_id,
            (user) => `${user.full_name} · ${user.ua_username} (ID ${user.ua_id})`);
        fillOptions(classSelect, "Bài đăng chung", classes, (item) => item.class_id,
            (item) => `${item.class_name} (ID ${item.class_id})`);
    }

    function updateControls() {
        const needsPost = mode !== "create" && !post;
        postIdInput.disabled = pending;
        loadButton.disabled = pending;
        fields.hidden = needsPost;
        fields.disabled = pending || needsPost;
        submitButton.disabled = pending || needsPost;
        confirmation.hidden = mode !== "delete" || !post;
        dialog.setAttribute("aria-busy", String(pending));
    }

    function clearPost() {
        post = null;
        summary.hidden = true;
        summary.textContent = "";
        nameInput.value = "";
        descriptionInput.value = "";
        account.value = "";
    }

    async function loadPost() {
        if (pending) return;
        clearPost();
        const id = readId(postIdInput.value);
        if (id === null) {
            setFeedback("Hãy nhập ID bài đăng là số nguyên dương hợp lệ.");
            updateControls();
            postIdInput.focus();
            return;
        }

        setFeedback();
        pending = true;
        updateControls();
        const response = await apiRequest(`/api/posts/${id}`);
        pending = false;

        if (!response.success) {
            setFeedback(response.message, response.error_code);
            updateControls();
            return;
        }

        post = response.data;
        if (mode === "edit") {
            nameInput.value = post.post_name;
            descriptionInput.value = post.post_description ?? "";
        }
        summary.textContent = `Bài #${post.post_id} · ${post.post_name}`;
        summary.hidden = false;
        updateControls();
        if (dialog.classList.contains("show")) {
            (mode === "edit" ? nameInput : account).focus();
        }
    }

    function openModal(action, id = null) {
        if (pending || dialog.classList.contains("show")) return;
        mode = action;
        opener = document.activeElement;
        form.reset();
        clearPost();
        fillLookups();
        setFeedback();
        title.textContent = actions[mode].title;
        lookup.hidden = mode === "create";
        contentFields.hidden = mode === "delete";
        classField.hidden = mode !== "create";
        accountLabel.textContent = mode === "create" ? "Tài khoản tác giả" : "Tài khoản thực hiện";
        submitButton.textContent = actions[mode].button;
        submitButton.classList.toggle("btn-danger", mode === "delete");
        submitButton.classList.toggle("btn-primary", mode !== "delete");
        postIdInput.value = id ?? "";
        updateControls();
        modal.show();
        if (id !== null) void loadPost();
    }

    function validateForm() {
        if (mode !== "delete") {
            const name = nameInput.value.trim();
            if (name.length === 0 || name.length > 200) {
                setFeedback("Tên bài đăng phải có từ 1 đến 200 ký tự.");
                nameInput.focus();
                return false;
            }
        }
        if (readId(account.value) === null) {
            setFeedback("Hãy chọn tài khoản thực hiện thao tác.");
            account.focus();
            return false;
        }
        return true;
    }

    async function submitPost(event) {
        event.preventDefault();
        if (pending || (mode !== "create" && !post) || !validateForm()) return;

        const uaId = readId(account.value);
        const body = {
            post_name: nameInput.value.trim(),
            post_description: descriptionInput.value.trim() || null,
        };
        let url = "/api/posts";
        const options = {};

        switch (mode) {
            case "create":
                options.method = "POST";
                options.body = JSON.stringify({
                    ...body,
                    ua_id: uaId,
                    class_id: readId(classSelect.value),
                });
                break;
            case "edit":
                url += `/${post.post_id}`;
                options.method = "PUT";
                options.body = JSON.stringify({ ...body, requester_ua_id: uaId });
                break;
            case "delete":
                url += `/${post.post_id}?requester_ua_id=${uaId}`;
                options.method = "DELETE";
                break;
        }

        setFeedback();
        pending = true;
        updateControls();
        const response = await apiRequest(url, options);
        pending = false;
        updateControls();

        if (!response.success) {
            setFeedback(response.message, response.error_code);
            return;
        }

        const postId = response.data.post_id;
        modal.hide();
        showAlert(`${actions[mode].success} #${postId}.`, "success");
        document.dispatchEvent(new CustomEvent("lms:posts-changed", {
            detail: { action: mode, postId },
        }));
    }

    byId("btn-open-create-post").addEventListener("click", () => openModal("create"));
    byId("btn-open-edit-post").addEventListener("click", () => openModal("edit"));
    byId("btn-open-delete-post").addEventListener("click", () => openModal("delete"));
    form.addEventListener("submit", submitPost);
    postIdInput.addEventListener("input", () => {
        clearPost();
        setFeedback();
        updateControls();
    });
    postIdInput.addEventListener("keydown", (event) => {
        if (event.key === "Enter") {
            event.preventDefault();
            void loadPost();
        }
    });
    loadButton.addEventListener("click", loadPost);
    document.addEventListener("lms:lookups-ready", fillLookups);

    dialog.addEventListener("shown.bs.modal", () => {
        if (!pending) {
            const firstField = mode === "create" || (post && mode === "edit") ? nameInput : postIdInput;
            (post && mode === "delete" ? account : firstField).focus();
        }
    });
    dialog.addEventListener("hide.bs.modal", (event) => {
        if (pending) event.preventDefault();
    });
    dialog.addEventListener("hidden.bs.modal", () => opener?.focus());

    // Các nút trên từng dòng của Mục 3.2 có thể mở trực tiếp bài đã chọn.
    window.openEditPost = (postId) => openModal("edit", postId);
    window.openDeletePost = (postId) => openModal("delete", postId);
})();
