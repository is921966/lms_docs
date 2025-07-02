<?php

declare(strict_types=1);

namespace Learning\Domain\Events;

use Common\Interfaces\DomainEventInterface;
use Learning\Domain\ValueObjects\CourseId;
use Learning\Domain\ValueObjects\CourseCode;
use Learning\Domain\ValueObjects\CourseStatus;
use DateTimeImmutable;

final class CourseCreated implements DomainEventInterface
{
    public function __construct(
        private readonly CourseId $courseId,
        private readonly CourseCode $courseCode,
        private readonly string $title,
        private readonly string $description,
        private readonly CourseStatus $status,
        private readonly DateTimeImmutable $occurredAt
    ) {}
    
    public static function create(
        CourseId $courseId,
        CourseCode $courseCode,
        string $title,
        string $description,
        CourseStatus $status
    ): self {
        return new self(
            $courseId,
            $courseCode,
            $title,
            $description,
            $status,
            new DateTimeImmutable()
        );
    }
    
    public function getCourseId(): CourseId
    {
        return $this->courseId;
    }
    
    public function getCourseCode(): CourseCode
    {
        return $this->courseCode;
    }
    
    public function getTitle(): string
    {
        return $this->title;
    }
    
    public function getDescription(): string
    {
        return $this->description;
    }
    
    public function getStatus(): CourseStatus
    {
        return $this->status;
    }
    
    public function getOccurredAt(): DateTimeImmutable
    {
        return $this->occurredAt;
    }
    
    public function getEventName(): string
    {
        return 'course.created';
    }
    
    public function getAggregateId(): string
    {
        return $this->courseId->getValue();
    }
    
    public function toArray(): array
    {
        return [
            'event_name' => $this->getEventName(),
            'course_id' => $this->courseId->getValue(),
            'course_code' => $this->courseCode->getValue(),
            'title' => $this->title,
            'description' => $this->description,
            'status' => $this->status->getValue(),
            'occurred_at' => $this->occurredAt->format('Y-m-d H:i:s')
        ];
    }
} 