-- Migration: Create project time registry table
-- Author: AI Development Agent
-- Date: 2025-07-04
-- Purpose: Centralized time tracking for project days and reports

-- Drop table if exists (for development)
DROP TABLE IF EXISTS project_time_registry CASCADE;

-- Create project time registry table
CREATE TABLE project_time_registry (
    id SERIAL PRIMARY KEY,
    
    -- Core time fields
    project_day INTEGER NOT NULL UNIQUE,          -- Условный день проекта (1, 2, 3...)
    calendar_date DATE NOT NULL,                  -- Реальная календарная дата
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- Фактическое время создания записи
    
    -- Sprint information
    sprint_number INTEGER NOT NULL,               -- Номер спринта
    sprint_day INTEGER NOT NULL,                  -- День внутри спринта (1-5)
    sprint_name VARCHAR(255),                     -- Название спринта
    
    -- Work time tracking
    start_time TIMESTAMP,                         -- Время начала работы
    end_time TIMESTAMP,                           -- Время завершения работы
    duration_minutes INTEGER,                     -- Продолжительность в минутах
    actual_work_time INTEGER DEFAULT 0,           -- Фактическое рабочее время (минуты)
    
    -- Status tracking
    status VARCHAR(20) DEFAULT 'planned',         -- planned, started, completed, cancelled
    
    -- Development metrics
    commits_count INTEGER DEFAULT 0,              -- Количество коммитов
    files_changed INTEGER DEFAULT 0,              -- Количество измененных файлов
    lines_added INTEGER DEFAULT 0,                -- Добавлено строк кода
    lines_deleted INTEGER DEFAULT 0,              -- Удалено строк кода
    
    -- Testing metrics
    tests_total INTEGER DEFAULT 0,                -- Всего тестов
    tests_passed INTEGER DEFAULT 0,               -- Прошло тестов
    tests_failed INTEGER DEFAULT 0,               -- Провалилось тестов
    tests_fixed INTEGER DEFAULT 0,                -- Исправлено тестов
    test_coverage_percent DECIMAL(5,2),           -- Процент покрытия
    
    -- Task metrics
    tasks_planned INTEGER DEFAULT 0,              -- Запланировано задач
    tasks_completed INTEGER DEFAULT 0,            -- Выполнено задач
    bugs_fixed INTEGER DEFAULT 0,                 -- Исправлено багов
    features_added INTEGER DEFAULT 0,             -- Добавлено фич
    
    -- Report references
    daily_report_path VARCHAR(500),               -- Путь к ежедневному отчету
    completion_report_path VARCHAR(500),          -- Путь к отчету завершения
    
    -- Additional information
    notes TEXT,                                   -- Примечания и комментарии
    weather VARCHAR(50),                          -- Погода (для контекста)
    mood VARCHAR(50),                             -- Настроение/продуктивность
    blockers TEXT,                                -- Блокеры и проблемы
    
    -- Metadata
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_by VARCHAR(100) DEFAULT 'ai_agent'
);

-- Create indexes for better performance
CREATE INDEX idx_project_day ON project_time_registry(project_day);
CREATE INDEX idx_calendar_date ON project_time_registry(calendar_date);
CREATE INDEX idx_sprint ON project_time_registry(sprint_number, sprint_day);
CREATE INDEX idx_status ON project_time_registry(status);
CREATE INDEX idx_created_at ON project_time_registry(created_at);

-- Create trigger to auto-update updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_project_time_registry_updated_at 
    BEFORE UPDATE ON project_time_registry 
    FOR EACH ROW 
    EXECUTE FUNCTION update_updated_at_column();

-- Create view for sprint summary
CREATE VIEW sprint_summary AS
SELECT 
    sprint_number,
    sprint_name,
    COUNT(*) as days_count,
    MIN(calendar_date) as start_date,
    MAX(calendar_date) as end_date,
    SUM(duration_minutes) as total_minutes,
    SUM(commits_count) as total_commits,
    SUM(tests_fixed) as total_tests_fixed,
    SUM(tasks_completed) as total_tasks_completed,
    AVG(test_coverage_percent) as avg_test_coverage
FROM project_time_registry
WHERE status = 'completed'
GROUP BY sprint_number, sprint_name;

-- Create view for daily productivity
CREATE VIEW daily_productivity AS
SELECT 
    project_day,
    calendar_date,
    sprint_number,
    duration_minutes,
    commits_count,
    (tests_passed::float / NULLIF(tests_total, 0) * 100) as test_pass_rate,
    (tasks_completed::float / NULLIF(tasks_planned, 0) * 100) as task_completion_rate,
    (lines_added - lines_deleted) as net_lines_changed
FROM project_time_registry
ORDER BY project_day DESC;

-- Add comments for documentation
COMMENT ON TABLE project_time_registry IS 'Central registry for tracking project time and metrics';
COMMENT ON COLUMN project_time_registry.project_day IS 'Sequential project day number (1, 2, 3...)';
COMMENT ON COLUMN project_time_registry.calendar_date IS 'Actual calendar date';
COMMENT ON COLUMN project_time_registry.status IS 'Day status: planned, started, completed, cancelled';
COMMENT ON COLUMN project_time_registry.mood IS 'Productivity indicator: high, normal, low';

-- Grant permissions (adjust as needed)
-- GRANT SELECT, INSERT, UPDATE ON project_time_registry TO lms_app;
-- GRANT SELECT ON sprint_summary TO lms_readonly;
-- GRANT SELECT ON daily_productivity TO lms_readonly; 