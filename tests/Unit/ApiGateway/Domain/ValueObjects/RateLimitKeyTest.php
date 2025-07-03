<?php

declare(strict_types=1);

namespace Tests\Unit\ApiGateway\Domain\ValueObjects;

use PHPUnit\Framework\TestCase;
use ApiGateway\Domain\ValueObjects\RateLimitKey;

class RateLimitKeyTest extends TestCase
{
    public function testCreateForUser(): void
    {
        $key = RateLimitKey::forUser('user-123');
        
        $this->assertEquals('user-123', $key->getIdentifier());
        $this->assertEquals('user', $key->getType());
        $this->assertEquals('rate_limit:user:user-123', $key->getCacheKey());
    }
    
    public function testCreateForIp(): void
    {
        $key = RateLimitKey::forIp('192.168.1.1');
        
        $this->assertEquals('192.168.1.1', $key->getIdentifier());
        $this->assertEquals('ip', $key->getType());
        $this->assertEquals('rate_limit:ip:192.168.1.1', $key->getCacheKey());
    }
    
    public function testCreateForApiKey(): void
    {
        $key = RateLimitKey::forApiKey('api-key-123');
        
        $this->assertEquals('api-key-123', $key->getIdentifier());
        $this->assertEquals('api_key', $key->getType());
        $this->assertEquals('rate_limit:api_key:api-key-123', $key->getCacheKey());
    }
    
    public function testCreateGlobal(): void
    {
        $key = RateLimitKey::global();
        
        $this->assertEquals('global', $key->getIdentifier());
        $this->assertEquals('global', $key->getType());
        $this->assertEquals('rate_limit:global:global', $key->getCacheKey());
    }
    
    public function testCannotCreateWithEmptyIdentifier(): void
    {
        $this->expectException(\InvalidArgumentException::class);
        $this->expectExceptionMessage('Rate limit identifier cannot be empty');
        
        RateLimitKey::forUser('');
    }
    
    public function testEquals(): void
    {
        $key1 = RateLimitKey::forUser('user-123');
        $key2 = RateLimitKey::forUser('user-123');
        $key3 = RateLimitKey::forUser('user-456');
        $key4 = RateLimitKey::forIp('user-123'); // Same ID but different type
        
        $this->assertTrue($key1->equals($key2));
        $this->assertFalse($key1->equals($key3));
        $this->assertFalse($key1->equals($key4));
    }
} 