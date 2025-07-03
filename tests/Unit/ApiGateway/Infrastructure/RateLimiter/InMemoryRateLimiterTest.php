<?php

declare(strict_types=1);

namespace Tests\Unit\ApiGateway\Infrastructure\RateLimiter;

use PHPUnit\Framework\TestCase;
use ApiGateway\Infrastructure\RateLimiter\InMemoryRateLimiter;
use ApiGateway\Domain\ValueObjects\RateLimitKey;

class InMemoryRateLimiterTest extends TestCase
{
    private InMemoryRateLimiter $rateLimiter;
    
    protected function setUp(): void
    {
        $this->rateLimiter = new InMemoryRateLimiter(10, 60); // 10 requests per minute
    }
    
    public function testConsumeAllowsRequestsWithinLimit(): void
    {
        $key = RateLimitKey::forUser('user-123');
        
        // First 10 requests should be allowed
        for ($i = 0; $i < 10; $i++) {
            $result = $this->rateLimiter->consume($key);
            $this->assertTrue($result->isAllowed());
            $this->assertEquals(10, $result->getLimit());
            $this->assertEquals(9 - $i, $result->getRemaining());
        }
    }
    
    public function testConsumeDeniesRequestsOverLimit(): void
    {
        $key = RateLimitKey::forUser('user-123');
        
        // Consume all tokens
        for ($i = 0; $i < 10; $i++) {
            $this->rateLimiter->consume($key);
        }
        
        // 11th request should be denied
        $result = $this->rateLimiter->consume($key);
        $this->assertTrue($result->isDenied());
        $this->assertEquals(0, $result->getRemaining());
        $this->assertEquals('Rate limit exceeded', $result->getReason());
    }
    
    public function testCheckDoesNotConsumeTokens(): void
    {
        $key = RateLimitKey::forUser('user-123');
        
        // Check multiple times
        for ($i = 0; $i < 5; $i++) {
            $result = $this->rateLimiter->check($key);
            $this->assertTrue($result->isAllowed());
            $this->assertEquals(10, $result->getRemaining());
        }
        
        // Consume one token
        $this->rateLimiter->consume($key);
        
        // Check should show 9 remaining
        $result = $this->rateLimiter->check($key);
        $this->assertEquals(9, $result->getRemaining());
    }
    
    public function testResetClearsTokenBucket(): void
    {
        $key = RateLimitKey::forUser('user-123');
        
        // Consume all tokens
        for ($i = 0; $i < 10; $i++) {
            $this->rateLimiter->consume($key);
        }
        
        // Should be denied
        $result = $this->rateLimiter->consume($key);
        $this->assertTrue($result->isDenied());
        
        // Reset the bucket
        $this->rateLimiter->reset($key);
        
        // Should be allowed again
        $result = $this->rateLimiter->consume($key);
        $this->assertTrue($result->isAllowed());
        $this->assertEquals(9, $result->getRemaining());
    }
    
    public function testSetLimitAppliesCustomLimit(): void
    {
        $key = RateLimitKey::forUser('user-123');
        
        // Set custom limit of 5 requests per 30 seconds
        $this->rateLimiter->setLimit($key, 5, 30);
        
        // Should allow 5 requests
        for ($i = 0; $i < 5; $i++) {
            $result = $this->rateLimiter->consume($key);
            $this->assertTrue($result->isAllowed());
            $this->assertEquals(5, $result->getLimit());
        }
        
        // 6th request should be denied
        $result = $this->rateLimiter->consume($key);
        $this->assertTrue($result->isDenied());
    }
    
    public function testDifferentKeysHaveSeparateBuckets(): void
    {
        $userKey = RateLimitKey::forUser('user-123');
        $ipKey = RateLimitKey::forIp('192.168.1.1');
        
        // Consume all tokens for user
        for ($i = 0; $i < 10; $i++) {
            $this->rateLimiter->consume($userKey);
        }
        
        // IP should still have all tokens
        $result = $this->rateLimiter->consume($ipKey);
        $this->assertTrue($result->isAllowed());
        $this->assertEquals(9, $result->getRemaining());
    }
    
    public function testResetsAtTimeIsCorrect(): void
    {
        $key = RateLimitKey::forUser('user-123');
        
        $result = $this->rateLimiter->check($key);
        
        // Reset time should be approximately 60 seconds in the future
        $resetsIn = $result->getResetsIn();
        $this->assertGreaterThan(55, $resetsIn);
        $this->assertLessThanOrEqual(60, $resetsIn);
    }
} 