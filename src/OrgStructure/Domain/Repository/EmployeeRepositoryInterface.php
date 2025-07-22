<?php

declare(strict_types=1);

namespace App\OrgStructure\Domain\Repository;

use App\OrgStructure\Domain\Models\Employee;
use App\OrgStructure\Domain\ValueObjects\EmployeeId;
use App\OrgStructure\Domain\ValueObjects\TabNumber;

interface EmployeeRepositoryInterface
{
    public function save(Employee $employee): void;
    
    public function findById(EmployeeId $id): ?Employee;
    
    public function findByTabNumber(TabNumber $tabNumber): ?Employee;
    
    public function existsByTabNumber(TabNumber $tabNumber): bool;
    
    /**
     * @return Employee[]
     */
    public function findAll(): array;
    
    public function beginTransaction(): void;
    
    public function commit(): void;
    
    public function rollback(): void;
} 