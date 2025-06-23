<?php

declare(strict_types=1);

namespace App\Position\Domain\Repository;

use App\Position\Domain\CareerPath;
use App\Position\Domain\ValueObjects\PositionId;

interface CareerPathRepositoryInterface
{
    public function save(CareerPath $careerPath): void;
    
    public function findById(string $id): ?CareerPath;
    
    /**
     * @return CareerPath[]
     */
    public function findByFromPosition(PositionId $positionId): array;
    
    /**
     * @return CareerPath[]
     */
    public function findByToPosition(PositionId $positionId): array;
    
    /**
     * Find direct career path between two positions
     */
    public function findPath(PositionId $from, PositionId $to): ?CareerPath;
    
    /**
     * @return CareerPath[]
     */
    public function findActive(): array;
    
    public function delete(string $id): void;
}
