<?php

declare(strict_types=1);

namespace Tests\Unit\ApiGateway\Infrastructure\Jwt;

use PHPUnit\Framework\TestCase;
use ApiGateway\Infrastructure\Jwt\FirebaseJwtService;
use ApiGateway\Domain\Exceptions\InvalidTokenException;
use User\Domain\ValueObjects\UserId;
use Firebase\JWT\JWT;
use Firebase\JWT\Key;

class FirebaseJwtServiceTest extends TestCase
{
    private FirebaseJwtService $jwtService;
    private string $secretKey = 'test-secret-key-for-testing-only';
    
    protected function setUp(): void
    {
        $this->jwtService = new FirebaseJwtService($this->secretKey, 'HS256', 3600, 604800);
    }
    
    public function testGenerateToken(): void
    {
        $userId = UserId::fromString('550e8400-e29b-41d4-a716-446655440000');
        
        $token = $this->jwtService->generateToken($userId);
        
        $this->assertNotEmpty($token->getAccessToken());
        $this->assertNotEmpty($token->getRefreshToken());
        $this->assertEquals(3600, $token->getExpiresIn());
        $this->assertFalse($token->isExpired());
    }
    
    public function testGenerateTokenWithClaims(): void
    {
        $userId = UserId::fromString('550e8400-e29b-41d4-a716-446655440000');
        $claims = ['role' => 'admin', 'permissions' => ['read', 'write']];
        
        $token = $this->jwtService->generateToken($userId, $claims);
        
        // Decode token to verify claims
        $decoded = JWT::decode($token->getAccessToken(), new Key($this->secretKey, 'HS256'));
        
        $this->assertEquals('admin', $decoded->role);
        $this->assertEquals(['read', 'write'], $decoded->permissions);
    }
    
    public function testValidateToken(): void
    {
        $userId = UserId::fromString('550e8400-e29b-41d4-a716-446655440000');
        $token = $this->jwtService->generateToken($userId);
        
        $validatedUserId = $this->jwtService->validateToken($token->getAccessToken());
        
        $this->assertEquals($userId->getValue(), $validatedUserId->getValue());
    }
    
    public function testValidateExpiredToken(): void
    {
        // Create expired token
        $payload = [
            'iss' => 'lms-api-gateway',
            'sub' => '550e8400-e29b-41d4-a716-446655440000',
            'iat' => time() - 7200, // 2 hours ago
            'exp' => time() - 3600, // 1 hour ago
            'type' => 'access'
        ];
        
        $expiredToken = JWT::encode($payload, $this->secretKey, 'HS256');
        
        $this->expectException(InvalidTokenException::class);
        $this->expectExceptionMessage('Token has expired');
        
        $this->jwtService->validateToken($expiredToken);
    }
    
    public function testValidateTokenWithInvalidSignature(): void
    {
        $userId = UserId::fromString('550e8400-e29b-41d4-a716-446655440000');
        $token = $this->jwtService->generateToken($userId);
        
        // Tamper with token
        $tamperedToken = $token->getAccessToken() . 'tampered';
        
        $this->expectException(InvalidTokenException::class);
        
        $this->jwtService->validateToken($tamperedToken);
    }
    
    public function testValidateRefreshTokenAsAccess(): void
    {
        $userId = UserId::fromString('550e8400-e29b-41d4-a716-446655440000');
        $token = $this->jwtService->generateToken($userId);
        
        $this->expectException(InvalidTokenException::class);
        $this->expectExceptionMessage('Token is malformed');
        
        // Try to use refresh token as access token
        $this->jwtService->validateToken($token->getRefreshToken());
    }
    
    public function testRefreshToken(): void
    {
        $userId = UserId::fromString('550e8400-e29b-41d4-a716-446655440000');
        $originalToken = $this->jwtService->generateToken($userId);
        
        // Wait 1 second to ensure different timestamps
        sleep(1);
        
        $newToken = $this->jwtService->refreshToken($originalToken->getRefreshToken());
        
        $this->assertNotEquals($originalToken->getAccessToken(), $newToken->getAccessToken());
        $this->assertNotEquals($originalToken->getRefreshToken(), $newToken->getRefreshToken());
        
        // Verify new access token is valid
        $validatedUserId = $this->jwtService->validateToken($newToken->getAccessToken());
        $this->assertEquals($userId->getValue(), $validatedUserId->getValue());
    }
    
    public function testRefreshTokenWithAccessToken(): void
    {
        $userId = UserId::fromString('550e8400-e29b-41d4-a716-446655440000');
        $token = $this->jwtService->generateToken($userId);
        
        $this->expectException(InvalidTokenException::class);
        $this->expectExceptionMessage('Token is malformed');
        
        // Try to refresh with access token instead of refresh token
        $this->jwtService->refreshToken($token->getAccessToken());
    }
    
    public function testBlacklistToken(): void
    {
        $token = 'some-token-jti';
        
        $this->assertFalse($this->jwtService->isBlacklisted($token));
        
        $this->jwtService->blacklistToken($token);
        
        $this->assertTrue($this->jwtService->isBlacklisted($token));
    }
    
    public function testRefreshTokenBlacklistsOldToken(): void
    {
        $userId = UserId::fromString('550e8400-e29b-41d4-a716-446655440000');
        $originalToken = $this->jwtService->generateToken($userId);
        
        // Decode refresh token to get jti
        $decoded = JWT::decode($originalToken->getRefreshToken(), new Key($this->secretKey, 'HS256'));
        $jti = $decoded->jti;
        
        // Refresh token
        $this->jwtService->refreshToken($originalToken->getRefreshToken());
        
        // Old refresh token jti should be blacklisted
        $this->assertTrue($this->jwtService->isBlacklisted($jti));
    }
} 