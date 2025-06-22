<?php

declare(strict_types=1);

namespace App\Common\Interfaces;

/**
 * Base repository interface for all entities
 * 
 * @template T of object
 */
interface RepositoryInterface
{
    /**
     * Find entity by ID
     * 
     * @param int|string $id
     * @return T|null
     */
    public function find(int|string $id): ?object;
    
    /**
     * Find all entities with optional pagination
     * 
     * @param int $limit
     * @param int $offset
     * @param array<string, mixed> $criteria
     * @param array<string, string> $orderBy
     * @return array<T>
     */
    public function findAll(
        int $limit = 100,
        int $offset = 0,
        array $criteria = [],
        array $orderBy = []
    ): array;
    
    /**
     * Save new entity
     * 
     * @param T $entity
     * @return T
     */
    public function save(object $entity): object;
    
    /**
     * Update existing entity
     * 
     * @param T $entity
     * @return T
     */
    public function update(object $entity): object;
    
    /**
     * Delete entity
     * 
     * @param T $entity
     * @return void
     */
    public function delete(object $entity): void;
    
    /**
     * Count entities matching criteria
     * 
     * @param array<string, mixed> $criteria
     * @return int
     */
    public function count(array $criteria = []): int;
} 