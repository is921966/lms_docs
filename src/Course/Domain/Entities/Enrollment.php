<?php

declare(strict_types=1);

namespace App\Course\Domain\Entities;

use App\Common\Domain\AggregateRoot;
use App\Common\Exceptions\InvalidArgumentException;
use App\Course\Domain\ValueObjects\CourseId;
use App\Course\Domain\Events\EnrollmentStarted;
use App\Course\Domain\Events\CourseCompleted;
use Ramsey\Uuid\Uuid;

class Enrollment extends AggregateRoot
{
    private const STATUS_ACTIVE = 'active';
    private const STATUS_SUSPENDED = 'suspended';
    private const STATUS_COMPLETED = 'completed';
    
    private string $id;
    private CourseId $courseId;
    private string $userId;
    private string $status;
    private int $progressPercent;
    private \DateTimeImmutable $enrolledAt;
    private ?\DateTimeImmutable $completedAt = null;
    private ?\DateTimeImmutable $lastActivityAt = null;
    
    public function __construct(CourseId $courseId, string $userId)
    {
        if (empty($userId)) {
            throw new InvalidArgumentException('User ID cannot be empty');
        }
        
        $this->id = 'ENR-' . Uuid::uuid4()->toString();
        $this->courseId = $courseId;
        $this->userId = $userId;
        $this->status = self::STATUS_ACTIVE;
        $this->progressPercent = 0;
        $this->enrolledAt = new \DateTimeImmutable();
        
        $this->recordEvent(new EnrollmentStarted(
            $this->id,
            $courseId->value(),
            $userId
        ));
    }
    
    public function updateProgress(int $progressPercent): void
    {
        if ($progressPercent < 0 || $progressPercent > 100) {
            throw new InvalidArgumentException('Progress must be between 0 and 100');
        }
        
        $this->progressPercent = $progressPercent;
        $this->lastActivityAt = new \DateTimeImmutable();
    }
    
    public function complete(): void
    {
        if ($this->progressPercent < 100) {
            throw new InvalidArgumentException('Cannot complete course with progress less than 100%');
        }
        
        if ($this->status === self::STATUS_COMPLETED) {
            throw new InvalidArgumentException('Enrollment is already completed');
        }
        
        $this->status = self::STATUS_COMPLETED;
        $this->completedAt = new \DateTimeImmutable();
        
        $this->recordEvent(new CourseCompleted(
            $this->id,
            $this->courseId->value(),
            $this->userId,
            $this->completedAt
        ));
    }
    
    public function suspend(): void
    {
        if ($this->status === self::STATUS_COMPLETED) {
            throw new InvalidArgumentException('Cannot suspend completed enrollment');
        }
        
        $this->status = self::STATUS_SUSPENDED;
        $this->lastActivityAt = new \DateTimeImmutable();
    }
    
    public function resume(): void
    {
        if ($this->status !== self::STATUS_SUSPENDED) {
            throw new InvalidArgumentException('Can only resume suspended enrollments');
        }
        
        $this->status = self::STATUS_ACTIVE;
        $this->lastActivityAt = new \DateTimeImmutable();
    }
    
    // Getters
    public function id(): string
    {
        return $this->id;
    }
    
    public function courseId(): CourseId
    {
        return $this->courseId;
    }
    
    public function userId(): string
    {
        return $this->userId;
    }
    
    public function status(): string
    {
        return $this->status;
    }
    
    public function progressPercent(): int
    {
        return $this->progressPercent;
    }
    
    public function enrolledAt(): \DateTimeImmutable
    {
        return $this->enrolledAt;
    }
    
    public function completedAt(): ?\DateTimeImmutable
    {
        return $this->completedAt;
    }
    
    public function lastActivityAt(): ?\DateTimeImmutable
    {
        return $this->lastActivityAt;
    }
    
    public function isActive(): bool
    {
        return $this->status === self::STATUS_ACTIVE;
    }
    
    public function isCompleted(): bool
    {
        return $this->status === self::STATUS_COMPLETED;
    }
    
    public function isSuspended(): bool
    {
        return $this->status === self::STATUS_SUSPENDED;
    }
} 