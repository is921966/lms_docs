<?php

declare(strict_types=1);

namespace App\User\Domain\Repository;

use App\User\Domain\User;
use App\User\Domain\ValueObjects\Email;
use App\User\Domain\ValueObjects\UserId;

/**
 * User repository interface
 */
interface UserRepositoryInterface
{
    /**
     * Find user by ID
     */
    public function findById(UserId $id): ?User;
    
    /**
     * Get user by ID (throws exception if not found)
     */
    public function getById(UserId $id): User;
    
    /**
     * Find user by email
     */
    public function findByEmail(Email $email): ?User;
    
    /**
     * Find user by AD username
     */
    public function findByAdUsername(string $username): ?User;
    
    /**
     * Check if email exists
     */
    public function emailExists(Email $email, ?UserId $excludeUserId = null): bool;
    
    /**
     * Find users by manager
     */
    public function findByManager(UserId $managerId): array;
    
    /**
     * Find users by department
     */
    public function findByDepartment(string $department): array;
    
    /**
     * Find users by position
     */
    public function findByPosition(int $positionId): array;
    
    /**
     * Find users with specific role
     */
    public function findByRole(string $roleName): array;
    
    /**
     * Find active users
     */
    public function findActive(): array;
    
    /**
     * Find users for LDAP sync
     */
    public function findForLdapSync(\DateTimeInterface $lastSyncBefore): array;
    
    /**
     * Search users
     */
    public function search(array $criteria): array;
    
    /**
     * Count users by criteria
     */
    public function countByCriteria(array $criteria): int;
    
    /**
     * Get user statistics
     */
    public function getStatistics(): array;
    
    /**
     * Save user
     */
    public function save(User $user): void;
    
    /**
     * Remove user
     */
    public function remove(User $user): void;
} 