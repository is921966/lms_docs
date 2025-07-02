<?php

namespace Auth\Domain\Repositories;

use Auth\Domain\Entities\Role;
use Auth\Domain\ValueObjects\RoleId;

interface RoleRepositoryInterface
{
    /**
     * Save role
     */
    public function save(Role $role): void;

    /**
     * Find role by ID
     */
    public function findById(RoleId $id): ?Role;

    /**
     * Find role by name
     */
    public function findByName(string $name): ?Role;

    /**
     * Get all roles
     */
    public function findAll(): array;

    /**
     * Delete role
     */
    public function delete(RoleId $id): void;

    /**
     * Check if role exists by name
     */
    public function existsByName(string $name): bool;

    /**
     * Get roles by user ID
     */
    public function findByUserId(string $userId): array;

    /**
     * Assign role to user
     */
    public function assignToUser(string $userId, RoleId $roleId): void;

    /**
     * Remove role from user
     */
    public function removeFromUser(string $userId, RoleId $roleId): void;

    /**
     * Get all permissions for user (from all roles)
     */
    public function getUserPermissions(string $userId): array;
} 