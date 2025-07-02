<?php

declare(strict_types=1);

namespace Learning\Application\Commands;

use InvalidArgumentException;
use DateTimeImmutable;

final class EnrollUserCommand
{
    private const VALID_ENROLLMENT_TYPES = ['voluntary', 'mandatory', 'recommended'];
    
    private string $commandId;
    private array $metadata;
    private DateTimeImmutable $createdAt;
    
    public function __construct(
        private readonly string $userId,
        private readonly string $courseId,
        private readonly string $enrolledBy,
        private readonly string $enrollmentType = 'voluntary',
        array $metadata = []
    ) {
        if (empty($userId)) {
            throw new InvalidArgumentException('User ID cannot be empty');
        }
        
        if (empty($courseId)) {
            throw new InvalidArgumentException('Course ID cannot be empty');
        }
        
        if (empty($enrolledBy)) {
            throw new InvalidArgumentException('Enrolled by cannot be empty');
        }
        
        if (!in_array($enrollmentType, self::VALID_ENROLLMENT_TYPES, true)) {
            throw new InvalidArgumentException('Invalid enrollment type');
        }
        
        $this->commandId = uniqid('cmd_', true);
        $this->metadata = $metadata;
        $this->createdAt = new DateTimeImmutable();
    }
    
    public function getCommandId(): string
    {
        return $this->commandId;
    }
    
    public function getUserId(): string
    {
        return $this->userId;
    }
    
    public function getCourseId(): string
    {
        return $this->courseId;
    }
    
    public function getEnrolledBy(): string
    {
        return $this->enrolledBy;
    }
    
    public function getEnrollmentType(): string
    {
        return $this->enrollmentType;
    }
    
    public function getMetadata(): array
    {
        return $this->metadata;
    }
    
    public function getCreatedAt(): DateTimeImmutable
    {
        return $this->createdAt;
    }
    
    public function isSelfEnrollment(): bool
    {
        return $this->userId === $this->enrolledBy;
    }
} 