<?php

namespace Tests\Unit\User\Application\Service;

use Tests\TestCase;
use App\User\Application\Service\UserService;
use App\User\Domain\User;
use App\User\Domain\Role;
use App\User\Domain\ValueObjects\Email;
use App\User\Domain\ValueObjects\Password;
use App\User\Domain\ValueObjects\UserId;
use App\User\Domain\Repository\UserRepositoryInterface;
use App\User\Domain\Repository\RoleRepositoryInterface;
use App\Common\Exceptions\NotFoundException;
use App\Common\Exceptions\ValidationException;
use Psr\Log\LoggerInterface;

class FixedUserServiceTest extends TestCase
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
        $this->userRepository->expects($this->once())
            ->method('emailExists')
            ->with($this->isInstanceOf(Email::class))
            ->willReturn(true);
        
        $this->expectException(ValidationException::class);
        
        $this->service->createUser([
            'email' => 'existing@example.com',
            'firstName' => 'John',
            'lastName' => 'Doe',
        ]);
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
    
    /**
     * @test
     */
    public function it_updates_user(): void
    {
        $userId = UserId::generate();
        $user = User::create(
            new Email('user@example.com'),
            'John',
            'Doe'
        );
        
        // Используем reflection чтобы установить ID
        $reflection = new \ReflectionClass($user);
        $property = $reflection->getProperty('id');
        $property->setAccessible(true);
        $property->setValue($user, $userId);
        
        $this->userRepository->expects($this->once())
            ->method('getById')
            ->with($userId)
            ->willReturn($user);
        
        $this->userRepository->expects($this->once())
            ->method('save')
            ->with($user);
        
        $updatedUser = $this->service->updateUser($userId, [
            'firstName' => 'Jane',
            'lastName' => 'Smith',
        ]);
        
        $this->assertEquals('Jane', $updatedUser->getFirstName());
        $this->assertEquals('Smith', $updatedUser->getLastName());
    }
    
    /**
     * @test
     */
    public function it_activates_user(): void
    {
        $userId = UserId::generate();
        $user = User::create(
            new Email('user@example.com'),
            'John',
            'Doe'
        );
        $user->deactivate();
        
        $this->userRepository->expects($this->once())
            ->method('getById')
            ->with($userId)
            ->willReturn($user);
        
        $this->userRepository->expects($this->once())
            ->method('save')
            ->with($user);
        
        $activatedUser = $this->service->activateUser($userId);
        
        $this->assertTrue($activatedUser->isActive());
    }
    
    /**
     * @test
     */
    public function it_deletes_user(): void
    {
        $userId = UserId::generate();
        $user = User::create(
            new Email('user@example.com'),
            'John',
            'Doe'
        );
        
        $this->userRepository->expects($this->once())
            ->method('getById')
            ->with($userId)
            ->willReturn($user);
        
        $this->userRepository->expects($this->once())
            ->method('save')
            ->with($user);
        
        $this->service->deleteUser($userId);
        
        $this->assertTrue($user->isDeleted());
    }
} 