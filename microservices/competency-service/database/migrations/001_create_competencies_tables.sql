-- Create competencies table
CREATE TABLE IF NOT EXISTS competencies (
    id UUID PRIMARY KEY,
    code VARCHAR(20) NOT NULL UNIQUE,
    name VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    category VARCHAR(100) NOT NULL,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP,
    
    INDEX idx_code (code),
    INDEX idx_category (category),
    INDEX idx_active (is_active)
);

-- Create competency levels table
CREATE TABLE IF NOT EXISTS competency_levels (
    id SERIAL PRIMARY KEY,
    competency_id UUID NOT NULL,
    level INTEGER NOT NULL CHECK (level >= 1 AND level <= 10),
    name VARCHAR(50) NOT NULL,
    description VARCHAR(500) NOT NULL,
    criteria JSON,
    
    FOREIGN KEY (competency_id) REFERENCES competencies(id) ON DELETE CASCADE,
    UNIQUE KEY unique_competency_level (competency_id, level),
    INDEX idx_competency (competency_id)
);

-- Create assessments table
CREATE TABLE IF NOT EXISTS assessments (
    id UUID PRIMARY KEY,
    competency_id UUID NOT NULL,
    user_id VARCHAR(255) NOT NULL,
    assessor_id VARCHAR(255) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'pending',
    score_level INTEGER CHECK (score_level >= 1 AND score_level <= 5),
    score_feedback TEXT,
    score_recommendations TEXT,
    cancellation_reason TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP,
    
    FOREIGN KEY (competency_id) REFERENCES competencies(id),
    INDEX idx_user (user_id),
    INDEX idx_assessor (assessor_id),
    INDEX idx_status (status),
    INDEX idx_competency_user (competency_id, user_id)
);

-- Create competency matrices table
CREATE TABLE IF NOT EXISTS competency_matrices (
    id UUID PRIMARY KEY,
    position_id VARCHAR(255) NOT NULL,
    name VARCHAR(255) NOT NULL,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP,
    
    INDEX idx_position (position_id),
    INDEX idx_active_matrix (is_active)
);

-- Create matrix requirements table
CREATE TABLE IF NOT EXISTS matrix_requirements (
    id SERIAL PRIMARY KEY,
    matrix_id UUID NOT NULL,
    competency_id UUID NOT NULL,
    required_level INTEGER NOT NULL CHECK (required_level >= 1 AND required_level <= 10),
    requirement_type VARCHAR(20) NOT NULL CHECK (requirement_type IN ('core', 'nice-to-have', 'optional')),
    
    FOREIGN KEY (matrix_id) REFERENCES competency_matrices(id) ON DELETE CASCADE,
    FOREIGN KEY (competency_id) REFERENCES competencies(id),
    UNIQUE KEY unique_matrix_competency (matrix_id, competency_id),
    INDEX idx_matrix (matrix_id),
    INDEX idx_requirement_type (requirement_type)
); 