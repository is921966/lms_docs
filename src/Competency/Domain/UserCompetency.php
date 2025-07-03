<?php

declare(strict_types=1);

namespace Competency\Domain;

use Common\Traits\HasDomainEvents;
use Competency\Domain\Events\UserCompetencyCreated;
use Competency\Domain\Events\UserCompetencyProgressUpdated;
use Competency\Domain\Events\TargetLevelSet;
use Competency\Domain\ValueObjects\CompetencyId;
use Competency\Domain\ValueObjects\CompetencyLevel;
use Competency\Domain\ValueObjects\UserCompetencyId;
use User\Domain\ValueObjects\UserId;

class UserCompetency
{
    use HasDomainEvents;
    
    private UserCompetencyId $id;
    private UserId $userId;
    private CompetencyId $competencyId;
    private CompetencyLevel $currentLevel;
    private ?CompetencyLevel $targetLevel;
    private \DateTimeImmutable $lastUpdated;
    
    private function __construct(
        UserCompetencyId $id,
        UserId $userId,
        CompetencyId $competencyId,
        CompetencyLevel $currentLevel,
        ?CompetencyLevel $targetLevel = null,
        \DateTimeImmutable $lastUpdated = new \DateTimeImmutable()
    ) {
        $this->id = $id;
        $this->userId = $userId;
        $this->competencyId = $competencyId;
        $this->currentLevel = $currentLevel;
        $this->targetLevel = $targetLevel;
        $this->lastUpdated = $lastUpdated;
    }
    
    public static function create(
        UserId $userId,
        CompetencyId $competencyId,
        CompetencyLevel $currentLevel,
        ?CompetencyLevel $targetLevel = null
    ): self {
        $id = UserCompetencyId::generate();
        
        $userCompetency = new self(
            $id,
            $userId,
            $competencyId,
            $currentLevel,
            $targetLevel
        );
        
        $userCompetency->recordDomainEvent(new UserCompetencyCreated(
            $id,
            $userId,
            $competencyId,
            $currentLevel->getValue(),
            $targetLevel?->getValue()
        ));
        
        return $userCompetency;
    }
    
    public static function createWithDate(
        UserId $userId,
        CompetencyId $competencyId,
        CompetencyLevel $currentLevel,
        \DateTimeImmutable $lastUpdated,
        ?CompetencyLevel $targetLevel = null
    ): self {
        $id = UserCompetencyId::generate();
        
        $userCompetency = new self(
            $id,
            $userId,
            $competencyId,
            $currentLevel,
            $targetLevel,
            $lastUpdated
        );
        
        $userCompetency->recordDomainEvent(new UserCompetencyCreated(
            $id,
            $userId,
            $competencyId,
            $currentLevel->getValue(),
            $targetLevel?->getValue()
        ));
        
        return $userCompetency;
    }
    
    public function setTargetLevel(CompetencyLevel $targetLevel): void
    {
        if ($targetLevel->getValue() <= $this->currentLevel->getValue()) {
            throw new \DomainException('Target level cannot be below or equal to current level');
        }
        
        $this->targetLevel = $targetLevel;
        
        $this->recordDomainEvent(new TargetLevelSet(
            $this->id,
            $this->userId,
            $this->competencyId,
            $targetLevel
        ));
    }
    
    public function removeTargetLevel(): void
    {
        $this->targetLevel = null;
    }
    
    public function updateProgress(CompetencyLevel $newLevel): void
    {
        $oldLevel = $this->currentLevel;
        $this->currentLevel = $newLevel;
        $this->lastUpdated = new \DateTimeImmutable();
        
        $this->recordDomainEvent(new UserCompetencyProgressUpdated(
            $this->id,
            $oldLevel->getValue(),
            $newLevel->getValue(),
            $this->getProgressPercentage()
        ));
    }
    
    public function getProgressPercentage(): int
    {
        if ($this->targetLevel === null) {
            return 0;
        }
        
        $currentValue = $this->currentLevel->getValue();
        $targetValue = $this->targetLevel->getValue();
        
        if ($currentValue >= $targetValue) {
            return 100;
        }
        
        // Calculate the starting level value when the target was set
        // We'll assume it starts from 1 (Beginner) for calculation
        $startValue = 1;
        $totalGap = $targetValue - $startValue;
        $currentProgress = $currentValue - $startValue;
        
        if ($totalGap <= 0) {
            return 0;
        }
        
        return (int) round(($currentProgress / $totalGap) * 100);
    }
    
    public function isTargetReached(): bool
    {
        if ($this->targetLevel === null) {
            return false;
        }
        
        return $this->currentLevel->getValue() >= $this->targetLevel->getValue();
    }
    
    public function getGapToTarget(): ?int
    {
        if ($this->targetLevel === null) {
            return null;
        }
        
        $gap = $this->targetLevel->getValue() - $this->currentLevel->getValue();
        return max(0, $gap);
    }
    
    public function hasTargetLevel(): bool
    {
        return $this->targetLevel !== null;
    }
    
    public function getDaysSinceLastUpdate(): int
    {
        $now = new \DateTimeImmutable();
        $diff = $now->diff($this->lastUpdated);
        return (int) $diff->days;
    }
    
    public function getId(): UserCompetencyId
    {
        return $this->id;
    }
    
    public function getUserId(): UserId
    {
        return $this->userId;
    }
    
    public function getCompetencyId(): CompetencyId
    {
        return $this->competencyId;
    }
    
    public function getCurrentLevel(): CompetencyLevel
    {
        return $this->currentLevel;
    }
    
    public function getTargetLevel(): ?CompetencyLevel
    {
        return $this->targetLevel;
    }
    
    public function getLastUpdated(): \DateTimeImmutable
    {
        return $this->lastUpdated;
    }
}
