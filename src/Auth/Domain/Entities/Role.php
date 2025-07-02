<?php

namespace Auth\Domain\Entities;

use Auth\Domain\ValueObjects\RoleId;
use Auth\Domain\ValueObjects\Permission;

class Role
{
    private RoleId $id;
    private string $name;
    private string $description;
    private array $permissions = [];

    private function __construct(
        RoleId $id,
        string $name,
        string $description
    ) {
        $this->id = $id;
        $this->name = $name;
        $this->description = $description;
    }

    public static function create(string $name, string $description): self
    {
        return new self(
            RoleId::generate(),
            $name,
            $description
        );
    }

    public static function createWithId(
        RoleId $id,
        string $name,
        string $description
    ): self {
        return new self($id, $name, $description);
    }

    public function getId(): RoleId
    {
        return $this->id;
    }

    public function getName(): string
    {
        return $this->name;
    }

    public function getDescription(): string
    {
        return $this->description;
    }

    public function updateDescription(string $description): void
    {
        $this->description = $description;
    }

    public function addPermission(Permission $permission): void
    {
        $key = $permission->getName();
        if (!isset($this->permissions[$key])) {
            $this->permissions[$key] = $permission;
        }
    }

    public function removePermission(string $permissionName): void
    {
        unset($this->permissions[$permissionName]);
    }

    public function hasPermission(string $permissionName): bool
    {
        return isset($this->permissions[$permissionName]);
    }

    public function getPermissions(): array
    {
        return array_values($this->permissions);
    }

    public function getPermissionNames(): array
    {
        return array_keys($this->permissions);
    }

    public function clearPermissions(): void
    {
        $this->permissions = [];
    }

    public function equals(Role $other): bool
    {
        return $this->id->equals($other->id);
    }
} 