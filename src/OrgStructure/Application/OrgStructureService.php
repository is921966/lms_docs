<?php

namespace App\OrgStructure\Application;

use App\OrgStructure\Application\DTO\CreateDepartmentDTO;
use App\OrgStructure\Application\DTO\UpdateDepartmentDTO;
use App\OrgStructure\Application\DTO\CreateEmployeeDTO;
use App\OrgStructure\Application\DTO\UpdateEmployeeDTO;
use App\OrgStructure\Application\Exception\DepartmentNotFoundException;
use App\OrgStructure\Application\Exception\EmployeeNotFoundException;
use App\OrgStructure\Application\Exception\DuplicateCodeException;
use App\OrgStructure\Application\Exception\DuplicateTabNumberException;
use App\OrgStructure\Application\Exception\DepartmentHasChildrenException;
use App\OrgStructure\Domain\Entity\Department;
use App\OrgStructure\Domain\Entity\Employee;
use App\OrgStructure\Domain\ValueObject\DepartmentCode;
use App\OrgStructure\Domain\ValueObject\TabNumber;
use App\OrgStructure\Domain\Repository\DepartmentRepositoryInterface;
use App\OrgStructure\Domain\Repository\EmployeeRepositoryInterface;
use Ramsey\Uuid\Uuid;

class OrgStructureService
{
    public function __construct(
        private DepartmentRepositoryInterface $departmentRepository,
        private EmployeeRepositoryInterface $employeeRepository
    ) {
    }
    
    public function createDepartment(CreateDepartmentDTO $dto): Department
    {
        $code = new DepartmentCode($dto->code);
        
        if ($this->departmentRepository->codeExists($code)) {
            throw new DuplicateCodeException($dto->code);
        }
        
        if ($dto->parentId && !$this->departmentRepository->exists($dto->parentId)) {
            throw new DepartmentNotFoundException($dto->parentId);
        }
        
        $department = new Department(
            Uuid::uuid4()->toString(),
            $dto->name,
            $code,
            $dto->parentId
        );
        
        $this->departmentRepository->save($department);
        
        return $department;
    }
    
    public function updateDepartment(string $id, UpdateDepartmentDTO $dto): Department
    {
        $department = $this->departmentRepository->findById($id);
        if (!$department) {
            throw new DepartmentNotFoundException($id);
        }
        
        if ($dto->name !== null) {
            $department->updateName($dto->name);
        }
        
        // Note: Updating parent is complex operation and might need special handling
        // to ensure no circular references
        
        $this->departmentRepository->save($department);
        
        return $department;
    }
    
    public function deleteDepartment(string $id): void
    {
        $department = $this->departmentRepository->findById($id);
        if (!$department) {
            throw new DepartmentNotFoundException($id);
        }
        
        $children = $this->departmentRepository->findChildren($id);
        if (count($children) > 0) {
            throw new DepartmentHasChildrenException($id);
        }
        
        $employeeCount = $this->employeeRepository->countByDepartment($id);
        if ($employeeCount > 0) {
            throw new \Exception("Cannot delete department with employees");
        }
        
        $this->departmentRepository->delete($id);
    }
    
    public function createEmployee(CreateEmployeeDTO $dto): Employee
    {
        $tabNumber = new TabNumber($dto->tabNumber);
        
        if ($this->employeeRepository->tabNumberExists($tabNumber)) {
            throw new DuplicateTabNumberException($dto->tabNumber);
        }
        
        if (!$this->departmentRepository->exists($dto->departmentId)) {
            throw new DepartmentNotFoundException($dto->departmentId);
        }
        
        $employee = new Employee(
            Uuid::uuid4()->toString(),
            $tabNumber,
            $dto->name,
            $dto->position,
            $dto->departmentId,
            $dto->email,
            $dto->phone
        );
        
        $this->employeeRepository->save($employee);
        
        // Update department employee count
        $department = $this->departmentRepository->findById($dto->departmentId);
        if ($department) {
            $count = $this->employeeRepository->countByDepartment($dto->departmentId);
            $department->setEmployeeCount($count);
            $this->departmentRepository->save($department);
        }
        
        return $employee;
    }
    
