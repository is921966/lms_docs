<?php

namespace Auth\Domain\ValueObjects;

final class Permission
{
    private string $name;
    private string $description;

    public function __construct(string $name, string $description = '')
    {
        if (empty($name)) {
            throw new \InvalidArgumentException('Permission name cannot be empty');
        }

        // Validate format: resource.action
        if (!preg_match('/^[a-z]+(\.[a-z]+)*$/', $name)) {
            throw new \InvalidArgumentException(
                'Permission name must be in format: resource.action (lowercase, dot-separated)'
            );
        }

        $this->name = $name;
        $this->description = $description;
    }

    public function getName(): string
    {
        return $this->name;
    }

    public function getDescription(): string
    {
        return $this->description;
    }

    public function getResource(): string
    {
        $parts = explode('.', $this->name);
        return $parts[0];
    }

    public function getAction(): string
    {
        $parts = explode('.', $this->name);
        return $parts[count($parts) - 1];
    }

    public function equals(Permission $other): bool
    {
        return $this->name === $other->name;
    }

    public function __toString(): string
    {
        return $this->name;
    }
} 