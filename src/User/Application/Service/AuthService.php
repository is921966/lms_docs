<?php

declare(strict_types=1);

namespace User\Application\Service;

use App\Common\Exceptions\AuthorizationException;
use App\User\Application\Service\Auth\TokenService;
use App\User\Application\Service\Auth\TwoFactorAuthService;
use App\User\Application\Service\Auth\PasswordResetService;
use App\User\Application\Service\Auth\AuthorizationTrait;
use App\User\Domain\Repository\UserRepositoryInterface;
use App\User\Domain\Service\AuthServiceInterface;
use App\User\Domain\Service\LdapServiceInterface;
use App\User\Domain\User;
use App\User\Domain\ValueObjects\Email;
use Psr\Log\LoggerInterface;
use Psr\Cache\CacheItemPoolInterface;

/**
 * Refactored Authentication service implementation
 */
class AuthService implements AuthServiceInterface
{
    use AuthorizationTrait;
    
    private TokenService $tokenService;
    private TwoFactorAuthService $twoFactorService;
    private PasswordResetService $passwordResetService;
    
    public function __construct(
        private UserRepositoryInterface $userRepository,
        private LdapServiceInterface $ldapService,
        private array $jwtConfig,
        private LoggerInterface $logger,
        ?CacheItemPoolInterface $cache = null
    ) {
        $cache = $cache ?? new \Symfony\Component\Cache\Adapter\ArrayAdapter();
        
        $this->tokenService = new TokenService($jwtConfig, $cache);
        $this->twoFactorService = new TwoFactorAuthService($userRepository, $logger);
        $this->passwordResetService = new PasswordResetService($userRepository, $logger);
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
        
        if (!$user->getPassword()) {
            throw new AuthorizationException('Password authentication not available');
        }
        
        if (!$user->getPassword()->verify($password)) {
            $this->logger->warning('Failed login attempt', ['email' => $email]);
            throw new AuthorizationException('Invalid credentials');
        }
        
        // Record successful login
        $ipAddress = $_SERVER['REMOTE_ADDR'] ?? '127.0.0.1';
        $userAgent = $_SERVER['HTTP_USER_AGENT'] ?? 'Unknown';
        $user->recordLogin($ipAddress, $userAgent);
        $this->userRepository->save($user);
        
        // Generate tokens
        $tokens = $this->tokenService->generateTokens($user);
        
        $this->logger->info('User authenticated successfully', ['userId' => $user->getId()->getValue()]);
        
        return $tokens;
    }
    
    /**
     * Authenticate user with LDAP
     */
    public function authenticateWithLdap(string $username, string $password): array
    {
        $this->logger->info('Authenticating user with LDAP', ['username' => $username]);
        
        // Authenticate against LDAP
        $ldapData = $this->ldapService->authenticate($username, $password);
        
        if (!$ldapData) {
            throw new AuthorizationException('Invalid LDAP credentials');
        }
        
        // Find or create user
        $user = $this->userRepository->findByAdUsername($username);
        
        if (!$user && !empty($ldapData['email'])) {
            $user = $this->userRepository->findByEmail(new Email($ldapData['email']));
        }
        
        if (!$user) {
            // Import user from LDAP
            $user = $this->ldapService->importUser($username);
            if (!$user) {
                throw new AuthorizationException('Failed to import user from LDAP');
            }
        } else {
            // Sync user data from LDAP
            $this->ldapService->syncUser($user);
        }
        
        if (!$user->isActive()) {
            throw new AuthorizationException('User account is not active');
        }
        
        // Record successful login
        $ipAddress = $_SERVER['REMOTE_ADDR'] ?? '127.0.0.1';
        $userAgent = $_SERVER['HTTP_USER_AGENT'] ?? 'Unknown';
        $user->recordLogin($ipAddress, $userAgent);
        $this->userRepository->save($user);
        
        // Generate tokens
        $tokens = $this->tokenService->generateTokens($user);
        
        $this->logger->info('User authenticated via LDAP successfully', ['userId' => $user->getId()->getValue()]);
        
        return $tokens;
    }
    
