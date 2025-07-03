<?php

declare(strict_types=1);

namespace Tests\Unit\ApiGateway\Domain\ValueObjects;

use PHPUnit\Framework\TestCase;
use ApiGateway\Domain\ValueObjects\JwtToken;

class JwtTokenTest extends TestCase
{
    public function testCreateJwtToken(): void
    {
        $token = new JwtToken(
            'access-token-123',
            'refresh-token-456',
            3600
        );
        
        $this->assertEquals('access-token-123', $token->getAccessToken());
        $this->assertEquals('refresh-token-456', $token->getRefreshToken());
        $this->assertEquals(3600, $token->getExpiresIn());
        $this->assertFalse($token->isExpired());
    }
    
    public function testCreateJwtTokenWithIssuedAt(): void
    {
        $issuedAt = new \DateTimeImmutable('2025-07-03 10:00:00');
        
        $token = new JwtToken(
            'access-token-123',
            'refresh-token-456',
            3600,
            $issuedAt
        );
        
        $expectedExpiresAt = new \DateTimeImmutable('2025-07-03 11:00:00');
        $this->assertEquals($expectedExpiresAt, $token->getExpiresAt());
    }
    
    public function testCannotCreateWithEmptyAccessToken(): void
    {
        $this->expectException(\InvalidArgumentException::class);
        $this->expectExceptionMessage('Access token cannot be empty');
        
        new JwtToken('', 'refresh-token', 3600);
    }
    
    public function testCannotCreateWithEmptyRefreshToken(): void
    {
        $this->expectException(\InvalidArgumentException::class);
        $this->expectExceptionMessage('Refresh token cannot be empty');
        
        new JwtToken('access-token', '', 3600);
    }
    
    public function testCannotCreateWithNegativeExpiration(): void
    {
        $this->expectException(\InvalidArgumentException::class);
        $this->expectExceptionMessage('Expiration time must be positive');
        
        new JwtToken('access-token', 'refresh-token', -1);
    }
    
    public function testCannotCreateWithZeroExpiration(): void
    {
        $this->expectException(\InvalidArgumentException::class);
        $this->expectExceptionMessage('Expiration time must be positive');
        
        new JwtToken('access-token', 'refresh-token', 0);
    }
    
    public function testIsExpired(): void
    {
        // Create token that expired 1 hour ago
        $issuedAt = new \DateTimeImmutable('-2 hours');
        
        $token = new JwtToken(
            'access-token-123',
            'refresh-token-456',
            3600, // 1 hour
            $issuedAt
        );
        
        $this->assertTrue($token->isExpired());
    }
    
    public function testIsNotExpired(): void
    {
        // Create token that will expire in 1 hour
        $issuedAt = new \DateTimeImmutable('now');
        
        $token = new JwtToken(
            'access-token-123',
            'refresh-token-456',
            3600, // 1 hour
            $issuedAt
        );
        
        $this->assertFalse($token->isExpired());
    }
    
    public function testToArray(): void
    {
        $issuedAt = new \DateTimeImmutable('2025-07-03 10:00:00');
        
        $token = new JwtToken(
            'access-token-123',
            'refresh-token-456',
            3600,
            $issuedAt
        );
        
        $array = $token->toArray();
        
        $this->assertEquals('access-token-123', $array['access_token']);
        $this->assertEquals('refresh-token-456', $array['refresh_token']);
        $this->assertEquals('Bearer', $array['token_type']);
        $this->assertEquals(3600, $array['expires_in']);
        $this->assertEquals('2025-07-03T11:00:00+00:00', $array['expires_at']);
    }
} 