<?php

declare(strict_types=1);

namespace App\Position\Domain\Repository;

use App\Position\Domain\PositionProfile;
use App\Position\Domain\ValueObjects\PositionId;
use App\Competency\Domain\ValueObjects\CompetencyId;

interface PositionProfileRepositoryInterface
{
    public function save(PositionProfile $profile): void;
    
    public function findByPositionId(PositionId $positionId): ?PositionProfile;
    
    /**
     * @return PositionProfile[]
     */
    public function findByCompetencyId(CompetencyId $competencyId): array;
    
    public function delete(PositionId $positionId): void;
} 