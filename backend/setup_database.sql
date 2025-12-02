-- ============================================
-- Setup Database cho Hi-Campus Project
-- ============================================

-- Tạo database hi_campus
CREATE DATABASE IF NOT EXISTS hi_campus CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Sử dụng database hi_campus
USE hi_campus;

-- ============================================
-- Table: users
-- Lưu trữ thông tin người dùng
-- ============================================
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    nickname VARCHAR(100),
    realname VARCHAR(100),
    main_language VARCHAR(10),
    nationality_iso2 VARCHAR(2),
    school_id INT,
    department_id INT,
    enrollment_year INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ============================================
-- Kiểm tra kết quả
-- ============================================
SHOW TABLES;
DESCRIBE users;

-- ============================================
-- Hướng dẫn sử dụng:
-- mysql -u root -p1234 < setup_database.sql
-- ============================================

