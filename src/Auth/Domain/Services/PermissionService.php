<?php

namespace Auth\Domain\Services;

use Auth\Domain\Repositories\RoleRepositoryInterface;

class PermissionService
{
    private RoleRepositoryInterface $roleRepository;
    private array $permissionCache = [];

    public function __construct(RoleRepositoryInterface $roleRepository)
    {
        $this->roleRepository = $roleRepository;
    }

    public function userHasPermission(string $userId, string $permission): bool
    {
        $permissions = $this->getUserPermissions($userId);
        return in_array($permission, $permissions);
    }

    public function userHasAnyPermission(string $userId, array $permissions): bool
    {
        $userPermissions = $this->getUserPermissions($userId);
        return !empty(array_intersect($permissions, $userPermissions));
    }

    public function userHasAllPermissions(string $userId, array $permissions): bool
    {
        $userPermissions = $this->getUserPermissions($userId);
        return empty(array_diff($permissions, $userPermissions));
    }

    public function getUserPermissions(string $userId): array
    {
        // Check cache
        if (isset($this->permissionCache[$userId])) {
            return $this->permissionCache[$userId];
        }

        // Get user roles
        $roles = $this->roleRepository->findByUserId($userId);
        
        // Collect all permissions
        $permissions = [];
        foreach ($roles as $role) {
            foreach ($role->getPermissionNames() as $permission) {
                $permissions[$permission] = true;
            }
        }

        // Cache and return unique permissions
        $this->permissionCache[$userId] = array_keys($permissions);
        return $this->permissionCache[$userId];
    }

    public function clearCache(?string $userId = null): void
    {
        if ($userId === null) {
            $this->permissionCache = [];
        } else {
            unset($this->permissionCache[$userId]);
        }
    }

    public function userHasRole(string $userId, string $roleName): bool
    {
        $roles = $this->roleRepository->findByUserId($userId);
        foreach ($roles as $role) {
            if ($role->getName() === $roleName) {
                return true;
            }
        }
        return false;
    }

    public function getUserRoles(string $userId): array
    {
        $roles = $this->roleRepository->findByUserId($userId);
        return array_map(fn($role) => $role->getName(), $roles);
    }
} 