<?php

namespace Tests\Unit\Auth\Application\Handlers;

use PHPUnit\Framework\TestCase;
use Auth\Application\Handlers\LoginHandler;
use Auth\Application\Commands\LoginCommand;
use Auth\Application\DTO\AuthTokensDTO;
use Auth\Domain\Services\JwtService;
use Auth\Domain\Repositories\TokenRepositoryInterface;
use Auth\Domain\ValueObjects\JwtToken;
use Auth\Domain\ValueObjects\TokenPayload;
use User\Domain\Repositories\UserRepositoryInterface;
use User\Domain\User;
use User\Domain\ValueObjects\Email;
use User\Domain\ValueObjects\Password;
use User\Domain\Exceptions\UserNotFoundException;
use User\Domain\ValueObjects\UserId;

class LoginHandlerTest extends TestCase
{
    private LoginHandler $handler;
    private $userRepository;
    private $jwtService;
    private $tokenRepository;

    protected function setUp(): void
    {
        $this->userRepository = $this->createMock(UserRepositoryInterface::class);
        $this->jwtService = $this->createMock(JwtService::class);
        $this->tokenRepository = $this->createMock(TokenRepositoryInterface::class);
        
        $this->handler = new LoginHandler(
            $this->userRepository,
            $this->jwtService,
            $this->tokenRepository
        );
    }

    public function testSuccessfulLogin()
    {
        // Arrange
        $command = new LoginCommand('test@example.com', 'password123');
        
        $userId = UserId::fromString('123e4567-e89b-12d3-a456-426614174000');
        
        $user = $this->createMock(User::class);
        $user->method('getId')->willReturn($userId);
        $user->method('getEmail')->willReturn('test@example.com');
        $user->method('getRoles')->willReturn(['user']);
        $user->method('verifyPassword')->willReturn(true);
        $user->method('isActive')->willReturn(true);

        $this->userRepository->expects($this->once())
            ->method('findByEmail')
            ->with('test@example.com')
            ->willReturn($user);

        $accessToken = $this->createMock(JwtToken::class);
        $accessToken->method('getValue')->willReturn('access-token-value');
        $accessToken->method('getExpiresAt')->willReturn(time() + 900);

        $refreshToken = $this->createMock(JwtToken::class);
        $refreshToken->method('getValue')->willReturn('refresh-token-value');
        $refreshToken->method('getExpiresAt')->willReturn(time() + 604800);

        $this->jwtService->expects($this->once())
            ->method('generateAccessToken')
            ->with('123e4567-e89b-12d3-a456-426614174000', 'test@example.com', ['user'])
            ->willReturn($accessToken);

        $this->jwtService->expects($this->once())
            ->method('generateRefreshToken')
            ->with('123e4567-e89b-12d3-a456-426614174000')
            ->willReturn($refreshToken);

        $this->tokenRepository->expects($this->once())
            ->method('saveRefreshToken')
            ->with(
                '123e4567-e89b-12d3-a456-426614174000',
                'refresh-token-value',
                $this->greaterThan(time())
            );

        // Act
        $result = $this->handler->handle($command);

        // Assert
        $this->assertInstanceOf(AuthTokensDTO::class, $result);
        $this->assertEquals('access-token-value', $result->accessToken);
        $this->assertEquals('refresh-token-value', $result->refreshToken);
        $this->assertEquals('Bearer', $result->tokenType);
        $this->assertEquals(900, $result->expiresIn);
    }

    public function testLoginWithInvalidEmail()
    {
        // Arrange
        $command = new LoginCommand('invalid@example.com', 'password123');

        $this->userRepository->expects($this->once())
            ->method('findByEmail')
            ->with('invalid@example.com')
            ->willReturn(null);

        // Act & Assert
        $this->expectException(\Auth\Domain\Exceptions\AuthenticationException::class);
        $this->expectExceptionMessage('Invalid credentials');
        $this->handler->handle($command);
    }

    public function testLoginWithInvalidPassword()
    {
        // Arrange
        $command = new LoginCommand('test@example.com', 'wrong-password');
        
        $user = $this->createMock(User::class);
        $user->method('verifyPassword')->willReturn(false);
        $user->method('isActive')->willReturn(true);

        $this->userRepository->expects($this->once())
            ->method('findByEmail')
            ->with('test@example.com')
            ->willReturn($user);

        // Act & Assert
        $this->expectException(\Auth\Domain\Exceptions\AuthenticationException::class);
        $this->expectExceptionMessage('Invalid credentials');
        $this->handler->handle($command);
    }

    public function testLoginWithInactiveUser()
    {
        // Arrange
        $command = new LoginCommand('test@example.com', 'password123');
        
        $user = $this->createMock(User::class);
        $user->method('verifyPassword')->willReturn(true);
        $user->method('isActive')->willReturn(false);

        $this->userRepository->expects($this->once())
            ->method('findByEmail')
            ->with('test@example.com')
            ->willReturn($user);

        // Act & Assert
        $this->expectException(\Auth\Domain\Exceptions\AuthenticationException::class);
        $this->expectExceptionMessage('Account is inactive');
        $this->handler->handle($command);
    }

    public function testLoginUpdatesLastLoginTime()
    {
        // Arrange
        $command = new LoginCommand('test@example.com', 'password123');
        
        $userId = UserId::fromString('123e4567-e89b-12d3-a456-426614174000');
        
        $user = $this->createMock(User::class);
        $user->method('getId')->willReturn($userId);
        $user->method('getEmail')->willReturn('test@example.com');
        $user->method('getRoles')->willReturn(['user']);
        $user->method('verifyPassword')->willReturn(true);
        $user->method('isActive')->willReturn(true);

        $this->userRepository->expects($this->once())
            ->method('findByEmail')
            ->willReturn($user);

        $user->expects($this->once())
            ->method('updateLastLogin');

        $this->userRepository->expects($this->once())
            ->method('save')
            ->with($user);

        $accessToken = $this->createMock(JwtToken::class);
        $accessToken->method('getValue')->willReturn('access-token');
        $accessToken->method('getExpiresAt')->willReturn(time() + 900);

        $refreshToken = $this->createMock(JwtToken::class);
        $refreshToken->method('getValue')->willReturn('refresh-token');
        $refreshToken->method('getExpiresAt')->willReturn(time() + 604800);

        $this->jwtService->method('generateAccessToken')->willReturn($accessToken);
        $this->jwtService->method('generateRefreshToken')->willReturn($refreshToken);

        // Act
        $this->handler->handle($command);
    }
} 