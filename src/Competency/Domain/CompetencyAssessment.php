<?php

declare(strict_types=1);

namespace Competency\Domain;

use Common\Traits\HasDomainEvents;
use Competency\Domain\Events\AssessmentCreated;
use Competency\Domain\Events\AssessmentUpdated;
use Competency\Domain\Events\AssessmentConfirmed;
use Competency\Domain\ValueObjects\CompetencyId;
use Competency\Domain\ValueObjects\CompetencyLevel;
use Competency\Domain\ValueObjects\AssessmentScore;
use User\Domain\ValueObjects\UserId;

class CompetencyAssessment
{
    use HasDomainEvents;
    
    private string $id;
    private CompetencyId $competencyId;
    private UserId $userId;
    private UserId $assessorId;
    private CompetencyLevel $level;
    private AssessmentScore $score;
    private ?string $comment;
    private \DateTimeImmutable $assessedAt;
    private ?UserId $confirmedBy;
    private ?\DateTimeImmutable $confirmedAt;
    
    private function __construct(
        string $id,
        CompetencyId $competencyId,
        UserId $userId,
        UserId $assessorId,
        CompetencyLevel $level,
        AssessmentScore $score,
        ?string $comment = null,
        \DateTimeImmutable $assessedAt = new \DateTimeImmutable(),
        ?UserId $confirmedBy = null,
        ?\DateTimeImmutable $confirmedAt = null
    ) {
        $this->id = $id;
        $this->competencyId = $competencyId;
        $this->userId = $userId;
        $this->assessorId = $assessorId;
        $this->level = $level;
        $this->score = $score;
        $this->comment = $comment;
        $this->assessedAt = $assessedAt;
        $this->confirmedBy = $confirmedBy;
        $this->confirmedAt = $confirmedAt;
    }
    
    public static function create(
        string $id,
        CompetencyId $competencyId,
        UserId $userId,
        UserId $assessorId,
        CompetencyLevel $level,
        AssessmentScore $score,
        ?string $comment = null
    ): self {
        $assessedAt = new \DateTimeImmutable();
        
        $assessment = new self(
            $id,
            $competencyId,
            $userId,
            $assessorId,
            $level,
            $score,
            $comment,
            $assessedAt
        );
        
        $assessment->recordDomainEvent(new AssessmentCreated(
            $id,
            $competencyId,
            $userId,
            $assessorId,
            $level,
            $score,
            $comment,
            $assessedAt
        ));
        
        return $assessment;
    }
    
    public static function createWithDate(
        string $id,
        CompetencyId $competencyId,
        UserId $userId,
        UserId $assessorId,
        CompetencyLevel $level,
        AssessmentScore $score,
        \DateTimeImmutable $assessedAt,
        ?string $comment = null
    ): self {
        $assessment = new self(
            $id,
            $competencyId,
            $userId,
            $assessorId,
            $level,
            $score,
            $comment,
            $assessedAt
        );
        
        $assessment->recordDomainEvent(new AssessmentCreated(
            $id,
            $competencyId,
            $userId,
            $assessorId,
            $level,
            $score,
            $comment,
            $assessedAt
        ));
        
        return $assessment;
    }
    
    public function confirm(UserId $confirmerId): void
    {
        if ($this->isConfirmed()) {
            throw new \DomainException('Assessment is already confirmed');
        }
        
        $this->confirmedBy = $confirmerId;
        $this->confirmedAt = new \DateTimeImmutable();
        
        $this->recordDomainEvent(new AssessmentConfirmed(
            $this->id,
            $confirmerId,
            $this->confirmedAt
        ));
    }
    
    public function update(CompetencyLevel $level, AssessmentScore $score, ?string $comment = null): void
    {
        if ($this->isConfirmed()) {
            throw new \DomainException('Cannot update confirmed assessment');
        }
        
        $this->level = $level;
        $this->score = $score;
        $this->comment = $comment;
        
        $this->recordDomainEvent(new AssessmentUpdated(
            $this->id,
            $level,
            $score,
            $comment
        ));
    }
    
    public function isSelfAssessment(): bool
    {
        return $this->userId->equals($this->assessorId);
    }
    
    public function isConfirmed(): bool
    {
        return $this->confirmedBy !== null;
    }
    
    public function getAssessmentType(): string
    {
        return $this->isSelfAssessment() ? 'self' : 'manager';
    }
    
    public function getGapToTarget(CompetencyLevel $targetLevel): int
    {
        return $targetLevel->getValue() - $this->level->getValue();
    }
    
    public function isAboveLevel(CompetencyLevel $level): bool
    {
        return $this->level->getValue() > $level->getValue();
    }
    
    public function getDaysSinceAssessment(): int
    {
        $now = new \DateTimeImmutable();
        $diff = $now->diff($this->assessedAt);
        return (int) $diff->days;
    }
    
    public function getId(): string
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
    
    public function getLevel(): CompetencyLevel
    {
        return $this->level;
    }
    
    public function getScore(): AssessmentScore
    {
        return $this->score;
    }
    
    public function getComment(): ?string
    {
        return $this->comment;
    }
    
    public function getAssessedAt(): \DateTimeImmutable
    {
        return $this->assessedAt;
    }
    
    public function getConfirmedBy(): ?UserId
    {
        return $this->confirmedBy;
    }
    
    public function getConfirmedAt(): ?\DateTimeImmutable
    {
        return $this->confirmedAt;
    }
} 