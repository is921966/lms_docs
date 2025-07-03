<?php

declare(strict_types=1);

namespace Competency\Domain\Events;

use Common\Interfaces\DomainEventInterface;
use Competency\Domain\ValueObjects\AssessmentId;
use User\Domain\ValueObjects\UserId;

final class AssessmentConfirmed implements DomainEventInterface
{
    public function __construct(
        public readonly AssessmentId $assessmentId,
        public readonly UserId $confirmedBy,
        public readonly string $confirmerRole,
        public readonly \DateTimeImmutable $occurredAt = new \DateTimeImmutable()
    ) {
    }
    
    public function getEventName(): string
    {
        return 'assessment.confirmed';
    }
    
    public function getAggregateId(): string
    {
        return $this->assessmentId->getValue();
    }
    
    public function getOccurredAt(): \DateTimeImmutable
    {
        return $this->occurredAt;
    }
    
    public function toArray(): array
    {
        return [
            'assessmentId' => $this->assessmentId->getValue(),
            'confirmedBy' => $this->confirmedBy->getValue(),
            'confirmerRole' => $this->confirmerRole,
            'occurredAt' => $this->occurredAt->format(\DateTimeInterface::ATOM),
        ];
    }
}
