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
use Symfony\Component\EventDispatcher\EventDispatcherInterface;

class UserServiceTest extends TestCase
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
    public function it_creates_user_with_valid_data(): void
    {
        $data = [
            'email' => 'newuser@example.com',
            'firstName' => 'John',
            'lastName' => 'Doe',
            'password' => 'SecurePassword123!',
            'roles' => ['employee'],
        ];
        
        $employeeRole = Role::create('employee', 'Employee');
        
        $this->roleRepository->expects($this->once())
            ->method('getDefaultRole')
            ->willReturn($employeeRole);
            
        $this->roleRepository->expects($this->once())
            ->method('findByNames')
            ->with(['employee'])
            ->willReturn([$employeeRole]);
        
        $this->userRepository->expects($this->once())
            ->method('emailExists')
            ->with($this->isInstanceOf(Email::class))
            ->willReturn(false);
        
        $this->userRepository->expects($this->once())
            ->method('save')
            ->with($this->isInstanceOf(User::class));
        
        $user = $this->service->createUser($data);
        
        $this->assertInstanceOf(User::class, $user);
        $this->assertEquals('newuser@example.com', $user->getEmail()->getValue());
        $this->assertEquals('John', $user->getFirstName());
        $this->assertEquals('Doe', $user->getLastName());
        $this->assertTrue($user->hasRole('employee'));
    }
    
    /**
     * @test
     */
    public function it_throws_exception_for_duplicate_email(): void
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
            'password' => 'Password123!',
        ]);
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
        
        // Set user ID using reflection
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
            'department' => 'HR',
        ]);
        
        $this->assertEquals('Jane', $updatedUser->getFirstName());
        $this->assertEquals('Smith', $updatedUser->getLastName());
        $this->assertEquals('HR', $updatedUser->getDepartment());
    }
    
    /**
     * @test
     */
    public function it_throws_not_found_exception(): void
    {
        $userId = UserId::generate();
        
        $this->userRepository->expects($this->once())
            ->method('getById')
            ->with($userId)
            ->willThrowException(new NotFoundException('User not found'));
        
        $this->expectException(NotFoundException::class);
        $this->expectExceptionMessage('User not found');
        
        $this->service->getUser($userId);
    }
    
    /**
     * @test
     */
    public function it_assigns_roles_to_user(): void
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
        
        $adminRole = Role::create('admin', 'Administrator');
        $managerRole = Role::create('manager', 'Manager');
        
        $this->userRepository->expects($this->once())
            ->method('getById')
            ->with($userId)
            ->willReturn($user);
        
        $this->roleRepository->expects($this->once())
            ->method('findByNames')
            ->with(['admin', 'manager'])
            ->willReturn([$adminRole, $managerRole]);
        
        $this->userRepository->expects($this->once())
            ->method('save')
            ->with($user);
        
        $assignedUser = $this->service->assignRoles($userId, ['admin', 'manager']);
        
        $this->assertTrue($assignedUser->hasRole('admin'));
        $this->assertTrue($assignedUser->hasRole('manager'));
    }
    
    /**
     * @test
     */
    public function it_changes_user_password(): void
    {
        $userId = UserId::generate();
        $currentPassword = 'CurrentPassword123!';
        $user = User::create(
            new Email('user@example.com'),
            'John',
            'Doe',
            Password::fromPlainText($currentPassword)
        );
        
        // Set user ID using reflection
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
        
        $this->service->changePassword(
            $userId,
            $currentPassword,
            'NewPassword123!'
        );
        
        $this->assertTrue($user->verifyPassword('NewPassword123!'));
    }
    
    /**
     * @test
     */
    public function it_searches_users_with_filters(): void
    {
        $filters = [
            'search' => 'john',
            'status' => 'active',
            'role' => 'employee',
        ];
        
        $user1 = User::create(
            new Email('john@example.com'),
            'John',
            'Doe'
        );
        
        $user2 = User::create(
            new Email('john2@example.com'),
            'John',
            'Smith'
        );
        
        $expectedUsers = [$user1, $user2];
        
        $this->userRepository->expects($this->once())
            ->method('search')
            ->with($filters)
            ->willReturn($expectedUsers);
        
        $result = $this->service->searchUsers($filters);
        
        $this->assertCount(2, $result);
        $this->assertSame($expectedUsers, $result);
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
        
        // Set user ID using reflection
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
        
        $activatedUser = $this->service->activateUser($userId);
        
        $this->assertTrue($activatedUser->isActive());
    }
    
    /**
     * @test
     */
    public function it_suspends_user(): void
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
        
        $this->userRepository->expects($this->once())
            ->method('getById')
            ->with($userId)
            ->willReturn($user);
        
        $this->userRepository->expects($this->once())
            ->method('save')
            ->with($user);
        
        $suspendedUser = $this->service->suspendUser(
            $userId,
            'Policy violation'
        );
        
        $this->assertTrue($suspendedUser->isSuspended());
    }
    
    /**
     * @test
     */
    public function it_deletes_and_restores_user(): void
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
        
        $this->userRepository->expects($this->exactly(2))
            ->method('getById')
            ->with($userId)
            ->willReturn($user);
        
        $this->userRepository->expects($this->exactly(2))
            ->method('save')
            ->with($user);
        
        // Delete
        $this->service->deleteUser($userId);
        $this->assertTrue($user->isDeleted());
        
        // Restore
        $restoredUser = $this->service->restoreUser($userId);
        $this->assertFalse($restoredUser->isDeleted());
    }
    
    /**
     * @test
     */
    public function it_validates_required_fields(): void
    {
        $this->expectException(ValidationException::class);
        
        $this->service->createUser([
            'email' => 'user@example.com',
            // Missing firstName and lastName
        ]);
    }
} 