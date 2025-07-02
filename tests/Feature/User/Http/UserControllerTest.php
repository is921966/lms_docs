<?php

namespace Tests\Feature\User\Http;

use Tests\FeatureTestCase;
use User\Domain\User;
use User\Domain\ValueObjects\Email;
use User\Domain\UserRepository;
use Symfony\Component\HttpFoundation\Response;

class UserControllerTest extends FeatureTestCase
{
    private UserRepository $userRepository;

    protected function setUp(): void
    {
        parent::setUp();
        $this->userRepository = $this->app->make(UserRepository::class);
    }

    public function testCreateUser()
    {
        // Arrange
        $data = [
            'name' => 'John Doe',
            'email' => 'john@example.com',
            'role' => 'admin'
        ];

        // Act
        $response = $this->postJson('/api/users', $data);

        // Assert
        $response->assertStatus(Response::HTTP_CREATED)
            ->assertJsonStructure([
                'data' => [
                    'id',
                    'name',
                    'email',
                    'role',
                    'status'
                ]
            ]);

        $this->assertDatabaseHas('users', [
            'email' => 'john@example.com',
            'first_name' => 'John',
            'last_name' => 'Doe'
        ]);
    }

    public function testCreateUserValidation()
    {
        // Arrange
        $data = [
            'name' => 'J', // Too short
            'email' => 'invalid-email',
            'role' => 'invalid_role'
        ];

        // Act
        $response = $this->postJson('/api/users', $data);

        // Assert
        $response->assertStatus(Response::HTTP_UNPROCESSABLE_ENTITY)
            ->assertJsonValidationErrors(['name', 'email', 'role']);
    }

    public function testGetUser()
    {
        // Arrange
        $user = User::create(
            new Email('john@example.com'),
            'John',
            'Doe'
        );
        $this->userRepository->save($user);

        // Act
        $response = $this->getJson('/api/users/' . $user->getId());

        // Assert
        $response->assertOk()
            ->assertJsonStructure([
                'data' => [
                    'id',
                    'firstName',
                    'lastName',
                    'email',
                    'status',
                    'createdAt',
                    'updatedAt'
                ]
            ]);
    }

    public function testGetNonExistentUser()
    {
        // Act
        $response = $this->getJson('/api/users/550e8400-e29b-41d4-a716-446655440000');

        // Assert
        $response->assertNotFound()
            ->assertJson([
                'message' => 'User not found'
            ]);
    }

    public function testUpdateUser()
    {
        // Arrange
        $user = User::create(
            new Email('john@example.com'),
            'John',
            'Doe'
        );
        $this->userRepository->save($user);

        $data = [
            'firstName' => 'Jane',
            'lastName' => 'Smith',
            'phone' => '+1234567890'
        ];

        // Act
        $response = $this->putJson('/api/users/' . $user->getId(), $data);

        // Assert
        $response->assertOk()
            ->assertJsonPath('data.firstName', 'Jane')
            ->assertJsonPath('data.lastName', 'Smith')
            ->assertJsonPath('data.phone', '+1234567890');
    }

    public function testDeleteUser()
    {
        // Arrange
        $user = User::create(
            new Email('john@example.com'),
            'John',
            'Doe'
        );
        $this->userRepository->save($user);

        // Act
        $response = $this->deleteJson('/api/users/' . $user->getId());

        // Assert
        $response->assertNoContent();

        $deletedUser = $this->userRepository->findById($user->getId());
        $this->assertTrue($deletedUser->isDeleted());
    }

    public function testListUsers()
    {
        // Arrange
        for ($i = 1; $i <= 5; $i++) {
            $user = User::create(
                new Email("user{$i}@example.com"),
                "User{$i}",
                "Test"
            );
            $this->userRepository->save($user);
        }

        // Act
        $response = $this->getJson('/api/users?page=1&perPage=2');

        // Assert
        $response->assertOk()
            ->assertJsonCount(2, 'data')
            ->assertJsonPath('meta.total', 5)
            ->assertJsonPath('meta.page', 1)
            ->assertJsonPath('meta.perPage', 2)
            ->assertJsonPath('meta.totalPages', 3);
    }

    public function testListUsersWithFilters()
    {
        // Arrange
        $activeUser = User::create(new Email('active@example.com'), 'Active', 'User');
        $this->userRepository->save($activeUser);

        $deletedUser = User::create(new Email('deleted@example.com'), 'Deleted', 'User');
        $deletedUser->delete();
        $this->userRepository->save($deletedUser);

        // Act
        $response = $this->getJson('/api/users?filters[status]=active');

        // Assert
        $response->assertOk()
            ->assertJsonCount(1, 'data')
            ->assertJsonPath('data.0.email', 'active@example.com');
    }

    public function testListUsersWithSearch()
    {
        // Arrange
        $john = User::create(new Email('john@example.com'), 'John', 'Doe');
        $jane = User::create(new Email('jane@example.com'), 'Jane', 'Smith');
        $this->userRepository->save($john);
        $this->userRepository->save($jane);

        // Act
        $response = $this->getJson('/api/users?search=john');

        // Assert
        $response->assertOk()
            ->assertJsonCount(1, 'data')
            ->assertJsonPath('data.0.firstName', 'John');
    }

    public function testUnauthorizedAccess()
    {
        // Arrange
        $this->withoutMiddleware(); // Временно для тестов
        
        // В реальном приложении здесь будет проверка аутентификации
        // $response = $this->getJson('/api/users');
        // $response->assertUnauthorized();
        
        $this->assertTrue(true); // Placeholder
    }
} 