<?php

namespace Tests\Unit\Auth\Domain\Services;

use PHPUnit\Framework\TestCase;
use Auth\Domain\Services\JwtService;
use Auth\Domain\ValueObjects\JwtToken;
use Auth\Domain\ValueObjects\TokenPayload;

class JwtServiceTest extends TestCase
{
    private JwtService $jwtService;
    private ?string $privateKey = null;
    private ?string $publicKey = null;

    protected function setUp(): void
    {
        // Генерируем тестовые ключи
        $config = [
            "private_key_bits" => 2048,
            "private_key_type" => OPENSSL_KEYTYPE_RSA,
        ];
        
        $res = openssl_pkey_new($config);
        $privateKey = '';
        openssl_pkey_export($res, $privateKey);
        $this->privateKey = $privateKey;
        
        $publicKeyDetails = openssl_pkey_get_details($res);
        $this->publicKey = $publicKeyDetails["key"];
        
        $this->jwtService = new JwtService(
            $this->privateKey,
            $this->publicKey,
            'lms-api',
            900,      // 15 minutes for access token
            604800    // 7 days for refresh token
        );
    }

    public function testGenerateAccessToken()
    {
        // Arrange
        $userId = '123e4567-e89b-12d3-a456-426614174000';
        $email = 'test@example.com';
        $roles = ['admin', 'user'];
        
        // Act
        $token = $this->jwtService->generateAccessToken($userId, $email, $roles);
        
        // Assert
        $this->assertInstanceOf(JwtToken::class, $token);
        $this->assertNotEmpty($token->getValue());
        $payload = $token->getPayload();
        $this->assertEquals($userId, $payload->getUserId());
        $this->assertEquals($email, $payload->getEmail());
        $this->assertEquals($roles, $payload->getRoles());
        $this->assertFalse($payload->isExpired());
    }

    public function testGenerateRefreshToken()
    {
        // Arrange
        $userId = '123e4567-e89b-12d3-a456-426614174000';
        
        // Act
        $token = $this->jwtService->generateRefreshToken($userId);
        
        // Assert
        $this->assertInstanceOf(JwtToken::class, $token);
        $this->assertNotEmpty($token->getValue());
        $payload = $token->getPayload();
        $this->assertEquals($userId, $payload->getUserId());
        $this->assertNull($payload->getEmail());
        $this->assertEmpty($payload->getRoles());
        $this->assertTrue($payload->isRefreshToken());
    }

    public function testValidateValidToken()
    {
        // Arrange
        $userId = '123e4567-e89b-12d3-a456-426614174000';
        $email = 'test@example.com';
        $roles = ['admin'];
        $token = $this->jwtService->generateAccessToken($userId, $email, $roles);
        
        // Act
        $payload = $this->jwtService->validateToken($token->getValue());
        
        // Assert
        $this->assertInstanceOf(TokenPayload::class, $payload);
        $this->assertEquals($userId, $payload->getUserId());
        $this->assertEquals($email, $payload->getEmail());
        $this->assertEquals($roles, $payload->getRoles());
    }

    public function testValidateExpiredToken()
    {
        // Arrange
        $expiredToken = $this->createExpiredToken();
        
        // Act & Assert
        $this->expectException(\Auth\Domain\Exceptions\InvalidTokenException::class);
        $this->expectExceptionMessage('Token has expired');
        $this->jwtService->validateToken($expiredToken);
    }

    public function testValidateInvalidSignature()
    {
        // Arrange
        $userId = '123e4567-e89b-12d3-a456-426614174000';
        $token = $this->jwtService->generateAccessToken($userId, 'test@example.com', ['user']);
        $tamperedToken = $this->tamperWithToken($token->getValue());
        
        // Act & Assert
        $this->expectException(\Auth\Domain\Exceptions\InvalidTokenException::class);
        $this->expectExceptionMessage('Invalid token signature');
        $this->jwtService->validateToken($tamperedToken);
    }

    public function testValidateMalformedToken()
    {
        // Act & Assert
        $this->expectException(\Auth\Domain\Exceptions\InvalidTokenException::class);
        $this->expectExceptionMessage('Malformed token');
        $this->jwtService->validateToken('not.a.valid.token');
    }

    public function testRefreshToken()
    {
        // Arrange
        $userId = '123e4567-e89b-12d3-a456-426614174000';
        $refreshToken = $this->jwtService->generateRefreshToken($userId);
        
        // Act
        $newAccessToken = $this->jwtService->refreshAccessToken($refreshToken->getValue());
        
        // Assert
        $this->assertInstanceOf(JwtToken::class, $newAccessToken);
        $payload = $newAccessToken->getPayload();
        $this->assertEquals($userId, $payload->getUserId());
        $this->assertTrue($payload->isAccessToken());
        $this->assertFalse($payload->isExpired());
    }

    public function testTokenContainsCorrectClaims()
    {
        // Arrange
        $userId = '123e4567-e89b-12d3-a456-426614174000';
        $email = 'test@example.com';
        $roles = ['admin', 'user'];
        
        // Act
        $token = $this->jwtService->generateAccessToken($userId, $email, $roles);
        $payload = $this->jwtService->validateToken($token->getValue());
        
        // Assert
        $this->assertEquals($userId, $payload->getUserId());
        $this->assertEquals($email, $payload->getEmail());
        $this->assertEquals($roles, $payload->getRoles());
        $this->assertNotNull($payload->getIssuedAt());
        $this->assertNotNull($payload->getExpiresAt());
        $this->assertEquals('lms-api', $payload->getIssuer());
        $this->assertEquals('access', $payload->getType());
    }

    private function createExpiredToken(): string
    {
        // Create a token with past expiration
        $header = base64_encode(json_encode(['alg' => 'RS256', 'typ' => 'JWT']));
        $payload = base64_encode(json_encode([
            'exp' => time() - 3600, // 1 hour ago
            'userId' => 'test-user-id',
            'iss' => 'lms-api',
            'type' => 'access'
        ]));
        
        $signature = '';
        openssl_sign(
            $header . '.' . $payload,
            $signature,
            $this->privateKey,
            OPENSSL_ALGO_SHA256
        );
        
        return $header . '.' . $payload . '.' . base64_encode($signature);
    }

    private function tamperWithToken(string $token): string
    {
        $parts = explode('.', $token);
        $payload = json_decode(base64_decode($parts[1]), true);
        $payload['userId'] = 'tampered-user-id';
        $parts[1] = base64_encode(json_encode($payload));
        
        return implode('.', $parts);
    }
} 