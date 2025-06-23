<?php

declare(strict_types=1);

namespace App\Position\Infrastructure\Repository;

use App\Position\Domain\Repository\PositionRepositoryInterface;
use App\Position\Domain\Position;
use App\Position\Domain\ValueObjects\PositionId;
use App\Position\Domain\ValueObjects\PositionCode;
use App\Position\Domain\ValueObjects\PositionLevel;
use App\Position\Domain\ValueObjects\Department;

class InMemoryPositionRepository implements PositionRepositoryInterface
{
    /**
     * @var array<string, Position>
     */
    private array $positions = [];
    
    public function save(Position $position): void
    {
        $this->positions[$position->getId()->getValue()] = $position;
    }
    
    public function findById(PositionId $id): ?Position
    {
        return $this->positions[$id->getValue()] ?? null;
    }
    
    public function findByCode(PositionCode $code): ?Position
    {
        foreach ($this->positions as $position) {
            if ($position->getCode()->getValue() === $code->getValue()) {
                return $position;
            }
        }
        
        return null;
    }
    
    /**
     * @return Position[]
     */
    public function findByDepartment(Department $department): array
    {
        return array_values(
            array_filter(
                $this->positions,
                fn(Position $position) => $position->getDepartment()->getValue() === $department->getValue()
            )
        );
    }
    
    /**
     * @return Position[]
     */
    public function findByLevel(PositionLevel $level): array
    {
        return array_values(
            array_filter(
                $this->positions,
                fn(Position $position) => $position->getLevel()->getValue() === $level->getValue()
            )
        );
    }
    
    /**
     * @return Position[]
     */
    public function findActive(): array
    {
        return array_values(
            array_filter(
                $this->positions,
                fn(Position $position) => $position->isActive()
            )
        );
    }
    
    public function exists(PositionId $id): bool
    {
        return isset($this->positions[$id->getValue()]);
    }
    
    public function countByDepartment(Department $department): int
    {
        return count($this->findByDepartment($department));
    }
    
    public function delete(PositionId $id): void
    {
        unset($this->positions[$id->getValue()]);
    }
} 