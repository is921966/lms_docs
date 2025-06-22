<?php

declare(strict_types=1);

namespace App\User\Application\Service\User;

use App\Common\Exceptions\BusinessLogicException;
use App\Common\Exceptions\ValidationException;
use App\User\Domain\Repository\UserRepositoryInterface;
use App\User\Domain\ValueObjects\Password;
use App\User\Domain\ValueObjects\UserId;
use Psr\Log\LoggerInterface;

/**
 * Service for managing user passwords
 */
class UserPasswordService
{
    public function __construct(
        private UserRepositoryInterface $userRepository,
        private LoggerInterface $logger
    ) {
    }
    
    /**
     * Change user password
     */
    public function changePassword(UserId $userId, string $currentPassword, string $newPassword): void
    {
        $this->logger->info('Changing user password', ['userId' => $userId->getValue()]);
        
        $user = $this->userRepository->getById($userId);
        
        if (!$user->getPassword()) {
            throw new BusinessLogicException('User has no password set');
        }
        
        if (!$user->getPassword()->verify($currentPassword)) {
            throw ValidationException::withErrors(['currentPassword' => 'Current password is incorrect']);
        }
        
        $user->changePassword(Password::fromPlainText($newPassword));
        $this->userRepository->save($user);
        
        $this->logger->info('Password changed successfully', ['userId' => $userId->getValue()]);
    }
    
    /**
     * Reset user password
     */
    public function resetPassword(UserId $userId): string
    {
        $this->logger->info('Resetting user password', ['userId' => $userId->getValue()]);
        
        $user = $this->userRepository->getById($userId);
        
        // Generate temporary password
        $tempPassword = bin2hex(random_bytes(8));
        $user->changePassword(Password::fromPlainText($tempPassword));
        
        $this->userRepository->save($user);
        
        $this->logger->info('Password reset successfully', ['userId' => $userId->getValue()]);
        
        return $tempPassword;
    }
} 