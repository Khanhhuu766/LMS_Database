-- =================================================================================
-- KHỞI TẠO CƠ SỞ DỮ LIỆU HỆ THỐNG E-LEARNING (BK-LMS)
-- Hệ QTCSDL : MS SQL Server
-- =================================================================================

-- TODO: Viết lệnh tạo và sử dụng Database tại đây
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'LMS_DB')
BEGIN
    CREATE DATABASE LMS_DB;
END;
GO

-- Chuyển ngữ cảnh làm việc sang database vừa tạo
USE LMS_DB;
GO