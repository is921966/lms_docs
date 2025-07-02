<?php

namespace Tests\Unit\User\Application\Queries\GetUser;

use PHPUnit\Framework\TestCase;
use User\Application\Queries\GetUser\GetUserQuery;
use User\Application\Queries\GetUser\GetUserHandler;
use User\Domain\User;
use User\Domain\UserRepository;
use User\Domain\ValueObjects\Email;

class GetUserHandlerTest extends TestCase
{
    private GetUserHandler $handler;
    private UserRepository $repository;

    protected function setUp(): void
    {
        $this->repository = new \Tests\Stubs\InMemoryUserRepository();
        $this->handler = new GetUserHandler($this->repository);
    }

    public function testGetUserByIdSuccess()
    {
        // Arrange
        $user = User::create(
            new Email('john@example.com'),
            'John',
            'Doe'
        );
        $user->updateProfile('John', 'Doe', 'Middle', '+123456', 'IT Department');
        $this->repository->save($user);
        
        $query = new GetUserQuery((string) $user->getId());

        // Act
        $response = $this->handler->handle($query);

        // Assert
        $this->assertEquals((string) $user->getId(), $response->getId());
        $this->assertEquals('John', $response->getFirstName());
        $this->assertEquals('Doe', $response->getLastName());
        $this->assertEquals('Middle', $response->getMiddleName());
        $this->assertEquals('john@example.com', $response->getEmail());
        $this->assertEquals('+123456', $response->getPhone());
        $this->assertEquals('IT Department', $response->getDepartment());
        $this->assertEquals('active', $response->getStatus());
    }

    public function testGetNonExistentUser()
    {
        // Arrange
        $query = new GetUserQuery('550e8400-e29b-41d4-a716-446655440000');

        // Act & Assert
        $this->expectException(\DomainException::class);
        $this->expectExceptionMessage('User not found');
        $this->handler->handle($query);
    }

    public function testGetDeletedUser()
    {
        // Arrange
        $user = User::create(
            new Email('john@example.com'),
            'John',
            'Doe'
        );
        $this->repository->save($user);
        $user->delete();
        $this->repository->save($user);
        
        $query = new GetUserQuery((string) $user->getId());

        // Act
        $response = $this->handler->handle($query);

        // Assert
        $this->assertTrue($response->isDeleted());
        $this->assertEquals('inactive', $response->getStatus());
        $this->assertNotNull($response->getDeletedAt());
    }

    public function testGetUserWithFullProfile()
    {
        // Arrange
        $user = User::create(
            new Email('john@example.com'),
            'John',
            'Doe'
        );
        $user->updateProfile('John', 'Doe', 'Middle', '+123456', 'IT Department');
        $user->setAdminStatus(true);
        $this->repository->save($user);
        
        $query = new GetUserQuery((string) $user->getId());

        // Act
        $response = $this->handler->handle($query);

        // Assert
        $this->assertEquals('John Doe', $response->getFullName());
        $this->assertTrue($response->isAdmin());
        $this->assertNotNull($response->getCreatedAt());
        $this->assertNotNull($response->getUpdatedAt());
    }
} 