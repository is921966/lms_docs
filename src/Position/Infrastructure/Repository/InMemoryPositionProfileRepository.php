<?php

declare(strict_types=1);

namespace App\Position\Infrastructure\Repository;

use App\Position\Domain\Repository\PositionProfileRepositoryInterface;
use App\Position\Domain\PositionProfile;
use App\Position\Domain\ValueObjects\PositionId;
use App\Competency\Domain\ValueObjects\CompetencyId;

class InMemoryPositionProfileRepository implements PositionProfileRepositoryInterface
{
    /**
     * @var array<string, PositionProfile>
     */
    private array $profiles = [];
    
    public function save(PositionProfile $profile): void
    {
        $this->profiles[$profile->getPositionId()->getValue()] = $profile;
    }
    
    public function findByPositionId(PositionId $positionId): ?PositionProfile
    {
        return $this->profiles[$positionId->getValue()] ?? null;
    }
    
    /**
     * @return PositionProfile[]
     */
    public function findByCompetencyId(CompetencyId $competencyId): array
    {
        return array_values(
            array_filter(
                $this->profiles,
                function (PositionProfile $profile) use ($competencyId) {
                    // Check in required competencies
                    foreach ($profile->getRequiredCompetencies() as $required) {
                        if ($required->getCompetencyId()->equals($competencyId)) {
                            return true;
                        }
                    }
                    
                    // Check in desired competencies
                    foreach ($profile->getDesiredCompetencies() as $desired) {
                        if ($desired->getCompetencyId()->equals($competencyId)) {
                            return true;
                        }
                    }
                    
                    return false;
                }
            )
        );
    }
    
    /**
     * @return PositionProfile[]
     */
    public function findAll(): array
    {
        return array_values($this->profiles);
    }
    
    public function delete(PositionId $positionId): void
    {
        unset($this->profiles[$positionId->getValue()]);
    }
    
    public function exists(PositionId $positionId): bool
    {
        return isset($this->profiles[$positionId->getValue()]);
    }
    
    public function countByCompetencyId(CompetencyId $competencyId): int
    {
        return count($this->findByCompetencyId($competencyId));
    }
} 