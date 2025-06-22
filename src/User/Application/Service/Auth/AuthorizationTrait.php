<?php

declare(strict_types=1);

namespace App\User\Application\Service\Auth;

use App\User\Domain\User;

/**
 * Trait for authorization checks
 */
trait AuthorizationTrait
{
    private ?User $currentUser = null;
    
    /**
     * Get current authenticated user
     */
    public function getCurrentUser(): ?User
    {
        return $this->currentUser;
    }
    
    /**
     * Check if user has permission
     */
    public function hasPermission(string $permission): bool
    {
        if (!$this->currentUser) {
            return false;
        }
        
        return $this->currentUser->hasPermission($permission);
    }
    
    /**
     * Check if user has any of the permissions
     */
    public function hasAnyPermission(array $permissions): bool
    {
        if (!$this->currentUser) {
            return false;
        }
        
        foreach ($permissions as $permission) {
            if ($this->currentUser->hasPermission($permission)) {
                return true;
            }
        }
        
        return false;
    }
    
    /**
     * Check if user has all permissions
     */
    public function hasAllPermissions(array $permissions): bool
    {
        if (!$this->currentUser) {
            return false;
        }
        
        foreach ($permissions as $permission) {
            if (!$this->currentUser->hasPermission($permission)) {
                return false;
            }
        }
        
        return true;
    }
    
    /**
     * Check if user has role
     */
    public function hasRole(string $role): bool
    {
        if (!$this->currentUser) {
            return false;
        }
        
        return $this->currentUser->hasRole($role);
    }
    
    /**
     * Check if user has any of the roles
     */
    public function hasAnyRole(array $roles): bool
    {
        if (!$this->currentUser) {
            return false;
        }
        
        foreach ($roles as $role) {
            if ($this->currentUser->hasRole($role)) {
                return true;
            }
        }
        
        return false;
    }
} 