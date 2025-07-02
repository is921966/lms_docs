<?php

namespace Tests\Unit\User\Application\Commands\DeleteUser;

use PHPUnit\Framework\TestCase;
use User\Application\Commands\DeleteUser\DeleteUserCommand;
use User\Application\Commands\DeleteUser\DeleteUserHandler;
use User\Domain\User;
use User\Domain\UserRepository;
use User\Domain\ValueObjects\Email;

class DeleteUserHandlerTest extends TestCase
{
    private DeleteUserHandler $handler;
    private UserRepository $repository;

    protected function setUp(): void
    {
        $this->repository = new \Tests\Stubs\InMemoryUserRepository();
        $this->handler = new DeleteUserHandler($this->repository);
    }

    public function testDeleteUserSuccess()
    {
        // Arrange
        $user = User::create(
            new Email('john@example.com'),
            'John',
            'Doe'
        );
        $this->repository->save($user);
        
        $command = new DeleteUserCommand((string) $user->getId());

        // Act
        $this->handler->handle($command);

        // Assert
        $deletedUser = $this->repository->findById($user->getId());
        $this->assertNotNull($deletedUser);
        $this->assertTrue($deletedUser->isDeleted());
        $this->assertEquals('inactive', $deletedUser->getStatus());
    }

    public function testDeleteNonExistentUser()
    {
        // Arrange
        $command = new DeleteUserCommand('550e8400-e29b-41d4-a716-446655440000');

        // Act & Assert
        $this->expectException(\DomainException::class);
        $this->expectExceptionMessage('User not found');
        $this->handler->handle($command);
    }

    public function testDeleteAlreadyDeletedUser()
    {
        // Arrange
        $user = User::create(
            new Email('john@example.com'),
            'John',
            'Doe'
        );
        $this->repository->save($user);
        
        // First deletion
        $command = new DeleteUserCommand((string) $user->getId());
        $this->handler->handle($command);

        // Act & Assert - Second deletion
        $this->expectException(\DomainException::class);
        $this->expectExceptionMessage('User is already deleted');
        $this->handler->handle($command);
    }

    public function testDeletePreservesUserData()
    {
        // Arrange
        $user = User::create(
            new Email('john@example.com'),
            'John',
            'Doe'
        );
        $user->updateProfile('John', 'Doe', 'Middle', '+123456', 'IT');
        $this->repository->save($user);
        
        $command = new DeleteUserCommand((string) $user->getId());

        // Act
        $this->handler->handle($command);

        // Assert - User data should be preserved
        $deletedUser = $this->repository->findById($user->getId());
        $this->assertEquals('John', $deletedUser->getFirstName());
        $this->assertEquals('Doe', $deletedUser->getLastName());
        $this->assertEquals('john@example.com', $deletedUser->getEmail());
        $this->assertEquals('+123456', $deletedUser->getPhone());
        $this->assertEquals('IT', $deletedUser->getDepartment());
    }
} 