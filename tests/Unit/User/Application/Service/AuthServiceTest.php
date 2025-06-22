<?php

namespace Tests\Unit\User\Application\Service;

use Tests\TestCase;
use App\User\Application\Service\AuthService;
use App\User\Domain\User;
use App\User\Domain\ValueObjects\Email;
use App\User\Domain\ValueObjects\Password;
use App\User\Domain\ValueObjects\UserId;
use App\User\Domain\Repository\UserRepositoryInterface;
use App\User\Domain\Service\LdapServiceInterface;
use App\Common\Exceptions\AuthorizationException;
use Firebase\JWT\JWT;
use Psr\Log\LoggerInterface;
use Tests\Stubs\CacheAdapterStub;

class WorkingAuthServiceTest extends TestCase
{
    private AuthService $service;
    private $userRepository;
    private $ldapService;
    private $logger;
    private $cache;
    private array $jwtConfig;
    
    protected function setUp(): void
    {
        parent::setUp();
        
        // Set up server variables for tests
        $_SERVER['REMOTE_ADDR'] = '127.0.0.1';
        $_SERVER['HTTP_USER_AGENT'] = 'PHPUnit Test';
        
        $this->userRepository = $this->createMock(UserRepositoryInterface::class);
        $this->ldapService = $this->createMock(LdapServiceInterface::class);
        $this->logger = $this->createMock(LoggerInterface::class);
        $this->cache = new CacheAdapterStub();
        
        $this->jwtConfig = [
            'secret' => 'test-secret-key',
            'access_ttl' => 3600,
            'refresh_ttl' => 86400,
            'issuer' => 'test-issuer',
        ];
        
        $this->service = new AuthService(
            $this->userRepository,
            $this->ldapService,
            $this->jwtConfig,
            $this->logger,
            $this->cache
        );
    }
    
    /**
     * @test
     */
    public function it_authenticates_user_with_valid_credentials(): void
    {
        $email = 'user@example.com';
        $password = 'ValidPassword123!';
        
        $user = User::create(
            new Email($email),
            'John',
            'Doe',
            Password::fromPlainText($password)
        );
        
        $this->userRepository->expects($this->once())
            ->method('findByEmail')
            ->with($this->isInstanceOf(Email::class))
            ->willReturn($user);
        
        $this->userRepository->expects($this->once())
            ->method('save')
            ->with($user);
        
        $result = $this->service->authenticate($email, $password);
        
        $this->assertArrayHasKey('access_token', $result);
        $this->assertArrayHasKey('refresh_token', $result);
        $this->assertArrayHasKey('expires_in', $result);
        $this->assertEquals(3600, $result['expires_in']);
    }
    
    /**
     * @test
     */
    public function it_throws_exception_for_invalid_email(): void
    {
        $this->userRepository->expects($this->once())
            ->method('findByEmail')
            ->with($this->isInstanceOf(Email::class))
            ->willReturn(null);
        
        $this->expectException(AuthorizationException::class);
        $this->expectExceptionMessage('Invalid credentials');
        
        $this->service->authenticate('invalid@example.com', 'password');
    }
    
    /**
     * @test
     */
    public function it_throws_exception_for_invalid_password(): void
    {
        $email = 'user@example.com';
        $user = User::create(
            new Email($email),
            'John',
            'Doe',
            Password::fromPlainText('CorrectPassword123!')
        );
        
        $this->userRepository->expects($this->once())
            ->method('findByEmail')
            ->with($this->isInstanceOf(Email::class))
            ->willReturn($user);
        
        $this->expectException(AuthorizationException::class);
        $this->expectExceptionMessage('Invalid credentials');
        
        $this->service->authenticate($email, 'WrongPassword');
    }
    
    /**
     * @test
     */
    public function it_throws_exception_for_inactive_user(): void
    {
        $email = 'user@example.com';
        $password = 'Password123!';
        
        $user = User::create(
            new Email($email),
            'John',
            'Doe',
            Password::fromPlainText($password)
        );
        $user->deactivate();
        
        $this->userRepository->expects($this->once())
            ->method('findByEmail')
            ->with($this->isInstanceOf(Email::class))
            ->willReturn($user);
        
        $this->expectException(AuthorizationException::class);
        $this->expectExceptionMessage('User account is not active');
        
        $this->service->authenticate($email, $password);
    }
    
