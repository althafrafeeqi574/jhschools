-- ============================================================
-- SCHOOL MANAGEMENT SYSTEM - DATABASE SCHEMA
-- ============================================================

-- Create Database
CREATE DATABASE IF NOT EXISTS school_management;
USE school_management;

-- ============================================================
-- USERS TABLE (Admin, Teachers, Students, Parents)
-- ============================================================
CREATE TABLE IF NOT EXISTS users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(15),
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    role ENUM('admin', 'teacher', 'student', 'parent') NOT NULL,
    profile_picture LONGBLOB,
    status ENUM('active', 'inactive') DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_username (username),
    INDEX idx_email (email),
    INDEX idx_role (role)
);

-- ============================================================
-- ACADEMIC YEAR TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS academic_years (
    id INT PRIMARY KEY AUTO_INCREMENT,
    year INT NOT NULL UNIQUE,
    start_date DATE,
    end_date DATE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ============================================================
-- CLASSES TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS classes (
    id INT PRIMARY KEY AUTO_INCREMENT,
    class_name VARCHAR(50),
    class_number INT,
    section VARCHAR(10),
    room_number VARCHAR(20),
    capacity INT,
    class_teacher_id INT,
    academic_year_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (class_teacher_id) REFERENCES users(id),
    FOREIGN KEY (academic_year_id) REFERENCES academic_years(id),
    UNIQUE KEY unique_class (class_number, section, academic_year_id),
    INDEX idx_class_teacher (class_teacher_id)
);

-- ============================================================
-- SUBJECTS TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS subjects (
    id INT PRIMARY KEY AUTO_INCREMENT,
    subject_name VARCHAR(100) NOT NULL,
    subject_code VARCHAR(20) UNIQUE,
    class_id INT,
    teacher_id INT,
    total_marks INT DEFAULT 100,
    passing_marks INT DEFAULT 35,
    academic_year_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (class_id) REFERENCES classes(id),
    FOREIGN KEY (teacher_id) REFERENCES users(id),
    FOREIGN KEY (academic_year_id) REFERENCES academic_years(id),
    INDEX idx_class (class_id),
    INDEX idx_teacher (teacher_id)
);

-- ============================================================
-- STUDENTS TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS students (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL UNIQUE,
    roll_number VARCHAR(20) NOT NULL,
    date_of_birth DATE,
    gender ENUM('M', 'F', 'Other'),
    blood_group VARCHAR(5),
    address VARCHAR(255),
    city VARCHAR(50),
    state VARCHAR(50),
    pin_code VARCHAR(10),
    enrollment_date DATE,
    class_id INT,
    parent_id INT,
    previous_school VARCHAR(100),
    status ENUM('active', 'inactive', 'transferred', 'graduated') DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (class_id) REFERENCES classes(id),
    FOREIGN KEY (parent_id) REFERENCES users(id),
    INDEX idx_user (user_id),
    INDEX idx_class (class_id),
    INDEX idx_roll (roll_number),
    INDEX idx_parent (parent_id)
);

-- ============================================================
-- TEACHERS TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS teachers (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL UNIQUE,
    employee_id VARCHAR(20) UNIQUE,
    date_of_birth DATE,
    gender ENUM('M', 'F', 'Other'),
    qualification VARCHAR(100),
    specialization VARCHAR(100),
    experience_years INT,
    joining_date DATE,
    department VARCHAR(50),
    designation VARCHAR(50),
    address VARCHAR(255),
    salary DECIMAL(10, 2),
    status ENUM('active', 'inactive', 'leave') DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id),
    INDEX idx_user (user_id),
    INDEX idx_employee (employee_id)
);

-- ============================================================
-- ATTENDANCE TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS attendance (
    id INT PRIMARY KEY AUTO_INCREMENT,
    student_id INT NOT NULL,
    class_id INT NOT NULL,
    attendance_date DATE NOT NULL,
    status ENUM('present', 'absent', 'leave', 'half-day') DEFAULT 'absent',
    remarks VARCHAR(255),
    marked_by INT,
    marked_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES students(id),
    FOREIGN KEY (class_id) REFERENCES classes(id),
    FOREIGN KEY (marked_by) REFERENCES users(id),
    UNIQUE KEY unique_attendance (student_id, attendance_date),
    INDEX idx_date (attendance_date),
    INDEX idx_student (student_id),
    INDEX idx_class (class_id)
);

