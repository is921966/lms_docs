<?php

declare(strict_types=1);

namespace User\Domain\Traits;

/**
 * Trait for user status management
 */
trait UserStatusManagementTrait
{
    /**
     * Activate user
     */
    public function activate(): void
    {
        if ($this->deletedAt !== null) {
            throw new \DomainException('Cannot activate deleted user');
        }
        
        $this->status = self::STATUS_ACTIVE;
        $this->suspensionReason = null;
        $this->suspendedUntil = null;
        $this->updatedAt = new \DateTimeImmutable();
    }
    
    /**
     * Deactivate user
     */
    public function deactivate(): void
    {
        $this->status = self::STATUS_INACTIVE;
        $this->updatedAt = new \DateTimeImmutable();
    }
    
    /**
     * Suspend user
     */
    public function suspend(string $reason, ?\DateTimeImmutable $until = null): void
    {
        if ($this->deletedAt !== null) {
            throw new \DomainException('Cannot suspend deleted user');
        }
        
        $this->status = self::STATUS_SUSPENDED;
        $this->suspensionReason = $reason;
        $this->suspendedUntil = $until;
        $this->updatedAt = new \DateTimeImmutable();
    }
    
    /**
     * Delete user (soft delete)
     */
    public function delete(): void
    {
        if ($this->deletedAt !== null) {
            throw new \DomainException('User is already deleted');
        }
        
        $this->deletedAt = new \DateTimeImmutable();
        $this->status = self::STATUS_INACTIVE;
        $this->updatedAt = new \DateTimeImmutable();
    }
    
    /**
     * Restore deleted user
     */
    public function restore(): void
    {
        if ($this->deletedAt === null) {
            throw new \DomainException('User is not deleted');
        }
        
        $this->deletedAt = null;
        $this->status = self::STATUS_ACTIVE;
        $this->updatedAt = new \DateTimeImmutable();
    }
    
    /**
     * Check if user is active
     */
    public function isActive(): bool
    {
        return $this->status === self::STATUS_ACTIVE && $this->deletedAt === null;
    }
    
    /**
     * Check if user is deleted
     */
    public function isDeleted(): bool
    {
        return $this->deletedAt !== null;
    }
    
    /**
     * Check if user is suspended
     */
    public function isSuspended(): bool
    {
        if ($this->status !== self::STATUS_SUSPENDED) {
            return false;
        }
        
        if ($this->suspendedUntil === null) {
            return true;
        }
        
        return $this->suspendedUntil > new \DateTimeImmutable();
    }
    
    /**
     * Get suspension info
     */
    public function getSuspensionInfo(): array
    {
        return [
            'reason' => $this->suspensionReason,
            'until' => $this->suspendedUntil
        ];
    }
    
    /**
     * Check if suspension has expired
     */
    public function checkSuspensionExpiry(): void
    {
        if ($this->isSuspended() && 
            $this->suspendedUntil !== null && 
            $this->suspendedUntil <= new \DateTimeImmutable()) {
            $this->activate();
        }
    }
    
    /**
     * Get deleted at timestamp
     */
    public function getDeletedAt(): ?\DateTimeImmutable
    {
        return $this->deletedAt;
    }
    
    /**
     * Metadata management (private methods)
     */
    private function addMetadata(string $key, mixed $value): void
    {
        $this->metadata[$key] = $value;
    }
    
    private function removeMetadata(string $key): void
    {
        unset($this->metadata[$key]);
    }
} 