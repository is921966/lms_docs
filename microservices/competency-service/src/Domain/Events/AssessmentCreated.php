<?php

namespace CompetencyService\Domain\Events;

use CompetencyService\Domain\Common\DomainEvent;
use CompetencyService\Domain\ValueObjects\AssessmentId;
use CompetencyService\Domain\ValueObjects\CompetencyId;
use CompetencyService\Domain\ValueObjects\UserId;

final class AssessmentCreated implements DomainEvent
{
    private AssessmentId $assessmentId;
    private CompetencyId $competencyId;
    private UserId $userId;
    private UserId $assessorId;
    private \DateTimeImmutable $occurredAt;
    
    public function __construct(
        AssessmentId $assessmentId,
        CompetencyId $competencyId,
        UserId $userId,
        UserId $assessorId
    ) {
        $this->assessmentId = $assessmentId;
        $this->competencyId = $competencyId;
        $this->userId = $userId;
        $this->assessorId = $assessorId;
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
        return 'assessment.created';
    }
    
    public function toArray(): array
    {
        return [
            'assessment_id' => $this->assessmentId->toString(),
            'competency_id' => $this->competencyId->toString(),
            'user_id' => $this->userId->getValue(),
            'assessor_id' => $this->assessorId->getValue(),
            'occurred_at' => $this->occurredAt->format('Y-m-d H:i:s')
        ];
    }
} 