<?php

declare(strict_types=1);

namespace Competency\Domain\Events;

use Common\Interfaces\DomainEventInterface;
use Competency\Domain\ValueObjects\AssessmentId;
use Competency\Domain\ValueObjects\UserCompetencyId;

final class AssessmentCreated implements DomainEventInterface
{
    public function __construct(
        public readonly AssessmentId $assessmentId,
        public readonly UserCompetencyId $userCompetencyId,
        public readonly string $assessmentType,
        public readonly array $questions,
        public readonly \DateTimeImmutable $occurredAt = new \DateTimeImmutable()
    ) {
    }
    
    public function getEventName(): string
    {
        return 'assessment.created';
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
            'userCompetencyId' => $this->userCompetencyId->getValue(),
            'assessmentType' => $this->assessmentType,
            'questions' => $this->questions,
            'occurredAt' => $this->occurredAt->format(\DateTimeInterface::ATOM),
        ];
    }
}
