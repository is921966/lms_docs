<?php

declare(strict_types=1);

namespace Competency\Infrastructure\Repository;

use Competency\Domain\Repository\UserCompetencyRepositoryInterface;
use Competency\Domain\UserCompetency;
use Competency\Domain\ValueObjects\CompetencyId;
use Competency\Domain\ValueObjects\CompetencyLevel;
use User\Domain\ValueObjects\UserId;

class InMemoryUserCompetencyRepository implements UserCompetencyRepositoryInterface
{
    /**
     * @var array<string, UserCompetency>
     */
    private array $userCompetencies = [];
    
    public function save(UserCompetency $userCompetency): void
    {
        $key = $this->createKey($userCompetency->getUserId(), $userCompetency->getCompetencyId());
        $this->userCompetencies[$key] = $userCompetency;
    }
    
    public function find(UserId $userId, CompetencyId $competencyId): ?UserCompetency
    {
        $key = $this->createKey($userId, $competencyId);
        return $this->userCompetencies[$key] ?? null;
    }
    
    public function findByUser(UserId $userId): array
    {
        return array_values(
            array_filter(
                $this->userCompetencies,
                fn(UserCompetency $uc) => $uc->getUserId()->equals($userId)
            )
        );
    }
    
    public function findByCompetency(CompetencyId $competencyId): array
    {
        return array_values(
            array_filter(
                $this->userCompetencies,
                fn(UserCompetency $uc) => $uc->getCompetencyId()->equals($competencyId)
            )
        );
    }
    
    public function findByCompetencyAndLevel(
        CompetencyId $competencyId,
        CompetencyLevel $minLevel
    ): array {
        return array_values(
            array_filter(
                $this->userCompetencies,
                fn(UserCompetency $uc) => 
                    $uc->getCompetencyId()->equals($competencyId) &&
                    $uc->getCurrentLevel()->getValue() >= $minLevel->getValue()
            )
        );
    }
    
    public function findWithTargets(UserId $userId): array
    {
        return array_values(
            array_filter(
                $this->userCompetencies,
                fn(UserCompetency $uc) => 
                    $uc->getUserId()->equals($userId) &&
                    $uc->getTargetLevel() !== null
            )
        );
    }
    
    public function findStale(int $daysSinceUpdate): array
    {
        $cutoffDate = new \DateTimeImmutable("-{$daysSinceUpdate} days");
        
        return array_values(
            array_filter(
                $this->userCompetencies,
                fn(UserCompetency $uc) => $uc->getLastUpdated() < $cutoffDate
            )
        );
    }
    
    public function getGapAnalysis(UserId $userId): array
    {
        $userCompetencies = $this->findByUser($userId);
        $gaps = [];
        
        foreach ($userCompetencies as $userCompetency) {
            if ($userCompetency->getTargetLevel() !== null) {
                $currentLevel = $userCompetency->getCurrentLevel()->getValue();
                $targetLevel = $userCompetency->getTargetLevel()->getValue();
                
                $gaps[] = [
                    'competency_id' => $userCompetency->getCompetencyId()->getValue(),
                    'current_level' => $currentLevel,
                    'target_level' => $targetLevel,
                    'gap' => $targetLevel - $currentLevel
                ];
            }
        }
        
        return $gaps;
    }
    
    public function delete(UserId $userId, CompetencyId $competencyId): void
    {
        $key = $this->createKey($userId, $competencyId);
        unset($this->userCompetencies[$key]);
    }
    
    public function exists(UserId $userId, CompetencyId $competencyId): bool
    {
        $key = $this->createKey($userId, $competencyId);
        return isset($this->userCompetencies[$key]);
    }
    
    private function createKey(UserId $userId, CompetencyId $competencyId): string
    {
        return $userId->getValue() . ':' . $competencyId->getValue();
    }
} 