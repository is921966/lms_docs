<?php

declare(strict_types=1);

namespace ApiGateway\Domain\Services;

use ApiGateway\Domain\ValueObjects\RateLimitKey;
use ApiGateway\Domain\ValueObjects\RateLimitResult;

interface RateLimiterInterface
{
    /**
     * Check if request is allowed and consume one token
     */
    public function consume(RateLimitKey $key): RateLimitResult;
    
    /**
     * Get current limit status without consuming
     */
    public function check(RateLimitKey $key): RateLimitResult;
    
    /**
     * Reset rate limit for a key
     */
    public function reset(RateLimitKey $key): void;
    
    /**
     * Set custom limit for a specific key
     */
    public function setLimit(RateLimitKey $key, int $limit, int $windowSeconds): void;
} 