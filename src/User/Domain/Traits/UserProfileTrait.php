<?php

declare(strict_types=1);

namespace User\Domain\Traits;

use User\Domain\Events\UserUpdated;
use User\Domain\ValueObjects\Email;

/**
 * Trait for user profile management
 */
trait UserProfileTrait
{
    /**
     * Update user profile
     */
    public function updateProfile(
        string $firstName,
        string $lastName,
        ?string $middleName = null,
        ?string $phone = null,
        ?string $department = null
    ): void {
        $this->firstName = $firstName;
        $this->lastName = $lastName;
        $this->middleName = $middleName;
        $this->phone = $phone;
        $this->department = $department;
        $this->updatedAt = new \DateTimeImmutable();
        
        $this->recordEvent(new UserUpdated($this->id));
    }
    
    /**
     * Update from LDAP data
     */
    public function updateFromLdap(array $ldapData): void
    {
        $this->firstName = $ldapData['givenName'] ?? $this->firstName;
        $this->lastName = $ldapData['sn'] ?? $this->lastName;
        $this->displayName = $ldapData['displayName'] ?? null;
        $this->department = $ldapData['department'] ?? null;
        $this->positionTitle = $ldapData['title'] ?? null;
        $this->ldapSyncedAt = new \DateTimeImmutable();
        $this->updatedAt = new \DateTimeImmutable();
    }
    
    /**
     * Sync with LDAP (alias for updateFromLdap)
     */
    public function syncWithLdap(array $ldapData): void
    {
        $this->updateFromLdap($ldapData);
    }
    
    /**
     * Change email
     */
    public function changeEmail(Email $newEmail): void
    {
        if ($this->email->equals($newEmail)) {
            throw new \DomainException('New email must be different from current email');
        }
        
        $this->email = $newEmail;
        $this->emailVerifiedAt = null; // Reset verification
        $this->updatedAt = new \DateTimeImmutable();
    }
    
    /**
     * Verify email
     */
    public function verifyEmail(): void
    {
        if ($this->emailVerifiedAt !== null) {
            throw new \DomainException('Email already verified');
        }
        
        $this->emailVerifiedAt = new \DateTimeImmutable();
        $this->updatedAt = new \DateTimeImmutable();
    }
    
    /**
     * Profile getters
     */
    public function getFullName(): string
    {
        $parts = array_filter([
            $this->firstName,
            $this->middleName,
            $this->lastName
        ]);
        
        return implode(' ', $parts);
    }
    
    public function getDisplayName(): string
    {
        return $this->displayName ?? $this->getFullName();
    }
    
    public function getFirstName(): string
    {
        return $this->firstName;
    }
    
    public function getLastName(): string
    {
        return $this->lastName;
    }
    
    public function getMiddleName(): ?string
    {
        return $this->middleName;
    }
    
    public function getEmail(): Email
    {
        return $this->email;
    }
    
    public function getPhone(): ?string
    {
        return $this->phone;
    }
    
    public function getDepartment(): ?string
    {
        return $this->department;
    }
    
    public function getAdUsername(): ?string
    {
        return $this->adUsername;
    }
    
    public function getLdapSyncedAt(): ?\DateTimeImmutable
    {
        return $this->ldapSyncedAt;
    }
    
    /**
     * Check if email is verified
     */
    public function isEmailVerified(): bool
    {
        return $this->emailVerifiedAt !== null;
    }
    
    /**
     * Check if user is LDAP user
     */
    public function isLdapUser(): bool
    {
        return $this->adUsername !== null;
    }
} 