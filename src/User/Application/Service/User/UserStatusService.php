<?php

declare(strict_types=1);

namespace App\User\Application\Service\User;

use App\Common\Exceptions\BusinessLogicException;
use App\User\Domain\Repository\UserRepositoryInterface;
use App\User\Domain\User;
use App\User\Domain\ValueObjects\UserId;
use Psr\Log\LoggerInterface;

/**
 * Service for managing user status
 */
class UserStatusService
{
    public function __construct(
        private UserRepositoryInterface $userRepository,
        private LoggerInterface $logger
    ) {
    }
    
    /**
     * Activate user
     */
    public function activateUser(UserId $userId): User
    {
        $this->logger->info('Activating user', ['userId' => $userId->getValue()]);
        
        $user = $this->userRepository->getById($userId);
        $user->activate();
        $this->userRepository->save($user);
        
        $this->logger->info('User activated successfully', ['userId' => $userId->getValue()]);
        
        return $user;
    }
    
    /**
     * Deactivate user
     */
    public function deactivateUser(UserId $userId): User
    {
        $this->logger->info('Deactivating user', ['userId' => $userId->getValue()]);
        
        $user = $this->userRepository->getById($userId);
        $user->deactivate();
        $this->userRepository->save($user);
        
        $this->logger->info('User deactivated successfully', ['userId' => $userId->getValue()]);
        
        return $user;
    }
    
    /**
     * Suspend user
     */
    public function suspendUser(UserId $userId, ?string $reason = null): User
    {
        $this->logger->info('Suspending user', ['userId' => $userId->getValue(), 'reason' => $reason]);
        
        $user = $this->userRepository->getById($userId);
        $user->suspend($reason);
        $this->userRepository->save($user);
        
        $this->logger->info('User suspended successfully', ['userId' => $userId->getValue()]);
        
        return $user;
    }
    
    /**
     * Restore deleted user
     */
    public function restoreUser(UserId $userId): User
    {
        $this->logger->info('Restoring user', ['userId' => $userId->getValue()]);
        
        $user = $this->userRepository->getById($userId);
        
        if (!$user->isDeleted()) {
            throw new BusinessLogicException('User is not deleted');
        }
        
        $user->restore();
        $this->userRepository->save($user);
        
        $this->logger->info('User restored successfully', ['userId' => $userId->getValue()]);
        
        return $user;
    }
} 