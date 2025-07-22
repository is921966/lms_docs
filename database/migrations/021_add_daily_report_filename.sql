-- Add daily_report_filename column to project_time_registry
ALTER TABLE project_time_registry 
ADD COLUMN IF NOT EXISTS daily_report_filename VARCHAR(255);

-- Update comment
COMMENT ON COLUMN project_time_registry.daily_report_filename IS 'Filename of the daily report for this day'; 