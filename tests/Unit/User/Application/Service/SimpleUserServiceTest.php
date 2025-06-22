<?php

namespace Tests\Unit\User\Application\Service;

use Tests\TestCase;
use App\User\Application\Service\UserService;
use App\User\Domain\Repository\UserRepositoryInterface;
use App\User\Domain\Repository\RoleRepositoryInterface;
use App\User\Domain\ValueObjects\Email;
use App\User\Domain\Role;
use App\Common\Exceptions\ValidationException;
use Psr\Log\LoggerInterface;

class SimpleUserServiceTest extends TestCase
{
    private UserService $service;
    private $userRepository;
    private $roleRepository;
    private $logger;
    
    protected function setUp(): void
    {
        parent::setUp();
        
        $this->userRepository = $this->createMock(UserRepositoryInterface::class);
        $this->roleRepository = $this->createMock(RoleRepositoryInterface::class);
        $this->logger = $this->createMock(LoggerInterface::class);
        
        $this->service = new UserService(
            $this->userRepository,
            $this->roleRepository,
            $this->logger
        );
    }
    
    /**
     * @test
     */
    public function it_validates_email_exists(): void
    {
        $data = [
            'email' => 'existing@example.com',
            'firstName' => 'John',
            'lastName' => 'Doe',
        ];
        
        $this->userRepository->expects($this->once())
            ->method('emailExists')
            ->with($this->isInstanceOf(Email::class))
            ->willReturn(true);
        
        $this->expectException(ValidationException::class);
        
        $this->service->createUser($data);
    }
    
    /**
     * @test
     */
    public function it_creates_user_with_minimal_data(): void
    {
        $data = [
            'email' => 'newuser@example.com',
            'firstName' => 'John',
            'lastName' => 'Doe',
        ];
        
        $defaultRole = Role::create('employee', 'Employee');
        
        $this->userRepository->expects($this->once())
            ->method('emailExists')
            ->willReturn(false);
            
        $this->roleRepository->expects($this->once())
            ->method('getDefaultRole')
            ->willReturn($defaultRole);
        
        $this->userRepository->expects($this->once())
            ->method('save');
        
        $user = $this->service->createUser($data);
        
        $this->assertEquals('newuser@example.com', $user->getEmail()->getValue());
        $this->assertEquals('John', $user->getFirstName());
        $this->assertEquals('Doe', $user->getLastName());
    }
} 