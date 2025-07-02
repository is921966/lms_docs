<?php

declare(strict_types=1);

namespace User\Infrastructure\Repository;

use App\User\Domain\Repository\UserRepositoryInterface;
use App\User\Domain\User;
use App\User\Domain\ValueObjects\Email;
use App\User\Domain\ValueObjects\UserId;
use App\Common\Exceptions\NotFoundException;

/**
 * In-memory implementation of UserRepository for testing
 */
class InMemoryUserRepository implements UserRepositoryInterface
{
    /**
     * @var array<string, User>
     */
    private array $users = [];
    
    /**
     * Save user
     */
    public function save(User $user): void
    {
        $this->users[$user->getId()->getValue()] = $user;
    }
    
    /**
     * Get user by ID
     */
    public function getById(UserId $userId): User
    {
        if (!isset($this->users[$userId->getValue()])) {
            throw new NotFoundException('User not found');
        }
        
        return $this->users[$userId->getValue()];
    }
    
    /**
     * Find user by email
     */
    public function findByEmail(Email $email): ?User
    {
        foreach ($this->users as $user) {
            if ($user->getEmail()->equals($email)) {
                return $user;
            }
        }
        
        return null;
    }
    
    /**
     * Check if email exists
     */
    public function emailExists(Email $email, ?UserId $excludeUserId = null): bool
    {
        foreach ($this->users as $user) {
            if ($user->getEmail()->equals($email)) {
                if ($excludeUserId && $user->getId()->equals($excludeUserId)) {
                    continue;
                }
                return true;
            }
        }
        
        return false;
    }
    
    /**
     * Find user by AD username
     */
    public function findByAdUsername(string $username): ?User
    {
        foreach ($this->users as $user) {
            if ($user->getAdUsername() === $username) {
                return $user;
            }
        }
        
        return null;
    }
    
    /**
     * Search users
     */
    public function search(array $criteria): array
    {
        $results = [];
        
        foreach ($this->users as $user) {
            // Simple search implementation
            if (!empty($criteria['search'])) {
                $search = strtolower($criteria['search']);
                $fullName = strtolower($user->getFirstName() . ' ' . $user->getLastName());
                if (strpos($fullName, $search) === false && 
                    strpos(strtolower($user->getEmail()->getValue()), $search) === false) {
                    continue;
                }
            }
            
            if (!empty($criteria['status']) && $user->getStatus() !== $criteria['status']) {
                continue;
            }
            
            if (!empty($criteria['includeDeleted']) && $user->isDeleted()) {
                continue;
            }
            
            $results[] = $user;
        }
        
        return $results;
    }
    
    /**
     * Get user statistics
     */
    public function getStatistics(): array
    {
        $stats = [
            'total' => 0,
            'active' => 0,
            'inactive' => 0,
            'suspended' => 0,
            'deleted' => 0,
        ];
        
        foreach ($this->users as $user) {
            $stats['total']++;
            
            if ($user->isDeleted()) {
                $stats['deleted']++;
            } elseif ($user->isSuspended()) {
                $stats['suspended']++;
            } elseif ($user->isActive()) {
                $stats['active']++;
            } else {
                $stats['inactive']++;
            }
        }
        
        return $stats;
    }
    
    /**
     * Clear all users (for testing)
     */
    public function clear(): void
    {
        $this->users = [];
    }
    
    /**
     * Find user by ID
     */
    public function findById(UserId $id): ?User
    {
        return $this->users[$id->getValue()] ?? null;
    }
    
    /**
     * Find users by manager
     */
    public function findByManager(UserId $managerId): array
    {
        return array_filter($this->users, function (User $user) use ($managerId) {
            return $user->getManagerId() && $user->getManagerId()->equals($managerId);
        });
    }
    
    /**
     * Find users by department
     */
    public function findByDepartment(string $department): array
    {
        return array_filter($this->users, function (User $user) use ($department) {
            return $user->getDepartment() === $department;
        });
    }
    
    /**
     * Find users by position
     */
    public function findByPosition(int $positionId): array
    {
        return array_filter($this->users, function (User $user) use ($positionId) {
            return $user->getPositionId() === $positionId;
        });
    }
    
    /**
     * Find users by role
     */
    public function findByRole(string $roleName): array
    {
        return array_filter($this->users, function (User $user) use ($roleName) {
            return $user->hasRole($roleName);
        });
    }
    
    /**
     * Find active users
     */
    public function findActive(): array
    {
        return array_filter($this->users, function (User $user) {
            return $user->isActive();
        });
    }
    
    /**
     * Find users for LDAP sync
     */
    public function findForLdapSync(\DateTimeInterface $lastSyncBefore): array
    {
        return array_filter($this->users, function (User $user) use ($lastSyncBefore) {
            return $user->getAdUsername() && 
                   (!$user->getLastSyncedAt() || $user->getLastSyncedAt() < $lastSyncBefore);
        });
    }
    
    /**
     * Count users by criteria
     */
    public function countByCriteria(array $criteria): int
    {
        return count($this->search($criteria));
    }
    
    /**
     * Remove user
     */
    public function remove(User $user): void
    {
        unset($this->users[$user->getId()->getValue()]);
    }
} 