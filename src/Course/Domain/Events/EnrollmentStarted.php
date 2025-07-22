<?php

declare(strict_types=1);

namespace App\Course\Domain\Events;

use App\Common\Domain\DomainEvent;

final class EnrollmentStarted implements DomainEvent
{
    private \DateTimeImmutable $occurredOn;
    
    public function __construct(
        public readonly string $enrollmentId,
        public readonly string $courseId,
        public readonly string $userId
    ) {
        $this->occurredOn = new \DateTimeImmutable();
    }
    
    public function occurredOn(): \DateTimeImmutable
    {
        return $this->occurredOn;
    }
    
    public function aggregateId(): string
    {
        return $this->enrollmentId;
    }
} 