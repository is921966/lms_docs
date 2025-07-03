<?php

declare(strict_types=1);

namespace Notification\Domain\ValueObjects;

class NotificationChannel
{
    private const EMAIL = 'email';
    private const PUSH = 'push';
    private const IN_APP = 'in_app';
    private const SMS = 'sms';
    
    private const VALID_CHANNELS = [
        self::EMAIL,
        self::PUSH,
        self::IN_APP,
        self::SMS,
    ];
    
    private const CHANNELS_WITH_TEMPLATES = [
        self::EMAIL,
    ];
    
    private const CHANNELS_WITH_ATTACHMENTS = [
        self::EMAIL,
    ];
    
    private string $value;
    
    private function __construct(string $value)
    {
        $this->value = $value;
    }
    
    public static function fromString(string $value): self
    {
        if (empty($value)) {
            throw new \InvalidArgumentException('Notification channel cannot be empty');
        }
        
        if (!in_array($value, self::VALID_CHANNELS, true)) {
            throw new \InvalidArgumentException('Invalid notification channel');
        }
        
        return new self($value);
    }
    
    public static function email(): self
    {
        return new self(self::EMAIL);
    }
    
    public static function push(): self
    {
        return new self(self::PUSH);
    }
    
    public static function inApp(): self
    {
        return new self(self::IN_APP);
    }
    
    public static function sms(): self
    {
        return new self(self::SMS);
    }
    
    public function getValue(): string
    {
        return $this->value;
    }
    
    public function supportsTemplates(): bool
    {
        return in_array($this->value, self::CHANNELS_WITH_TEMPLATES, true);
    }
    
    public function supportsAttachments(): bool
    {
        return in_array($this->value, self::CHANNELS_WITH_ATTACHMENTS, true);
    }
    
    public function equals(self $other): bool
    {
        return $this->value === $other->value;
    }
    
    public function __toString(): string
    {
        return $this->value;
    }
} 