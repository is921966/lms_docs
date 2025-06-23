<?php

declare(strict_types=1);

namespace App\Position\Domain\Repository;

use App\Position\Domain\Position;
use App\Position\Domain\ValueObjects\PositionId;
use App\Position\Domain\ValueObjects\PositionCode;
use App\Position\Domain\ValueObjects\Department;

interface PositionRepositoryInterface
{
    public function save(Position $position): void;
    
    public function findById(PositionId $id): ?Position;
    
    public function findByCode(PositionCode $code): ?Position;
    
    /**
     * @return Position[]
     */
    public function findByDepartment(Department $department): array;
    
    /**
     * @return Position[]
     */
    public function findActive(): array;
    
    public function delete(PositionId $id): void;
} 