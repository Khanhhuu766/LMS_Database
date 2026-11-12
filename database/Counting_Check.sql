USE LMS_DB;
GO

-- 1. Kiem tra so luong bang
SELECT COUNT(*) AS Total_Tables
FROM sys.tables;
GO

-- 2. Kiem tra so luong Primary Key
SELECT COUNT(*) AS Total_Primary_Keys
FROM sys.key_constraints
WHERE type = 'PK';
GO

-- 3. Kiem tra so luong Foreign Key
SELECT COUNT(*) AS Total_Foreign_Keys
FROM sys.foreign_keys;
GO

-- 4. Kiem tra so luong UNIQUE
SELECT COUNT(*) AS Total_Unique_Constraints
FROM sys.key_constraints
WHERE type = 'UQ';
GO

-- 5. Kiem tra so luong CHECK
SELECT COUNT(*) AS Total_Check_Constraints
FROM sys.check_constraints;
GO

-- 6. Liet ke tat ca cac bang
SELECT name AS Table_Name
FROM sys.tables
ORDER BY name;
GO