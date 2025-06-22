<?php

declare(strict_types=1);

namespace App\User\Application\Service\Auth;

use App\Common\Exceptions\AuthorizationException;
use App\Common\Exceptions\BusinessLogicException;
use App\User\Domain\User;
use App\User\Domain\Repository\UserRepositoryInterface;
use Psr\Log\LoggerInterface;

/**
 * Service for two-factor authentication
 */
class TwoFactorAuthService
{
    public function __construct(
        private UserRepositoryInterface $userRepository,
        private LoggerInterface $logger
    ) {
    }
    
    /**
     * Enable two-factor authentication
     */
    public function enableTwoFactor(User $user): array
    {
        $this->logger->info('Enabling two-factor authentication', ['userId' => $user->getId()->getValue()]);
        
        if ($user->hasTwoFactorEnabled()) {
            throw new BusinessLogicException('Two-factor authentication is already enabled');
        }
        
        // Generate secret
        $secret = $this->generateSecret();
        $user->enableTwoFactor($secret);
        
        // Generate backup codes
        $backupCodes = $this->generateBackupCodes();
        
        $this->userRepository->save($user);
        
        $this->logger->info('Two-factor authentication enabled', ['userId' => $user->getId()->getValue()]);
        
        return [
            'secret' => $secret,
            'qr_code' => $this->generateQrCode($user, $secret),
            'backup_codes' => $backupCodes
        ];
    }
    
    /**
     * Disable two-factor authentication
     */
    public function disableTwoFactor(User $user, string $password): void
    {
        $this->logger->info('Disabling two-factor authentication', ['userId' => $user->getId()->getValue()]);
        
        if (!$user->hasTwoFactorEnabled()) {
            throw new BusinessLogicException('Two-factor authentication is not enabled');
        }
        
        if (!$user->getPassword() || !$user->getPassword()->verify($password)) {
            throw new AuthorizationException('Invalid password');
        }
        
        $user->disableTwoFactor();
        $this->userRepository->save($user);
        
        $this->logger->info('Two-factor authentication disabled', ['userId' => $user->getId()->getValue()]);
    }
    
    /**
     * Verify two-factor code
     */
    public function verifyCode(User $user, string $code): bool
    {
        // TODO: Implement actual TOTP verification
        // For now, simple check
        return $user->getTwoFactorSecret() !== null && strlen($code) === 6;
    }
    
    /**
     * Generate two-factor secret
     */
    private function generateSecret(): string
    {
        return base32_encode(random_bytes(16));
    }
    
    /**
     * Generate backup codes
     */
    private function generateBackupCodes(): array
    {
        $codes = [];
        for ($i = 0; $i < 8; $i++) {
            $codes[] = strtoupper(bin2hex(random_bytes(4)));
        }
        return $codes;
    }
    
    /**
     * Generate QR code URI for two-factor authentication
     */
    private function generateQrCode(User $user, string $secret): string
    {
        $issuer = 'LMS';
        $label = $user->getEmail()->getValue();
        
        return sprintf(
            'otpauth://totp/%s:%s?secret=%s&issuer=%s',
            $issuer,
            $label,
            $secret,
            $issuer
        );
    }
}

/**
 * Base32 encoding for TOTP
 */
function base32_encode(string $input): string
{
    $alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';
    $output = '';
    $position = 0;
    $storedData = 0;
    $storedBitCount = 0;
    $dataCount = strlen($input);
    
    while ($position < $dataCount || $storedBitCount > 0) {
        if ($storedBitCount < 5) {
            if ($position < $dataCount) {
                $storedData <<= 8;
                $storedData += ord($input[$position++]);
                $storedBitCount += 8;
            } else {
                $storedData <<= (5 - $storedBitCount);
                $storedBitCount = 5;
            }
        }
        
        $output .= $alphabet[$storedData >> ($storedBitCount - 5)];
        $storedData &= ((1 << ($storedBitCount - 5)) - 1);
        $storedBitCount -= 5;
    }
    
    return $output;
} 