-- ============================================================
-- GRADES TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS grades (
    id INT PRIMARY KEY AUTO_INCREMENT,
    student_id INT NOT NULL,
    subject_id INT NOT NULL,
    exam_type VARCHAR(50),
    marks_obtained DECIMAL(5, 2),
    total_marks INT,
    percentage DECIMAL(5, 2),
    grade VARCHAR(2),
    remarks VARCHAR(255),
    academic_year_id INT,
    semester INT,
    entered_by INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES students(id),
    FOREIGN KEY (subject_id) REFERENCES subjects(id),
    FOREIGN KEY (academic_year_id) REFERENCES academic_years(id),
    FOREIGN KEY (entered_by) REFERENCES users(id),
    INDEX idx_student (student_id),
    INDEX idx_subject (subject_id),
    INDEX idx_exam_type (exam_type)
);

-- ============================================================
-- FEES TABLE (Student Accounts)
-- ============================================================
CREATE TABLE IF NOT EXISTS fees (
    id INT PRIMARY KEY AUTO_INCREMENT,
    student_id INT NOT NULL,
    academic_year_id INT,
    fee_type VARCHAR(50),
    description VARCHAR(255),
    amount DECIMAL(10, 2),
    due_date DATE,
    paid_date DATE,
    status ENUM('pending', 'paid', 'overdue', 'cancelled') DEFAULT 'pending',
    payment_method VARCHAR(50),
    transaction_id VARCHAR(100),
    receipt_number VARCHAR(50),
    notes VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES students(id),
    FOREIGN KEY (academic_year_id) REFERENCES academic_years(id),
    INDEX idx_student (student_id),
    INDEX idx_status (status),
    INDEX idx_paid_date (paid_date)
);

-- ============================================================
-- REPORT CARD TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS report_cards (
    id INT PRIMARY KEY AUTO_INCREMENT,
    student_id INT NOT NULL,
    academic_year_id INT NOT NULL,
    semester INT NOT NULL,
    total_marks_obtained DECIMAL(5, 2),
    total_marks INT,
    percentage DECIMAL(5, 2),
    overall_grade VARCHAR(2),
    rank_in_class INT,
    principal_remarks TEXT,
    generated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES students(id),
    FOREIGN KEY (academic_year_id) REFERENCES academic_years(id),
    UNIQUE KEY unique_report (student_id, academic_year_id, semester),
    INDEX idx_student (student_id)
);

-- ============================================================
-- ANNOUNCEMENTS TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS announcements (
    id INT PRIMARY KEY AUTO_INCREMENT,
    title VARCHAR(200) NOT NULL,
    content TEXT,
    category VARCHAR(50),
    priority ENUM('low', 'medium', 'high') DEFAULT 'medium',
    created_by INT,
    posted_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    expiry_date DATE,
    is_active BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (created_by) REFERENCES users(id),
    INDEX idx_posted_date (posted_date)
);

-- ============================================================
-- EVENTS TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS events (
    id INT PRIMARY KEY AUTO_INCREMENT,
    event_name VARCHAR(200) NOT NULL,
    description TEXT,
    event_date DATE,
    event_time TIME,
    location VARCHAR(255),
    event_type VARCHAR(50),
    created_by INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (created_by) REFERENCES users(id)
);

-- ============================================================
-- HOMEWORK TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS homework (
    id INT PRIMARY KEY AUTO_INCREMENT,
    subject_id INT NOT NULL,
    class_id INT NOT NULL,
    description TEXT,
    due_date DATE,
    assigned_date DATE DEFAULT CURDATE(),
    assigned_by INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (subject_id) REFERENCES subjects(id),
    FOREIGN KEY (class_id) REFERENCES classes(id),
    FOREIGN KEY (assigned_by) REFERENCES users(id)
);

