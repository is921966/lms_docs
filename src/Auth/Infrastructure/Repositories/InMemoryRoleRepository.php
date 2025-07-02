<?php

namespace Auth\Infrastructure\Repositories;

use Auth\Domain\Repositories\RoleRepositoryInterface;
use Auth\Domain\Entities\Role;
use Auth\Domain\ValueObjects\RoleId;

class InMemoryRoleRepository implements RoleRepositoryInterface
{
    private array $roles = [];
    private array $userRoles = [];

    public function save(Role $role): void
    {
        $this->roles[$role->getId()->getValue()] = $role;
    }

    public function findById(RoleId $id): ?Role
    {
        return $this->roles[$id->getValue()] ?? null;
    }

    public function findByName(string $name): ?Role
    {
        foreach ($this->roles as $role) {
            if ($role->getName() === $name) {
                return $role;
            }
        }
        return null;
    }

    public function findAll(): array
    {
        return array_values($this->roles);
    }

    public function delete(RoleId $id): void
    {
        unset($this->roles[$id->getValue()]);
        
        // Remove role from all users
        foreach ($this->userRoles as $userId => &$roleIds) {
            $roleIds = array_filter($roleIds, fn($roleId) => $roleId !== $id->getValue());
        }
    }

    public function existsByName(string $name): bool
    {
        return $this->findByName($name) !== null;
    }

    public function findByUserId(string $userId): array
    {
        if (!isset($this->userRoles[$userId])) {
            return [];
        }

        $roles = [];
        foreach ($this->userRoles[$userId] as $roleId) {
            if (isset($this->roles[$roleId])) {
                $roles[] = $this->roles[$roleId];
            }
        }

        return $roles;
    }

    public function assignToUser(string $userId, RoleId $roleId): void
    {
        if (!isset($this->userRoles[$userId])) {
            $this->userRoles[$userId] = [];
        }

        $roleIdValue = $roleId->getValue();
        if (!in_array($roleIdValue, $this->userRoles[$userId])) {
            $this->userRoles[$userId][] = $roleIdValue;
        }
    }

    public function removeFromUser(string $userId, RoleId $roleId): void
    {
        if (!isset($this->userRoles[$userId])) {
            return;
        }

        $this->userRoles[$userId] = array_filter(
            $this->userRoles[$userId],
            fn($id) => $id !== $roleId->getValue()
        );
    }

    public function getUserPermissions(string $userId): array
    {
        $roles = $this->findByUserId($userId);
        $permissions = [];

        foreach ($roles as $role) {
            foreach ($role->getPermissionNames() as $permission) {
                $permissions[$permission] = true;
            }
        }

        return array_keys($permissions);
    }
} 