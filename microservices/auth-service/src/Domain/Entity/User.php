<?php

namespace App\Domain\Entity;

use App\Domain\ValueObject\Email;
use App\Domain\ValueObject\UserId;
use App\Domain\ValueObject\Password;
use App\Domain\Event\UserCreated;
use App\Domain\Event\UserPasswordChanged;
use App\Domain\Event\UserActivated;
use App\Domain\Event\UserDeactivated;
use Symfony\Component\Security\Core\User\PasswordAuthenticatedUserInterface;
use Symfony\Component\Security\Core\User\UserInterface;

class User implements UserInterface, PasswordAuthenticatedUserInterface
{
    private UserId $id;
    private Email $email;
    private Password $password;
    private array $roles = [];
    private bool $isActive = true;
    private \DateTimeImmutable $createdAt;
    private ?\DateTimeImmutable $lastLoginAt = null;
    private array $domainEvents = [];
    
    public function __construct(
        UserId $id,
        Email $email,
        Password $password,
        array $roles = ['ROLE_USER']
    ) {
        $this->id = $id;
        $this->email = $email;
        $this->password = $password;
        $this->roles = $roles;
        $this->createdAt = new \DateTimeImmutable();
        
        $this->raise(new UserCreated($id, $email));
    }
    
    public function getId(): UserId
    {
        return $this->id;
    }
    
    public function getEmail(): Email
    {
        return $this->email;
    }
    
    public function changePassword(Password $newPassword): void
    {
        $this->password = $newPassword;
        $this->raise(new UserPasswordChanged($this->id));
    }
    
    public function activate(): void
    {
        if (!$this->isActive) {
            $this->isActive = true;
            $this->raise(new UserActivated($this->id));
        }
    }
    
    public function deactivate(): void
    {
        if ($this->isActive) {
            $this->isActive = false;
            $this->raise(new UserDeactivated($this->id));
        }
    }
    
    public function recordLogin(): void
    {
        $this->lastLoginAt = new \DateTimeImmutable();
    }
    
    public function isActive(): bool
    {
        return $this->isActive;
    }
    
    public function getCreatedAt(): \DateTimeImmutable
    {
        return $this->createdAt;
    }
    
    public function getLastLoginAt(): ?\DateTimeImmutable
    {
        return $this->lastLoginAt;
    }
    
    // UserInterface methods
    public function getUserIdentifier(): string
    {
        return $this->email->getValue();
    }
    
    public function getRoles(): array
    {
        $roles = $this->roles;
        // guarantee every user at least has ROLE_USER
        $roles[] = 'ROLE_USER';
        
        return array_unique($roles);
    }
    
    public function eraseCredentials(): void
    {
        // If you store any temporary, sensitive data on the user, clear it here
    }
    
    // PasswordAuthenticatedUserInterface
    public function getPassword(): string
    {
        return $this->password->getHashed();
    }
    
    // Domain Events
    private function raise(object $event): void
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