-- ============================================================
-- EXAM TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS exams (
    id INT PRIMARY KEY AUTO_INCREMENT,
    exam_name VARCHAR(100) NOT NULL,
    exam_type VARCHAR(50),
    class_id INT NOT NULL,
    start_date DATE,
    end_date DATE,
    description TEXT,
    created_by INT,
    academic_year_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (class_id) REFERENCES classes(id),
    FOREIGN KEY (created_by) REFERENCES users(id),
    FOREIGN KEY (academic_year_id) REFERENCES academic_years(id)
);

-- ============================================================
-- EXAM SCHEDULE TABLE
-- ============================================================
CREATE TABLE IF NOT EXISTS exam_schedule (
    id INT PRIMARY KEY AUTO_INCREMENT,
    exam_id INT NOT NULL,
    subject_id INT NOT NULL,
    exam_date DATE,
    start_time TIME,
    end_time TIME,
    room_number VARCHAR(20),
    total_marks INT,
    passing_marks INT,
    FOREIGN KEY (exam_id) REFERENCES exams(id),
    FOREIGN KEY (subject_id) REFERENCES subjects(id)
);

-- ============================================================
-- LEAVE APPLICATION TABLE (Teachers/Staff)
-- ============================================================
CREATE TABLE IF NOT EXISTS leave_applications (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    leave_type VARCHAR(50),
    start_date DATE,
    end_date DATE,
    reason TEXT,
    status ENUM('pending', 'approved', 'rejected') DEFAULT 'pending',
    approved_by INT,
    remarks VARCHAR(255),
    applied_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (approved_by) REFERENCES users(id)
);

-- ============================================================
-- SAMPLE DATA
-- ============================================================

-- Insert Academic Year
INSERT INTO academic_years (year, start_date, end_date, is_active) VALUES
(2024, '2024-04-01', '2025-03-31', TRUE),
(2025, '2025-04-01', '2026-03-31', FALSE);

-- Insert Admin User
INSERT INTO users (username, password, email, phone, first_name, last_name, role, status) VALUES
('admin', '$2a$08$8WY0nVa6TUcVeXz9qrKbDuaKqPRCqb9DK7WM8.vZ7qw8QJy7bZgk2', 'admin@school.edu', '9000000000', 'Admin', 'User', 'admin', 'active');

-- Insert Teachers
INSERT INTO users (username, password, email, phone, first_name, last_name, role, status) VALUES
('teacher1', '$2a$08$8WY0nVa6TUcVeXz9qrKbDuaKqPRCqb9DK7WM8.vZ7qw8QJy7bZgk2', 'teacher1@school.edu', '9100000000', 'Rajesh', 'Kumar', 'teacher', 'active'),
('teacher2', '$2a$08$8WY0nVa6TUcVeXz9qrKbDuaKqPRCqb9DK7WM8.vZ7qw8QJy7bZgk2', 'teacher2@school.edu', '9200000000', 'Priya', 'Sharma', 'teacher', 'active');

-- Insert Parents
INSERT INTO users (username, password, email, phone, first_name, last_name, role, status) VALUES
('parent1', '$2a$08$8WY0nVa6TUcVeXz9qrKbDuaKqPRCqb9DK7WM8.vZ7qw8QJy7bZgk2', 'parent1@school.edu', '8100000000', 'Ramesh', 'Sharma', 'parent', 'active'),
('parent2', '$2a$08$8WY0nVa6TUcVeXz9qrKbDuaKqPRCqb9DK7WM8.vZ7qw8QJy7bZgk2', 'parent2@school.edu', '8200000000', 'Anjali', 'Singh', 'parent', 'active');

-- Insert Students
INSERT INTO users (username, password, email, phone, first_name, last_name, role, status) VALUES
('student1', '$2a$08$8WY0nVa6TUcVeXz9qrKbDuaKqPRCqb9DK7WM8.vZ7qw8QJy7bZgk2', 'student1@school.edu', '7100000000', 'Aniket', 'Sharma', 'student', 'active'),
('student2', '$2a$08$8WY0nVa6TUcVeXz9qrKbDuaKqPRCqb9DK7WM8.vZ7qw8QJy7bZgk2', 'student2@school.edu', '7200000000', 'Priya', 'Singh', 'student', 'active');

