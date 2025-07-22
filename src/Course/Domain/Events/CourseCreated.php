<?php

declare(strict_types=1);

namespace App\Course\Domain\Events;

use App\Common\Domain\DomainEvent;

final class CourseCreated implements DomainEvent
{
    private \DateTimeImmutable $occurredOn;
    
    public function __construct(
        public readonly string $courseId,
        public readonly string $courseCode,
        public readonly string $title,
        public readonly string $description,
        public readonly int $durationMinutes,
        public readonly float $priceAmount,
        public readonly string $priceCurrency
    ) {
        $this->occurredOn = new \DateTimeImmutable();
    }
    
    public function occurredOn(): \DateTimeImmutable
    {
        return $this->occurredOn;
    }
    
    public function aggregateId(): string
    {
        return $this->courseId;
    }
} 