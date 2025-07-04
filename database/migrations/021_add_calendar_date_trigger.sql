-- Migration: Add trigger to auto-update calendar_date from start_time
-- Author: AI Development Agent
-- Date: 2025-07-04
-- Purpose: Automatically set calendar_date from start_time when starting a day

-- Create function to update calendar_date from start_time
CREATE OR REPLACE FUNCTION update_calendar_date_from_start_time()
RETURNS TRIGGER AS $$
BEGIN
    -- If start_time is being set, update calendar_date
    IF NEW.start_time IS NOT NULL AND (OLD.start_time IS NULL OR NEW.start_time != OLD.start_time) THEN
        NEW.calendar_date = DATE(NEW.start_time);
    END IF;
    
    -- If end_time is being set and it's a different date than start, update accordingly
    IF NEW.end_time IS NOT NULL AND NEW.start_time IS NOT NULL THEN
        -- Use the date from start_time as the primary calendar date
        NEW.calendar_date = DATE(NEW.start_time);
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to auto-update calendar_date
DROP TRIGGER IF EXISTS update_calendar_date_trigger ON project_time_registry;

CREATE TRIGGER update_calendar_date_trigger
    BEFORE INSERT OR UPDATE ON project_time_registry
    FOR EACH ROW
    EXECUTE FUNCTION update_calendar_date_from_start_time();

-- Update existing records to set calendar_date from start_time where available
UPDATE project_time_registry 
SET calendar_date = DATE(start_time) 
WHERE start_time IS NOT NULL;

-- Add comment
COMMENT ON FUNCTION update_calendar_date_from_start_time() IS 'Automatically updates calendar_date based on start_time timestamp'; 