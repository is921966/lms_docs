-- Sprint 41: Notifications & Push Module
-- Database schema for notifications system
-- Created: 2025-01-13

-- Notifications table
CREATE TABLE IF NOT EXISTS notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    type VARCHAR(50) NOT NULL,
    title VARCHAR(255) NOT NULL,
    body TEXT NOT NULL,
    data JSONB,
    channels TEXT[] NOT NULL DEFAULT ARRAY['inApp']::TEXT[],
    priority VARCHAR(20) NOT NULL DEFAULT 'medium',
    is_read BOOLEAN NOT NULL DEFAULT FALSE,
    read_at TIMESTAMP WITH TIME ZONE,
    expires_at TIMESTAMP WITH TIME ZONE,
    metadata JSONB,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- Indexes for notifications
CREATE INDEX idx_notifications_user_id ON notifications(user_id);
CREATE INDEX idx_notifications_type ON notifications(type);
CREATE INDEX idx_notifications_is_read ON notifications(is_read);
CREATE INDEX idx_notifications_created_at ON notifications(created_at DESC);
CREATE INDEX idx_notifications_expires_at ON notifications(expires_at) WHERE expires_at IS NOT NULL;

-- Push tokens table
CREATE TABLE IF NOT EXISTS push_tokens (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    device_id VARCHAR(255) NOT NULL,
    token TEXT NOT NULL,
    platform VARCHAR(20) NOT NULL CHECK (platform IN ('iOS', 'android', 'web')),
    environment VARCHAR(20) NOT NULL DEFAULT 'production' CHECK (environment IN ('production', 'sandbox')),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    last_used_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    UNIQUE(device_id, platform)
);

-- Indexes for push tokens
CREATE INDEX idx_push_tokens_user_id ON push_tokens(user_id);
CREATE INDEX idx_push_tokens_token ON push_tokens(token) WHERE is_active = TRUE;
CREATE INDEX idx_push_tokens_device_id ON push_tokens(device_id);

-- Notification preferences table
CREATE TABLE IF NOT EXISTS notification_preferences (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE UNIQUE,
    is_enabled BOOLEAN NOT NULL DEFAULT TRUE,
    channel_preferences JSONB NOT NULL DEFAULT '{}'::JSONB,
    quiet_hours JSONB,
    frequency_limits JSONB,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- Index for notification preferences
CREATE INDEX idx_notification_preferences_user_id ON notification_preferences(user_id);

-- Notification templates table
CREATE TABLE IF NOT EXISTS notification_templates (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    type VARCHAR(50) NOT NULL UNIQUE,
    title_template TEXT NOT NULL,
    body_template TEXT NOT NULL,
    default_channels TEXT[] NOT NULL DEFAULT ARRAY['inApp']::TEXT[],
    default_priority VARCHAR(20) NOT NULL DEFAULT 'medium',
    metadata JSONB,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- Index for notification templates
CREATE INDEX idx_notification_templates_type ON notification_templates(type);

-- Notification queue table (for async processing)
CREATE TABLE IF NOT EXISTS notification_queue (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    notification_id UUID REFERENCES notifications(id) ON DELETE CASCADE,
    channel VARCHAR(20) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'processing', 'sent', 'failed')),
    attempts INT NOT NULL DEFAULT 0,
    last_attempt_at TIMESTAMP WITH TIME ZONE,
    error_message TEXT,
    metadata JSONB,
    scheduled_for TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- Indexes for notification queue
CREATE INDEX idx_notification_queue_notification_id ON notification_queue(notification_id);
CREATE INDEX idx_notification_queue_status ON notification_queue(status);
CREATE INDEX idx_notification_queue_scheduled_for ON notification_queue(scheduled_for) WHERE status = 'pending';

-- Notification analytics table
CREATE TABLE IF NOT EXISTS notification_analytics (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    notification_id UUID REFERENCES notifications(id) ON DELETE CASCADE,
    channel VARCHAR(20) NOT NULL,
    event_type VARCHAR(50) NOT NULL CHECK (event_type IN ('sent', 'delivered', 'opened', 'clicked', 'dismissed', 'failed')),
    event_data JSONB,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

-- Indexes for notification analytics
CREATE INDEX idx_notification_analytics_notification_id ON notification_analytics(notification_id);
CREATE INDEX idx_notification_analytics_event_type ON notification_analytics(event_type);
CREATE INDEX idx_notification_analytics_created_at ON notification_analytics(created_at DESC);

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers for updated_at
CREATE TRIGGER update_notifications_updated_at BEFORE UPDATE ON notifications
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_push_tokens_updated_at BEFORE UPDATE ON push_tokens
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_notification_preferences_updated_at BEFORE UPDATE ON notification_preferences
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_notification_templates_updated_at BEFORE UPDATE ON notification_templates
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_notification_queue_updated_at BEFORE UPDATE ON notification_queue
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Insert default notification templates
INSERT INTO notification_templates (type, title_template, body_template, default_channels, default_priority) VALUES
    ('course_assigned', 'Назначен новый курс', 'Вам назначен курс "{{courseName}}". {{#deadline}}Срок выполнения: {{deadline}}.{{/deadline}}', ARRAY['push', 'email', 'inApp']::TEXT[], 'high'),
    ('course_completed', 'Курс завершен', 'Поздравляем! Вы успешно завершили курс "{{courseName}}".', ARRAY['push', 'inApp']::TEXT[], 'medium'),
    ('test_available', 'Доступен новый тест', 'Тест "{{testName}}" доступен для прохождения.', ARRAY['push', 'inApp']::TEXT[], 'medium'),
    ('test_deadline', 'Приближается дедлайн теста', 'До дедлайна теста "{{testName}}" осталось {{daysLeft}} дней.', ARRAY['push', 'email', 'inApp']::TEXT[], 'high'),
    ('achievement_unlocked', 'Новое достижение', 'Поздравляем! Вы получили достижение "{{achievementName}}".', ARRAY['push', 'inApp']::TEXT[], 'low'),
    ('certificate_issued', 'Выдан сертификат', 'Вам выдан сертификат за успешное прохождение курса "{{courseName}}".', ARRAY['push', 'email', 'inApp']::TEXT[], 'medium'),
    ('system_message', 'Системное сообщение', '{{message}}', ARRAY['inApp']::TEXT[], 'low'),
    ('admin_message', 'Сообщение от администратора', '{{message}}', ARRAY['push', 'email', 'inApp']::TEXT[], 'high')
ON CONFLICT (type) DO NOTHING; 