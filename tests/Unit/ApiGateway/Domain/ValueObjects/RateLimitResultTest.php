<?php

declare(strict_types=1);

namespace Tests\Unit\ApiGateway\Domain\ValueObjects;

use PHPUnit\Framework\TestCase;
use ApiGateway\Domain\ValueObjects\RateLimitResult;

class RateLimitResultTest extends TestCase
{
    public function testCreateAllowedResult(): void
    {
        $resetsAt = new \DateTimeImmutable('+1 hour');
        $result = RateLimitResult::allow(100, 75, $resetsAt);
        
        $this->assertTrue($result->isAllowed());
        $this->assertFalse($result->isDenied());
        $this->assertEquals(100, $result->getLimit());
        $this->assertEquals(75, $result->getRemaining());
        $this->assertEquals($resetsAt, $result->getResetsAt());
        $this->assertNull($result->getReason());
    }
    
    public function testCreateDeniedResult(): void
    {
        $resetsAt = new \DateTimeImmutable('+1 hour');
        $result = RateLimitResult::deny(100, $resetsAt, 'Too many requests');
        
        $this->assertFalse($result->isAllowed());
        $this->assertTrue($result->isDenied());
        $this->assertEquals(100, $result->getLimit());
        $this->assertEquals(0, $result->getRemaining());
        $this->assertEquals($resetsAt, $result->getResetsAt());
        $this->assertEquals('Too many requests', $result->getReason());
    }
    
    public function testCreateDeniedResultWithDefaultReason(): void
    {
        $resetsAt = new \DateTimeImmutable('+1 hour');
        $result = RateLimitResult::deny(100, $resetsAt);
        
        $this->assertEquals('Rate limit exceeded', $result->getReason());
    }
    
    public function testCannotCreateWithNegativeLimit(): void
    {
        $this->expectException(\InvalidArgumentException::class);
        $this->expectExceptionMessage('Limit cannot be negative');
        
        new RateLimitResult(true, -1, 0, new \DateTimeImmutable());
    }
    
    public function testCannotCreateWithNegativeRemaining(): void
    {
        $this->expectException(\InvalidArgumentException::class);
        $this->expectExceptionMessage('Remaining cannot be negative');
        
        new RateLimitResult(true, 100, -1, new \DateTimeImmutable());
    }
    
    public function testCannotCreateWithRemainingExceedingLimit(): void
    {
        $this->expectException(\InvalidArgumentException::class);
        $this->expectExceptionMessage('Remaining cannot exceed limit');
        
        new RateLimitResult(true, 100, 101, new \DateTimeImmutable());
    }
    
    public function testGetResetsIn(): void
    {
        // Create result that resets in approximately 1 hour
        $resetsAt = new \DateTimeImmutable('+3600 seconds');
        $result = RateLimitResult::allow(100, 75, $resetsAt);
        
        $resetsIn = $result->getResetsIn();
        
        // Should be approximately 3600 seconds (might be slightly less due to execution time)
        $this->assertGreaterThan(3595, $resetsIn);
        $this->assertLessThanOrEqual(3600, $resetsIn);
    }
    
    public function testGetResetsInForPastTime(): void
    {
        // Create result with reset time in the past
        $resetsAt = new \DateTimeImmutable('-1 hour');
        $result = RateLimitResult::allow(100, 75, $resetsAt);
        
        $this->assertEquals(0, $result->getResetsIn());
    }
    
    public function testToArray(): void
    {
        $resetsAt = new \DateTimeImmutable('2025-07-03 12:00:00');
        $result = RateLimitResult::allow(100, 75, $resetsAt);
        
        $array = $result->toArray();
        
        $this->assertTrue($array['allowed']);
        $this->assertEquals(100, $array['limit']);
        $this->assertEquals(75, $array['remaining']);
        $this->assertEquals('2025-07-03T12:00:00+00:00', $array['resets_at']);
        $this->assertArrayHasKey('resets_in', $array);
        $this->assertNull($array['reason']);
    }
    
    public function testToHeaders(): void
    {
        $resetsAt = new \DateTimeImmutable('2025-07-03 12:00:00');
        $result = RateLimitResult::allow(100, 75, $resetsAt);
        
        $headers = $result->toHeaders();
        
        $this->assertEquals('100', $headers['X-RateLimit-Limit']);
        $this->assertEquals('75', $headers['X-RateLimit-Remaining']);
        $this->assertEquals((string) $resetsAt->getTimestamp(), $headers['X-RateLimit-Reset']);
    }
} 