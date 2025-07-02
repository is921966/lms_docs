<?php

namespace Tests\Integration\User\Infrastructure;

use Tests\Integration\IntegrationTestCase;
use User\Infrastructure\Persistence\MySQL\MySQLUserRepository;
use User\Domain\User;
use User\Domain\ValueObjects\Email;
use User\Domain\ValueObjects\UserId;
use PDO;

class MySQLUserRepositoryTest extends IntegrationTestCase
{
    private MySQLUserRepository $repository;
    private PDO $pdo;

    protected function setUp(): void
    {
        parent::setUp();
        
        // Использовать SQLite в памяти для тестов
        $this->pdo = new PDO('sqlite::memory:');
        $this->pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
        
        // Создать таблицу users
        $this->createUsersTable();
        
        $this->repository = new MySQLUserRepository($this->pdo);
    }

    private function createUsersTable(): void
    {
        $sql = "
            CREATE TABLE users (
                id VARCHAR(36) PRIMARY KEY,
                email VARCHAR(255) UNIQUE NOT NULL,
                password VARCHAR(255),
                first_name VARCHAR(100) NOT NULL,
                last_name VARCHAR(100) NOT NULL,
                middle_name VARCHAR(100),
                phone VARCHAR(20),
                department VARCHAR(100),
                display_name VARCHAR(255),
                position_title VARCHAR(100),
                position_id VARCHAR(36),
                manager_id VARCHAR(36),
                ad_username VARCHAR(100),
                status VARCHAR(20) NOT NULL DEFAULT 'active',
                is_admin BOOLEAN DEFAULT 0,
                deleted_at TIMESTAMP NULL,
                suspension_reason TEXT,
                suspended_until TIMESTAMP NULL,
                email_verified_at TIMESTAMP NULL,
                password_changed_at TIMESTAMP NULL,
                last_login_at TIMESTAMP NULL,
                last_login_ip VARCHAR(45),
                last_user_agent TEXT,
                login_count INTEGER DEFAULT 0,
                two_factor_enabled BOOLEAN DEFAULT 0,
                two_factor_secret VARCHAR(255),
                ldap_synced_at TIMESTAMP NULL,
                metadata TEXT,
                created_at TIMESTAMP NOT NULL,
                updated_at TIMESTAMP NOT NULL
            )
        ";
        
        $this->pdo->exec($sql);
    }

    protected function tearDown(): void
    {
        // SQLite в памяти автоматически очищается
        parent::tearDown();
    }

    public function testSaveAndFindById()
    {
        // Arrange
        $user = User::create(
            new Email('john@example.com'),
            'John',
            'Doe'
        );
        
        // Act
        $this->repository->save($user);
        $foundUser = $this->repository->findById($user->getId());
        
        // Assert
        $this->assertNotNull($foundUser);
        $this->assertEquals($user->getId()->getValue(), $foundUser->getId()->getValue());
        $this->assertEquals('John', $foundUser->getFirstName());
        $this->assertEquals('Doe', $foundUser->getLastName());
        $this->assertEquals('john@example.com', $foundUser->getEmail());
    }

    public function testFindByEmail()
    {
        // Arrange
        $user = User::create(
            new Email('john@example.com'),
            'John',
            'Doe'
        );
        $this->repository->save($user);
        
        // Act
        $foundUser = $this->repository->findByEmail('john@example.com');
        
        // Assert
        $this->assertNotNull($foundUser);
        $this->assertEquals('john@example.com', $foundUser->getEmail());
    }

    public function testUpdateUser()
    {
        // Arrange
        $user = User::create(
            new Email('john@example.com'),
            'John',
            'Doe'
        );
        $this->repository->save($user);
        
        // Act
        $user->updateProfile('Jane', 'Smith', 'Middle', '+123456', 'IT');
        $this->repository->save($user);
        
        $updatedUser = $this->repository->findById($user->getId());
        
        // Assert
        $this->assertEquals('Jane', $updatedUser->getFirstName());
        $this->assertEquals('Smith', $updatedUser->getLastName());
        $this->assertEquals('Middle', $updatedUser->getMiddleName());
        $this->assertEquals('+123456', $updatedUser->getPhone());
        $this->assertEquals('IT', $updatedUser->getDepartment());
    }

    public function testSoftDelete()
    {
        // Arrange
        $user = User::create(
            new Email('john@example.com'),
            'John',
            'Doe'
        );
        $this->repository->save($user);
        
        // Act
        $user->delete();
        $this->repository->save($user);
        
        $deletedUser = $this->repository->findById($user->getId());
        
        // Assert
        $this->assertNotNull($deletedUser);
        $this->assertTrue($deletedUser->isDeleted());
        $this->assertNotNull($deletedUser->getDeletedAt());
    }

    public function testFindAll()
    {
        // Arrange
        $users = [];
        for ($i = 1; $i <= 3; $i++) {
            $user = User::create(
                new Email("user{$i}@example.com"),
                "User{$i}",
                "Test{$i}"
            );
            $this->repository->save($user);
            $users[] = $user;
        }
        
        // Act
        $allUsers = $this->repository->findAll();
        
        // Assert
        $this->assertCount(3, $allUsers);
    }

    public function testFindNonExistentUser()
    {
        // Act
        $user = $this->repository->findById(UserId::generate());
        
        // Assert
        $this->assertNull($user);
    }

    public function testTransactionRollback()
    {
        // Arrange
        $user = User::create(
            new Email('john@example.com'),
            'John',
            'Doe'
        );
        
        // Act
        $this->pdo->beginTransaction();
        try {
            $this->repository->save($user);
            throw new \Exception('Simulated error');
        } catch (\Exception $e) {
            $this->pdo->rollBack();
        }
        
        // Assert
        $foundUser = $this->repository->findById($user->getId());
        $this->assertNull($foundUser);
    }
} 