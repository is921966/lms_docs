<?php

namespace Tests\Unit\User\Application\Service;

use Tests\TestCase;
use App\User\Application\Service\SimpleAuthService;
use App\User\Domain\User;
use App\User\Domain\ValueObjects\Email;
use App\User\Domain\ValueObjects\Password;
use App\User\Domain\Repository\UserRepositoryInterface;
use App\User\Domain\Service\LdapServiceInterface;
use App\Common\Exceptions\AuthorizationException;
use Psr\Log\LoggerInterface;

class SimpleAuthServiceTest extends TestCase
{
    private SimpleAuthService $service;
    private $userRepository;
    private $ldapService;
    private $logger;
    
    protected function setUp(): void
    {
        parent::setUp();
        
        $this->userRepository = $this->createMock(UserRepositoryInterface::class);
        $this->ldapService = $this->createMock(LdapServiceInterface::class);
        $this->logger = $this->createMock(LoggerInterface::class);
        
        $jwtConfig = [
            'secret' => 'test-secret-key',
            'access_ttl' => 3600,
            'refresh_ttl' => 86400,
            'issuer' => 'test-issuer',
        ];
        
        $this->service = new SimpleAuthService(
            $this->userRepository,
            $this->ldapService,
            $jwtConfig,
            $this->logger
        );
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
} 