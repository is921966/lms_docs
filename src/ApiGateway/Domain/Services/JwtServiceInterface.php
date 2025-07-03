<?php

declare(strict_types=1);

namespace ApiGateway\Domain\Services;

use ApiGateway\Domain\ValueObjects\JwtToken;
use User\Domain\ValueObjects\UserId;

interface JwtServiceInterface
{
    /**
     * Generate JWT token for user
     */
    public function generateToken(UserId $userId, array $claims = []): JwtToken;
    
    /**
     * Validate JWT token and return user ID
     * 
     * @throws InvalidTokenException
     */
    public function validateToken(string $token): UserId;
    
    /**
     * Refresh JWT token
     * 
     * @throws InvalidTokenException
     */
    public function refreshToken(string $refreshToken): JwtToken;
    
    /**
     * Blacklist a token (logout)
     */
    public function blacklistToken(string $token): void;
    
    /**
     * Check if token is blacklisted
     */
    public function isBlacklisted(string $token): bool;
} 