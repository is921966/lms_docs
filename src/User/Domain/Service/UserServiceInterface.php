<?php

declare(strict_types=1);

namespace User\Domain\Service;

use User\Domain\User;
use User\Domain\ValueObjects\UserId;

/**
 * User service interface
 */
interface UserServiceInterface
{
    /**
     * Create a new user
     */
    public function createUser(array $data): User;
    
    /**
     * Update user
     */
    public function updateUser(UserId $userId, array $data): User;
    
    /**
     * Delete user (soft delete)
     */
    public function deleteUser(UserId $userId): void;
    
    /**
     * Restore deleted user
     */
    public function restoreUser(UserId $userId): User;
    
    /**
     * Activate user
     */
    public function activateUser(UserId $userId): User;
    
    /**
     * Deactivate user
     */
    public function deactivateUser(UserId $userId): User;
    
    /**
     * Suspend user
     */
    public function suspendUser(UserId $userId, ?string $reason = null): User;
    
    /**
     * Assign roles to user
     */
    public function assignRoles(UserId $userId, array $roleNames): User;
    
    /**
     * Remove roles from user
     */
    public function removeRoles(UserId $userId, array $roleNames): User;
    
    /**
     * Sync user roles (replace all)
     */
    public function syncRoles(UserId $userId, array $roleNames): User;
    
    /**
     * Change user password
     */
    public function changePassword(UserId $userId, string $currentPassword, string $newPassword): void;
    
    /**
     * Reset user password
     */
    public function resetPassword(UserId $userId): string;
    
    /**
     * Import users from CSV
     */
    public function importFromCsv(string $filePath): array;
    
    /**
     * Export users to CSV
     */
    public function exportToCsv(array $criteria): string;
    
    /**
     * Get user by ID
     */
    public function getUser(UserId $userId): User;
    
    /**
     * Search users
     */
    public function searchUsers(array $criteria): array;
    
    /**
     * Get user statistics
     */
    public function getStatistics(): array;
} 