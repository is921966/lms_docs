<?php

declare(strict_types=1);

namespace Notification\Domain\ValueObjects;

class NotificationType
{
    private const COURSE_ASSIGNED = 'course_assigned';
    private const COURSE_COMPLETED = 'course_completed';
    private const PROGRAM_ENROLLED = 'program_enrolled';
    private const CERTIFICATE_ISSUED = 'certificate_issued';
    private const REMINDER_COURSE = 'reminder_course';
    private const SYSTEM_ANNOUNCEMENT = 'system_announcement';
    
    private const DISPLAY_NAMES = [
        self::COURSE_ASSIGNED => 'Course Assigned',
        self::COURSE_COMPLETED => 'Course Completed',
        self::PROGRAM_ENROLLED => 'Program Enrolled',
        self::CERTIFICATE_ISSUED => 'Certificate Issued',
        self::REMINDER_COURSE => 'Course Reminder',
        self::SYSTEM_ANNOUNCEMENT => 'System Announcement',
    ];
    
    private string $value;
    
    private function __construct(string $value)
    {
        $this->value = $value;
    }
    
    public static function fromString(string $value): self
    {
        if (empty($value)) {
            throw new \InvalidArgumentException('Notification type cannot be empty');
        }
        
        if (!preg_match('/^[a-z_]+$/', $value)) {
            throw new \InvalidArgumentException('Invalid notification type format');
        }
        
        return new self($value);
    }
    
    public static function courseAssigned(): self
    {
        return new self(self::COURSE_ASSIGNED);
    }
    
    public static function courseCompleted(): self
    {
        return new self(self::COURSE_COMPLETED);
    }
    
    public static function programEnrolled(): self
    {
        return new self(self::PROGRAM_ENROLLED);
    }
    
    public static function certificateIssued(): self
    {
        return new self(self::CERTIFICATE_ISSUED);
    }
    
    public static function reminderCourse(): self
    {
        return new self(self::REMINDER_COURSE);
    }
    
    public static function systemAnnouncement(): self
    {
        return new self(self::SYSTEM_ANNOUNCEMENT);
    }
    
    public function getValue(): string
    {
        return $this->value;
    }
    
    public function getDisplayName(): string
    {
        return self::DISPLAY_NAMES[$this->value] ?? ucwords(str_replace('_', ' ', $this->value));
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