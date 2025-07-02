<?php

declare(strict_types=1);

namespace User\Application\Service\Auth;

use App\User\Domain\User;
use App\User\Domain\ValueObjects\UserId;
use Firebase\JWT\JWT;
use Firebase\JWT\Key;
use Psr\Cache\CacheItemPoolInterface;

/**
 * Service for JWT token operations
 */
class TokenService
{
    public function __construct(
        private array $jwtConfig,
        private CacheItemPoolInterface $cache
    ) {
    }
    
    /**
     * Generate JWT tokens for user
     */
    public function generateTokens(User $user): array
    {
        $now = time();
        
        // Access token payload
        $accessPayload = [
            'iss' => $this->jwtConfig['issuer'],
            'sub' => $user->getId()->getValue(),
            'iat' => $now,
            'exp' => $now + $this->jwtConfig['access_ttl'],
            'type' => 'access',
            'email' => $user->getEmail()->getValue(),
            'roles' => $user->getRoleNames(),
            'permissions' => $user->getPermissionIds()
        ];
        
        // Refresh token payload
        $refreshPayload = [
            'iss' => $this->jwtConfig['issuer'],
            'sub' => $user->getId()->getValue(),
            'iat' => $now,
            'exp' => $now + $this->jwtConfig['refresh_ttl'],
            'type' => 'refresh'
        ];
        
        return [
            'access_token' => JWT::encode($accessPayload, $this->jwtConfig['secret'], 'HS256'),
            'refresh_token' => JWT::encode($refreshPayload, $this->jwtConfig['secret'], 'HS256'),
            'token_type' => 'Bearer',
            'expires_in' => $this->jwtConfig['access_ttl']
        ];
    }
    
    /**
     * Decode and validate token
     */
    public function decodeToken(string $token): ?object
    {
        try {
            return JWT::decode($token, new Key($this->jwtConfig['secret'], 'HS256'));
        } catch (\Exception $e) {
            return null;
        }
    }
    
    /**
     * Check if token is blacklisted
     */
    public function isTokenBlacklisted(string $token): bool
    {
        $blacklistKey = 'token_blacklist:' . $token;
        return $this->cache->hasItem($blacklistKey);
    }
    
    /**
     * Blacklist token
     */
    public function blacklistToken(string $token, int $ttl): void
    {
        $blacklistKey = 'token_blacklist:' . $token;
        $item = $this->cache->getItem($blacklistKey);
        $item->set(true);
        $item->expiresAfter($ttl);
        $this->cache->save($item);
    }
    
    /**
     * Extract user ID from token payload
     */
    public function extractUserId(object $payload): ?UserId
    {
        if (!isset($payload->sub)) {
            return null;
        }
        
        return UserId::fromString($payload->sub);
    }
    
    /**
     * Validate token type
     */
    public function isTokenType(object $payload, string $type): bool
    {
        return isset($payload->type) && $payload->type === $type;
    }
} 