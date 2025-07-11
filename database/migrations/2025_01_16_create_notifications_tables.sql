-- Migration: Create notifications tables
-- Date: 2025-01-16
-- Description: Tables for notification system

-- Enable UUID extension if not already enabled
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Drop tables if they exist (for clean migration)
DROP TABLE IF EXISTS notification_events CASCADE;
DROP TABLE IF EXISTS notification_preferences CASCADE;
DROP TABLE IF EXISTS push_tokens CASCADE;
DROP TABLE IF EXISTS notifications CASCADE;

-- Create notifications table
CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    type VARCHAR(50) NOT NULL,
    title VARCHAR(255) NOT NULL,
    body TEXT NOT NULL,
    data JSONB,
    channels TEXT[] DEFAULT ARRAY['in_app'],
    priority INTEGER DEFAULT 1 CHECK (priority >= 0 AND priority <= 3),
    is_read BOOLEAN DEFAULT FALSE,
    read_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT NOW(),
    expires_at TIMESTAMP,
    metadata JSONB,
    
    -- Indexes
    INDEX idx_notifications_user_id (user_id),
    INDEX idx_notifications_type (type),
    INDEX idx_notifications_created_at (created_at DESC),
    INDEX idx_notifications_is_read (is_read),
    INDEX idx_notifications_user_unread (user_id, is_read) WHERE is_read = FALSE
);

-- Create push_tokens table
CREATE TABLE push_tokens (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token VARCHAR(255) NOT NULL,
    device_id VARCHAR(255) NOT NULL,
    platform VARCHAR(20) NOT NULL CHECK (platform IN ('ios', 'android', 'web')),
    environment VARCHAR(20) NOT NULL CHECK (environment IN ('development', 'production')),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT NOW(),
    last_used_at TIMESTAMP DEFAULT NOW(),
    
    -- Unique constraint: one token per device
    UNIQUE(device_id, platform),
    
    -- Indexes
    INDEX idx_push_tokens_user_id (user_id),
    INDEX idx_push_tokens_token (token),
    INDEX idx_push_tokens_active (is_active) WHERE is_active = TRUE
);

-- Create notification_preferences table
CREATE TABLE notification_preferences (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    channel_preferences JSONB DEFAULT '{}',
    is_enabled BOOLEAN DEFAULT TRUE,
    quiet_hours JSONB,
    frequency_limits JSONB DEFAULT '{}',
    updated_at TIMESTAMP DEFAULT NOW(),
    
    -- One preference per user
    UNIQUE(user_id),
    
    -- Indexes
    INDEX idx_notification_preferences_user_id (user_id)
);

-- Create notification_events table for analytics
CREATE TABLE notification_events (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    notification_id UUID NOT NULL REFERENCES notifications(id) ON DELETE CASCADE,
    type VARCHAR(50) NOT NULL CHECK (type IN ('delivered', 'opened', 'action_taken', 'dismissed', 'failed')),
    timestamp TIMESTAMP DEFAULT NOW(),
    metadata JSONB,
    
    -- Indexes
    INDEX idx_notification_events_notification_id (notification_id),
    INDEX idx_notification_events_type (type),
    INDEX idx_notification_events_timestamp (timestamp DESC)
);

-- Create trigger to update last_used_at for push tokens
CREATE OR REPLACE FUNCTION update_push_token_last_used()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE push_tokens 
    SET last_used_at = NOW() 
    WHERE id = NEW.id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_push_token_last_used
AFTER INSERT ON notification_events
FOR EACH ROW
EXECUTE FUNCTION update_push_token_last_used();

-- Create trigger to update read_at when marking as read
CREATE OR REPLACE FUNCTION update_notification_read_at()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.is_read = TRUE AND OLD.is_read = FALSE THEN
        NEW.read_at = NOW();
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_notification_read_at
BEFORE UPDATE ON notifications
FOR EACH ROW
EXECUTE FUNCTION update_notification_read_at();

-- Create function to get unread count for user
CREATE OR REPLACE FUNCTION get_unread_notification_count(p_user_id UUID)
RETURNS INTEGER AS $$
BEGIN
    RETURN (
        SELECT COUNT(*)
        FROM notifications
        WHERE user_id = p_user_id
        AND is_read = FALSE
        AND (expires_at IS NULL OR expires_at > NOW())
    );
END;
$$ LANGUAGE plpgsql;

-- Create function to mark all notifications as read for user
CREATE OR REPLACE FUNCTION mark_all_notifications_read(p_user_id UUID)
RETURNS INTEGER AS $$
DECLARE
    affected_rows INTEGER;
BEGIN
    UPDATE notifications
    SET is_read = TRUE,
        read_at = NOW()
    WHERE user_id = p_user_id
    AND is_read = FALSE;
    
    GET DIAGNOSTICS affected_rows = ROW_COUNT;
    RETURN affected_rows;
END;
$$ LANGUAGE plpgsql;

-- Insert default notification preferences for existing users
INSERT INTO notification_preferences (user_id, channel_preferences, is_enabled)
SELECT id, 
       '{"course_assigned": ["in_app", "push"], "test_deadline": ["in_app", "push", "email"]}'::jsonb,
       true
FROM users
WHERE NOT EXISTS (
    SELECT 1 FROM notification_preferences WHERE user_id = users.id
);

-- Comments
COMMENT ON TABLE notifications IS 'Stores all notifications for users';
COMMENT ON TABLE push_tokens IS 'Stores push notification tokens for devices';
COMMENT ON TABLE notification_preferences IS 'User preferences for notifications';
COMMENT ON TABLE notification_events IS 'Analytics events for notifications';

COMMENT ON COLUMN notifications.priority IS '0=low, 1=medium, 2=high, 3=urgent';
COMMENT ON COLUMN notifications.channels IS 'Array of delivery channels: in_app, push, email, sms';
COMMENT ON COLUMN push_tokens.platform IS 'Device platform: ios, android, web';
COMMENT ON COLUMN notification_events.type IS 'Event type: delivered, opened, action_taken, dismissed, failed'; 