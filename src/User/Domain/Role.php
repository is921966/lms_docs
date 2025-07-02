<?php

declare(strict_types=1);

namespace User\Domain;

use Doctrine\Common\Collections\ArrayCollection;
use Doctrine\Common\Collections\Collection;

/**
 * Role entity
 */
class Role
{
    private int $id;
    private string $name;
    private string $displayName;
    private ?string $description;
    private Collection $permissions;
    private bool $isSystem;
    private int $priority = 100;
    private \DateTimeImmutable $createdAt;
    private \DateTimeImmutable $updatedAt;
    
    /**
     * System roles that cannot be deleted
     */
    public const ROLE_ADMIN = 'admin';
    public const ROLE_MANAGER = 'manager';
    public const ROLE_EMPLOYEE = 'employee';
    public const ROLE_INSTRUCTOR = 'instructor';
    public const ROLE_HR = 'hr';
    
    private function __construct(
        string $name,
        string $displayName,
        ?string $description = null,
        bool $isSystem = false
    ) {
        $this->id = 0; // Will be set by ORM
        $this->name = $name;
        $this->displayName = $displayName;
        $this->description = $description;
        $this->isSystem = $isSystem;
        $this->permissions = new ArrayCollection();
        $this->createdAt = new \DateTimeImmutable();
        $this->updatedAt = new \DateTimeImmutable();
    }
    
    /**
     * Create new role
     */
    public static function create(
        string $name,
        string $displayName,
        ?string $description = null
    ): self {
        self::validateName($name);
        
        return new self($name, $displayName, $description, false);
    }
    
    /**
     * Create system role
     */
    public static function createSystem(
        string $name,
        string $displayName,
        ?string $description = null
    ): self {
        return new self($name, $displayName, $description, true);
    }
    
    /**
     * Update role details
     */
    public function update(string $displayName, ?string $description = null): void
    {
        if ($this->isSystem) {
            throw new \DomainException('Cannot update system role');
        }
        
        $this->displayName = $displayName;
        $this->description = $description;
        $this->updatedAt = new \DateTimeImmutable();
    }
    
    /**
     * Assign permission to role
     */
    public function assignPermission(Permission $permission): void
    {
        if ($this->permissions->contains($permission)) {
            return;
        }
        
        $this->permissions->add($permission);
        $this->updatedAt = new \DateTimeImmutable();
    }
    
    /**
     * Remove permission from role
     */
    public function removePermission(Permission $permission): void
    {
        if ($this->isSystem) {
            throw new \DomainException('Cannot modify permissions of system role');
        }
        
        $this->permissions->removeElement($permission);
        $this->updatedAt = new \DateTimeImmutable();
    }
    
    /**
     * Check if role has permission
     */
    public function hasPermission(string $permissionName): bool
    {
        return $this->permissions->exists(
            fn($key, Permission $permission) => $permission->getName() === $permissionName
        );
    }
    
    /**
     * Sync permissions
     */
    public function syncPermissions(array $permissions): void
    {
        if ($this->isSystem) {
            throw new \DomainException('Cannot modify permissions of system role');
        }
        
        $this->permissions->clear();
        
        foreach ($permissions as $permission) {
            $this->permissions->add($permission);
        }
        
        $this->updatedAt = new \DateTimeImmutable();
    }
    
    /**
     * Check if role can be deleted
     */
    public function canBeDeleted(): bool
    {
        return !$this->isSystem;
    }
    
    /**
     * Validate role name
     */
    private static function validateName(string $name): void
    {
        if (!preg_match('/^[a-z0-9_]+$/', $name)) {
            throw new \InvalidArgumentException(
                'Role name must contain only lowercase letters, numbers and underscores'
            );
        }
        
        if (strlen($name) < 3 || strlen($name) > 50) {
            throw new \InvalidArgumentException(
                'Role name must be between 3 and 50 characters'
            );
        }
    }
    
    /**
     * Get priority
     */
    public function getPriority(): int
    {
        return $this->priority;
    }
    
    /**
     * Check if role has higher priority than another
     */
    public function hasHigherPriorityThan(Role $other): bool
    {
        return $this->priority < $other->priority;
    }
    
    /**
     * Get permission names
     */
    public function getPermissionNames(): array
    {
        return $this->permissions->map(
            fn(Permission $permission) => $permission->getName()
        )->toArray();
    }
    
    /**
     * Get permission IDs
     */
    public function getPermissionIds(): array
    {
        return $this->permissions->map(
            fn(Permission $permission) => $permission->getId()
        )->toArray();
    }
    
    /**
     * Clone role with new name
     */
    public function clone(string $newName, string $newDisplayName): self
    {
        $clone = self::create($newName, $newDisplayName, $this->description);
        
        foreach ($this->permissions as $permission) {
            $clone->assignPermission($permission);
        }
        
        return $clone;
    }
    
    /**
     * Convert to array
     */
    public function toArray(): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'description' => $this->displayName,
            'is_system' => $this->isSystem,
            'priority' => $this->priority,
            'permissions_count' => $this->permissions->count(),
            'created_at' => $this->createdAt->format('c'),
            'updated_at' => $this->updatedAt->format('c'),
        ];
    }
    
    // Getters
    
    public function getId(): int
    {
        return $this->id;
    }
    
    public function getName(): string
    {
        return $this->name;
    }
    
    public function getDisplayName(): string
    {
        return $this->displayName;
    }
    
    public function getDescription(): ?string
    {
        return $this->description;
    }
    
    public function getPermissions(): Collection
    {
        return $this->permissions;
    }
    
    public function isSystem(): bool
    {
        return $this->isSystem;
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