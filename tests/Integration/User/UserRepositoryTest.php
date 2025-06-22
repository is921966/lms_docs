<?php

namespace Tests\Integration\User;

use Tests\IntegrationTestCase;
use App\User\Infrastructure\Repository\UserRepository;
use App\User\Domain\User;
use App\User\Domain\Role;
use App\User\Domain\ValueObjects\Email;
use App\User\Domain\ValueObjects\Password;
use App\User\Domain\ValueObjects\UserId;

class UserRepositoryTest extends IntegrationTestCase
{
    private UserRepository $repository;
    
    protected array $fixtures = [
        'createRoles',
        'createUsers',
    ];
    
    protected function setUp(): void
    {
        parent::setUp();
        $this->repository = new UserRepository($this->entityManager);
    }
    
    protected function createRoles($em): void
    {
        $roles = [
            new Role('admin', 'Administrator'),
            new Role('manager', 'Manager'),
            new Role('employee', 'Employee'),
        ];
        
        foreach ($roles as $role) {
            $em->persist($role);
        }
    }
    
    protected function createUsers($em): void
    {
        $adminRole = $em->getRepository(Role::class)->findOneBy(['name' => 'admin']);
        $employeeRole = $em->getRepository(Role::class)->findOneBy(['name' => 'employee']);
        
        // Active admin user
        $admin = new User(
            UserId::generate(),
            new Email('admin@example.com'),
            'Admin',
            'User',
            Password::fromPlainText('AdminPass123!')
        );
        $admin->addRole($adminRole);
        $admin->setDepartment('IT');
        $em->persist($admin);
        
        // Active employee
        $employee1 = new User(
            UserId::generate(),
            new Email('john.doe@example.com'),
            'John',
            'Doe',
            Password::fromPlainText('Password123!')
        );
        $employee1->addRole($employeeRole);
        $employee1->setDepartment('Sales');
        $em->persist($employee1);
        
        // Inactive employee
        $employee2 = new User(
            UserId::generate(),
            new Email('jane.smith@example.com'),
            'Jane',
            'Smith',
            Password::fromPlainText('Password123!')
        );
        $employee2->addRole($employeeRole);
        $employee2->setDepartment('HR');
        $employee2->deactivate();
        $em->persist($employee2);
        
        // Deleted employee
        $employee3 = new User(
            UserId::generate(),
            new Email('deleted@example.com'),
            'Deleted',
            'User',
            Password::fromPlainText('Password123!')
        );
        $employee3->delete();
        $em->persist($employee3);
    }
    
    /**
     * @test
     */
    public function it_saves_and_finds_user_by_id(): void
    {
        $userId = UserId::generate();
        $user = new User(
            $userId,
            new Email('newuser@example.com'),
            'New',
            'User',
            Password::fromPlainText('Password123!')
        );
        
        $this->repository->save($user);
        $this->clearEntityManager();
        
        $foundUser = $this->repository->findById($userId->getValue());
        
        $this->assertNotNull($foundUser);
        $this->assertEquals('newuser@example.com', $foundUser->getEmail()->getValue());
        $this->assertEquals('New', $foundUser->getFirstName());
        $this->assertEquals('User', $foundUser->getLastName());
    }
    
    /**
     * @test
     */
    public function it_finds_user_by_email(): void
    {
        $user = $this->repository->findByEmail('admin@example.com');
        
        $this->assertNotNull($user);
        $this->assertEquals('Admin', $user->getFirstName());
        $this->assertTrue($user->hasRole('admin'));
    }
    
    /**
     * @test
     */
    public function it_finds_user_by_ad_username(): void
    {
        $user = new User(
            UserId::generate(),
            new Email('ldap@example.com'),
            'LDAP',
            'User',
            Password::fromPlainText('Password123!')
        );
        $user->setAdUsername('ldap.user');
        
        $this->repository->save($user);
        $this->clearEntityManager();
        
        $foundUser = $this->repository->findByAdUsername('ldap.user');
        
        $this->assertNotNull($foundUser);
        $this->assertEquals('ldap@example.com', $foundUser->getEmail()->getValue());
    }
    
    /**
     * @test
     */
    public function it_searches_users_with_filters(): void
    {
        $results = $this->repository->search([
            'search' => 'john',
            'status' => 'active',
        ]);
        
        $this->assertCount(1, $results['data']);
        $this->assertEquals('john.doe@example.com', $results['data'][0]->getEmail()->getValue());
        $this->assertEquals(1, $results['total']);
    }
    
