<?php

declare(strict_types=1);

namespace ApiGateway\Domain\ValueObjects;

final class RateLimitKey
{
    private string $identifier;
    private string $type;
    
    private function __construct(string $identifier, string $type)
    {
        if (empty($identifier)) {
            throw new \InvalidArgumentException('Rate limit identifier cannot be empty');
        }
        
        if (!in_array($type, ['user', 'ip', 'api_key', 'global'], true)) {
            throw new \InvalidArgumentException('Invalid rate limit type: ' . $type);
        }
        
        $this->identifier = $identifier;
        $this->type = $type;
    }
    
    public static function forUser(string $userId): self
    {
        return new self($userId, 'user');
    }
    
    public static function forIp(string $ipAddress): self
    {
        return new self($ipAddress, 'ip');
    }
    
    public static function forApiKey(string $apiKey): self
    {
        return new self($apiKey, 'api_key');
    }
    
    public static function global(): self
    {
        return new self('global', 'global');
    }
    
    public function getIdentifier(): string
    {
        return $this->identifier;
    }
    
    public function getType(): string
    {
        return $this->type;
    }
    
    public function getCacheKey(): string
    {
        return sprintf('rate_limit:%s:%s', $this->type, $this->identifier);
    }
    
    public function equals(self $other): bool
    {
        return $this->identifier === $other->identifier && $this->type === $other->type;
    }
} 