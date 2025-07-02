<?php

namespace Auth\Application\Handlers;

use Auth\Application\Commands\LoginCommand;
use Auth\Application\DTO\AuthTokensDTO;
use Auth\Domain\Services\JwtService;
use Auth\Domain\Repositories\TokenRepositoryInterface;
use Auth\Domain\Exceptions\AuthenticationException;
use User\Domain\Repositories\UserRepositoryInterface;

class LoginHandler
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

    public function handle(LoginCommand $command): AuthTokensDTO
    {
        // Find user by email
        $user = $this->userRepository->findByEmail($command->getEmail());
        if (!$user) {
            throw AuthenticationException::invalidCredentials();
        }

        // Verify password
        if (!$user->verifyPassword($command->getPassword())) {
            throw AuthenticationException::invalidCredentials();
        }

        // Check if user is active
        if (!$user->isActive()) {
            throw AuthenticationException::accountInactive();
        }

        // Update last login time
        $user->updateLastLogin();
        $this->userRepository->save($user);

        // Generate tokens
        $accessToken = $this->jwtService->generateAccessToken(
            (string) $user->getId(),
            $user->getEmail(),
            $user->getRoles()
        );

        $refreshToken = $this->jwtService->generateRefreshToken(
            (string) $user->getId()
        );

        // Save refresh token
        $this->tokenRepository->saveRefreshToken(
            (string) $user->getId(),
            $refreshToken->getValue(),
            $refreshToken->getExpiresAt()
        );

        return new AuthTokensDTO(
            $accessToken->getValue(),
            $refreshToken->getValue(),
            'Bearer',
            900 // 15 minutes
        );
    }
} 