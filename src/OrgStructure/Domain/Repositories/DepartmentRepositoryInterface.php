<?php

namespace App\OrgStructure\Domain\Repositories;

use App\OrgStructure\Domain\Models\Department;
use App\OrgStructure\Domain\ValueObjects\DepartmentId;
use App\OrgStructure\Domain\ValueObjects\DepartmentCode;

interface DepartmentRepositoryInterface
{
    public function findById(DepartmentId $id): ?Department;
    
    public function findByCode(DepartmentCode $code): ?Department;
    
    public function findAll(): array;
    
    public function findAllActive(): array;
    
    public function save(Department $department): void;
    
    public function delete(DepartmentId $id): void;
    
    public function beginTransaction(): void;
    
    public function commit(): void;
    
    public function rollback(): void;
} 