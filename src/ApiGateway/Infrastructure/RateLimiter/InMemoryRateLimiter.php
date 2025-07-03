<?php

declare(strict_types=1);

namespace ApiGateway\Infrastructure\RateLimiter;

use ApiGateway\Domain\Services\RateLimiterInterface;
use ApiGateway\Domain\ValueObjects\RateLimitKey;
use ApiGateway\Domain\ValueObjects\RateLimitResult;

class InMemoryRateLimiter implements RateLimiterInterface
{
    private array $buckets = [];
    private array $limits = [];
    private int $defaultLimit;
    private int $defaultWindowSeconds;
    
    public function __construct(int $defaultLimit = 100, int $defaultWindowSeconds = 60)
    {
        $this->defaultLimit = $defaultLimit;
        $this->defaultWindowSeconds = $defaultWindowSeconds;
    }
    
    public function consume(RateLimitKey $key): RateLimitResult
    {
        $cacheKey = $key->getCacheKey();
        $now = time();
        
        // Get or create bucket
        if (!isset($this->buckets[$cacheKey])) {
            $this->buckets[$cacheKey] = [
                'tokens' => $this->getLimit($key),
                'reset_at' => $now + $this->getWindowSeconds($key)
            ];
        }
        
        $bucket = &$this->buckets[$cacheKey];
        
        // Check if window has expired
        if ($now >= $bucket['reset_at']) {
            $bucket['tokens'] = $this->getLimit($key);
            $bucket['reset_at'] = $now + $this->getWindowSeconds($key);
        }
        
        // Check if tokens available
        if ($bucket['tokens'] > 0) {
            $bucket['tokens']--;
            return RateLimitResult::allow(
                $this->getLimit($key),
                $bucket['tokens'],
                new \DateTimeImmutable('@' . $bucket['reset_at'])
            );
        }
        
        // Rate limit exceeded
        return RateLimitResult::deny(
            $this->getLimit($key),
            new \DateTimeImmutable('@' . $bucket['reset_at'])
        );
    }
    
    public function check(RateLimitKey $key): RateLimitResult
    {
        $cacheKey = $key->getCacheKey();
        $now = time();
        
        // Get or create bucket without consuming
        if (!isset($this->buckets[$cacheKey])) {
            return RateLimitResult::allow(
                $this->getLimit($key),
                $this->getLimit($key),
                new \DateTimeImmutable('@' . ($now + $this->getWindowSeconds($key)))
            );
        }
        
        $bucket = $this->buckets[$cacheKey];
        
        // Check if window has expired
        if ($now >= $bucket['reset_at']) {
            return RateLimitResult::allow(
                $this->getLimit($key),
                $this->getLimit($key),
                new \DateTimeImmutable('@' . ($now + $this->getWindowSeconds($key)))
            );
        }
        
        // Return current state
        if ($bucket['tokens'] > 0) {
            return RateLimitResult::allow(
                $this->getLimit($key),
                $bucket['tokens'],
                new \DateTimeImmutable('@' . $bucket['reset_at'])
            );
        }
        
        return RateLimitResult::deny(
            $this->getLimit($key),
            new \DateTimeImmutable('@' . $bucket['reset_at'])
        );
    }
    
    public function reset(RateLimitKey $key): void
    {
        $cacheKey = $key->getCacheKey();
        unset($this->buckets[$cacheKey]);
    }
    
    public function setLimit(RateLimitKey $key, int $limit, int $windowSeconds): void
    {
        $cacheKey = $key->getCacheKey();
        $this->limits[$cacheKey] = [
            'limit' => $limit,
            'window' => $windowSeconds
        ];
    }
    
    private function getLimit(RateLimitKey $key): int
    {
        $cacheKey = $key->getCacheKey();
        return $this->limits[$cacheKey]['limit'] ?? $this->defaultLimit;
    }
    
    private function getWindowSeconds(RateLimitKey $key): int
    {
        $cacheKey = $key->getCacheKey();
        return $this->limits[$cacheKey]['window'] ?? $this->defaultWindowSeconds;
    }
} 