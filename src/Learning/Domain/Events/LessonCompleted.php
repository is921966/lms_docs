<?php

declare(strict_types=1);

namespace Learning\Domain\Events;

use Common\Interfaces\DomainEventInterface;
use Learning\Domain\ValueObjects\CourseId;
use DateTimeImmutable;

final class LessonCompleted implements DomainEventInterface
{
    public function __construct(
        private readonly string $userId,
        private readonly CourseId $courseId,
        private readonly string $lessonId,
        private readonly DateTimeImmutable $completedAt,
        private readonly int $timeSpentMinutes
    ) {}
    
    public static function create(
        string $userId,
        CourseId $courseId,
        string $lessonId,
        int $timeSpentMinutes
    ): self {
        return new self(
            $userId,
            $courseId,
            $lessonId,
            new DateTimeImmutable(),
            $timeSpentMinutes
        );
    }
    
    public function getUserId(): string
    {
        return $this->userId;
    }
    
    public function getCourseId(): CourseId
    {
        return $this->courseId;
    }
    
    public function getLessonId(): string
    {
        return $this->lessonId;
    }
    
    public function getCompletedAt(): DateTimeImmutable
    {
        return $this->completedAt;
    }
    
    public function getTimeSpentMinutes(): int
    {
        return $this->timeSpentMinutes;
    }
    
    public function getOccurredAt(): DateTimeImmutable
    {
        return $this->completedAt;
    }
    
    public function getEventName(): string
    {
        return 'lesson.completed';
    }
    
    public function getAggregateId(): string
    {
        // For learning progress, aggregate is user's progress in course
        return "{$this->userId}:{$this->courseId->getValue()}";
    }
    
    public function toArray(): array
    {
        return [
            'event_name' => $this->getEventName(),
            'user_id' => $this->userId,
            'course_id' => $this->courseId->getValue(),
            'lesson_id' => $this->lessonId,
            'completed_at' => $this->completedAt->format('Y-m-d H:i:s'),
            'time_spent_minutes' => $this->timeSpentMinutes,
            'occurred_at' => $this->getOccurredAt()->format('Y-m-d H:i:s')
        ];
    }
} 