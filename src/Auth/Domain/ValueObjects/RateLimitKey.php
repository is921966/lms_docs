<?php

namespace Auth\Domain\ValueObjects;

final class RateLimitKey
{
    private string $identifier;
    private string $context;

    public function __construct(string $identifier, string $context = '')
    {
        if (empty($identifier)) {
            throw new \InvalidArgumentException('Rate limit identifier cannot be empty');
        }

        $this->identifier = $identifier;
        $this->context = $context;
    }

    public function getIdentifier(): string
    {
        return $this->identifier;
    }

    public function getContext(): string
    {
        return $this->context;
    }

    public function getKey(): string
    {
        if (empty($this->context)) {
            return $this->identifier;
        }
        
        return sprintf('%s:%s', $this->identifier, $this->context);
    }

    public function equals(RateLimitKey $other): bool
    {
        return $this->getKey() === $other->getKey();
    }

    public function __toString(): string
    {
        return $this->getKey();
    }
} 