    public function updateEmployee(string $id, UpdateEmployeeDTO $dto): Employee
    {
        $employee = $this->employeeRepository->findById($id);
        if (!$employee) {
            throw new EmployeeNotFoundException($id);
        }
        
        if ($dto->name !== null) {
            // Re-create employee with new name (since name is constructor param)
            $employee = new Employee(
                $employee->getId(),
                $employee->getTabNumber(),
                $dto->name,
                $employee->getPosition(),
                $employee->getDepartmentId(),
                $employee->getEmail(),
                $employee->getPhone()
            );
        }
        
        if ($dto->position !== null) {
            $employee->updatePosition($dto->position);
        }
        
        if ($dto->email !== null) {
            $employee->updateEmail($dto->email);
        }
        
        if ($dto->phone !== null) {
            $employee->updatePhone($dto->phone);
        }
        
        if ($dto->departmentId !== null && $dto->departmentId !== $employee->getDepartmentId()) {
            return $this->moveEmployeeToDepartment($id, $dto->departmentId);
        }
        
        $this->employeeRepository->save($employee);
        
        return $employee;
    }
    
    public function deleteEmployee(string $id): void
    {
        $employee = $this->employeeRepository->findById($id);
        if (!$employee) {
            throw new EmployeeNotFoundException($id);
        }
        
        $departmentId = $employee->getDepartmentId();
        
        $this->employeeRepository->delete($id);
        
        // Update department employee count
        $department = $this->departmentRepository->findById($departmentId);
        if ($department) {
            $count = $this->employeeRepository->countByDepartment($departmentId);
            $department->setEmployeeCount($count);
            $this->departmentRepository->save($department);
        }
    }
    
    public function moveEmployeeToDepartment(string $employeeId, string $newDepartmentId): Employee
    {
        $employee = $this->employeeRepository->findById($employeeId);
        if (!$employee) {
            throw new EmployeeNotFoundException($employeeId);
        }
        
        if (!$this->departmentRepository->exists($newDepartmentId)) {
            throw new DepartmentNotFoundException($newDepartmentId);
        }
        
        $oldDepartmentId = $employee->getDepartmentId();
        
        $employee->changeDepartment($newDepartmentId);
        $this->employeeRepository->save($employee);
        
        // Update employee counts
        $oldDepartment = $this->departmentRepository->findById($oldDepartmentId);
        if ($oldDepartment) {
            $count = $this->employeeRepository->countByDepartment($oldDepartmentId);
            $oldDepartment->setEmployeeCount($count);
            $this->departmentRepository->save($oldDepartment);
        }
        
        $newDepartment = $this->departmentRepository->findById($newDepartmentId);
        if ($newDepartment) {
            $count = $this->employeeRepository->countByDepartment($newDepartmentId);
            $newDepartment->setEmployeeCount($count);
            $this->departmentRepository->save($newDepartment);
        }
        
        return $employee;
    }
    
    /**
     * Get hierarchical department tree
     * @return Department[]
     */
    public function getDepartmentTree(): array
    {
        $roots = $this->departmentRepository->findRoots();
        
        foreach ($roots as $root) {
            $this->loadChildren($root);
        }
        
        return $roots;
    }
    
    private function loadChildren(Department $department): void
    {
        $children = $this->departmentRepository->findChildren($department->getId());
        
        foreach ($children as $child) {
            $department->addChild($child);
            $this->loadChildren($child);
        }
    }
    
    /**
     * Get department with full path
     */
    public function getDepartmentWithPath(string $id): array
    {
        $department = $this->departmentRepository->findById($id);
        if (!$department) {
            throw new DepartmentNotFoundException($id);
        }
        
        $path = [];
        $current = $department;
        
        while ($current) {
            array_unshift($path, $current);
            
            if ($current->getParentId()) {
                $current = $this->departmentRepository->findById($current->getParentId());
            } else {
                $current = null;
            }
        }
        
        return $path;
    }
    
    /**
     * Search employees
     * @return Employee[]
     */
    public function searchEmployees(string $query): array
    {
        return $this->employeeRepository->search($query);
    }
    
    /**
     * Get department statistics
     */
    public function getDepartmentStats(): array
    {
        return [
            'totalDepartments' => count($this->departmentRepository->findAll()),
            'totalEmployees' => count($this->employeeRepository->findAll()),
            'levelStats' => $this->departmentRepository->getStatsByLevel(),
        ];
    }
} 