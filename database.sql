-- Professional Database Schema for SISTEMA EDUCATIVO RUBEN (CEA Bolivia)
CREATE DATABASE IF NOT EXISTS cea_ruben_db;
USE cea_ruben_db;

-- 1. Configuration and Roles
CREATE TABLE IF NOT EXISTS academic_config (
    id INT AUTO_INCREMENT PRIMARY KEY,
    academic_year INT NOT NULL,
    working_days INT DEFAULT 200
);
INSERT IGNORE INTO academic_config (academic_year, working_days) VALUES (2026, 200);

CREATE TABLE IF NOT EXISTS roles (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE
);
INSERT IGNORE INTO roles (name) VALUES ('Director'), ('Secretaria'), ('Profesor'), ('Estudiante');

-- 2. User Management
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    role_id INT,
    carnet VARCHAR(20) NOT NULL UNIQUE,
    rude_number VARCHAR(20) NULL UNIQUE,  -- Official Student Registry Number
    full_name VARCHAR(100) NOT NULL,
    birth_date DATE,
    gender ENUM('M', 'F', 'Otro'),
    area_type ENUM('Humanistica', 'Tecnica', 'Control') DEFAULT 'Control',
    FOREIGN KEY (role_id) REFERENCES roles(id)
);

-- 3. Academic Structure - Humanistica
CREATE TABLE IF NOT EXISTS humanistic_subjects (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL
);
INSERT IGNORE INTO humanistic_subjects (name) VALUES 
('Matemática'), 
('Comunicación y Lenguajes'), 
('Ciencias Naturales'), 
('Ciencias Sociales');

-- 4. Academic Structure - Tecnica
CREATE TABLE IF NOT EXISTS technical_levels (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    duration VARCHAR(50) NOT NULL
);
INSERT IGNORE INTO technical_levels (name, duration) VALUES 
('Técnico Básico', '6 meses'),
('Técnico Auxiliar', '6 meses'),
('Técnico Medio', '1 año');

-- 5. Unified Modules Table
CREATE TABLE IF NOT EXISTS modules (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    subject_id INT NULL,   -- For Humanistica
    level_id INT NULL,     -- For Tecnica
    module_number INT,     -- 1 or 2 for Humanistica, 1 to 5 for Tecnica
    FOREIGN KEY (subject_id) REFERENCES humanistic_subjects(id),
    FOREIGN KEY (level_id) REFERENCES technical_levels(id)
);

-- Seed Modules for Humanistica
INSERT IGNORE INTO modules (name, subject_id, module_number) VALUES 
('Matemática Módulo 1', 1, 1), ('Matemática Módulo 2', 1, 2),
('Lenguaje Módulo 1', 2, 1), ('Lenguaje Módulo 2', 2, 2),
('Ciencias Naturales Módulo 1', 3, 1), ('Ciencias Naturales Módulo 2', 3, 2),
('Ciencias Sociales Módulo 1', 4, 1), ('Ciencias Sociales Módulo 2', 4, 2);

-- Seed Modules for Tecnica (Sistemas Informáticos Example)
INSERT IGNORE INTO modules (name, level_id, module_number) VALUES 
('Ofimática', 1, 1), ('Hardware básico', 1, 2), ('Sistemas operativos', 1, 3), ('Internet', 1, 4), ('Emprendimiento', 1, 5),
('Redes', 2, 1), ('Base de datos', 2, 2), ('Programación', 2, 3), ('Soporte técnico', 2, 4), ('Seguridad informática', 2, 5),
('Desarrollo de sistemas', 3, 1), ('Administración de redes', 3, 2), ('Base de datos avanzada', 3, 3), ('Desarrollo web', 3, 4), ('Proyecto técnico', 3, 5);

-- 6. Enrollment and Grades
CREATE TABLE IF NOT EXISTS enrollments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT,
    area_id ENUM('Humanistica', 'Tecnica') NOT NULL,
    level_id INT NULL, -- Only for Tecnica
    enrolled_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES users(id),
    FOREIGN KEY (level_id) REFERENCES technical_levels(id)
);

CREATE TABLE IF NOT EXISTS grades (
    id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT,
    module_id INT,
    teacher_id INT,
    score INT CHECK (score BETWEEN 0 AND 100),
    status ENUM('APROBADO', 'REPROBADO') NOT NULL,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES users(id),
    FOREIGN KEY (module_id) REFERENCES modules(id),
    FOREIGN KEY (teacher_id) REFERENCES users(id)
);

-- Seed Some Initial Users (Example)
-- Passwords should be carnet (to be hashed or stored plain for this example per user request)
INSERT IGNORE INTO users (username, password, role_id, carnet, full_name, area_type) VALUES 
('director_ruben@educaruben.com', '1001', 1, '1001', 'Ruben Director', 'Control'),
('profe_juan@educaruben.com', '2001', 3, '2001', 'Juan Pérez', 'Humanistica'),
('estudiante_ana@educaruben.com', '3001', 4, '3001', 'Ana Gomez', 'Tecnica');
