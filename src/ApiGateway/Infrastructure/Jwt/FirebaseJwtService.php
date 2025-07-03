<?php

declare(strict_types=1);

namespace ApiGateway\Infrastructure\Jwt;

use ApiGateway\Domain\Services\JwtServiceInterface;
use ApiGateway\Domain\ValueObjects\JwtToken;
use ApiGateway\Domain\Exceptions\InvalidTokenException;
use User\Domain\ValueObjects\UserId;
use Firebase\JWT\JWT;
use Firebase\JWT\Key;
use Firebase\JWT\ExpiredException;
use Firebase\JWT\SignatureInvalidException;
use Firebase\JWT\BeforeValidException;

class FirebaseJwtService implements JwtServiceInterface
{
    private string $secretKey;
    private string $algorithm;
    private int $accessTokenTtl;
    private int $refreshTokenTtl;
    private array $blacklist = []; // In production, use Redis or database
    
    public function __construct(
        string $secretKey,
        string $algorithm = 'HS256',
        int $accessTokenTtl = 3600, // 1 hour
        int $refreshTokenTtl = 604800 // 1 week
    ) {
        $this->secretKey = $secretKey;
        $this->algorithm = $algorithm;
        $this->accessTokenTtl = $accessTokenTtl;
        $this->refreshTokenTtl = $refreshTokenTtl;
    }
    
    public function generateToken(UserId $userId, array $claims = []): JwtToken
    {
        $issuedAt = time();
        $expiresAt = $issuedAt + $this->accessTokenTtl;
        $refreshExpiresAt = $issuedAt + $this->refreshTokenTtl;
        
        // Access token payload
        $accessPayload = array_merge([
            'iss' => 'lms-api-gateway',
            'sub' => $userId->getValue(),
            'iat' => $issuedAt,
            'exp' => $expiresAt,
            'type' => 'access'
        ], $claims);
        
        // Refresh token payload
        $refreshPayload = [
            'iss' => 'lms-api-gateway',
            'sub' => $userId->getValue(),
            'iat' => $issuedAt,
            'exp' => $refreshExpiresAt,
            'type' => 'refresh',
            'jti' => bin2hex(random_bytes(16)) // Unique ID for refresh token
        ];
        
        $accessToken = JWT::encode($accessPayload, $this->secretKey, $this->algorithm);
        $refreshToken = JWT::encode($refreshPayload, $this->secretKey, $this->algorithm);
        
        return new JwtToken(
            $accessToken,
            $refreshToken,
            $this->accessTokenTtl,
            new \DateTimeImmutable('@' . $issuedAt)
        );
    }
    
    public function validateToken(string $token): UserId
    {
        try {
            $decoded = JWT::decode($token, new Key($this->secretKey, $this->algorithm));
            
            // Validate token type
            if (!isset($decoded->type) || $decoded->type !== 'access') {
                throw InvalidTokenException::malformed();
            }
            
            // Validate subject claim
            if (!isset($decoded->sub)) {
                throw InvalidTokenException::missingClaim('sub');
            }
            
            return UserId::fromString($decoded->sub);
            
        } catch (ExpiredException $e) {
            throw InvalidTokenException::expired();
        } catch (SignatureInvalidException $e) {
            throw InvalidTokenException::invalidSignature();
        } catch (BeforeValidException $e) {
            throw InvalidTokenException::notYetValid();
        } catch (\Exception $e) {
            throw InvalidTokenException::malformed();
        }
    }
    
    public function refreshToken(string $refreshToken): JwtToken
    {
        try {
            $decoded = JWT::decode($refreshToken, new Key($this->secretKey, $this->algorithm));
            
            // Validate token type
            if (!isset($decoded->type) || $decoded->type !== 'refresh') {
                throw InvalidTokenException::malformed();
            }
            
            // Check if refresh token is blacklisted
            if (isset($decoded->jti) && $this->isBlacklisted($decoded->jti)) {
                throw InvalidTokenException::malformed();
            }
            
            // Generate new token pair
            $userId = UserId::fromString($decoded->sub);
            
            // Blacklist the old refresh token
            if (isset($decoded->jti)) {
                $this->blacklistToken($decoded->jti);
            }
            
            return $this->generateToken($userId);
            
        } catch (ExpiredException $e) {
            throw InvalidTokenException::expired();
        } catch (\Exception $e) {
            throw InvalidTokenException::malformed();
        }
    }
    
    public function blacklistToken(string $token): void
    {
        // In production, store in Redis with expiration
        $this->blacklist[$token] = time();
    }
    
    public function isBlacklisted(string $token): bool
    {
        return isset($this->blacklist[$token]);
    }
} 