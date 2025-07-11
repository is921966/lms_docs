-- Migration: Add daily report filename field
-- Author: AI Development Agent
-- Date: 2025-07-04
-- Purpose: Auto-generate daily report filename on day start

-- Add column for daily report filename
ALTER TABLE project_time_registry 
ADD COLUMN daily_report_filename VARCHAR(100);

-- Create function to generate report filename
CREATE OR REPLACE FUNCTION generate_report_filename()
RETURNS TRIGGER AS $$
BEGIN
    -- Generate filename when day starts (start_time is set)
    IF NEW.start_time IS NOT NULL AND 
       (OLD.start_time IS NULL OR NEW.start_time != OLD.start_time) AND
       NEW.calendar_date IS NOT NULL THEN
        
        -- Format: DAY_XXX_SUMMARY_YYYYMMDD.md
        NEW.daily_report_filename = FORMAT(
            'DAY_%s_SUMMARY_%s.md',
            LPAD(NEW.project_day::TEXT, 3, '0'),
            TO_CHAR(NEW.calendar_date, 'YYYYMMDD')
        );
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to auto-generate filename
CREATE TRIGGER generate_report_filename_trigger
    BEFORE INSERT OR UPDATE ON project_time_registry
    FOR EACH ROW
    EXECUTE FUNCTION generate_report_filename();

-- Update existing records that have start_time
UPDATE project_time_registry 
SET daily_report_filename = FORMAT(
    'DAY_%s_SUMMARY_%s.md',
    LPAD(project_day::TEXT, 3, '0'),
    TO_CHAR(calendar_date, 'YYYYMMDD')
)
WHERE start_time IS NOT NULL AND calendar_date IS NOT NULL;

-- Add comment
COMMENT ON COLUMN project_time_registry.daily_report_filename IS 'Auto-generated daily report filename (DAY_XXX_SUMMARY_YYYYMMDD.md)'; 