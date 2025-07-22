<?php

namespace App\Infrastructure\Cache;

use Predis\Client;

class RedisTokenCache
{
    private Client $redis;
    private int $defaultTtl;
    
    public function __construct(string $redisUrl, int $defaultTtl = 3600)
    {
        $this->redis = new Client($redisUrl);
        $this->defaultTtl = $defaultTtl;
    }
    
    public function setUserSession(string $userId, array $sessionData, ?int $ttl = null): void
    {
        $key = $this->getUserSessionKey($userId);
        $this->redis->setex(
            $key,
            $ttl ?? $this->defaultTtl,
            json_encode($sessionData)
        );
    }
    
    public function getUserSession(string $userId): ?array
    {
        $key = $this->getUserSessionKey($userId);
        $data = $this->redis->get($key);
        
        return $data ? json_decode($data, true) : null;
    }
    
    public function invalidateUserSession(string $userId): void
    {
        $key = $this->getUserSessionKey($userId);
        $this->redis->del([$key]);
    }
    
    public function blacklistToken(string $token, \DateTimeInterface $expiresAt): void
    {
        $key = $this->getBlacklistKey($token);
        $ttl = $expiresAt->getTimestamp() - time();
        
        if ($ttl > 0) {
            $this->redis->setex($key, $ttl, '1');
        }
    }
    
    public function isTokenBlacklisted(string $token): bool
    {
        $key = $this->getBlacklistKey($token);
        return $this->redis->exists($key) === 1;
    }
    
    public function setRefreshToken(string $token, string $userId, int $ttl = 2592000): void
    {
        $key = $this->getRefreshTokenKey($token);
        $this->redis->setex($key, $ttl, $userId);
    }
    
    public function getRefreshTokenUserId(string $token): ?string
    {
        $key = $this->getRefreshTokenKey($token);
        return $this->redis->get($key);
    }
    
    public function invalidateRefreshToken(string $token): void
    {
        $key = $this->getRefreshTokenKey($token);
        $this->redis->del([$key]);
    }
    
    public function incrementLoginAttempts(string $identifier): int
    {
        $key = $this->getLoginAttemptsKey($identifier);
        $attempts = $this->redis->incr($key);
        
        if ($attempts === 1) {
            $this->redis->expire($key, 900); // 15 minutes
        }
        
        return $attempts;
    }
    
    public function getLoginAttempts(string $identifier): int
    {
        $key = $this->getLoginAttemptsKey($identifier);
        return (int) $this->redis->get($key);
    }
    
    public function resetLoginAttempts(string $identifier): void
    {
        $key = $this->getLoginAttemptsKey($identifier);
        $this->redis->del([$key]);
    }
    
    private function getUserSessionKey(string $userId): string
    {
        return sprintf('auth:session:%s', $userId);
    }
    
    private function getBlacklistKey(string $token): string
    {
        return sprintf('auth:blacklist:%s', hash('sha256', $token));
    }
    
    private function getRefreshTokenKey(string $token): string
    {
        return sprintf('auth:refresh:%s', hash('sha256', $token));
    }
    
    private function getLoginAttemptsKey(string $identifier): string
    {
        return sprintf('auth:attempts:%s', hash('sha256', $identifier));
    }
} 