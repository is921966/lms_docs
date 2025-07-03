<?php

declare(strict_types=1);

namespace Competency\Domain\Events;

use Common\Interfaces\DomainEventInterface;
use Competency\Domain\ValueObjects\AssessmentId;

final class AssessmentUpdated implements DomainEventInterface
{
    public function __construct(
        public readonly AssessmentId $assessmentId,
        public readonly array $answers,
        public readonly int $currentProgress,
        public readonly \DateTimeImmutable $occurredAt = new \DateTimeImmutable()
    ) {
    }
    
    public function getEventName(): string
    {
        return 'assessment.updated';
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
            'answers' => $this->answers,
            'currentProgress' => $this->currentProgress,
            'occurredAt' => $this->occurredAt->format(\DateTimeInterface::ATOM),
        ];
    }
}
