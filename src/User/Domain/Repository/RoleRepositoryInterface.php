<?php

declare(strict_types=1);

namespace User\Domain\Repository;

use User\Domain\Role;

/**
 * Role repository interface
 */
interface RoleRepositoryInterface
{
    /**
     * Find role by name
     */
    public function findByName(string $name): ?Role;
    
    /**
     * Get role by name (throws exception if not found)
     */
    public function getByName(string $name): Role;
    
    /**
     * Find roles by names
     */
    public function findByNames(array $names): array;
    
    /**
     * Find active roles
     */
    public function findActive(): array;
    
    /**
     * Find system roles
     */
    public function findSystemRoles(): array;
    
    /**
     * Find custom roles
     */
    public function findCustomRoles(): array;
    
    /**
     * Find roles with specific permission
     */
    public function findByPermission(string $permissionId): array;
    
    /**
     * Check if role name exists
     */
    public function nameExists(string $name, ?int $excludeId = null): bool;
    
    /**
     * Get highest priority
     */
    public function getHighestPriority(): int;
    
    /**
     * Get default role
     */
    public function getDefaultRole(): ?Role;
    
    /**
     * Save role
     */
    public function save(Role $role): void;
    
    /**
     * Remove role
     */
    public function remove(Role $role): void;
} 