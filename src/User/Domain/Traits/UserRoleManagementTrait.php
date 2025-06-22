<?php

declare(strict_types=1);

namespace App\User\Domain\Traits;

use App\User\Domain\Role;
use Doctrine\Common\Collections\Collection;

/**
 * Trait for user role management
 */
trait UserRoleManagementTrait
{
    /**
     * Assign role
     */
    public function assignRole(Role $role): void
    {
        if ($this->roles->contains($role)) {
            return;
        }
        
        $this->roles->add($role);
        $this->updatedAt = new \DateTimeImmutable();
    }
    
    /**
     * Remove role
     */
    public function removeRole(Role $role): void
    {
        $this->roles->removeElement($role);
        $this->updatedAt = new \DateTimeImmutable();
    }
    
    /**
     * Check if user has role
     */
    public function hasRole(string $roleName): bool
    {
        return $this->roles->exists(fn($key, Role $role) => $role->getName() === $roleName);
    }
    
    /**
     * Check if user has permission
     */
    public function hasPermission(string $permission): bool
    {
        // Direct permissions
        if (in_array($permission, $this->permissions, true)) {
            return true;
        }
        
        // Role permissions
        foreach ($this->roles as $role) {
            if ($role->hasPermission($permission)) {
                return true;
            }
        }
        
        return false;
    }
    
    /**
     * Add role (alias for assignRole)
     */
    public function addRole(Role $role): void
    {
        $this->assignRole($role);
    }
    
    /**
     * Sync roles (replace all roles)
     */
    public function syncRoles(array $roles): void
    {
        $this->roles->clear();
        foreach ($roles as $role) {
            $this->assignRole($role);
        }
        $this->updatedAt = new \DateTimeImmutable();
    }
    
    /**
     * Get roles
     */
    public function getRoles(): Collection
    {
        return $this->roles;
    }
    
    /**
     * Get role names
     */
    public function getRoleNames(): array
    {
        return $this->roles->map(fn(Role $role) => $role->getName())->toArray();
    }
    
    /**
     * Get permission IDs
     */
    public function getPermissionIds(): array
    {
        $permissions = [];
        
        // Direct permissions
        $permissions = array_merge($permissions, $this->permissions);
        
        // Role permissions
        foreach ($this->roles as $role) {
            $permissions = array_merge($permissions, $role->getPermissionIds());
        }
        
        return array_unique($permissions);
    }
} 