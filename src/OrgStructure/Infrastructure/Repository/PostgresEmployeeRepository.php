<?php

namespace App\OrgStructure\Infrastructure\Repository;

use App\OrgStructure\Domain\Repository\EmployeeRepositoryInterface;
use App\OrgStructure\Domain\Models\Employee;
use App\OrgStructure\Domain\ValueObjects\EmployeeId;
use App\OrgStructure\Domain\ValueObjects\TabNumber;
use App\OrgStructure\Domain\ValueObjects\PersonalInfo;
use App\OrgStructure\Domain\ValueObjects\DepartmentId;
use App\OrgStructure\Domain\ValueObjects\PositionId;
use PDO;

class PostgresEmployeeRepository implements EmployeeRepositoryInterface
{
    private PDO $pdo;
    
    public function __construct(PDO $pdo)
    {
        $this->pdo = $pdo;
    }
    
    public function findById(EmployeeId $id): ?Employee
    {
        $sql = "SELECT * FROM employees WHERE id = :id";
        $stmt = $this->pdo->prepare($sql);
        $stmt->execute(['id' => $id->toString()]);
        
        $data = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if (!$data) {
            return null;
        }
        
        return $this->hydrate($data);
    }
    
    public function findByTabNumber(TabNumber $tabNumber): ?Employee
    {
        $sql = "SELECT * FROM employees WHERE tab_number = :tab_number";
        $stmt = $this->pdo->prepare($sql);
        $stmt->execute(['tab_number' => $tabNumber->toString()]);
        
        $data = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if (!$data) {
            return null;
        }
        
        return $this->hydrate($data);
    }
    
    public function save(Employee $employee): void
    {
        $sql = "
            INSERT INTO employees (
                id, tab_number, full_name, email, phone,
                department_id, position_id, manager_id, hire_date,
                is_active, ldap_dn
            ) VALUES (
                :id, :tab_number, :full_name, :email, :phone,
                :department_id, :position_id, :manager_id, :hire_date,
                :is_active, :ldap_dn
            )
            ON CONFLICT (id) DO UPDATE SET
                tab_number = EXCLUDED.tab_number,
                full_name = EXCLUDED.full_name,
                email = EXCLUDED.email,
                phone = EXCLUDED.phone,
                department_id = EXCLUDED.department_id,
                position_id = EXCLUDED.position_id,
                manager_id = EXCLUDED.manager_id,
                is_active = EXCLUDED.is_active,
                ldap_dn = EXCLUDED.ldap_dn,
                updated_at = CURRENT_TIMESTAMP
        ";
        
        $stmt = $this->pdo->prepare($sql);
        $stmt->execute([
            'id' => $employee->getId()->toString(),
            'tab_number' => $employee->getTabNumber()->toString(),
            'full_name' => $employee->getPersonalInfo()->getFullName(),
            'email' => $employee->getPersonalInfo()->getEmail(),
            'phone' => $employee->getPersonalInfo()->getPhone(),
            'department_id' => $employee->getDepartmentId()?->toString(),
            'position_id' => $employee->getPositionId()?->toString(),
            'manager_id' => $employee->getManagerId()?->toString(),
            'hire_date' => $employee->getHireDate()->format('Y-m-d'),
            'is_active' => $employee->isActive(),
            'ldap_dn' => null // will be set by LDAP integration
        ]);
    }
    
    public function delete(EmployeeId $id): void
    {
        $sql = "DELETE FROM employees WHERE id = :id";
        $stmt = $this->pdo->prepare($sql);
        $stmt->execute(['id' => $id->toString()]);
    }
    
    /**
     * @return Employee[]
     */
    public function findAll(): array
    {
        $sql = "SELECT * FROM employees ORDER BY tab_number";
        $stmt = $this->pdo->prepare($sql);
        $stmt->execute();
        
        $employees = [];
        while ($data = $stmt->fetch(PDO::FETCH_ASSOC)) {
            $employees[] = $this->hydrate($data);
        }
        
        return $employees;
    }
    
    /**
     * @return Employee[]
     */
    public function findAllActive(): array
    {
        $sql = "SELECT * FROM employees WHERE is_active = true ORDER BY tab_number";
        $stmt = $this->pdo->prepare($sql);
        $stmt->execute();
        
        $employees = [];
        while ($data = $stmt->fetch(PDO::FETCH_ASSOC)) {
            $employees[] = $this->hydrate($data);
        }
        
        return $employees;
    }
    
    /**
     * @return Employee[]
     */
    public function findByDepartment(DepartmentId $departmentId): array
    {
        $sql = "SELECT * FROM employees WHERE department_id = :department_id ORDER BY tab_number";
        $stmt = $this->pdo->prepare($sql);
        $stmt->execute(['department_id' => $departmentId->toString()]);
        
        $employees = [];
        $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        foreach ($rows as $data) {
            $employees[] = $this->hydrate($data);
        }
        
        return $employees;
    }
    
    /**
     * @return Employee[]
     */
    public function findByManager(EmployeeId $managerId): array
    {
        $sql = "SELECT * FROM employees WHERE manager_id = :manager_id ORDER BY tab_number";
        $stmt = $this->pdo->prepare($sql);
        $stmt->execute(['manager_id' => $managerId->toString()]);
        
        $employees = [];
        $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        foreach ($rows as $data) {
            $employees[] = $this->hydrate($data);
        }
        
        return $employees;
    }
    
    public function existsByTabNumber(TabNumber $tabNumber): bool
    {
        $sql = "SELECT COUNT(*) FROM employees WHERE tab_number = :tab_number";
        $stmt = $this->pdo->prepare($sql);
        $stmt->execute(['tab_number' => $tabNumber->toString()]);
        
        return (int)$stmt->fetchColumn() > 0;
    }
    
    public function beginTransaction(): void
    {
        $this->pdo->beginTransaction();
    }
    
    public function commit(): void
    {
        $this->pdo->commit();
    }
    
    public function rollback(): void
    {
        $this->pdo->rollback();
    }
    
    private function hydrate(array $data): Employee
    {
        $personalInfo = new PersonalInfo(
            $data['full_name'],
            $data['email'],
            $data['phone'] ?? ''
        );
        
        $departmentId = $data['department_id'] ? DepartmentId::fromString($data['department_id']) : DepartmentId::generate();
        $positionId = $data['position_id'] ? PositionId::fromString($data['position_id']) : PositionId::generate();
        
        $employee = new Employee(
            EmployeeId::fromString($data['id']),
            new TabNumber($data['tab_number']),
            $personalInfo,
            $departmentId,
            $positionId
        );
        
        if ($data['department_id']) {
            $employee->assignToDepartment(DepartmentId::fromString($data['department_id']));
        }
        
        if ($data['position_id']) {
            $employee->assignToPosition(PositionId::fromString($data['position_id']));
        }
        
        if ($data['manager_id']) {
            $employee->setManager(EmployeeId::fromString($data['manager_id']));
        }
        
        if (isset($data['hire_date'])) {
            $reflection = new \ReflectionClass($employee);
            $hireDateProperty = $reflection->getProperty('hireDate');
            $hireDateProperty->setAccessible(true);
            $hireDateProperty->setValue($employee, new \DateTimeImmutable($data['hire_date']));
        }
        
        if (isset($data['is_active']) && !$data['is_active']) {
            $employee->deactivate();
        }
        
        return $employee;
    }
} 