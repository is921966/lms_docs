<?php

namespace Auth\Domain\ValueObjects;

class TokenPayload
{
    private string $userId;
    private ?string $email;
    private array $roles;
    private int $issuedAt;
    private int $expiresAt;
    private string $issuer;
    private string $type;

    public function __construct(
        string $userId,
        ?string $email,
        array $roles,
        int $issuedAt,
        int $expiresAt,
        string $issuer,
        string $type = 'access'
    ) {
        $this->userId = $userId;
        $this->email = $email;
        $this->roles = $roles;
        $this->issuedAt = $issuedAt;
        $this->expiresAt = $expiresAt;
        $this->issuer = $issuer;
        $this->type = $type;
    }

    public function getUserId(): string
    {
        return $this->userId;
    }

    public function getEmail(): ?string
    {
        return $this->email;
    }

    public function getRoles(): array
    {
        return $this->roles;
    }

    public function hasRole(string $role): bool
    {
        return in_array($role, $this->roles);
    }

    public function getIssuedAt(): int
    {
        return $this->issuedAt;
    }

    public function getExpiresAt(): int
    {
        return $this->expiresAt;
    }

    public function getIssuer(): string
    {
        return $this->issuer;
    }

    public function getType(): string
    {
        return $this->type;
    }

    public function isExpired(): bool
    {
        return time() >= $this->expiresAt;
    }

    public function isAccessToken(): bool
    {
        return $this->type === 'access';
    }

    public function isRefreshToken(): bool
    {
        return $this->type === 'refresh';
    }

    public function toArray(): array
    {
        return [
            'userId' => $this->userId,
            'email' => $this->email,
            'roles' => $this->roles,
            'issuedAt' => $this->issuedAt,
            'expiresAt' => $this->expiresAt,
            'issuer' => $this->issuer,
            'type' => $this->type
        ];
    }
} 