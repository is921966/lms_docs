<?php

namespace Auth\Domain\Services;

use Auth\Domain\ValueObjects\JwtToken;
use Auth\Domain\ValueObjects\TokenPayload;
use Auth\Domain\Exceptions\InvalidTokenException;
use User\Domain\User;
use Firebase\JWT\JWT;
use Firebase\JWT\Key;

class JwtService
{
    private string $privateKey;
    private string $publicKey;
    private string $issuer;
    private int $accessTokenTtl;
    private int $refreshTokenTtl;

    public function __construct(
        string $privateKey,
        string $publicKey,
        string $issuer,
        int $accessTokenTtl = 900, // 15 minutes
        int $refreshTokenTtl = 604800 // 7 days
    ) {
        $this->privateKey = $privateKey;
        $this->publicKey = $publicKey;
        $this->issuer = $issuer;
        $this->accessTokenTtl = $accessTokenTtl;
        $this->refreshTokenTtl = $refreshTokenTtl;
    }

    public function generateAccessToken(string $userId, ?string $email, array $roles): JwtToken
    {
        $issuedAt = time();
        $expiresAt = $issuedAt + $this->accessTokenTtl;

        $payload = new TokenPayload(
            $userId,
            $email,
            $roles,
            $issuedAt,
            $expiresAt,
            $this->issuer,
            'access'
        );

        $tokenString = $this->createToken($payload);
        
        return new JwtToken($tokenString, $payload);
    }

    public function generateRefreshToken(string $userId): JwtToken
    {
        $issuedAt = time();
        $expiresAt = $issuedAt + $this->refreshTokenTtl;

        $payload = new TokenPayload(
            $userId,
            null,
            [],
            $issuedAt,
            $expiresAt,
            $this->issuer,
            'refresh'
        );

        $tokenString = $this->createToken($payload);
        
        return new JwtToken($tokenString, $payload);
    }

    public function validateToken(string $token): TokenPayload
    {
        try {
            $decoded = JWT::decode($token, new Key($this->publicKey, 'RS256'));
            
            return new TokenPayload(
                $decoded->userId,
                $decoded->email ?? null,
                $decoded->roles ?? [],
                $decoded->iat,
                $decoded->exp,
                $decoded->iss,
                $decoded->type ?? 'access'
            );
        } catch (\Exception $e) {
            if (strpos($e->getMessage(), 'Expired') !== false) {
                throw InvalidTokenException::expired();
            }
            if (strpos($e->getMessage(), 'Signature') !== false) {
                throw InvalidTokenException::invalidSignature();
            }
            throw InvalidTokenException::malformed();
        }
    }

    public function refreshAccessToken(string $refreshToken): JwtToken
    {
        $payload = $this->validateToken($refreshToken);
        
        if (!$payload->isRefreshToken()) {
            throw InvalidTokenException::invalidType('refresh', $payload->getType());
        }

        if ($payload->isExpired()) {
            throw InvalidTokenException::expired();
        }

        // Generate new access token with same user ID
        return $this->generateAccessToken(
            $payload->getUserId(),
            null, // Email will be fetched from user repository
            []    // Roles will be fetched from user repository
        );
    }

    private function createToken(TokenPayload $payload): string
    {
        $data = [
            'userId' => $payload->getUserId(),
            'email' => $payload->getEmail(),
            'roles' => $payload->getRoles(),
            'iat' => $payload->getIssuedAt(),
            'exp' => $payload->getExpiresAt(),
            'iss' => $payload->getIssuer(),
            'type' => $payload->getType()
        ];

        return JWT::encode($data, $this->privateKey, 'RS256');
    }

    private function getUserRoles(User $user): array
    {
        $roles = [];
        
        if ($user->isAdmin()) {
            $roles[] = 'admin';
        }
        
        // Get actual roles when Role system is implemented
        $userRole = $user->getRole();
        if (!empty($userRole)) {
            $roles[] = $userRole;
        }
        
        return empty($roles) ? ['user'] : $roles;
    }

    private function createUserFromPayload(TokenPayload $payload): User
    {
        // This is a temporary solution
        // In real implementation, inject UserRepository and fetch user
        $reflection = new \ReflectionClass(User::class);
        $user = $reflection->newInstanceWithoutConstructor();
        
        $idProperty = $reflection->getProperty('id');
        $idProperty->setAccessible(true);
        $idProperty->setValue($user, \User\Domain\ValueObjects\UserId::fromString($payload->getUserId()));
        
        if ($payload->getEmail()) {
            $emailProperty = $reflection->getProperty('email');
            $emailProperty->setAccessible(true);
            $emailProperty->setValue($user, new \User\Domain\ValueObjects\Email($payload->getEmail()));
        }
        
        if (in_array('admin', $payload->getRoles())) {
            $adminProperty = $reflection->getProperty('isAdmin');
            $adminProperty->setAccessible(true);
            $adminProperty->setValue($user, true);
        }
        
        return $user;
    }
} 