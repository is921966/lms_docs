<?php

declare(strict_types=1);

namespace Learning\Domain;

use Learning\Domain\ValueObjects\ProgressId;
use Learning\Domain\ValueObjects\ProgressStatus;
use Learning\Domain\ValueObjects\EnrollmentId;
use Learning\Domain\ValueObjects\LessonId;

class Progress
{
    private ProgressId $id;
    private EnrollmentId $enrollmentId;
    private LessonId $lessonId;
    private ProgressStatus $status;
    private float $percentage = 0.0;
    private ?float $score = null;
    private ?float $highestScore = null;
    private int $attemptCount = 0;
    private int $timeSpentMinutes = 0;
    private ?\DateTimeImmutable $startedAt = null;
    private ?\DateTimeImmutable $completedAt = null;
    private ?\DateTimeImmutable $failedAt = null;
    private \DateTimeImmutable $createdAt;
    private \DateTimeImmutable $updatedAt;
    
    private function __construct(
        ProgressId $id,
        EnrollmentId $enrollmentId,
        LessonId $lessonId
    ) {
        $this->id = $id;
        $this->enrollmentId = $enrollmentId;
        $this->lessonId = $lessonId;
        $this->status = ProgressStatus::NOT_STARTED;
        $this->createdAt = new \DateTimeImmutable();
        $this->updatedAt = new \DateTimeImmutable();
    }
    
    public static function create(
        EnrollmentId $enrollmentId,
        LessonId $lessonId
    ): self {
        return new self(
            ProgressId::generate(),
            $enrollmentId,
            $lessonId
        );
    }
    
    public function start(): void
    {
        $this->status = ProgressStatus::IN_PROGRESS;
        $this->startedAt = new \DateTimeImmutable();
        $this->attemptCount++;
        $this->updatedAt = new \DateTimeImmutable();
    }
    
    public function restart(): void
    {
        $this->status = ProgressStatus::IN_PROGRESS;
        $this->percentage = 0.0;
        $this->score = null;
        $this->startedAt = new \DateTimeImmutable();
        $this->completedAt = null;
        $this->failedAt = null;
        $this->attemptCount++;
        $this->updatedAt = new \DateTimeImmutable();
    }
    
    public function updatePercentage(float $percentage): void
    {
        if ($percentage < 0 || $percentage > 100) {
            throw new \InvalidArgumentException('Percentage must be between 0 and 100');
        }
        
        $this->percentage = $percentage;
        $this->status = ProgressStatus::fromPercentage($percentage);
        
        if ($this->status === ProgressStatus::COMPLETED) {
            $this->completedAt = new \DateTimeImmutable();
        }
        
        $this->updatedAt = new \DateTimeImmutable();
    }
    
    public function recordScore(float $score): void
    {
        $this->score = $score;
        
        if ($this->highestScore === null || $score > $this->highestScore) {
            $this->highestScore = $score;
        }
        
        $this->updatedAt = new \DateTimeImmutable();
    }
    
    public function markAsFailed(): void
    {
        $this->status = ProgressStatus::FAILED;
        $this->failedAt = new \DateTimeImmutable();
        $this->updatedAt = new \DateTimeImmutable();
    }
    
    public function addTimeSpent(int $minutes): void
    {
        $this->timeSpentMinutes += $minutes;
        $this->updatedAt = new \DateTimeImmutable();
    }
    
    // Getters
    public function getId(): ProgressId
    {
        return $this->id;
    }
    
    public function getEnrollmentId(): EnrollmentId
    {
        return $this->enrollmentId;
    }
    
    public function getLessonId(): LessonId
    {
        return $this->lessonId;
    }
    
    public function getStatus(): ProgressStatus
    {
        return $this->status;
    }
    
    public function getPercentage(): float
    {
        return $this->percentage;
    }
    
    public function getScore(): ?float
    {
        return $this->score;
    }
    
    public function getHighestScore(): ?float
    {
        return $this->highestScore;
    }
    
    public function getAttemptCount(): int
    {
        return $this->attemptCount;
    }
    
    public function getTimeSpentMinutes(): int
    {
        return $this->timeSpentMinutes;
    }
    
    public function getStartedAt(): ?\DateTimeImmutable
    {
        return $this->startedAt;
    }
    
    public function getCompletedAt(): ?\DateTimeImmutable
    {
        return $this->completedAt;
    }
    
    public function getFailedAt(): ?\DateTimeImmutable
    {
        return $this->failedAt;
    }
    
    public function getCreatedAt(): \DateTimeImmutable
    {
        return $this->createdAt;
    }
    
    public function getUpdatedAt(): \DateTimeImmutable
    {
        return $this->updatedAt;
    }
} 