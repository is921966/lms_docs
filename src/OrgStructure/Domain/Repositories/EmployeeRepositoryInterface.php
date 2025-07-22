<?php

namespace App\OrgStructure\Domain\Repositories;

use App\OrgStructure\Domain\Models\Employee;
use App\OrgStructure\Domain\ValueObjects\EmployeeId;
use App\OrgStructure\Domain\ValueObjects\TabNumber;
use App\OrgStructure\Domain\ValueObjects\DepartmentId;

interface EmployeeRepositoryInterface
{
    public function findById(EmployeeId $id): ?Employee;
    
    public function findByTabNumber(TabNumber $tabNumber): ?Employee;
    
    public function findByDepartment(DepartmentId $departmentId): array;
    
    public function findByManager(EmployeeId $managerId): array;
    
    public function findAll(): array;
    
    public function save(Employee $employee): void;
    
    public function delete(EmployeeId $id): void;
    
    public function existsByTabNumber(TabNumber $tabNumber): bool;
    
    public function beginTransaction(): void;
    
    public function commit(): void;
    
    public function rollback(): void;
} 