<?php

declare(strict_types=1);

namespace App\OrgStructure\Application\Services;

use App\OrgStructure\Domain\Repository\DepartmentRepositoryInterface;
use App\OrgStructure\Domain\Repository\EmployeeRepositoryInterface;
use App\OrgStructure\Domain\Repository\PositionRepositoryInterface;
use App\OrgStructure\Domain\ValueObjects\DepartmentCode;

class RelationshipValidator
{
    /** @var string[] */
    private array $errors = [];

    public function __construct(
        private readonly EmployeeRepositoryInterface $employeeRepository,
        private readonly DepartmentRepositoryInterface $departmentRepository,
        private readonly PositionRepositoryInterface $positionRepository
    ) {}

    public function validateDepartmentHierarchy(array $departments): bool
    {
        $this->clearErrors();
        
        // Create a map of codes for quick lookup
        $codeMap = [];
        foreach ($departments as $dept) {
            $codeMap[$dept['code']] = $dept;
        }
        
        // Check for missing parents
        foreach ($departments as $dept) {
            if (!empty($dept['parent_code']) && !isset($codeMap[$dept['parent_code']])) {
                $this->errors[] = "Parent department {$dept['parent_code']} not found for department {$dept['code']}";
            }
        }
        
        // Check for circular dependencies
        foreach ($departments as $dept) {
            if ($this->hasCircularDependency($dept['code'], $codeMap)) {
                $this->errors[] = "Circular dependency detected for department {$dept['code']}";
                break;
            }
        }
        
        return empty($this->errors);
    }

    private function hasCircularDependency(string $code, array $codeMap, array $visited = []): bool
    {
        if (in_array($code, $visited)) {
            return true;
        }
        
        if (!isset($codeMap[$code]) || empty($codeMap[$code]['parent_code'])) {
            return false;
        }
        
        $visited[] = $code;
        return $this->hasCircularDependency($codeMap[$code]['parent_code'], $codeMap, $visited);
    }

    public function validateEmployeeRelationships(array $employees): bool
    {
        $this->clearErrors();
        
        // Check for duplicate tab numbers
        $tabNumbers = [];
        foreach ($employees as $employee) {
            if (isset($tabNumbers[$employee['tab_number']])) {
                $this->errors[] = "Duplicate tab number: {$employee['tab_number']}";
            }
            $tabNumbers[$employee['tab_number']] = true;
        }
        
        // Create map for manager validation
        $employeeMap = [];
        foreach ($employees as $employee) {
            $employeeMap[$employee['tab_number']] = $employee;
        }
        
        // Validate each employee
        foreach ($employees as $employee) {
            // Check self-reference
            if (!empty($employee['manager_id']) && $employee['manager_id'] === $employee['tab_number']) {
                $this->errors[] = "Employee {$employee['tab_number']} cannot be their own manager";
            }
            
            // Check manager exists
            if (!empty($employee['manager_id']) && !isset($employeeMap[$employee['manager_id']])) {
                $this->errors[] = "Manager with tab number {$employee['manager_id']} not found for employee {$employee['tab_number']}";
            }
            
            // Check department exists
            $department = $this->departmentRepository->findByCode(new DepartmentCode($employee['department_id']));
            if ($department === null) {
                $this->errors[] = "Department {$employee['department_id']} not found for employee {$employee['tab_number']}";
            }
            
            // Check position exists
            if (!$this->positionRepository->existsByCode($employee['position_id'])) {
                $this->errors[] = "Position {$employee['position_id']} not found for employee {$employee['tab_number']}";
            }
        }
        
        return empty($this->errors);
    }

    /**
     * @return string[]
     */
    public function getErrors(): array
    {
        return $this->errors;
    }

    public function clearErrors(): void
    {
        $this->errors = [];
    }
} 