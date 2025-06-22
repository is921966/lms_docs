<?php

declare(strict_types=1);

namespace App\User\Domain\Traits;

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
        if ($this->status === self::STATUS_ACTIVE) {
            throw new \DomainException('User already active');
        }
        
        $this->status = self::STATUS_ACTIVE;
        $this->updatedAt = new \DateTimeImmutable();
        
        $this->removeMetadata('suspension_reason');
        $this->removeMetadata('suspended_at');
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
     * Suspend user with reason and optional until date
     */
    public function suspend(string $reason, ?\DateTimeInterface $until = null): void
    {
        if ($this->status === self::STATUS_SUSPENDED) {
            throw new \DomainException('User already suspended');
        }
        
        $this->status = self::STATUS_SUSPENDED;
        $this->suspensionReason = $reason;
        $this->suspendedUntil = $until ? \DateTimeImmutable::createFromInterface($until) : null;
        $this->updatedAt = new \DateTimeImmutable();
        
        $this->addMetadata('suspension_reason', $reason);
        $this->addMetadata('suspended_at', $this->updatedAt->format('Y-m-d H:i:s'));
    }
    
    /**
     * Soft delete user
     */
    public function delete(): void
    {
        if ($this->deletedAt !== null) {
            throw new \DomainException('User already deleted');
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
            throw new \DomainException('User not deleted');
        }
        
        $this->deletedAt = null;
        $this->status = self::STATUS_ACTIVE;
        $this->updatedAt = new \DateTimeImmutable();
    }
    
    /**
     * Status getters
     */
    public function getStatus(): string
    {
        return $this->status;
    }
    
    public function isActive(): bool
    {
        return $this->status === self::STATUS_ACTIVE;
    }
    
    public function isDeleted(): bool
    {
        return $this->deletedAt !== null;
    }
    
    public function isSuspended(): bool
    {
        return $this->status === self::STATUS_SUSPENDED;
    }
    
    public function isAdmin(): bool
    {
        return $this->isAdmin;
    }
    
    public function getSuspensionReason(): ?string
    {
        return $this->suspensionReason;
    }
    
    public function getSuspendedUntil(): ?\DateTimeImmutable
    {
        return $this->suspendedUntil;
    }
    
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