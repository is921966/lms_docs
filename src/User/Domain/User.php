<?php

declare(strict_types=1);

namespace User\Domain;

use User\Domain\Events\UserCreated;
use User\Domain\Events\UserUpdated;
use User\Domain\Events\UserLoggedIn;
use User\Domain\ValueObjects\Email;
use User\Domain\ValueObjects\Password;
use User\Domain\ValueObjects\UserId;
use User\Domain\Traits\UserAuthenticationTrait;
use User\Domain\Traits\UserProfileTrait;
use User\Domain\Traits\UserRoleManagementTrait;
use User\Domain\Traits\UserStatusManagementTrait;
use Doctrine\Common\Collections\ArrayCollection;
use Doctrine\Common\Collections\Collection;

/**
 * User domain entity
 */
class User
{
    use UserAuthenticationTrait;
    use UserProfileTrait;
    use UserRoleManagementTrait;
    use UserStatusManagementTrait;
    
    // Status constants
    public const STATUS_ACTIVE = 'active';
    public const STATUS_INACTIVE = 'inactive';
    public const STATUS_SUSPENDED = 'suspended';
    
    // Core properties
    private UserId $id;
    private Email $email;
    private ?Password $password;
    private string $firstName;
    private string $lastName;
    private ?string $middleName = null;
    private ?string $phone = null;
    private ?string $department = null;
    private ?string $displayName = null;
    private ?string $positionTitle = null;
    private ?string $positionId = null;
    private ?UserId $managerId = null;
    private ?string $adUsername = null;
    
    // Status properties
    private string $status = self::STATUS_ACTIVE;
    private bool $isAdmin = false;
    private bool $isDeleted = false;
    private bool $isActive = true;
    private ?\DateTimeImmutable $deletedAt = null;
    private ?string $suspensionReason = null;
    private ?\DateTimeImmutable $suspendedUntil = null;
    
    // Authentication properties
    private ?\DateTimeImmutable $emailVerifiedAt = null;
    private ?\DateTimeImmutable $passwordChangedAt = null;
    private ?\DateTimeImmutable $lastLoginAt = null;
    private ?string $lastLoginIp = null;
    private ?string $lastUserAgent = null;
    private int $loginCount = 0;
    private bool $twoFactorEnabled = false;
    private ?string $twoFactorSecret = null;
    
    // LDAP properties
    private ?\DateTimeImmutable $ldapSyncedAt = null;
    
    // Collections
    private Collection $roles;
    private array $permissions = [];
    private array $metadata = [];
    
    // Domain events
    private array $domainEvents = [];
    
    // Timestamps
    private \DateTimeImmutable $createdAt;
    private \DateTimeImmutable $updatedAt;
    
    /**
     * Private constructor - use factory methods
     */
    private function __construct(
        UserId $id,
        Email $email,
        string $firstName,
        string $lastName,
        ?Password $password = null,
        ?string $adUsername = null
    ) {
        $this->id = $id;
        $this->email = $email;
        $this->firstName = $firstName;
        $this->lastName = $lastName;
        $this->password = $password;
        $this->adUsername = $adUsername;
        $this->roles = new ArrayCollection();
        $this->createdAt = new \DateTimeImmutable();
        $this->updatedAt = new \DateTimeImmutable();
        
        if ($password) {
            $this->passwordChangedAt = new \DateTimeImmutable();
        }
        
        $this->recordEvent(new UserCreated($this->id, $this->email, $this->firstName, $this->lastName));
    }
    
    /**
     * Create new user
     */
    public static function create(
        Email $email,
        string $firstName,
        string $lastName,
        ?Password $password = null,
        ?string $adUsername = null
    ): self {
        return new self(
            UserId::generate(),
            $email,
            $firstName,
            $lastName,
            $password,
            $adUsername
        );
    }
    
    /**
     * Create user from LDAP data
     */
    public static function createFromLdap(array $ldapData): self
    {
        $user = self::create(
            new Email($ldapData['mail']),
            $ldapData['givenName'],
            $ldapData['sn'],
            null,
            $ldapData['sAMAccountName']
        );
        
        $user->updateFromLdap($ldapData);
        
        return $user;
    }
    
    /**
     * Record domain event
     */
    private function recordEvent(object $event): void
    {
        $this->domainEvents[] = $event;
    }
    
    /**
     * Get and clear domain events
     */
    public function pullDomainEvents(): array
    {
        $events = $this->domainEvents;
        $this->domainEvents = [];
        
        return $events;
    }
    
    // Core getters
    
    public function getId(): UserId
    {
        return $this->id;
    }
    
    public function getCreatedAt(): \DateTimeImmutable
    {
        return $this->createdAt;
    }
    
    public function getUpdatedAt(): \DateTimeImmutable
    {
        return $this->updatedAt;
    }

    public function getEmail(): string
    {
        return $this->email->getValue();
    }

    public function getRole(): string
    {
        return $this->roles->first() ? $this->roles->first()->getName() : '';
    }

    public function getStatus(): string
    {
        return $this->status;
    }
    
    public function isAdmin(): bool
    {
        return $this->isAdmin;
    }
    
    public function setAdminStatus(bool $isAdmin): void
    {
        $this->isAdmin = $isAdmin;
        $this->updatedAt = new \DateTimeImmutable();
    }

    public function verifyPassword(string $password): bool
    {
        return $this->password->verify($password);
    }

    public function isActive(): bool
    {
        return $this->isActive && !$this->isDeleted;
    }

    public function activate(): void
    {
        $this->isActive = true;
    }

    public function deactivate(): void
    {
        $this->isActive = false;
    }

    public function updateLastLogin(): void
    {
        $this->lastLoginAt = new \DateTimeImmutable();
    }

    public function getLastLoginAt(): ?\DateTimeImmutable
    {
        return $this->lastLoginAt;
    }

    public function getRoles(): array
    {
        $roles = ['user'];
        if ($this->isAdmin) {
            $roles[] = 'admin';
        }
        return $roles;
    }
} 