    /**
     * @test
     */
    public function it_filters_by_role(): void
    {
        $results = $this->repository->search([
            'role' => 'employee',
        ]);
        
        $this->assertCount(2, $results['data']); // Active and inactive employees
        $this->assertEquals(2, $results['total']);
    }
    
    /**
     * @test
     */
    public function it_filters_by_department(): void
    {
        $results = $this->repository->search([
            'department' => 'Sales',
        ]);
        
        $this->assertCount(1, $results['data']);
        $this->assertEquals('John', $results['data'][0]->getFirstName());
    }
    
    /**
     * @test
     */
    public function it_excludes_deleted_users_by_default(): void
    {
        $results = $this->repository->search([]);
        
        $emails = array_map(fn($u) => $u->getEmail()->getValue(), $results['data']);
        $this->assertNotContains('deleted@example.com', $emails);
    }
    
    /**
     * @test
     */
    public function it_includes_deleted_users_when_specified(): void
    {
        $results = $this->repository->search(['include_deleted' => true]);
        
        $emails = array_map(fn($u) => $u->getEmail()->getValue(), $results['data']);
        $this->assertContains('deleted@example.com', $emails);
    }
    
    /**
     * @test
     */
    public function it_paginates_results(): void
    {
        // Add more users for pagination test
        for ($i = 1; $i <= 10; $i++) {
            $user = new User(
                UserId::generate(),
                new Email("user{$i}@example.com"),
                "User",
                "Number{$i}",
                Password::fromPlainText('Password123!')
            );
            $this->repository->save($user);
        }
        
        $page1 = $this->repository->search([], 1, 5);
        $page2 = $this->repository->search([], 2, 5);
        
        $this->assertCount(5, $page1['data']);
        $this->assertCount(5, $page2['data']);
        $this->assertEquals(1, $page1['page']);
        $this->assertEquals(2, $page2['page']);
        $this->assertEquals(13, $page1['total']); // 3 initial + 10 new
    }
    
    /**
     * @test
     */
    public function it_sorts_results(): void
    {
        $results = $this->repository->search([], 1, 20, 'email', 'asc');
        
        $emails = array_map(fn($u) => $u->getEmail()->getValue(), $results['data']);
        $sortedEmails = $emails;
        sort($sortedEmails);
        
        $this->assertEquals($sortedEmails, $emails);
    }
    
    /**
     * @test
     */
    public function it_gets_user_statistics(): void
    {
        $stats = $this->repository->getStatistics();
        
        $this->assertEquals(3, $stats['total']); // Excluding deleted
        $this->assertEquals(2, $stats['active']);
        $this->assertEquals(1, $stats['inactive']);
        $this->assertEquals(0, $stats['suspended']);
        $this->assertArrayHasKey('by_role', $stats);
        $this->assertArrayHasKey('by_department', $stats);
    }
    
    /**
     * @test
     */
    public function it_handles_transactions(): void
    {
        $this->beginTransaction();
        
        $user = new User(
            UserId::generate(),
            new Email('transaction@example.com'),
            'Transaction',
            'Test',
            Password::fromPlainText('Password123!')
        );
        
        $this->repository->save($user);
        
        // User should exist within transaction
        $this->assertEntityExists(User::class, ['email' => 'transaction@example.com']);
        
        $this->rollback();
        
        // User should not exist after rollback
        $this->assertEntityNotExists(User::class, ['email' => 'transaction@example.com']);
    }
    
    /**
     * @test
     */
    public function it_updates_existing_user(): void
    {
        $user = $this->repository->findByEmail('john.doe@example.com');
        $originalUpdatedAt = $user->getUpdatedAt();
        
        sleep(1); // Ensure timestamp difference
        
        $user->updateProfile([
            'firstName' => 'Jonathan',
            'department' => 'Marketing',
        ]);
        
        $this->repository->save($user);
        $this->clearEntityManager();
        
        $updatedUser = $this->repository->findByEmail('john.doe@example.com');
        
        $this->assertEquals('Jonathan', $updatedUser->getFirstName());
        $this->assertEquals('Marketing', $updatedUser->getDepartment());
        $this->assertGreaterThan($originalUpdatedAt, $updatedUser->getUpdatedAt());
    }
} 