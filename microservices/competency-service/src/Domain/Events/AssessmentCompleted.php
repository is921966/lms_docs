<?php

namespace CompetencyService\Domain\Events;

use CompetencyService\Domain\Common\DomainEvent;
use CompetencyService\Domain\ValueObjects\AssessmentId;
use CompetencyService\Domain\ValueObjects\AssessmentScore;

final class AssessmentCompleted implements DomainEvent
{
    private AssessmentId $assessmentId;
    private AssessmentScore $score;
    private \DateTimeImmutable $occurredAt;
    
    public function __construct(
        AssessmentId $assessmentId,
        AssessmentScore $score
    ) {
        $this->assessmentId = $assessmentId;
        $this->score = $score;
        $this->occurredAt = new \DateTimeImmutable();
    }
    
    public function getAggregateId(): string
    {
        return $this->assessmentId->toString();
    }
    
    public function getOccurredAt(): \DateTimeImmutable
    {
        return $this->occurredAt;
    }
    
    public function getEventName(): string
    {
        return 'assessment.completed';
    }
    
    public function toArray(): array
    {
        return [
            'assessment_id' => $this->assessmentId->toString(),
            'score' => $this->score->toArray(),
            'occurred_at' => $this->occurredAt->format('Y-m-d H:i:s')
        ];
    }
} 