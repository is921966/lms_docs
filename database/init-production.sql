-- LMS Production Database Initialization
-- This script combines all migrations for Railway deployment

-- Enable extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Import all migrations in order
\i database/migrations/001_create_users_table.sql
\i database/migrations/002_create_competencies_table.sql
\i database/migrations/003_create_positions_table.sql
\i database/migrations/004_create_courses_table.sql
\i database/migrations/005_create_tests_table.sql
\i database/migrations/006_create_programs_table.sql
\i database/migrations/007_create_notifications_table.sql
\i database/migrations/008_create_learning_progress_table.sql
\i database/migrations/009_add_content_indexes.sql
\i database/migrations/010_create_analytics_tables.sql
\i database/migrations/011_add_foreign_keys.sql
\i database/migrations/012_create_cache_table.sql
\i database/migrations/013_create_onboarding_tables.sql
\i database/migrations/014_update_courses_content_url.sql
\i database/migrations/015_create_api_gateway_tables.sql
\i database/migrations/016_add_user_profile_fields.sql
\i database/migrations/017_add_delete_cascade.sql
\i database/migrations/018_add_metadata_fields.sql
\i database/migrations/019_add_cmi5_support.sql

-- Insert default admin user (password: Admin123!)
INSERT INTO users (id, email, password, first_name, last_name, is_admin, status, created_at, updated_at)
VALUES (
    uuid_generate_v4(),
    'admin@lms.company.ru',
    crypt('Admin123!', gen_salt('bf')),
    'System',
    'Administrator',
    true,
    'active',
    NOW(),
    NOW()
) ON CONFLICT (email) DO NOTHING;

-- Insert demo student user (password: Student123!)
INSERT INTO users (id, email, password, first_name, last_name, is_admin, status, created_at, updated_at)
VALUES (
    uuid_generate_v4(),
    'student@lms.company.ru',
    crypt('Student123!', gen_salt('bf')),
    'Demo',
    'Student',
    false,
    'active',
    NOW(),
    NOW()
) ON CONFLICT (email) DO NOTHING; 