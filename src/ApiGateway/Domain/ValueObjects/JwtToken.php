<?php

declare(strict_types=1);

namespace ApiGateway\Domain\ValueObjects;

final class JwtToken
{
    private string $accessToken;
    private string $refreshToken;
    private int $expiresIn;
    private \DateTimeImmutable $issuedAt;
    
    public function __construct(
        string $accessToken,
        string $refreshToken,
        int $expiresIn,
        ?\DateTimeImmutable $issuedAt = null
    ) {
        if (empty($accessToken)) {
            throw new \InvalidArgumentException('Access token cannot be empty');
        }
        
        if (empty($refreshToken)) {
            throw new \InvalidArgumentException('Refresh token cannot be empty');
        }
        
        if ($expiresIn <= 0) {
            throw new \InvalidArgumentException('Expiration time must be positive');
        }
        
        $this->accessToken = $accessToken;
        $this->refreshToken = $refreshToken;
        $this->expiresIn = $expiresIn;
        $this->issuedAt = $issuedAt ?? new \DateTimeImmutable();
    }
    
    public function getAccessToken(): string
    {
        return $this->accessToken;
    }
    
    public function getRefreshToken(): string
    {
        return $this->refreshToken;
    }
    
    public function getExpiresIn(): int
    {
        return $this->expiresIn;
    }
    
    public function getExpiresAt(): \DateTimeImmutable
    {
        return $this->issuedAt->modify("+{$this->expiresIn} seconds");
    }
    
    public function isExpired(): bool
    {
        return $this->getExpiresAt() < new \DateTimeImmutable();
    }
    
    public function toArray(): array
    {
        return [
            'access_token' => $this->accessToken,
            'refresh_token' => $this->refreshToken,
            'token_type' => 'Bearer',
            'expires_in' => $this->expiresIn,
            'expires_at' => $this->getExpiresAt()->format(\DateTimeInterface::ATOM),
        ];
    }
} 