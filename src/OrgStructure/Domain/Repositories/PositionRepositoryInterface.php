<?php

namespace App\OrgStructure\Domain\Repositories;

use App\OrgStructure\Domain\Models\Position;
use App\OrgStructure\Domain\ValueObjects\PositionId;
use App\OrgStructure\Domain\ValueObjects\DepartmentId;

interface PositionRepositoryInterface
{
    public function findById(PositionId $id): ?Position;
    
    public function findByDepartment(DepartmentId $departmentId): array;
    
    public function findAll(): array;
    
    public function save(Position $position): void;
    
    public function delete(PositionId $id): void;
    
    public function existsByCode(string $code): bool;
    
    public function beginTransaction(): void;
    
    public function commit(): void;
    
    public function rollback(): void;
} 