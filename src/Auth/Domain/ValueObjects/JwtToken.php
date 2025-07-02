<?php

namespace Auth\Domain\ValueObjects;

class JwtToken
{
    private string $value;
    private TokenPayload $payload;

    public function __construct(string $value, TokenPayload $payload)
    {
        $this->value = $value;
        $this->payload = $payload;
    }

    public function getValue(): string
    {
        return $this->value;
    }

    public function getPayload(): TokenPayload
    {
        return $this->payload;
    }

    public function getExpiresAt(): int
    {
        return $this->payload->getExpiresAt();
    }

    public function isExpired(): bool
    {
        return $this->payload->isExpired();
    }

    public function getType(): string
    {
        return $this->payload->getType();
    }

    public function getTimeToLive(): int
    {
        return max(0, $this->payload->getExpiresAt() - time());
    }

    public function __toString(): string
    {
        return $this->value;
    }
} 