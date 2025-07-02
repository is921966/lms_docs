<?php

declare(strict_types=1);

namespace Learning\Application\DTO;

use Learning\Domain\Progress;

final class ProgressDTO
{
    public function __construct(
        public readonly ?string $id,
        public readonly string $enrollmentId,
        public readonly string $lessonId,
        public readonly string $status,
        public readonly float $percentage,
        public readonly ?float $score,
        public readonly ?float $highestScore,
        public readonly int $attemptCount,
        public readonly int $timeSpentMinutes,
        public readonly ?string $startedAt,
        public readonly ?string $completedAt,
        public readonly ?string $failedAt,
        public readonly ?string $createdAt = null,
        public readonly ?string $updatedAt = null
    ) {}
    
    public static function fromArray(array $data): self
    {
        return new self(
            id: $data['id'] ?? null,
            enrollmentId: $data['enrollmentId'],
            lessonId: $data['lessonId'],
            status: $data['status'] ?? 'not_started',
            percentage: $data['percentage'] ?? 0.0,
            score: $data['score'] ?? null,
            highestScore: $data['highestScore'] ?? null,
            attemptCount: $data['attemptCount'] ?? 0,
            timeSpentMinutes: $data['timeSpentMinutes'] ?? 0,
            startedAt: $data['startedAt'] ?? null,
            completedAt: $data['completedAt'] ?? null,
            failedAt: $data['failedAt'] ?? null,
            createdAt: $data['createdAt'] ?? null,
            updatedAt: $data['updatedAt'] ?? null
        );
    }
    
    public static function fromEntity(Progress $progress): self
    {
        return new self(
            id: $progress->getId()->getValue(),
            enrollmentId: $progress->getEnrollmentId()->getValue(),
            lessonId: $progress->getLessonId()->getValue(),
            status: $progress->getStatus()->value,
            percentage: $progress->getPercentage(),
            score: $progress->getScore(),
            highestScore: $progress->getHighestScore(),
            attemptCount: $progress->getAttemptCount(),
            timeSpentMinutes: $progress->getTimeSpentMinutes(),
            startedAt: $progress->getStartedAt()?->format('c'),
            completedAt: $progress->getCompletedAt()?->format('c'),
            failedAt: $progress->getFailedAt()?->format('c'),
            createdAt: $progress->getCreatedAt()->format('c'),
            updatedAt: $progress->getUpdatedAt()->format('c')
        );
    }
    
    public function toArray(): array
    {
        return [
            'id' => $this->id,
            'enrollmentId' => $this->enrollmentId,
            'lessonId' => $this->lessonId,
            'status' => $this->status,
            'percentage' => $this->percentage,
            'score' => $this->score,
            'highestScore' => $this->highestScore,
            'attemptCount' => $this->attemptCount,
            'timeSpentMinutes' => $this->timeSpentMinutes,
            'startedAt' => $this->startedAt,
            'completedAt' => $this->completedAt,
            'failedAt' => $this->failedAt,
            'createdAt' => $this->createdAt,
            'updatedAt' => $this->updatedAt,
        ];
    }
    
    public function isPassed(float $passingScore = 60.0): bool
    {
        if ($this->status !== 'completed') {
            return false;
        }
        
        return ($this->highestScore ?? 0.0) >= $passingScore;
    }
} 