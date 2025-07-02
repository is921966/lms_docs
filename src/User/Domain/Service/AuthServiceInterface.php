<?php

declare(strict_types=1);

namespace User\Domain\Service;

use User\Domain\User;

/**
 * Authentication service interface
 */
interface AuthServiceInterface
{
    /**
     * Authenticate user with email and password
     */
    public function authenticate(string $email, string $password): array;
    
    /**
     * Authenticate user with LDAP
     */
    public function authenticateWithLdap(string $username, string $password): array;
    
    /**
     * Refresh authentication token
     */
    public function refreshToken(string $refreshToken): array;
    
    /**
     * Logout user
     */
    public function logout(string $token): void;
    
    /**
     * Validate token
     */
    public function validateToken(string $token): ?User;
    
    /**
     * Get current authenticated user
     */
    public function getCurrentUser(): ?User;
    
    /**
     * Check if user has permission
     */
    public function hasPermission(string $permission): bool;
    
    /**
     * Check if user has any of the permissions
     */
    public function hasAnyPermission(array $permissions): bool;
    
    /**
     * Check if user has all permissions
     */
    public function hasAllPermissions(array $permissions): bool;
    
    /**
     * Check if user has role
     */
    public function hasRole(string $role): bool;
    
    /**
     * Check if user has any of the roles
     */
    public function hasAnyRole(array $roles): bool;
    
    /**
     * Request password reset
     */
    public function requestPasswordReset(string $email): void;
    
    /**
     * Reset password with token
     */
    public function resetPasswordWithToken(string $token, string $newPassword): void;
    
    /**
     * Verify email with token
     */
    public function verifyEmail(string $token): void;
    
    /**
     * Enable two-factor authentication
     */
    public function enableTwoFactor(User $user): array;
    
    /**
     * Disable two-factor authentication
     */
    public function disableTwoFactor(User $user, string $password): void;
    
    /**
     * Verify two-factor code
     */
    public function verifyTwoFactorCode(string $code, string $token): array;
} 