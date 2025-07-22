<?php

namespace App\OrgStructure\Infrastructure\Repository;

use App\OrgStructure\Domain\Repository\DepartmentRepositoryInterface;
use App\OrgStructure\Domain\Models\Department;
use App\OrgStructure\Domain\ValueObjects\DepartmentId;
use App\OrgStructure\Domain\ValueObjects\DepartmentCode;
use App\OrgStructure\Domain\Exceptions\InvalidDepartmentException;
use PDO;
use PDOException;

class PostgresDepartmentRepository implements DepartmentRepositoryInterface
{
    private PDO $pdo;
    
    public function __construct(PDO $pdo)
    {
        $this->pdo = $pdo;
    }
    
    public function findById(DepartmentId $id): ?Department
    {
        $sql = "SELECT * FROM departments WHERE id = :id";
        $stmt = $this->pdo->prepare($sql);
        $stmt->execute(['id' => $id->toString()]);
        
        $data = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if (!$data) {
            return null;
        }
        
        return $this->hydrate($data);
    }
    
    public function findByCode(DepartmentCode $code): ?Department
    {
        $sql = "SELECT * FROM departments WHERE department_code = :code";
        $stmt = $this->pdo->prepare($sql);
        $stmt->execute(['code' => $code->toString()]);
        
        $data = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if (!$data) {
            return null;
        }
        
        return $this->hydrate($data);
    }
    
    public function save(Department $department): void
    {
        $sql = "
            INSERT INTO departments (
                id, department_code, name, parent_id, level, path, is_active
            ) VALUES (
                :id, :code, :name, :parent_id, :level, :path, :is_active
            )
            ON CONFLICT (id) DO UPDATE SET
                department_code = EXCLUDED.department_code,
                name = EXCLUDED.name,
                parent_id = EXCLUDED.parent_id,
                level = EXCLUDED.level,
                path = EXCLUDED.path,
                is_active = EXCLUDED.is_active,
                updated_at = CURRENT_TIMESTAMP
        ";
        
        $stmt = $this->pdo->prepare($sql);
        $stmt->execute([
            'id' => $department->getId()->toString(),
            'code' => $department->getCode()->toString(),
            'name' => $department->getName(),
            'parent_id' => $department->getParentId()?->toString(),
            'level' => $department->getLevel(),
            'path' => $department->getPath(),
            'is_active' => $department->isActive()
        ]);
    }
    
    public function delete(DepartmentId $id): void
    {
        $sql = "DELETE FROM departments WHERE id = :id";
        $stmt = $this->pdo->prepare($sql);
        $stmt->execute(['id' => $id->toString()]);
    }
    
    /**
     * @return Department[]
     */
    public function findAll(): array
    {
        $sql = "SELECT * FROM departments ORDER BY path";
        $stmt = $this->pdo->prepare($sql);
        $stmt->execute();
        
        $departments = [];
        while ($data = $stmt->fetch(PDO::FETCH_ASSOC)) {
            $departments[] = $this->hydrate($data);
        }
        
        return $departments;
    }
    
    /**
     * @return Department[]
     */
    public function findAllActive(): array
    {
        $sql = "SELECT * FROM departments WHERE is_active = true ORDER BY path";
        $stmt = $this->pdo->prepare($sql);
        $stmt->execute();
        
        $departments = [];
        $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        foreach ($rows as $data) {
            $departments[] = $this->hydrate($data);
        }
        
        return $departments;
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
    
    private function hydrate(array $data): Department
    {
        $department = new Department(
            DepartmentId::fromString($data['id']),
            new DepartmentCode($data['department_code']),
            $data['name']
        );
        
        if ($data['parent_id']) {
            $department->setParentId(DepartmentId::fromString($data['parent_id']));
        }
        
        if (isset($data['is_active']) && !$data['is_active']) {
            $department->deactivate();
        }
        
        // Устанавливаем уровень и путь если они есть
        if (isset($data['level'])) {
            $reflection = new \ReflectionClass($department);
            $levelProperty = $reflection->getProperty('level');
            $levelProperty->setAccessible(true);
            $levelProperty->setValue($department, (int)$data['level']);
        }
        
        if (isset($data['path'])) {
            $reflection = new \ReflectionClass($department);
            $pathProperty = $reflection->getProperty('path');
            $pathProperty->setAccessible(true);
            $pathProperty->setValue($department, $data['path']);
        } else {
            // Если path не задан, вычисляем его
            $reflection = new \ReflectionClass($department);
            $pathProperty = $reflection->getProperty('path');
            $pathProperty->setAccessible(true);
            $pathProperty->setValue($department, '/' . $data['name']);
        }
        
        return $department;
    }
} 