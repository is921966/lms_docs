<?php

declare(strict_types=1);

namespace App\User\Application\Service\User;

use App\User\Domain\Repository\RoleRepositoryInterface;
use App\User\Domain\Repository\UserRepositoryInterface;
use App\User\Domain\User;
use App\User\Domain\ValueObjects\UserId;
use Psr\Log\LoggerInterface;

/**
 * Service for managing user roles
 */
class UserRoleService
{
    public function __construct(
        private UserRepositoryInterface $userRepository,
        private RoleRepositoryInterface $roleRepository,
        private LoggerInterface $logger
    ) {
    }
    
    /**
     * Assign roles to user
     */
    public function assignRoles(UserId $userId, array $roleNames): User
    {
        $this->logger->info('Assigning roles to user', ['userId' => $userId->getValue(), 'roles' => $roleNames]);
        
        $user = $this->userRepository->getById($userId);
        $roles = $this->roleRepository->findByNames($roleNames);
        
        foreach ($roles as $role) {
            $user->addRole($role);
        }
        
        $this->userRepository->save($user);
        
        $this->logger->info('Roles assigned successfully', ['userId' => $userId->getValue()]);
        
        return $user;
    }
    
    /**
     * Remove roles from user
     */
    public function removeRoles(UserId $userId, array $roleNames): User
    {
        $this->logger->info('Removing roles from user', ['userId' => $userId->getValue(), 'roles' => $roleNames]);
        
        $user = $this->userRepository->getById($userId);
        $roles = $this->roleRepository->findByNames($roleNames);
        
        foreach ($roles as $role) {
            $user->removeRole($role);
        }
        
        $this->userRepository->save($user);
        
        $this->logger->info('Roles removed successfully', ['userId' => $userId->getValue()]);
        
        return $user;
    }
    
    /**
     * Sync user roles (replace all)
     */
    public function syncRoles(UserId $userId, array $roleNames): User
    {
        $this->logger->info('Syncing user roles', ['userId' => $userId->getValue(), 'roles' => $roleNames]);
        
        $user = $this->userRepository->getById($userId);
        $roles = $this->roleRepository->findByNames($roleNames);
        
        $user->syncRoles($roles);
        $this->userRepository->save($user);
        
        $this->logger->info('Roles synced successfully', ['userId' => $userId->getValue()]);
        
        return $user;
    }
} 