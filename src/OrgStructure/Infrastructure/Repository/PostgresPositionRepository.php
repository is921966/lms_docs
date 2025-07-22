<?php

namespace App\OrgStructure\Infrastructure\Repository;

use App\OrgStructure\Domain\Repository\PositionRepositoryInterface;
use App\OrgStructure\Domain\Models\Position;
use App\OrgStructure\Domain\ValueObjects\PositionId;
use App\OrgStructure\Domain\ValueObjects\DepartmentId;
use PDO;

class PostgresPositionRepository implements PositionRepositoryInterface
{
    private PDO $pdo;
    
    public function __construct(PDO $pdo)
    {
        $this->pdo = $pdo;
    }
    
    public function findById(PositionId $id): ?Position
    {
        $sql = "SELECT * FROM positions WHERE id = :id";
        $stmt = $this->pdo->prepare($sql);
        $stmt->execute(['id' => $id->toString()]);
        
        $data = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if (!$data) {
            return null;
        }
        
        return $this->hydrate($data);
    }
    
    public function save(Position $position): void
    {
        $sql = "
            INSERT INTO positions (
                id, code, title, category, department_id, is_active
            ) VALUES (
                :id, :code, :title, :category, :department_id, :is_active
            )
            ON CONFLICT (id) DO UPDATE SET
                code = EXCLUDED.code,
                title = EXCLUDED.title,
                category = EXCLUDED.category,
                department_id = EXCLUDED.department_id,
                is_active = EXCLUDED.is_active,
                updated_at = CURRENT_TIMESTAMP
        ";
        
        $stmt = $this->pdo->prepare($sql);
        $stmt->execute([
            'id' => $position->getId()->toString(),
            'code' => $position->getCode(),
            'title' => $position->getTitle(),
            'category' => $position->getCategory(),
            'department_id' => $position->getDepartmentId()?->toString(),
            'is_active' => $position->isActive()
        ]);
    }
    
    public function delete(PositionId $id): void
    {
        $sql = "DELETE FROM positions WHERE id = :id";
        $stmt = $this->pdo->prepare($sql);
        $stmt->execute(['id' => $id->toString()]);
    }
    
    /**
     * @return Position[]
     */
    public function findAll(): array
    {
        $sql = "SELECT * FROM positions ORDER BY code";
        $stmt = $this->pdo->prepare($sql);
        $stmt->execute();
        
        $positions = [];
        while ($data = $stmt->fetch(PDO::FETCH_ASSOC)) {
            $positions[] = $this->hydrate($data);
        }
        
        return $positions;
    }
    
    /**
     * @return Position[]
     */
    public function findAllActive(): array
    {
        $sql = "SELECT * FROM positions WHERE is_active = true ORDER BY code";
        $stmt = $this->pdo->prepare($sql);
        $stmt->execute();
        
        $positions = [];
        $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        foreach ($rows as $data) {
            $positions[] = $this->hydrate($data);
        }
        
        return $positions;
    }
    
    /**
     * @return Position[]
     */
    public function findByDepartment(DepartmentId $departmentId): array
    {
        $sql = "SELECT * FROM positions WHERE department_id = :department_id ORDER BY code";
        $stmt = $this->pdo->prepare($sql);
        $stmt->execute(['department_id' => $departmentId->toString()]);
        
        $positions = [];
        $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        foreach ($rows as $data) {
            $positions[] = $this->hydrate($data);
        }
        
        return $positions;
    }
    
    public function existsByCode(string $code): bool
    {
        $sql = "SELECT COUNT(*) FROM positions WHERE code = :code";
        $stmt = $this->pdo->prepare($sql);
        $stmt->execute(['code' => $code]);
        
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
    
    private function hydrate(array $data): Position
    {
        $position = new Position(
            PositionId::fromString($data['id']),
            $data['code'],
            $data['title'],
            $data['category']
        );
        
        if ($data['department_id']) {
            $position->assignToDepartment(DepartmentId::fromString($data['department_id']));
        }
        
        if (isset($data['is_active']) && !$data['is_active']) {
            $position->deactivate();
        }
        
        return $position;
    }
} 