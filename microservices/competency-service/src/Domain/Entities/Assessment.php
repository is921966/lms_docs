<?php

namespace CompetencyService\Domain\Entities;

use CompetencyService\Domain\Common\AggregateRoot;
use CompetencyService\Domain\ValueObjects\AssessmentId;
use CompetencyService\Domain\ValueObjects\CompetencyId;
use CompetencyService\Domain\ValueObjects\UserId;
use CompetencyService\Domain\ValueObjects\AssessmentScore;
use CompetencyService\Domain\Events\AssessmentCreated;
use CompetencyService\Domain\Events\AssessmentCompleted;
use DomainException;

class Assessment extends AggregateRoot
{
    private AssessmentId $id;
    private CompetencyId $competencyId;
    private UserId $userId;
    private UserId $assessorId;
    private string $status;
    private ?AssessmentScore $score = null;
    private ?string $cancellationReason = null;
    private \DateTimeImmutable $createdAt;
    private ?\DateTimeImmutable $completedAt = null;
    
    public function __construct(
        AssessmentId $id,
        CompetencyId $competencyId,
        UserId $userId,
        UserId $assessorId
    ) {
        $this->id = $id;
        $this->competencyId = $competencyId;
        $this->userId = $userId;
        $this->assessorId = $assessorId;
        $this->status = 'pending';
        $this->createdAt = new \DateTimeImmutable();
        
        $this->raiseDomainEvent(new AssessmentCreated(
            $id,
            $competencyId,
            $userId,
            $assessorId
        ));
    }
    
    public function complete(AssessmentScore $score): void
    {
        if ($this->status !== 'pending') {
            throw new DomainException('Cannot complete assessment that is not pending');
        }
        
        $this->score = $score;
        $this->status = 'completed';
        $this->completedAt = new \DateTimeImmutable();
        
        $this->raiseDomainEvent(new AssessmentCompleted(
            $this->id,
            $score
        ));
    }
    
    public function cancel(string $reason): void
    {
        if ($this->status !== 'pending') {
            throw new DomainException('Cannot cancel assessment that is not pending');
        }
        
        $this->status = 'cancelled';
        $this->cancellationReason = $reason;
    }
    
    // Getters
    public function getId(): AssessmentId
    {
        return $this->id;
    }
    
    public function getCompetencyId(): CompetencyId
    {
        return $this->competencyId;
    }
    
    public function getUserId(): UserId
    {
        return $this->userId;
    }
    
    public function getAssessorId(): UserId
    {
        return $this->assessorId;
    }
    
    public function getStatus(): string
    {
        return $this->status;
    }
    
    public function getScore(): ?AssessmentScore
    {
        return $this->score;
    }
    
    public function getCancellationReason(): ?string
    {
        return $this->cancellationReason;
    }
    
    public function getCompletedAt(): ?\DateTimeImmutable
    {
        return $this->completedAt;
    }
    
    public function toArray(): array
    {
        return [
            'id' => $this->id->toString(),
            'competency_id' => $this->competencyId->toString(),
            'user_id' => $this->userId->getValue(),
            'assessor_id' => $this->assessorId->getValue(),
            'status' => $this->status,
            'score' => $this->score?->toArray(),
            'cancellation_reason' => $this->cancellationReason,
            'created_at' => $this->createdAt->format('Y-m-d H:i:s'),
            'completed_at' => $this->completedAt?->format('Y-m-d H:i:s')
        ];
    }
} 