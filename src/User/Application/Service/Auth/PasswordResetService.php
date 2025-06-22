<?php

declare(strict_types=1);

namespace App\User\Application\Service\Auth;

use App\Common\Exceptions\ValidationException;
use App\User\Domain\Repository\UserRepositoryInterface;
use App\User\Domain\ValueObjects\Email;
use App\User\Domain\ValueObjects\Password;
use Psr\Log\LoggerInterface;

/**
 * Service for password reset functionality
 */
class PasswordResetService
{
    public function __construct(
        private UserRepositoryInterface $userRepository,
        private LoggerInterface $logger
    ) {
    }
    
    /**
     * Request password reset
     */
    public function requestPasswordReset(string $email): void
    {
        $this->logger->info('Password reset requested', ['email' => $email]);
        
        $user = $this->userRepository->findByEmail(new Email($email));
        
        if (!$user) {
            // Don't reveal if email exists for security
            $this->logger->warning('Password reset requested for non-existent email', ['email' => $email]);
            return;
        }
        
        // Generate reset token
        $resetToken = $this->generateResetToken();
        
        // TODO: Save reset token to user
        // This would require adding methods to User domain model
        // For now, we'll just log it
        
        $this->logger->info('Password reset token generated', [
            'userId' => $user->getId()->getValue(),
            'token' => substr($resetToken, 0, 8) . '...'
        ]);
        
        // TODO: Send reset email
        // $this->emailService->sendPasswordResetEmail($user, $resetToken);
    }
    
    /**
     * Reset password with token
     */
    public function resetPasswordWithToken(string $token, string $newPassword): void
    {
        $this->logger->info('Resetting password with token');
        
        // TODO: Find user by reset token
        // This would require adding a method to repository
        // For now, throw validation error
        
        throw ValidationException::withErrors(['token' => 'Password reset functionality not fully implemented']);
    }
    
    /**
     * Verify email with token
     */
    public function verifyEmail(string $token): void
    {
        $this->logger->info('Verifying email with token');
        
        // TODO: Find user by verification token
        // This would require adding a method to repository
        
        throw ValidationException::withErrors(['token' => 'Email verification functionality not fully implemented']);
    }
    
    /**
     * Generate secure reset token
     */
    private function generateResetToken(): string
    {
        return bin2hex(random_bytes(32));
    }
} 