<?php

declare(strict_types=1);

namespace App\User\Domain;

use App\User\Domain\Events\UserCreated;
use App\User\Domain\Events\UserUpdated;
use App\User\Domain\Events\UserLoggedIn;
use App\User\Domain\ValueObjects\Email;
use App\User\Domain\ValueObjects\Password;
use App\User\Domain\ValueObjects\UserId;
use App\User\Domain\Traits\UserAuthenticationTrait;
use App\User\Domain\Traits\UserProfileTrait;
use App\User\Domain\Traits\UserRoleManagementTrait;
use App\User\Domain\Traits\UserStatusManagementTrait;
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
} 