<?php

declare(strict_types=1);

namespace App\Domain\Entity;

use App\Domain\ValueObject\UserId;
use App\Domain\ValueObject\Email;
use App\Domain\ValueObject\FullName;
use App\Domain\ValueObject\PhoneNumber;
use App\Domain\ValueObject\UserStatus;
use App\Domain\Event\UserCreated;
use App\Domain\Event\UserUpdated;
use App\Domain\Event\UserDeactivated;
use App\Domain\Event\UserActivated;
use App\Domain\Event\RoleAssigned;
use App\Domain\Event\RoleRevoked;
use DateTimeImmutable;
use DomainException;

class User
{
    private array $domainEvents = [];
    private array $roles = [];
    private ?Profile $profile = null;
    
    public function __construct(
        private UserId $id,
        private Email $email,
        private FullName $fullName,
        private UserStatus $status,
        private DateTimeImmutable $createdAt,
        private ?DateTimeImmutable $updatedAt = null,
        private ?DateTimeImmutable $lastLoginAt = null,
        private ?PhoneNumber $phoneNumber = null,
        private ?string $avatarUrl = null,
        private array $metadata = []
    ) {
        $this->recordEvent(new UserCreated(
            $this->id->toString(),
            $this->email->getValue(),
            $this->fullName->getFullName(),
            $this->createdAt
        ));
    }
    
    public static function create(
        UserId $id,
        Email $email,
        FullName $fullName
    ): self {
        return new self(
            $id,
            $email,
            $fullName,
            UserStatus::active(),
            new DateTimeImmutable()
        );
    }
    
    public function update(
        FullName $fullName,
        ?PhoneNumber $phoneNumber = null,
        ?string $avatarUrl = null
    ): void {
        $this->fullName = $fullName;
        $this->phoneNumber = $phoneNumber;
        $this->avatarUrl = $avatarUrl;
        $this->updatedAt = new DateTimeImmutable();
        
        $this->recordEvent(new UserUpdated(
            $this->id->toString(),
            $this->updatedAt
        ));
    }
    
    public function deactivate(): void
    {
        if ($this->status->isInactive()) {
            throw new DomainException('User is already inactive');
        }
        
        $this->status = UserStatus::inactive();
        $this->updatedAt = new DateTimeImmutable();
        
        $this->recordEvent(new UserDeactivated(
            $this->id->toString(),
            $this->updatedAt
        ));
    }
    
    public function activate(): void
    {
        if ($this->status->isActive()) {
            throw new DomainException('User is already active');
        }
        
        $this->status = UserStatus::active();
        $this->updatedAt = new DateTimeImmutable();
        
        $this->recordEvent(new UserActivated(
            $this->id->toString(),
            $this->updatedAt
        ));
    }
    
    public function assignRole(Role $role): void
    {
        if ($this->hasRole($role)) {
            return;
        }
        
        $this->roles[] = $role;
        $this->updatedAt = new DateTimeImmutable();
        
        $this->recordEvent(new RoleAssigned(
            $this->id->toString(),
            $role->getId()->toString(),
            $role->getName(),
            $this->updatedAt
        ));
    }
    
    public function revokeRole(Role $role): void
    {
        $this->roles = array_filter(
            $this->roles,
            fn(Role $r) => !$r->equals($role)
        );
        
        $this->updatedAt = new DateTimeImmutable();
        
        $this->recordEvent(new RoleRevoked(
            $this->id->toString(),
            $role->getId()->toString(),
            $role->getName(),
            $this->updatedAt
        ));
    }
    
    public function hasRole(Role $role): bool
    {
        foreach ($this->roles as $userRole) {
            if ($userRole->equals($role)) {
                return true;
            }
        }
        return false;
    }
    
    public function hasPermission(string $permission): bool
    {
        foreach ($this->roles as $role) {
            if ($role->hasPermission($permission)) {
                return true;
            }
        }
        return false;
    }
    
    public function updateLastLogin(): void
    {
        $this->lastLoginAt = new DateTimeImmutable();
    }
    
    public function attachProfile(Profile $profile): void
    {
        $this->profile = $profile;
    }
    
    public function updateMetadata(array $metadata): void
    {
        $this->metadata = array_merge($this->metadata, $metadata);
        $this->updatedAt = new DateTimeImmutable();
    }
    
    // Getters
    public function getId(): UserId
    {
        return $this->id;
    }
    
    public function getEmail(): Email
    {
        return $this->email;
    }
    
    public function getFullName(): FullName
    {
        return $this->fullName;
    }
    
    public function getStatus(): UserStatus
    {
        return $this->status;
    }
    
    public function getCreatedAt(): DateTimeImmutable
    {
        return $this->createdAt;
    }
    
    public function getUpdatedAt(): ?DateTimeImmutable
    {
        return $this->updatedAt;
    }
    
    public function getLastLoginAt(): ?DateTimeImmutable
    {
        return $this->lastLoginAt;
    }
    
    public function getPhoneNumber(): ?PhoneNumber
    {
        return $this->phoneNumber;
    }
    
    public function getAvatarUrl(): ?string
    {
        return $this->avatarUrl;
    }
    
    public function getRoles(): array
    {
        return $this->roles;
    }
    
    public function getProfile(): ?Profile
    {
        return $this->profile;
    }
    
    public function getMetadata(): array
    {
        return $this->metadata;
    }
    
    // Domain Events
    private function recordEvent(object $event): void
    {
        $this->domainEvents[] = $event;
    }
    
    public function pullDomainEvents(): array
    {
        $events = $this->domainEvents;
        $this->domainEvents = [];
        return $events;
    }
} 