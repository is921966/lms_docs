<?php

namespace CompetencyService\Infrastructure\Persistence;

use CompetencyService\Domain\Repositories\CompetencyRepositoryInterface;
use CompetencyService\Domain\Entities\Competency;
use CompetencyService\Domain\ValueObjects\CompetencyId;
use CompetencyService\Domain\ValueObjects\CompetencyCode;
use CompetencyService\Domain\ValueObjects\CompetencyLevel;
use PDO;

class PostgresCompetencyRepository implements CompetencyRepositoryInterface
{
    public function __construct(
        private readonly PDO $connection
    ) {}
    
    public function findById(CompetencyId $id): ?Competency
    {
        $stmt = $this->connection->prepare(
            'SELECT * FROM competencies WHERE id = :id'
        );
        $stmt->execute(['id' => $id->toString()]);
        $row = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if (!$row) {
            return null;
        }
        
        return $this->hydrateCompetency($row);
    }
    
    public function findByCode(CompetencyCode $code): ?Competency
    {
        $stmt = $this->connection->prepare(
            'SELECT * FROM competencies WHERE code = :code'
        );
        $stmt->execute(['code' => $code->getValue()]);
        $row = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if (!$row) {
            return null;
        }
        
        return $this->hydrateCompetency($row);
    }
    
    public function findAll(): array
    {
        $stmt = $this->connection->query(
            'SELECT * FROM competencies ORDER BY category, name'
        );
        
        $competencies = [];
        while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
            $competencies[] = $this->hydrateCompetency($row);
        }
        
        return $competencies;
    }
    
    public function findByCategory(string $category): array
    {
        $stmt = $this->connection->prepare(
            'SELECT * FROM competencies WHERE category = :category ORDER BY name'
        );
        $stmt->execute(['category' => $category]);
        
        $competencies = [];
        while ($row = $stmt->fetch(PDO::FETCH_ASSOC)) {
            $competencies[] = $this->hydrateCompetency($row);
        }
        
        return $competencies;
    }
    
    public function save(Competency $competency): void
    {
        $this->connection->beginTransaction();
        
        try {
            // Save competency
            $stmt = $this->connection->prepare('
                INSERT INTO competencies (id, code, name, description, category, is_active, created_at, updated_at)
                VALUES (:id, :code, :name, :description, :category, :is_active, :created_at, :updated_at)
                ON CONFLICT (id) DO UPDATE SET
                    name = EXCLUDED.name,
                    description = EXCLUDED.description,
                    is_active = EXCLUDED.is_active,
                    updated_at = EXCLUDED.updated_at
            ');
            
            $data = $competency->toArray();
            $stmt->execute([
                'id' => $data['id'],
                'code' => $data['code'],
                'name' => $data['name'],
                'description' => $data['description'],
                'category' => $data['category'],
                'is_active' => $data['is_active'] ? 'true' : 'false',
                'created_at' => $data['created_at'],
                'updated_at' => $data['updated_at'] ?? null
            ]);
            
            // Delete existing levels
            $stmt = $this->connection->prepare(
                'DELETE FROM competency_levels WHERE competency_id = :competency_id'
            );
            $stmt->execute(['competency_id' => $data['id']]);
            
            // Save levels
            if (!empty($data['levels'])) {
                $stmt = $this->connection->prepare('
                    INSERT INTO competency_levels (competency_id, level, name, description, criteria)
                    VALUES (:competency_id, :level, :name, :description, :criteria)
                ');
                
                foreach ($data['levels'] as $level) {
                    $stmt->execute([
                        'competency_id' => $data['id'],
                        'level' => $level['level'],
                        'name' => $level['name'],
                        'description' => $level['description'],
                        'criteria' => json_encode($level['criteria'])
                    ]);
                }
            }
            
            $this->connection->commit();
        } catch (\Exception $e) {
            $this->connection->rollBack();
            throw $e;
        }
    }
    
    public function delete(CompetencyId $id): void
    {
        $stmt = $this->connection->prepare(
            'DELETE FROM competencies WHERE id = :id'
        );
        $stmt->execute(['id' => $id->toString()]);
    }
    
    private function hydrateCompetency(array $row): Competency
    {
        $competency = new Competency(
            CompetencyId::fromString($row['id']),
            new CompetencyCode($row['code']),
            $row['name'],
            $row['description'],
            $row['category']
        );
        
        // Load levels
        $stmt = $this->connection->prepare(
            'SELECT * FROM competency_levels WHERE competency_id = :competency_id ORDER BY level'
        );
        $stmt->execute(['competency_id' => $row['id']]);
        
        while ($levelRow = $stmt->fetch(PDO::FETCH_ASSOC)) {
            $level = new CompetencyLevel(
                $levelRow['level'],
                $levelRow['name'],
                $levelRow['description'],
                json_decode($levelRow['criteria'], true) ?? []
            );
            $competency->addLevel($level);
        }
        
        // Set active status
        if ($row['is_active'] === false || $row['is_active'] === 'false') {
            $competency->deactivate();
        }
        
        return $competency;
    }
} 