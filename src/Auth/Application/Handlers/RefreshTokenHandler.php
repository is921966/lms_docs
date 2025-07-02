<?php

namespace Auth\Application\Handlers;

use Auth\Application\Commands\RefreshTokenCommand;
use Auth\Application\DTO\AuthTokensDTO;
use Auth\Domain\Services\JwtService;
use Auth\Domain\Repositories\TokenRepositoryInterface;
use Auth\Domain\Exceptions\InvalidTokenException;
use Auth\Domain\Exceptions\AuthenticationException;
use User\Domain\Repositories\UserRepositoryInterface;
use User\Domain\ValueObjects\UserId;
use User\Domain\Exceptions\UserNotFoundException;

class RefreshTokenHandler
{
    private UserRepositoryInterface $userRepository;
    private JwtService $jwtService;
    private TokenRepositoryInterface $tokenRepository;

    public function __construct(
        UserRepositoryInterface $userRepository,
        JwtService $jwtService,
        TokenRepositoryInterface $tokenRepository
    ) {
        $this->userRepository = $userRepository;
        $this->jwtService = $jwtService;
        $this->tokenRepository = $tokenRepository;
    }

    public function handle(RefreshTokenCommand $command): AuthTokensDTO
    {
        $refreshToken = $command->getRefreshToken();

        // Validate refresh token
        if (!$this->tokenRepository->isRefreshTokenValid($refreshToken)) {
            throw new InvalidTokenException('Invalid refresh token');
        }

        // Get user ID from token
        $userId = $this->tokenRepository->getUserIdByRefreshToken($refreshToken);
        if (!$userId) {
            throw new InvalidTokenException('Invalid refresh token');
        }

        // Find user
        $user = $this->userRepository->findById(UserId::fromString($userId));
        if (!$user) {
            throw new UserNotFoundException('User not found');
        }

        // Check if user is active
        if (!$user->isActive()) {
            throw AuthenticationException::accountInactive();
        }

        // Generate new tokens
        $newAccessToken = $this->jwtService->generateAccessToken(
            (string) $user->getId(),
            $user->getEmail(),
            $user->getRoles()
        );

        $newRefreshToken = $this->jwtService->generateRefreshToken(
            (string) $user->getId()
        );

        // Revoke old refresh token (rotation)
        $this->tokenRepository->revokeRefreshToken($refreshToken);

        // Save new refresh token
        $this->tokenRepository->saveRefreshToken(
            (string) $user->getId(),
            $newRefreshToken->getValue(),
            $newRefreshToken->getExpiresAt()
        );

        return new AuthTokensDTO(
            $newAccessToken->getValue(),
            $newRefreshToken->getValue(),
            'Bearer',
            900 // 15 minutes
        );
    }
} 