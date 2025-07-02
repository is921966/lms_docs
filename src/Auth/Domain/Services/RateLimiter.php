<?php

namespace Auth\Domain\Services;

use Auth\Domain\ValueObjects\RateLimitKey;
use Auth\Domain\Exceptions\RateLimitExceededException;

class RateLimiter
{
    private array $storage = [];
    private array $config;

    public function __construct(array $config = [])
    {
        $this->config = array_merge([
            'throw_exception' => false
        ], $config);
    }

    public function allowRequest(RateLimitKey $key, int $limit, int $window): bool
    {
        $keyString = $key->getKey();
        $now = time();

        // Clean expired entries
        $this->cleanExpired($keyString, $now - $window);

        // Initialize if not exists
        if (!isset($this->storage[$keyString])) {
            $this->storage[$keyString] = [];
        }

        // Count requests in window
        $count = count($this->storage[$keyString]);

        // Check limit
        if ($count >= $limit) {
            if ($this->config['throw_exception']) {
                $resetTime = $this->getResetTime($key);
                throw RateLimitExceededException::withDetails($resetTime - $now, $limit);
            }
            return false;
        }

        // Record request
        $this->storage[$keyString][] = $now;

        return true;
    }

    public function getRemainingAttempts(RateLimitKey $key, int $limit, int $window): int
    {
        $keyString = $key->getKey();
        $now = time();

        // Clean expired entries
        $this->cleanExpired($keyString, $now - $window);

        // Count current requests
        $count = isset($this->storage[$keyString]) ? count($this->storage[$keyString]) : 0;

        return max(0, $limit - $count);
    }

    public function getResetTime(RateLimitKey $key): int
    {
        $keyString = $key->getKey();

        if (!isset($this->storage[$keyString]) || empty($this->storage[$keyString])) {
            return time();
        }

        // Get oldest request time
        $oldest = min($this->storage[$keyString]);

        // Reset time is when oldest request expires
        return $oldest + 60; // Assuming 60 second window
    }

    public function clear(RateLimitKey $key): void
    {
        $keyString = $key->getKey();
        unset($this->storage[$keyString]);
    }

    public function clearAll(): void
    {
        $this->storage = [];
    }

    private function cleanExpired(string $key, int $threshold): void
    {
        if (!isset($this->storage[$key])) {
            return;
        }

        // Remove timestamps older than threshold
        $this->storage[$key] = array_filter(
            $this->storage[$key],
            fn($timestamp) => $timestamp > $threshold
        );

        // Remove empty keys
        if (empty($this->storage[$key])) {
            unset($this->storage[$key]);
        }
    }
} 