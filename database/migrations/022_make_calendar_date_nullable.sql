-- Migration: Make calendar_date nullable
-- Author: AI Development Agent
-- Date: 2025-07-04
-- Purpose: Allow calendar_date to be NULL until day actually starts

-- Alter table to make calendar_date nullable
ALTER TABLE project_time_registry 
ALTER COLUMN calendar_date DROP NOT NULL;

-- Update comment
COMMENT ON COLUMN project_time_registry.calendar_date IS 'Actual calendar date - set automatically from start_time'; 