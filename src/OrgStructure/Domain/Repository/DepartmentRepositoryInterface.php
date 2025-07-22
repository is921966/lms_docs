<?php

declare(strict_types=1);

namespace App\OrgStructure\Domain\Repository;

use App\OrgStructure\Domain\Models\Department;
use App\OrgStructure\Domain\ValueObjects\DepartmentCode;
use App\OrgStructure\Domain\ValueObjects\DepartmentId;

interface DepartmentRepositoryInterface
{
    public function save(Department $department): void;
    
    public function findById(DepartmentId $id): ?Department;
    
    public function findByCode(DepartmentCode $code): ?Department;
    
    /**
     * @return Department[]
     */
    public function findAll(): array;
    
    public function beginTransaction(): void;
    
    public function commit(): void;
    
    public function rollback(): void;
} 