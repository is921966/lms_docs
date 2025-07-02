<?php

namespace Tests\Unit\User\Application\Queries\ListUsers;

use PHPUnit\Framework\TestCase;
use User\Application\Queries\ListUsers\ListUsersQuery;
use User\Application\Queries\ListUsers\ListUsersHandler;
use User\Domain\User;
use User\Domain\UserRepository;
use User\Domain\ValueObjects\Email;

class ListUsersHandlerTest extends TestCase
{
    private ListUsersHandler $handler;
    private UserRepository $repository;

    protected function setUp(): void
    {
        $this->repository = new \Tests\Stubs\InMemoryUserRepository();
        $this->handler = new ListUsersHandler($this->repository);
        
        // Подготовить тестовые данные
        $this->seedTestUsers();
    }

    private function seedTestUsers(): void
    {
        $users = [
            ['john@example.com', 'John', 'Doe', 'IT'],
            ['jane@example.com', 'Jane', 'Smith', 'HR'],
            ['bob@example.com', 'Bob', 'Johnson', 'IT'],
            ['alice@example.com', 'Alice', 'Williams', 'Finance'],
            ['charlie@example.com', 'Charlie', 'Brown', 'IT'],
        ];

        foreach ($users as [$email, $firstName, $lastName, $department]) {
            $user = User::create(new Email($email), $firstName, $lastName);
            $user->updateProfile($firstName, $lastName, null, null, $department);
            $this->repository->save($user);
        }
    }

    public function testListAllUsers()
    {
        // Arrange
        $query = new ListUsersQuery();

        // Act
        $response = $this->handler->handle($query);

        // Assert
        $this->assertCount(5, $response->getUsers());
        $this->assertEquals(5, $response->getTotal());
        $this->assertEquals(1, $response->getPage());
        $this->assertEquals(10, $response->getPerPage());
    }

    public function testListUsersWithPagination()
    {
        // Arrange
        $query = new ListUsersQuery(page: 1, perPage: 2);

        // Act
        $response = $this->handler->handle($query);

        // Assert
        $this->assertCount(2, $response->getUsers());
        $this->assertEquals(5, $response->getTotal());
        $this->assertEquals(1, $response->getPage());
        $this->assertEquals(2, $response->getPerPage());
        $this->assertEquals(3, $response->getTotalPages());
    }

    public function testListUsersSecondPage()
    {
        // Arrange
        $query = new ListUsersQuery(page: 2, perPage: 2);

        // Act
        $response = $this->handler->handle($query);

        // Assert
        $this->assertCount(2, $response->getUsers());
        $this->assertEquals(2, $response->getPage());
    }

    public function testFilterByDepartment()
    {
        // Arrange
        $query = new ListUsersQuery(filters: ['department' => 'IT']);

        // Act
        $response = $this->handler->handle($query);

        // Assert
        $this->assertCount(3, $response->getUsers());
        foreach ($response->getUsers() as $user) {
            $this->assertEquals('IT', $user['department']);
        }
    }

    public function testFilterByStatus()
    {
        // Arrange - удалить одного пользователя
        $users = $this->repository->findAll();
        $users[0]->delete();
        $this->repository->save($users[0]);

        $query = new ListUsersQuery(filters: ['status' => 'active']);

        // Act
        $response = $this->handler->handle($query);

        // Assert
        $this->assertCount(4, $response->getUsers());
        foreach ($response->getUsers() as $user) {
            $this->assertEquals('active', $user['status']);
        }
    }

    public function testSearchByName()
    {
        // Arrange
        $query = new ListUsersQuery(search: 'John');

        // Act
        $response = $this->handler->handle($query);

        // Assert
        $this->assertCount(2, $response->getUsers()); // John Doe и Bob Johnson
    }

    public function testSortByName()
    {
        // Arrange
        $query = new ListUsersQuery(sortBy: 'name', sortOrder: 'asc');

        // Act
        $response = $this->handler->handle($query);

        // Assert
        $users = $response->getUsers();
        $this->assertEquals('Alice', $users[0]['firstName']);
        $this->assertEquals('Bob', $users[1]['firstName']);
        $this->assertEquals('Charlie', $users[2]['firstName']);
    }

    public function testEmptyResultSet()
    {
        // Arrange
        $query = new ListUsersQuery(filters: ['department' => 'NonExistent']);

        // Act
        $response = $this->handler->handle($query);

        // Assert
        $this->assertCount(0, $response->getUsers());
        $this->assertEquals(0, $response->getTotal());
    }
} 