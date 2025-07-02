<?php

declare(strict_types=1);

namespace Program\Domain;

use Common\Domain\AggregateRoot;
use Program\Domain\ValueObjects\ProgramId;
use User\Domain\ValueObjects\UserId;
use Program\Domain\Events\UserEnrolledInProgram;

class ProgramEnrollment extends AggregateRoot
{
    private UserId $userId;
    private ProgramId $programId;
    private string $status;
    private int $progress = 0;
    private \DateTimeImmutable $enrolledAt;
    private ?\DateTimeImmutable $startedAt = null;
    private ?\DateTimeImmutable $completedAt = null;
    
    private const STATUS_ENROLLED = 'enrolled';
    private const STATUS_IN_PROGRESS = 'in_progress';
    private const STATUS_SUSPENDED = 'suspended';
    private const STATUS_COMPLETED = 'completed';
    
    private function __construct(UserId $userId, ProgramId $programId)
    {
        $this->userId = $userId;
        $this->programId = $programId;
        $this->status = self::STATUS_ENROLLED;
        $this->enrolledAt = new \DateTimeImmutable();
    }
    
    public static function create(UserId $userId, ProgramId $programId): self
    {
        $enrollment = new self($userId, $programId);
        
        $enrollment->recordThat(new UserEnrolledInProgram(
            $userId,
            $programId,
            $enrollment->enrolledAt
        ));
        
        return $enrollment;
    }
    
    public function start(): void
    {
        if ($this->status === self::STATUS_IN_PROGRESS) {
            throw new \DomainException('Program already started');
        }
        
        if ($this->status === self::STATUS_COMPLETED) {
            throw new \DomainException('Cannot start completed program');
        }
        
        $this->status = self::STATUS_IN_PROGRESS;
        $this->startedAt = new \DateTimeImmutable();
    }
    
    public function complete(): void
    {
        if ($this->status !== self::STATUS_IN_PROGRESS) {
            throw new \DomainException('Cannot complete program that has not been started');
        }
        
        $this->status = self::STATUS_COMPLETED;
        $this->completedAt = new \DateTimeImmutable();
        $this->progress = 100;
    }
    
    public function suspend(): void
    {
        if ($this->status !== self::STATUS_IN_PROGRESS) {
            throw new \DomainException('Can only suspend programs in progress');
        }
        
        $this->status = self::STATUS_SUSPENDED;
    }
    
    public function resume(): void
    {
        if ($this->status !== self::STATUS_SUSPENDED) {
            throw new \DomainException('Can only resume suspended programs');
        }
        
        $this->status = self::STATUS_IN_PROGRESS;
    }
    
    public function updateProgress(int $progress): void
    {
        if ($progress < 0 || $progress > 100) {
            throw new \InvalidArgumentException('Progress must be between 0 and 100');
        }
        
        $this->progress = $progress;
        
        if ($progress === 100 && $this->status === self::STATUS_IN_PROGRESS) {
            $this->complete();
        }
    }
    
    // Getters
    public function getUserId(): UserId
    {
        return $this->userId;
    }
    
    public function getProgramId(): ProgramId
    {
        return $this->programId;
    }
    
    public function getStatus(): string
    {
        return $this->status;
    }
    
    public function getProgress(): int
    {
        return $this->progress;
    }
    
    public function getEnrolledAt(): \DateTimeImmutable
    {
        return $this->enrolledAt;
    }
    
    public function getStartedAt(): ?\DateTimeImmutable
    {
        return $this->startedAt;
    }
    
    public function getCompletedAt(): ?\DateTimeImmutable
    {
        return $this->completedAt;
    }
    
    public function toArray(): array
    {
        return [
            'userId' => $this->userId->getValue(),
            'programId' => $this->programId->getValue(),
            'status' => $this->status,
            'progress' => $this->progress,
            'enrolledAt' => $this->enrolledAt->format('Y-m-d H:i:s'),
            'startedAt' => $this->startedAt?->format('Y-m-d H:i:s'),
            'completedAt' => $this->completedAt?->format('Y-m-d H:i:s')
        ];
    }
} 