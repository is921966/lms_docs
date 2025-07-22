<?php

declare(strict_types=1);

namespace App\OrgStructure\Domain\Repository;

use App\OrgStructure\Domain\Models\Position;
use App\OrgStructure\Domain\ValueObjects\PositionId;

interface PositionRepositoryInterface
{
    public function save(Position $position): void;
    
    public function findById(PositionId $id): ?Position;
    
    public function existsByCode(string $code): bool;
    
    /**
     * @return Position[]
     */
    public function findAll(): array;
    
    public function beginTransaction(): void;
    
    public function commit(): void;
    
    public function rollback(): void;
} 