    /**
     * Refresh authentication token
     */
    public function refreshToken(string $refreshToken): array
    {
        $this->logger->info('Refreshing authentication token');
        
        $payload = $this->tokenService->decodeToken($refreshToken);
        
        if (!$payload || !$this->tokenService->isTokenType($payload, 'refresh')) {
            throw new AuthorizationException('Invalid refresh token');
        }
        
        if ($this->tokenService->isTokenBlacklisted($refreshToken)) {
            throw new AuthorizationException('Token has been revoked');
        }
        
        $userId = $this->tokenService->extractUserId($payload);
        if (!$userId) {
            throw new AuthorizationException('Invalid token payload');
        }
        
        $user = $this->userRepository->getById($userId);
        
        if (!$user->isActive()) {
            throw new AuthorizationException('User account is not active');
        }
        
        // Generate new tokens
        $tokens = $this->tokenService->generateTokens($user);
        
        // Blacklist old refresh token
        $ttl = $payload->exp - time();
        if ($ttl > 0) {
            $this->tokenService->blacklistToken($refreshToken, $ttl);
        }
        
        $this->logger->info('Token refreshed successfully', ['userId' => $user->getId()->getValue()]);
        
        return $tokens;
    }
    
    /**
     * Logout user
     */
    public function logout(string $token): void
    {
        $this->logger->info('Logging out user');
        
        $payload = $this->tokenService->decodeToken($token);
        
        if ($payload && isset($payload->exp)) {
            $ttl = $payload->exp - time();
            if ($ttl > 0) {
                $this->tokenService->blacklistToken($token, $ttl);
            }
        }
        
        $this->logger->info('User logged out successfully');
    }
    
    /**
     * Validate token
     */
    public function validateToken(string $token): ?User
    {
        $payload = $this->tokenService->decodeToken($token);
        
        if (!$payload || !$this->tokenService->isTokenType($payload, 'access')) {
            return null;
        }
        
        if ($this->tokenService->isTokenBlacklisted($token)) {
            return null;
        }
        
        $userId = $this->tokenService->extractUserId($payload);
        if (!$userId) {
            return null;
        }
        
        $user = $this->userRepository->getById($userId);
        
        if (!$user->isActive()) {
            return null;
        }
        
        $this->currentUser = $user;
        
        return $user;
    }
    
    /**
     * Request password reset
     */
    public function requestPasswordReset(string $email): void
    {
        $this->passwordResetService->requestPasswordReset($email);
    }
    
    /**
     * Reset password with token
     */
    public function resetPasswordWithToken(string $token, string $newPassword): void
    {
        $this->passwordResetService->resetPasswordWithToken($token, $newPassword);
    }
    
    /**
     * Verify email with token
     */
    public function verifyEmail(string $token): void
    {
        $this->passwordResetService->verifyEmail($token);
    }
    
    /**
     * Enable two-factor authentication
     */
    public function enableTwoFactor(User $user): array
    {
        return $this->twoFactorService->enableTwoFactor($user);
    }
    
    /**
     * Disable two-factor authentication
     */
    public function disableTwoFactor(User $user, string $password): void
    {
        $this->twoFactorService->disableTwoFactor($user, $password);
    }
    
    /**
     * Verify two-factor code
     */
    public function verifyTwoFactorCode(string $code, string $token): array
    {
        // First validate the token
        $user = $this->validateToken($token);
        
        if (!$user) {
            throw new AuthorizationException('Invalid token');
        }
        
        if (!$user->hasTwoFactorEnabled()) {
            throw new AuthorizationException('Two-factor authentication is not enabled');
        }
        
        if (!$this->twoFactorService->verifyCode($user, $code)) {
            throw new AuthorizationException('Invalid two-factor code');
        }
        
        // Generate new tokens with 2FA verification
        return $this->tokenService->generateTokens($user);
    }
} 