    /**
     * @test
     */
    public function it_validates_access_token(): void
    {
        $userId = UserId::generate();
        $user = User::create(
            new Email('user@example.com'),
            'John',
            'Doe'
        );
        
        // Set user ID using reflection
        $reflection = new \ReflectionClass($user);
        $property = $reflection->getProperty('id');
        $property->setAccessible(true);
        $property->setValue($user, $userId);
        
        // Create a valid access token
        $accessToken = JWT::encode([
            'iss' => $this->jwtConfig['issuer'],
            'sub' => $userId->getValue(),
            'type' => 'access',
            'exp' => time() + 3600,
            'iat' => time(),
        ], $this->jwtConfig['secret'], 'HS256');
        
        $this->userRepository->expects($this->once())
            ->method('getById')
            ->with($this->isInstanceOf(UserId::class))
            ->willReturn($user);
        
        $validatedUser = $this->service->validateToken($accessToken);
        
        $this->assertSame($user, $validatedUser);
    }
    
    /**
     * @test
     */
    public function it_returns_null_for_expired_token(): void
    {
        // Create an expired token
        $expiredToken = JWT::encode([
            'iss' => $this->jwtConfig['issuer'],
            'sub' => 'user-id',
            'type' => 'access',
            'exp' => time() - 3600, // Expired 1 hour ago
            'iat' => time() - 7200,
        ], $this->jwtConfig['secret'], 'HS256');
        
        // Should return null for expired token
        $result = $this->service->validateToken($expiredToken);
        
        $this->assertNull($result);
    }
    
    /**
     * @test
     */
    public function it_refreshes_access_token(): void
    {
        $userId = UserId::generate();
        $user = User::create(
            new Email('user@example.com'),
            'John',
            'Doe'
        );
        
        // Set user ID using reflection
        $reflection = new \ReflectionClass($user);
        $property = $reflection->getProperty('id');
        $property->setAccessible(true);
        $property->setValue($user, $userId);
        
        // Create a valid refresh token
        $refreshToken = JWT::encode([
            'iss' => $this->jwtConfig['issuer'],
            'sub' => $userId->getValue(),
            'type' => 'refresh',
            'exp' => time() + 86400,
            'iat' => time(),
        ], $this->jwtConfig['secret'], 'HS256');
        
        $this->userRepository->expects($this->once())
            ->method('getById')
            ->with($this->isInstanceOf(UserId::class))
            ->willReturn($user);
        
        $result = $this->service->refreshToken($refreshToken);
        
        $this->assertArrayHasKey('access_token', $result);
        $this->assertArrayHasKey('refresh_token', $result);
        $this->assertArrayHasKey('expires_in', $result);
    }
    
    /**
     * @test
     */
    public function it_logs_out_user(): void
    {
        $accessToken = JWT::encode([
            'iss' => $this->jwtConfig['issuer'],
            'sub' => 'user-id',
            'type' => 'access',
            'exp' => time() + 3600,
            'iat' => time(),
        ], $this->jwtConfig['secret'], 'HS256');
        
        // Should not throw exception
        $this->service->logout($accessToken);
        
        // Verify token is blacklisted
        $this->assertTrue($this->cache->hasItem('token_blacklist:' . $accessToken));
    }
    
    /**
     * @test
     */
    public function it_authenticates_via_ldap(): void
    {
        $username = 'john.doe';
        $password = 'LdapPassword123!';
        
        $ldapData = [
            'sAMAccountName' => $username,
            'mail' => 'john.doe@company.com',
            'givenName' => 'John',
            'sn' => 'Doe',
        ];
        
        $this->ldapService->expects($this->once())
            ->method('authenticate')
            ->with($username, $password)
            ->willReturn($ldapData);
        
        $user = User::createFromLdap($ldapData);
        
        $this->userRepository->expects($this->once())
            ->method('findByAdUsername')
            ->with($username)
            ->willReturn($user);
            
        $this->userRepository->expects($this->once())
            ->method('save')
            ->with($user);
        
        $result = $this->service->authenticateWithLdap($username, $password);
        
        $this->assertArrayHasKey('access_token', $result);
        $this->assertArrayHasKey('refresh_token', $result);
        $this->assertArrayHasKey('expires_in', $result);
    }
    
    /**
     * @test
     */
    public function it_checks_user_permission(): void
    {
        // Set current user using reflection
        $user = $this->createMock(User::class);
        $user->expects($this->once())
            ->method('hasPermission')
            ->with('users.create')
            ->willReturn(true);
            
        $reflection = new \ReflectionClass($this->service);
        $property = $reflection->getProperty('currentUser');
        $property->setAccessible(true);
        $property->setValue($this->service, $user);
        
        $hasPermission = $this->service->hasPermission('users.create');
        
        $this->assertTrue($hasPermission);
    }
} 