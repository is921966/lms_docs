<?php

namespace Tests\Unit\Auth\Infrastructure\Repositories;

use PHPUnit\Framework\TestCase;
use Auth\Infrastructure\Repositories\InMemoryTokenRepository;

class InMemoryTokenRepositoryTest extends TestCase
{
    private InMemoryTokenRepository $repository;

    protected function setUp(): void
    {
        $this->repository = new InMemoryTokenRepository();
    }

    public function testSaveAndValidateRefreshToken()
    {
        // Arrange
        $userId = '123e4567-e89b-12d3-a456-426614174000';
        $token = 'refresh-token-123';
        $expiresAt = time() + 3600;

        // Act
        $this->repository->saveRefreshToken($userId, $token, $expiresAt);

        // Assert
        $this->assertTrue($this->repository->isRefreshTokenValid($token));
    }

    public function testInvalidTokenReturnsFalse()
    {
        // Act & Assert
        $this->assertFalse($this->repository->isRefreshTokenValid('non-existent-token'));
    }

    public function testExpiredTokenIsInvalid()
    {
        // Arrange
        $userId = '123e4567-e89b-12d3-a456-426614174000';
        $token = 'expired-token';
        $expiresAt = time() - 3600; // 1 hour ago

        // Act
        $this->repository->saveRefreshToken($userId, $token, $expiresAt);

        // Assert
        $this->assertFalse($this->repository->isRefreshTokenValid($token));
    }

    public function testRevokeRefreshToken()
    {
        // Arrange
        $userId = '123e4567-e89b-12d3-a456-426614174000';
        $token = 'token-to-revoke';
        $expiresAt = time() + 3600;
        $this->repository->saveRefreshToken($userId, $token, $expiresAt);

        // Act
        $this->repository->revokeRefreshToken($token);

        // Assert
        $this->assertFalse($this->repository->isRefreshTokenValid($token));
    }

    public function testRevokeAllUserTokens()
    {
        // Arrange
        $userId = '123e4567-e89b-12d3-a456-426614174000';
        $token1 = 'user-token-1';
        $token2 = 'user-token-2';
        $otherUserId = '456e7890-e89b-12d3-a456-426614174000';
        $otherToken = 'other-user-token';
        $expiresAt = time() + 3600;

        $this->repository->saveRefreshToken($userId, $token1, $expiresAt);
        $this->repository->saveRefreshToken($userId, $token2, $expiresAt);
        $this->repository->saveRefreshToken($otherUserId, $otherToken, $expiresAt);

        // Act
        $this->repository->revokeAllUserTokens($userId);

        // Assert
        $this->assertFalse($this->repository->isRefreshTokenValid($token1));
        $this->assertFalse($this->repository->isRefreshTokenValid($token2));
        $this->assertTrue($this->repository->isRefreshTokenValid($otherToken));
    }

    public function testGetUserIdByRefreshToken()
    {
        // Arrange
        $userId = '123e4567-e89b-12d3-a456-426614174000';
        $token = 'user-token';
        $expiresAt = time() + 3600;
        $this->repository->saveRefreshToken($userId, $token, $expiresAt);

        // Act
        $retrievedUserId = $this->repository->getUserIdByRefreshToken($token);

        // Assert
        $this->assertEquals($userId, $retrievedUserId);
    }

    public function testGetUserIdForInvalidTokenReturnsNull()
    {
        // Act & Assert
        $this->assertNull($this->repository->getUserIdByRefreshToken('invalid-token'));
    }

    public function testCleanupExpiredTokens()
    {
        // Arrange
        $userId = '123e4567-e89b-12d3-a456-426614174000';
        $validToken = 'valid-token';
        $expiredToken1 = 'expired-token-1';
        $expiredToken2 = 'expired-token-2';

        $this->repository->saveRefreshToken($userId, $validToken, time() + 3600);
        $this->repository->saveRefreshToken($userId, $expiredToken1, time() - 3600);
        $this->repository->saveRefreshToken($userId, $expiredToken2, time() - 7200);

        // Act
        $cleanedCount = $this->repository->cleanupExpiredTokens();

        // Assert
        $this->assertEquals(2, $cleanedCount);
        $this->assertTrue($this->repository->isRefreshTokenValid($validToken));
        $this->assertFalse($this->repository->isRefreshTokenValid($expiredToken1));
        $this->assertFalse($this->repository->isRefreshTokenValid($expiredToken2));
    }
} 