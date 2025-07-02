<?php

namespace Tests\Unit\User\Application\Commands\UpdateUser;

use PHPUnit\Framework\TestCase;
use User\Application\Commands\UpdateUser\UpdateUserCommand;
use User\Application\Commands\UpdateUser\UpdateUserHandler;
use User\Domain\User;
use User\Domain\UserRepository;
use User\Domain\ValueObjects\Email;
use User\Domain\ValueObjects\UserId;

class UpdateUserHandlerTest extends TestCase
{
    private UpdateUserHandler $handler;
    private UserRepository $repository;

    protected function setUp(): void
    {
        $this->repository = new \Tests\Stubs\InMemoryUserRepository();
        $this->handler = new UpdateUserHandler($this->repository);
    }

    public function testUpdateUserProfileSuccess()
    {
        // Arrange
        $user = User::create(
            new Email('john@example.com'),
            'John',
            'Doe'
        );
        $this->repository->save($user);
        
        $command = new UpdateUserCommand(
            (string) $user->getId(),
            'Jane',
            'Smith',
            'Marie',
            '+1234567890',
            'IT Department'
        );

        // Act
        $response = $this->handler->handle($command);

        // Assert
        $this->assertEquals('Jane', $response->getFirstName());
        $this->assertEquals('Smith', $response->getLastName());
        $this->assertEquals('Marie', $response->getMiddleName());
        $this->assertEquals('+1234567890', $response->getPhone());
        $this->assertEquals('IT Department', $response->getDepartment());
    }

    public function testUpdateUserEmailSuccess()
    {
        // Arrange
        $user = User::create(
            new Email('old@example.com'),
            'John',
            'Doe'
        );
        $this->repository->save($user);
        
        $command = new UpdateUserCommand(
            (string) $user->getId(),
            null,
            null,
            null,
            null,
            null,
            'new@example.com'
        );

        // Act
        $response = $this->handler->handle($command);

        // Assert
        $this->assertEquals('new@example.com', $response->getEmail());
    }

    public function testUpdateNonExistentUser()
    {
        // Arrange
        $command = new UpdateUserCommand(
            '550e8400-e29b-41d4-a716-446655440000', // Valid UUID format
            'Jane',
            'Doe'
        );

        // Act & Assert
        $this->expectException(\DomainException::class);
        $this->expectExceptionMessage('User not found');
        $this->handler->handle($command);
    }

    public function testUpdateWithInvalidEmail()
    {
        // Arrange
        $user = User::create(
            new Email('john@example.com'),
            'John',
            'Doe'
        );
        $this->repository->save($user);
        
        $command = new UpdateUserCommand(
            (string) $user->getId(),
            null,
            null,
            null,
            null,
            null,
            'invalid-email'
        );

        // Act & Assert
        $this->expectException(\InvalidArgumentException::class);
        $this->handler->handle($command);
    }

    public function testPartialUpdate()
    {
        // Arrange
        $user = User::create(
            new Email('john@example.com'),
            'John',
            'Doe'
        );
        $this->repository->save($user);
        
        $command = new UpdateUserCommand(
            (string) $user->getId(),
            'Jane', // Only update first name
            null,   // Keep last name
            null,
            null,
            null
        );

        // Act
        $response = $this->handler->handle($command);

        // Assert
        $this->assertEquals('Jane', $response->getFirstName());
        $this->assertEquals('Doe', $response->getLastName()); // Should remain unchanged
    }
} 