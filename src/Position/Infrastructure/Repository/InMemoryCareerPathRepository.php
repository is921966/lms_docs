<?php

declare(strict_types=1);

namespace App\Position\Infrastructure\Repository;

use App\Position\Domain\Repository\CareerPathRepositoryInterface;
use App\Position\Domain\CareerPath;
use App\Position\Domain\ValueObjects\PositionId;

class InMemoryCareerPathRepository implements CareerPathRepositoryInterface
{
    /**
     * @var array<string, CareerPath>
     */
    private array $careerPaths = [];
    
    /**
     * @var array<string, string> Maps CareerPath object to ID
     */
    private array $pathToId = [];
    
    public function save(CareerPath $careerPath, ?string $id = null): void
    {
        if ($id === null) {
            // Find existing ID if updating
            $objectHash = spl_object_hash($careerPath);
            $id = $this->pathToId[$objectHash] ?? \Ramsey\Uuid\Uuid::uuid4()->toString();
        }
        
        $this->careerPaths[$id] = $careerPath;
        $this->pathToId[spl_object_hash($careerPath)] = $id;
    }
    
    public function findById(string $id): ?CareerPath
    {
        return $this->careerPaths[$id] ?? null;
    }
    
    public function findPath(PositionId $fromPositionId, PositionId $toPositionId): ?CareerPath
    {
        foreach ($this->careerPaths as $careerPath) {
            if ($careerPath->getFromPositionId()->equals($fromPositionId) &&
                $careerPath->getToPositionId()->equals($toPositionId)) {
                return $careerPath;
            }
        }
        
        return null;
    }
    
    /**
     * @return CareerPath[]
     */
    public function findByFromPosition(PositionId $fromPositionId): array
    {
        return array_values(
            array_filter(
                $this->careerPaths,
                fn(CareerPath $path) => $path->getFromPositionId()->equals($fromPositionId)
            )
        );
    }
    
    /**
     * @return CareerPath[]
     */
    public function findByToPosition(PositionId $toPositionId): array
    {
        return array_values(
            array_filter(
                $this->careerPaths,
                fn(CareerPath $path) => $path->getToPositionId()->equals($toPositionId)
            )
        );
    }
    
    /**
     * @return CareerPath[]
     */
    public function findActive(): array
    {
        return array_values(
            array_filter(
                $this->careerPaths,
                fn(CareerPath $path) => $path->isActive()
            )
        );
    }
    
    public function delete(string $id): void
    {
        if (isset($this->careerPaths[$id])) {
            $careerPath = $this->careerPaths[$id];
            unset($this->pathToId[spl_object_hash($careerPath)]);
            unset($this->careerPaths[$id]);
        }
    }
    
    public function exists(string $id): bool
    {
        return isset($this->careerPaths[$id]);
    }
    
    public function existsPath(PositionId $fromPositionId, PositionId $toPositionId): bool
    {
        return $this->findPath($fromPositionId, $toPositionId) !== null;
    }
} 