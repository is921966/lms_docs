-- Migration: Create courses table
-- Author: AI Development Agent
-- Date: 2025-07-17
-- Purpose: Store course information for CourseService

-- Drop table if exists (for development)
DROP TABLE IF EXISTS course_modules CASCADE;
DROP TABLE IF EXISTS course_lessons CASCADE;
DROP TABLE IF EXISTS course_enrollments CASCADE;
DROP TABLE IF EXISTS courses CASCADE;

-- Create courses table
CREATE TABLE courses (
    id VARCHAR(50) PRIMARY KEY,  -- Format: CRS-uuid
    code VARCHAR(20) NOT NULL UNIQUE,
    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    duration_minutes INTEGER NOT NULL CHECK (duration_minutes > 0),
    price_amount DECIMAL(10,2) NOT NULL CHECK (price_amount >= 0),
    price_currency VARCHAR(3) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'draft' CHECK (status IN ('draft', 'published', 'archived')),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    published_at TIMESTAMP,
    archived_at TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Indexes
    INDEX idx_courses_code (code),
    INDEX idx_courses_status (status),
    INDEX idx_courses_created_at (created_at),
    INDEX idx_courses_published_at (published_at)
);

-- Create trigger to auto-update updated_at
CREATE OR REPLACE FUNCTION update_courses_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_courses_updated_at 
    BEFORE UPDATE ON courses 
    FOR EACH ROW 
    EXECUTE FUNCTION update_courses_updated_at();

-- Create course_modules table
CREATE TABLE course_modules (
    id VARCHAR(50) PRIMARY KEY,  -- Format: MOD-uuid
    course_id VARCHAR(50) NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    order_index INTEGER NOT NULL CHECK (order_index > 0),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Constraints
    UNIQUE(course_id, order_index),
    
    -- Indexes
    INDEX idx_course_modules_course_id (course_id),
    INDEX idx_course_modules_order (course_id, order_index)
);

-- Create course_lessons table
CREATE TABLE course_lessons (
    id VARCHAR(50) PRIMARY KEY,  -- Format: LSN-uuid
    module_id VARCHAR(50) NOT NULL REFERENCES course_modules(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    content TEXT,
    type VARCHAR(20) NOT NULL DEFAULT 'text' CHECK (type IN ('text', 'video', 'audio', 'quiz', 'assignment')),
    duration_minutes INTEGER NOT NULL CHECK (duration_minutes > 0),
    order_index INTEGER NOT NULL CHECK (order_index > 0),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Constraints
    UNIQUE(module_id, order_index),
    
    -- Indexes
    INDEX idx_course_lessons_module_id (module_id),
    INDEX idx_course_lessons_order (module_id, order_index),
    INDEX idx_course_lessons_type (type)
);

-- Create course_enrollments table
CREATE TABLE course_enrollments (
    id VARCHAR(50) PRIMARY KEY,  -- Format: ENR-uuid
    course_id VARCHAR(50) NOT NULL REFERENCES courses(id) ON DELETE CASCADE,
    user_id VARCHAR(50) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'active' CHECK (status IN ('active', 'suspended', 'completed')),
    progress_percent INTEGER NOT NULL DEFAULT 0 CHECK (progress_percent >= 0 AND progress_percent <= 100),
    enrolled_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP,
    last_activity_at TIMESTAMP,
    
    -- Constraints
    UNIQUE(course_id, user_id),
    
    -- Indexes
    INDEX idx_course_enrollments_course_id (course_id),
    INDEX idx_course_enrollments_user_id (user_id),
    INDEX idx_course_enrollments_status (status),
    INDEX idx_course_enrollments_enrolled_at (enrolled_at),
    INDEX idx_course_enrollments_completed_at (completed_at)
);

-- Add comments
COMMENT ON TABLE courses IS 'Stores course information';
COMMENT ON TABLE course_modules IS 'Stores course modules/chapters';
COMMENT ON TABLE course_lessons IS 'Stores individual lessons within modules';
COMMENT ON TABLE course_enrollments IS 'Tracks user enrollments in courses';

COMMENT ON COLUMN courses.id IS 'Unique identifier with CRS- prefix';
COMMENT ON COLUMN courses.code IS 'Short course code (e.g., CS101)';
COMMENT ON COLUMN courses.status IS 'Course lifecycle status';
COMMENT ON COLUMN course_enrollments.progress_percent IS 'Overall course completion percentage'; 