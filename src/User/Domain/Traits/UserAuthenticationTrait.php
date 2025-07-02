<?php

declare(strict_types=1);

namespace User\Domain\Traits;

use User\Domain\Events\UserLoggedIn;
use User\Domain\ValueObjects\Password;

/**
 * Trait for user authentication functionality
 */
trait UserAuthenticationTrait
{
    /**
     * Change password
     */
    public function changePassword(Password $newPassword): void
    {
        if ($this->password && $this->password->equals($newPassword)) {
            throw new \DomainException('New password must be different from current password');
        }
        
        $this->password = $newPassword;
        $this->passwordChangedAt = new \DateTimeImmutable();
        $this->updatedAt = new \DateTimeImmutable();
    }
    
    /**
     * Verify password
     */
    public function verifyPassword(string $plainPassword): bool
    {
        if ($this->password === null) {
            return false;
        }
        
        return $this->password->verify($plainPassword);
    }
    
    /**
     * Check if user can be authenticated
     */
    public function canAuthenticate(): bool
    {
        return $this->status === self::STATUS_ACTIVE 
            && $this->deletedAt === null;
    }
    
    /**
     * Check if password needs to be changed
     */
    public function needsPasswordChange(int $maxAgeDays = 90): bool
    {
        if ($this->passwordChangedAt === null) {
            return true;
        }
        
        $daysSinceChange = $this->passwordChangedAt->diff(new \DateTimeImmutable())->days;
        
        return $daysSinceChange > $maxAgeDays;
    }
    
    /**
     * Record login with additional tracking
     */
    public function recordLogin(string $ipAddress, ?string $userAgent = null): void
    {
        $this->lastLoginAt = new \DateTimeImmutable();
        $this->lastLoginIp = $ipAddress;
        $this->lastUserAgent = $userAgent;
        $this->loginCount++;
        $this->updatedAt = new \DateTimeImmutable();
        
        $this->recordEvent(new UserLoggedIn($this->id, $ipAddress, $userAgent));
    }
    
    /**
     * Record failed login attempt
     */
    public function recordFailedLogin(): void
    {
        $this->addMetadata('last_failed_login', (new \DateTimeImmutable())->format('Y-m-d H:i:s'));
        $this->updatedAt = new \DateTimeImmutable();
    }
    
    /**
     * Set last login time (simple version)
     */
    public function setLastLoginAt(\DateTime $dateTime): void
    {
        $this->lastLoginAt = \DateTimeImmutable::createFromMutable($dateTime);
        $this->updatedAt = new \DateTimeImmutable();
    }
    
    /**
     * Two-factor authentication methods
     */
    public function hasTwoFactorEnabled(): bool
    {
        return $this->twoFactorEnabled;
    }
    
    public function enableTwoFactor(string $secret): void
    {
        $this->twoFactorEnabled = true;
        $this->twoFactorSecret = $secret;
        $this->updatedAt = new \DateTimeImmutable();
    }
    
    public function disableTwoFactor(): void
    {
        $this->twoFactorEnabled = false;
        $this->twoFactorSecret = null;
        $this->updatedAt = new \DateTimeImmutable();
    }
    
    public function getTwoFactorSecret(): ?string
    {
        return $this->twoFactorSecret;
    }
    
    /**
     * Get authentication related data
     */
    public function getPassword(): ?Password
    {
        return $this->password;
    }
    
    public function getLastLoginAt(): ?\DateTimeImmutable
    {
        return $this->lastLoginAt;
    }
    
    public function getLastLoginIp(): ?string
    {
        return $this->lastLoginIp;
    }
    
    public function getLastUserAgent(): ?string
    {
        return $this->lastUserAgent;
    }
    
    public function getLoginCount(): int
    {
        return $this->loginCount;
    }
} 