<?php

declare(strict_types=1);

namespace User\Application\Service;

use App\User\Application\Service\User\UserCrudService;
use App\User\Application\Service\User\UserImportExportService;
use App\User\Application\Service\User\UserPasswordService;
use App\User\Application\Service\User\UserRoleService;
use App\User\Application\Service\User\UserStatusService;
use App\User\Domain\Repository\RoleRepositoryInterface;
use App\User\Domain\Repository\UserRepositoryInterface;
use App\User\Domain\Service\UserServiceInterface;
use App\User\Domain\User;
use App\User\Domain\ValueObjects\UserId;
use Psr\Log\LoggerInterface;

/**
 * User service implementation - facade for user operations
 */
class UserService implements UserServiceInterface
{
    private UserCrudService $crudService;
    private UserStatusService $statusService;
    private UserRoleService $roleService;
    private UserPasswordService $passwordService;
    private UserImportExportService $importExportService;
    
    public function __construct(
        private UserRepositoryInterface $userRepository,
        private RoleRepositoryInterface $roleRepository,
        private LoggerInterface $logger
    ) {
        $this->crudService = new UserCrudService($userRepository, $roleRepository, $logger);
        $this->statusService = new UserStatusService($userRepository, $logger);
        $this->roleService = new UserRoleService($userRepository, $roleRepository, $logger);
        $this->passwordService = new UserPasswordService($userRepository, $logger);
        $this->importExportService = new UserImportExportService($userRepository, $this->crudService, $logger);
    }
    
    /**
     * Create a new user
     */
    public function createUser(array $data): User
    {
        return $this->crudService->createUser($data);
    }
    
    /**
     * Update user
     */
    public function updateUser(UserId $userId, array $data): User
    {
        return $this->crudService->updateUser($userId, $data);
    }
    
    /**
     * Delete user (soft delete)
     */
    public function deleteUser(UserId $userId): void
    {
        $this->crudService->deleteUser($userId);
    }
    
    /**
     * Restore deleted user
     */
    public function restoreUser(UserId $userId): User
    {
        return $this->statusService->restoreUser($userId);
    }
    
    /**
     * Activate user
     */
    public function activateUser(UserId $userId): User
    {
        return $this->statusService->activateUser($userId);
    }
    
    /**
     * Deactivate user
     */
    public function deactivateUser(UserId $userId): User
    {
        return $this->statusService->deactivateUser($userId);
    }
    
    /**
     * Suspend user
     */
    public function suspendUser(UserId $userId, ?string $reason = null): User
    {
        return $this->statusService->suspendUser($userId, $reason);
    }
    
    /**
     * Assign roles to user
     */
    public function assignRoles(UserId $userId, array $roleNames): User
    {
        return $this->roleService->assignRoles($userId, $roleNames);
    }
    
    /**
     * Remove roles from user
     */
    public function removeRoles(UserId $userId, array $roleNames): User
    {
        return $this->roleService->removeRoles($userId, $roleNames);
    }
    
    /**
     * Sync user roles (replace all)
     */
    public function syncRoles(UserId $userId, array $roleNames): User
    {
        return $this->roleService->syncRoles($userId, $roleNames);
    }
    
    /**
     * Change user password
     */
    public function changePassword(UserId $userId, string $currentPassword, string $newPassword): void
    {
        $this->passwordService->changePassword($userId, $currentPassword, $newPassword);
    }
    
    /**
     * Reset user password
     */
    public function resetPassword(UserId $userId): string
    {
        return $this->passwordService->resetPassword($userId);
    }
    
    /**
     * Import users from CSV
     */
    public function importFromCsv(string $filePath): array
    {
        return $this->importExportService->importFromCsv($filePath);
    }
    
    /**
     * Export users to CSV
     */
    public function exportToCsv(array $criteria): string
    {
        return $this->importExportService->exportToCsv($criteria);
    }
    
    /**
     * Get user by ID
     */
    public function getUser(UserId $userId): User
    {
        return $this->crudService->getUser($userId);
    }
    
    /**
     * Search users
     */
    public function searchUsers(array $criteria): array
    {
        return $this->crudService->searchUsers($criteria);
    }
    
    /**
     * Get user statistics
     */
    public function getStatistics(): array
    {
        return $this->userRepository->getStatistics();
    }
} 