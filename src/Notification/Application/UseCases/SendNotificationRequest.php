<?php

declare(strict_types=1);

namespace Notification\Application\UseCases;

use Ramsey\Uuid\Uuid;

class SendNotificationRequest
{
    private const VALID_CHANNELS = ['email', 'push', 'in_app', 'sms'];
    private const VALID_PRIORITIES = ['high', 'medium', 'low'];
    
    public function __construct(
        public readonly string $recipientId,
        public readonly string $type,
        public readonly string $channel,
        public readonly string $subject,
        public readonly string $content,
        public readonly string $priority = 'medium',
        public readonly array $metadata = []
    ) {
        $this->validate();
    }
    
    private function validate(): void
    {
        if (!Uuid::isValid($this->recipientId)) {
            throw new \InvalidArgumentException('Invalid recipient ID');
        }
        
        if (empty($this->subject)) {
            throw new \InvalidArgumentException('Subject cannot be empty');
        }
        
        if (empty($this->content)) {
            throw new \InvalidArgumentException('Content cannot be empty');
        }
        
        if (!preg_match('/^[a-z_]+$/', $this->type)) {
            throw new \InvalidArgumentException('Invalid notification type');
        }
        
        if (!in_array($this->channel, self::VALID_CHANNELS, true)) {
            throw new \InvalidArgumentException('Invalid notification channel');
        }
        
        if (!in_array($this->priority, self::VALID_PRIORITIES, true)) {
            throw new \InvalidArgumentException('Invalid notification priority');
        }
    }
} 