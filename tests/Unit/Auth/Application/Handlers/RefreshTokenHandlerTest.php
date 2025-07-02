<?php

namespace Tests\Unit\Auth\Application\Handlers;

use PHPUnit\Framework\TestCase;
use Auth\Application\Handlers\RefreshTokenHandler;
use Auth\Application\Commands\RefreshTokenCommand;
use Auth\Application\DTO\AuthTokensDTO;
use Auth\Domain\Services\JwtService;
use Auth\Domain\Repositories\TokenRepositoryInterface;
use Auth\Domain\ValueObjects\JwtToken;
use Auth\Domain\ValueObjects\TokenPayload;
use Auth\Domain\Exceptions\InvalidTokenException;
use User\Domain\Repositories\UserRepositoryInterface;
use User\Domain\User;
use User\Domain\ValueObjects\UserId;

class RefreshTokenHandlerTest extends TestCase
{
    private RefreshTokenHandler $handler;
    private $userRepository;
    private $jwtService;
    private $tokenRepository;

    protected function setUp(): void
    {
        $this->userRepository = $this->createMock(UserRepositoryInterface::class);
        $this->jwtService = $this->createMock(JwtService::class);
        $this->tokenRepository = $this->createMock(TokenRepositoryInterface::class);
        
        $this->handler = new RefreshTokenHandler(
            $this->userRepository,
            $this->jwtService,
            $this->tokenRepository
        );
    }

    public function testSuccessfulRefresh()
    {
        // Arrange
        $command = new RefreshTokenCommand('valid-refresh-token');
        $userId = '123e4567-e89b-12d3-a456-426614174000';
        
        $this->tokenRepository->expects($this->once())
            ->method('isRefreshTokenValid')
            ->with('valid-refresh-token')
            ->willReturn(true);

        $this->tokenRepository->expects($this->once())
            ->method('getUserIdByRefreshToken')
            ->with('valid-refresh-token')
            ->willReturn($userId);

        $user = $this->createMock(User::class);
        $user->method('getId')->willReturn(UserId::fromString($userId));
        $user->method('getEmail')->willReturn('test@example.com');
        $user->method('getRoles')->willReturn(['user']);
        $user->method('isActive')->willReturn(true);

        $this->userRepository->expects($this->once())
            ->method('findById')
            ->with($this->isInstanceOf(UserId::class))
            ->willReturn($user);

        $newAccessToken = $this->createMock(JwtToken::class);
        $newAccessToken->method('getValue')->willReturn('new-access-token');
        $newAccessToken->method('getExpiresAt')->willReturn(time() + 900);

        $newRefreshToken = $this->createMock(JwtToken::class);
        $newRefreshToken->method('getValue')->willReturn('new-refresh-token');
        $newRefreshToken->method('getExpiresAt')->willReturn(time() + 604800);

        $this->jwtService->expects($this->once())
            ->method('generateAccessToken')
            ->with($userId, 'test@example.com', ['user'])
            ->willReturn($newAccessToken);

        $this->jwtService->expects($this->once())
            ->method('generateRefreshToken')
            ->with($userId)
            ->willReturn($newRefreshToken);

        // Revoke old token
        $this->tokenRepository->expects($this->once())
            ->method('revokeRefreshToken')
            ->with('valid-refresh-token');

        // Save new token
        $this->tokenRepository->expects($this->once())
            ->method('saveRefreshToken')
            ->with($userId, 'new-refresh-token', $this->greaterThan(time()));

        // Act
        $result = $this->handler->handle($command);

        // Assert
        $this->assertInstanceOf(AuthTokensDTO::class, $result);
        $this->assertEquals('new-access-token', $result->accessToken);
        $this->assertEquals('new-refresh-token', $result->refreshToken);
    }

    public function testRefreshWithInvalidToken()
    {
        // Arrange
        $command = new RefreshTokenCommand('invalid-refresh-token');

        $this->tokenRepository->expects($this->once())
            ->method('isRefreshTokenValid')
            ->with('invalid-refresh-token')
            ->willReturn(false);

        // Act & Assert
        $this->expectException(InvalidTokenException::class);
        $this->expectExceptionMessage('Invalid refresh token');
        $this->handler->handle($command);
    }

    public function testRefreshWithInactiveUser()
    {
        // Arrange
        $command = new RefreshTokenCommand('valid-refresh-token');
        $userId = '123e4567-e89b-12d3-a456-426614174000';

        $this->tokenRepository->expects($this->once())
            ->method('isRefreshTokenValid')
            ->with('valid-refresh-token')
            ->willReturn(true);

        $this->tokenRepository->expects($this->once())
            ->method('getUserIdByRefreshToken')
            ->with('valid-refresh-token')
            ->willReturn($userId);

        $user = $this->createMock(User::class);
        $user->method('isActive')->willReturn(false);

        $this->userRepository->expects($this->once())
            ->method('findById')
            ->willReturn($user);

        // Act & Assert
        $this->expectException(\Auth\Domain\Exceptions\AuthenticationException::class);
        $this->expectExceptionMessage('Account is inactive');
        $this->handler->handle($command);
    }

    public function testRefreshWithNonExistentUser()
    {
        // Arrange
        $command = new RefreshTokenCommand('valid-refresh-token');
        $userId = '123e4567-e89b-12d3-a456-426614174000';

        $this->tokenRepository->expects($this->once())
            ->method('isRefreshTokenValid')
            ->with('valid-refresh-token')
            ->willReturn(true);

        $this->tokenRepository->expects($this->once())
            ->method('getUserIdByRefreshToken')
            ->with('valid-refresh-token')
            ->willReturn($userId);

        $this->userRepository->expects($this->once())
            ->method('findById')
            ->willReturn(null);

        // Act & Assert
        $this->expectException(\User\Domain\Exceptions\UserNotFoundException::class);
        $this->expectExceptionMessage('User not found');
        $this->handler->handle($command);
    }
} 