-- Insert Class
INSERT INTO classes (class_name, class_number, section, room_number, capacity, class_teacher_id, academic_year_id) VALUES
('Class VI - A', 6, 'A', '6A', 40, 2, 1);

-- Insert Subjects
INSERT INTO subjects (subject_name, subject_code, class_id, teacher_id, total_marks, passing_marks, academic_year_id) VALUES
('English', 'ENG101', 1, 2, 100, 35, 1),
('Mathematics', 'MAT101', 1, 3, 100, 35, 1),
('Science', 'SCI101', 1, 2, 100, 35, 1),
('Social Studies', 'SOC101', 1, 3, 100, 35, 1);

-- Insert Students Details
INSERT INTO students (user_id, roll_number, date_of_birth, gender, address, city, state, pin_code, enrollment_date, class_id, parent_id, status) VALUES
(5, 'RN001', '2010-05-15', 'M', '123 Main Street', 'Erode', 'Tamil Nadu', '638001', '2024-04-01', 1, 3, 'active'),
(6, 'RN002', '2010-06-20', 'F', '456 Oak Avenue', 'Erode', 'Tamil Nadu', '638001', '2024-04-01', 1, 4, 'active');

-- Insert Teachers Details
INSERT INTO teachers (user_id, employee_id, date_of_birth, gender, qualification, specialization, experience_years, joining_date, department, designation, status) VALUES
(2, 'EMP001', '1985-03-10', 'M', 'B.Ed', 'English', 15, '2009-06-01', 'Languages', 'Senior Teacher', 'active'),
(3, 'EMP002', '1988-07-15', 'F', 'B.Ed', 'Mathematics', 12, '2012-06-01', 'Science', 'Teacher', 'active');

-- Insert Sample Attendance
INSERT INTO attendance (student_id, class_id, attendance_date, status, marked_by) VALUES
(1, 1, '2024-03-04', 'present', 2),
(1, 1, '2024-03-03', 'present', 2),
(1, 1, '2024-03-02', 'absent', 2),
(2, 1, '2024-03-04', 'present', 2),
(2, 1, '2024-03-03', 'present', 2),
(2, 1, '2024-03-02', 'present', 2);

-- Insert Sample Grades
INSERT INTO grades (student_id, subject_id, exam_type, marks_obtained, total_marks, percentage, grade, academic_year_id, semester, entered_by) VALUES
(1, 1, 'Midterm', 85, 100, 85.00, 'A', 1, 1, 2),
(1, 2, 'Midterm', 75, 100, 75.00, 'B', 1, 1, 3),
(1, 3, 'Midterm', 80, 100, 80.00, 'A', 1, 1, 2),
(2, 1, 'Midterm', 92, 100, 92.00, 'A', 1, 1, 2),
(2, 2, 'Midterm', 88, 100, 88.00, 'A', 1, 1, 3);

-- Insert Sample Fees
INSERT INTO fees (student_id, academic_year_id, fee_type, amount, due_date, paid_date, status, payment_method, transaction_id) VALUES
(1, 1, 'Tuition Fee', 50000, '2024-05-31', '2024-05-25', 'paid', 'bank transfer', 'TXN001'),
(1, 1, 'Activities Fee', 5000, '2024-06-30', '2024-06-28', 'paid', 'cash', 'TXN002'),
(2, 1, 'Tuition Fee', 50000, '2024-05-31', NULL, 'pending', NULL, NULL),
(2, 1, 'Activities Fee', 5000, '2024-06-30', NULL, 'pending', NULL, NULL);

-- Create Indexes for Performance
CREATE INDEX idx_fees_student_year ON fees(student_id, academic_year_id);
CREATE INDEX idx_grades_student_year ON grades(student_id, academic_year_id);
CREATE INDEX idx_attendance_student_date ON attendance(student_id, attendance_date);

-- ============================================================
-- END OF DATABASE SCHEMA
-- ============================================================
