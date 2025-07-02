<?php

namespace Tests\Unit\Auth\Domain\Services;

use PHPUnit\Framework\TestCase;
use Auth\Domain\Services\RateLimiter;
use Auth\Domain\ValueObjects\RateLimitKey;
use Auth\Domain\Exceptions\RateLimitExceededException;

class RateLimiterTest extends TestCase
{
    private RateLimiter $rateLimiter;

    protected function setUp(): void
    {
        $this->rateLimiter = new RateLimiter();
    }

    public function testAllowsRequestWithinLimit()
    {
        // Arrange
        $key = new RateLimitKey('user', '127.0.0.1');
        $limit = 10;
        $window = 60; // 1 minute

        // Act & Assert
        for ($i = 0; $i < $limit; $i++) {
            $this->assertTrue($this->rateLimiter->allowRequest($key, $limit, $window));
        }
    }

    public function testBlocksRequestOverLimit()
    {
        // Arrange
        $key = new RateLimitKey('user', '127.0.0.1');
        $limit = 5;
        $window = 60;

        // Use up the limit
        for ($i = 0; $i < $limit; $i++) {
            $this->rateLimiter->allowRequest($key, $limit, $window);
        }

        // Act & Assert
        $this->assertFalse($this->rateLimiter->allowRequest($key, $limit, $window));
    }

    public function testResetsAfterWindow()
    {
        // Arrange
        $key = new RateLimitKey('user', '127.0.0.1');
        $limit = 2;
        $window = 1; // 1 second window

        // Use up the limit
        for ($i = 0; $i < $limit; $i++) {
            $this->rateLimiter->allowRequest($key, $limit, $window);
        }
        
        // Assert limit reached
        $this->assertFalse($this->rateLimiter->allowRequest($key, $limit, $window));

        // Wait for window to expire
        sleep(2);

        // Act & Assert - should allow again
        $this->assertTrue($this->rateLimiter->allowRequest($key, $limit, $window));
    }

    public function testGetRemainingAttempts()
    {
        // Arrange
        $key = new RateLimitKey('user', '127.0.0.1');
        $limit = 10;
        $window = 60;

        // Act
        $this->assertEquals($limit, $this->rateLimiter->getRemainingAttempts($key, $limit, $window));
        
        $this->rateLimiter->allowRequest($key, $limit, $window);
        $this->assertEquals($limit - 1, $this->rateLimiter->getRemainingAttempts($key, $limit, $window));
        
        $this->rateLimiter->allowRequest($key, $limit, $window);
        $this->assertEquals($limit - 2, $this->rateLimiter->getRemainingAttempts($key, $limit, $window));
    }

    public function testGetResetTime()
    {
        // Arrange
        $key = new RateLimitKey('user', '127.0.0.1');
        $limit = 10;
        $window = 60;

        // Act
        $this->rateLimiter->allowRequest($key, $limit, $window);
        $resetTime = $this->rateLimiter->getResetTime($key);

        // Assert
        $this->assertGreaterThan(time(), $resetTime);
        $this->assertLessThanOrEqual(time() + $window, $resetTime);
    }

    public function testDifferentKeysHaveSeparateLimits()
    {
        // Arrange
        $key1 = new RateLimitKey('user1', '127.0.0.1');
        $key2 = new RateLimitKey('user2', '127.0.0.1');
        $limit = 2;
        $window = 60;

        // Use up limit for key1
        for ($i = 0; $i < $limit; $i++) {
            $this->rateLimiter->allowRequest($key1, $limit, $window);
        }

        // Act & Assert
        $this->assertFalse($this->rateLimiter->allowRequest($key1, $limit, $window));
        $this->assertTrue($this->rateLimiter->allowRequest($key2, $limit, $window));
    }

    public function testThrowsExceptionWhenConfigured()
    {
        // Arrange
        $rateLimiter = new RateLimiter(['throw_exception' => true]);
        $key = new RateLimitKey('user', '127.0.0.1');
        $limit = 1;
        $window = 60;

        // Use up the limit
        $rateLimiter->allowRequest($key, $limit, $window);

        // Act & Assert
        $this->expectException(RateLimitExceededException::class);
        $this->expectExceptionMessage('Rate limit of 1 requests exceeded');
        $rateLimiter->allowRequest($key, $limit, $window);
    }

    public function testClearLimitsForKey()
    {
        // Arrange
        $key = new RateLimitKey('user', '127.0.0.1');
        $limit = 2;
        $window = 60;

        // Use up the limit
        for ($i = 0; $i < $limit; $i++) {
            $this->rateLimiter->allowRequest($key, $limit, $window);
        }

        // Act
        $this->rateLimiter->clear($key);

        // Assert
        $this->assertTrue($this->rateLimiter->allowRequest($key, $limit, $window));
        $this->assertEquals($limit - 1, $this->rateLimiter->getRemainingAttempts($key, $limit, $window));
    }
} 