<?php

declare(strict_types=1);

namespace App\User\Application\Service;

use App\Common\Exceptions\AuthorizationException;
use App\User\Domain\Repository\UserRepositoryInterface;
use App\User\Domain\Service\AuthServiceInterface;
use App\User\Domain\Service\LdapServiceInterface;
use App\User\Domain\User;
use App\User\Domain\ValueObjects\Email;
use Firebase\JWT\JWT;
use Firebase\JWT\Key;
use Psr\Log\LoggerInterface;

/**
 * Simple authentication service for testing
 */
class SimpleAuthService implements AuthServiceInterface
{
    private array $blacklist = [];
    
    public function __construct(
        private UserRepositoryInterface $userRepository,
        private LdapServiceInterface $ldapService,
        private array $jwtConfig,
        private LoggerInterface $logger
    ) {
    }
    
    /**
     * Authenticate user with email and password
     */
    public function authenticate(string $email, string $password): array
    {
        $this->logger->info('Authenticating user', ['email' => $email]);
        
        $user = $this->userRepository->findByEmail(new Email($email));
        
        if (!$user) {
            throw new AuthorizationException('Invalid credentials');
        }
        
        if (!$user->isActive()) {
            throw new AuthorizationException('User account is not active');
        }
        
        if (!$user->getPassword() || !$user->getPassword()->verify($password)) {
            throw new AuthorizationException('Invalid credentials');
        }
        
        $user->recordLogin();
        $this->userRepository->save($user);
        
        return $this->generateTokens($user);
    }
    
    /**
     * Authenticate with LDAP
     */
    public function authenticateWithLdap(string $username, string $password): array
    {
        $ldapData = $this->ldapService->authenticate($username, $password);
        
        if (!$ldapData) {
            throw new AuthorizationException('Invalid LDAP credentials');
        }
        
        $user = $this->userRepository->findByAdUsername($username);
        
        if (!$user) {
            throw new AuthorizationException('User not found');
        }
        
        if (!$user->isActive()) {
            throw new AuthorizationException('User account is not active');
        }
        
        $user->recordLogin();
        $this->userRepository->save($user);
        
        return $this->generateTokens($user);
    }
    
    /**
     * Refresh token
     */
    public function refreshToken(string $refreshToken): array
    {
        try {
            $payload = JWT::decode($refreshToken, new Key($this->jwtConfig['secret'], 'HS256'));
            
            if ($payload->type !== 'refresh') {
                throw new AuthorizationException('Invalid token type');
            }
            
            if (isset($this->blacklist[$refreshToken])) {
                throw new AuthorizationException('Token has been revoked');
            }
            
            $user = $this->userRepository->getById(new \App\User\Domain\ValueObjects\UserId($payload->sub));
            
            if (!$user->isActive()) {
                throw new AuthorizationException('User account is not active');
            }
            
            $this->blacklist[$refreshToken] = true;
            
            return $this->generateTokens($user);
            
        } catch (\Exception $e) {
            throw new AuthorizationException('Invalid refresh token');
        }
    }
    
    /**
     * Logout
     */
    public function logout(string $token): void
    {
        $this->blacklist[$token] = true;
    }
    
    /**
     * Validate token
     */
    public function validateToken(string $token): ?User
    {
        try {
            $payload = JWT::decode($token, new Key($this->jwtConfig['secret'], 'HS256'));
            
            if ($payload->type !== 'access') {
                return null;
            }
            
            if (isset($this->blacklist[$token])) {
                return null;
            }
            
            $user = $this->userRepository->getById(new \App\User\Domain\ValueObjects\UserId($payload->sub));
            
            if (!$user->isActive()) {
                return null;
            }
            
            return $user;
            
        } catch (\Exception $e) {
            return null;
        }
    }
    
    /**
     * Get current user
     */
    public function getCurrentUser(): ?User
    {
        return null;
    }
    
    /**
     * Check permission
     */
    public function hasPermission(string $permission): bool
    {
        return false;
    }
    
    /**
     * Check any permission
     */
    public function hasAnyPermission(array $permissions): bool
    {
        return false;
    }
    
    /**
     * Check all permissions
     */
    public function hasAllPermissions(array $permissions): bool
    {
        return false;
    }
    
    /**
     * Check role
     */
    public function hasRole(string $role): bool
    {
        return false;
    }
    
    /**
     * Check any role
     */
    public function hasAnyRole(array $roles): bool
    {
        return false;
    }
    
    /**
     * Request password reset
     */
    public function requestPasswordReset(string $email): void
    {
        // Not implemented
    }
    
    /**
     * Reset password with token
     */
    public function resetPasswordWithToken(string $token, string $newPassword): void
    {
        // Not implemented
    }
    
    /**
     * Verify email
     */
    public function verifyEmail(string $token): void
    {
        // Not implemented
    }
    
    /**
     * Enable two factor
     */
    public function enableTwoFactor(User $user): array
    {
        return [];
    }
    
    /**
     * Disable two factor
     */
    public function disableTwoFactor(User $user, string $password): void
    {
        // Not implemented
    }
    
    /**
     * Verify two factor code
     */
    public function verifyTwoFactorCode(string $code, string $token): array
    {
        return [];
    }
    
    /**
     * Generate tokens
     */
    private function generateTokens(User $user): array
    {
        $now = time();
        
        $accessPayload = [
            'iss' => $this->jwtConfig['issuer'],
            'sub' => $user->getId()->getValue(),
            'iat' => $now,
            'exp' => $now + $this->jwtConfig['access_ttl'],
            'type' => 'access',
        ];
        
        $refreshPayload = [
            'iss' => $this->jwtConfig['issuer'],
            'sub' => $user->getId()->getValue(),
            'iat' => $now,
            'exp' => $now + $this->jwtConfig['refresh_ttl'],
            'type' => 'refresh',
        ];
        
        $accessToken = JWT::encode($accessPayload, $this->jwtConfig['secret'], 'HS256');
        $refreshToken = JWT::encode($refreshPayload, $this->jwtConfig['secret'], 'HS256');
        
        return [
            'access_token' => $accessToken,
            'refresh_token' => $refreshToken,
            'expires_in' => $this->jwtConfig['access_ttl'],
        ];
    }
} 