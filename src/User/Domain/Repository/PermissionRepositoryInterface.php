<?php

declare(strict_types=1);

namespace User\Domain\Repository;

use User\Domain\Permission;

/**
 * Permission repository interface
 */
interface PermissionRepositoryInterface
{
    /**
     * Find permission by ID
     */
    public function findById(string $id): ?Permission;
    
    /**
     * Get permission by ID (throws exception if not found)
     */
    public function getById(string $id): Permission;
    
    /**
     * Find permissions by IDs
     */
    public function findByIds(array $ids): array;
    
    /**
     * Find permissions by category
     */
    public function findByCategory(string $category): array;
    
    /**
     * Get all permissions grouped by category
     */
    public function getAllGroupedByCategory(): array;
    
    /**
     * Find permissions by role
     */
    public function findByRole(int $roleId): array;
    
    /**
     * Check if permission exists
     */
    public function exists(string $id): bool;
    
    /**
     * Get all categories
     */
    public function getCategories(): array;
    
    /**
     * Search permissions
     */
    public function search(string $query): array;
    
    /**
     * Save permission
     */
    public function save(Permission $permission): void;
    
    /**
     * Remove permission
     */
    public function remove(Permission $permission): void;
    
    /**
     * Initialize default permissions
     */
    public function initializeDefaults(): void;
} 