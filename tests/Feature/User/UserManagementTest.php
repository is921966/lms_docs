<?php

namespace Tests\Feature\User;

use Tests\FeatureTestCase;
use App\User\Domain\Role;
use App\User\Domain\Permission;

class UserManagementTest extends FeatureTestCase
{
    protected array $fixtures = [
        'createRolesAndPermissions',
    ];
    
    protected function createRolesAndPermissions($em): void
    {
        // Create permissions
        $permissions = [
            new Permission('users.view', 'View users', 'users'),
            new Permission('users.create', 'Create users', 'users'),
            new Permission('users.update', 'Update users', 'users'),
            new Permission('users.delete', 'Delete users', 'users'),
            new Permission('users.manage_roles', 'Manage user roles', 'users'),
        ];
        
        foreach ($permissions as $permission) {
            $em->persist($permission);
        }
        
        // Create admin role with all permissions
        $adminRole = new Role('admin', 'Administrator');
        foreach ($permissions as $permission) {
            $adminRole->addPermission($permission);
        }
        $em->persist($adminRole);
        
        // Create manager role with limited permissions
        $managerRole = new Role('manager', 'Manager');
        $managerRole->addPermission($permissions[0]); // view
        $managerRole->addPermission($permissions[2]); // update
        $em->persist($managerRole);
        
        // Create employee role with view only
        $employeeRole = new Role('employee', 'Employee');
        $employeeRole->addPermission($permissions[0]); // view
        $em->persist($employeeRole);
    }
    
    /**
     * @test
     */
    public function it_lists_users_with_pagination(): void
    {
        $admin = $this->createAuthenticatedUser();
        $this->assignRole($admin, 'admin');
        
        // Create test users
        for ($i = 1; $i <= 25; $i++) {
            $this->createUser([
                'email' => "user{$i}@example.com",
                'firstName' => "User",
                'lastName' => "Number{$i}",
            ]);
        }
        
        $response = $this->getJson('/api/v1/users?page=1&per_page=10');
        
        $this->assertResponseOk($response);
        $data = $this->assertJsonSuccess($response);
        
        $this->assertArrayHasKey('data', $data);
        $this->assertArrayHasKey('meta', $data);
        
        $this->assertCount(10, $data['data']);
        $this->assertEquals(26, $data['meta']['total']); // 25 + admin
        $this->assertEquals(1, $data['meta']['page']);
        $this->assertEquals(10, $data['meta']['per_page']);
        $this->assertEquals(3, $data['meta']['last_page']);
    }
    
    /**
     * @test
     */
    public function it_searches_users(): void
    {
        $admin = $this->createAuthenticatedUser();
        $this->assignRole($admin, 'admin');
        
        $this->createUser([
            'email' => 'john.doe@example.com',
            'firstName' => 'John',
            'lastName' => 'Doe',
        ]);
        
        $this->createUser([
            'email' => 'jane.smith@example.com',
            'firstName' => 'Jane',
            'lastName' => 'Smith',
        ]);
        
        $response = $this->getJson('/api/v1/users?q=john');
        
        $this->assertResponseOk($response);
        $data = $this->assertJsonSuccess($response);
        
        $this->assertCount(1, $data['data']);
        $this->assertEquals('john.doe@example.com', $data['data'][0]['email']);
    }
    
    /**
     * @test
     */
    public function it_creates_new_user(): void
    {
        $admin = $this->createAuthenticatedUser();
        $this->assignRole($admin, 'admin');
        
        $userData = [
            'email' => 'newuser@example.com',
            'firstName' => 'New',
            'lastName' => 'User',
            'password' => 'Password123!',
            'department' => 'IT',
            'phone' => '+1234567890',
            'roles' => ['employee'],
        ];
        
        $response = $this->postJson('/api/v1/users', $userData);
        
        $this->assertResponseCreated($response);
        $data = $this->assertJsonSuccess($response);
        
        $this->assertArrayHasKey('data', $data);
        $this->assertEquals('newuser@example.com', $data['data']['email']);
        $this->assertEquals('New', $data['data']['first_name']);
        $this->assertEquals('User', $data['data']['last_name']);
        $this->assertEquals('IT', $data['data']['department']);
        $this->assertContains('employee', array_column($data['data']['roles'], 'name'));
    }
    
    /**
     * @test
     */
    public function it_validates_user_creation(): void
    {
        $admin = $this->createAuthenticatedUser();
        $this->assignRole($admin, 'admin');
        
        $response = $this->postJson('/api/v1/users', [
            'email' => 'invalid-email',
            'firstName' => '',
            'password' => 'weak',
        ]);
        
        $this->assertResponseValidationError($response);
        $data = $this->assertJsonError($response);
        
        $this->assertArrayHasKey('errors', $data);
        $this->assertArrayHasKey('email', $data['errors']);
        $this->assertArrayHasKey('firstName', $data['errors']);
        $this->assertArrayHasKey('lastName', $data['errors']); // required
        $this->assertArrayHasKey('password', $data['errors']);
    }
    
    /**
     * @test
     */
    public function it_prevents_duplicate_email(): void
    {
        $admin = $this->createAuthenticatedUser();
        $this->assignRole($admin, 'admin');
        
        $existingUser = $this->createUser([
            'email' => 'existing@example.com',
        ]);
        
        $response = $this->postJson('/api/v1/users', [
            'email' => 'existing@example.com',
            'firstName' => 'Another',
            'lastName' => 'User',
            'password' => 'Password123!',
        ]);
        
        $this->assertResponseValidationError($response);
        $data = $this->assertJsonError($response);
        $this->assertStringContainsString('already exists', $data['message']);
    }
    
    /**
     * @test
     */
    public function it_updates_user(): void
    {
        $admin = $this->createAuthenticatedUser();
        $this->assignRole($admin, 'admin');
        
        $user = $this->createUser([
            'firstName' => 'Original',
            'lastName' => 'Name',
            'department' => 'Sales',
        ]);
        
        $response = $this->putJson("/api/v1/users/{$user->getId()->getValue()}", [
            'firstName' => 'Updated',
            'lastName' => 'Name',
            'department' => 'Marketing',
            'phone' => '+9876543210',
        ]);
        
        $this->assertResponseOk($response);
        $data = $this->assertJsonSuccess($response);
        
        $this->assertEquals('Updated', $data['data']['first_name']);
        $this->assertEquals('Marketing', $data['data']['department']);
        $this->assertEquals('+9876543210', $data['data']['phone']);
    }
    
    /**
     * @test
     */
    public function it_deletes_user(): void
    {
        $admin = $this->createAuthenticatedUser();
        $this->assignRole($admin, 'admin');
        
        $user = $this->createUser();
        
        $response = $this->deleteJson("/api/v1/users/{$user->getId()->getValue()}");
        
        $this->assertResponseOk($response);
        $this->assertJsonSuccess($response);
        
        // User should be soft deleted
        $getResponse = $this->getJson("/api/v1/users/{$user->getId()->getValue()}");
        $this->assertResponseNotFound($getResponse);
    }
    
    /**
     * @test
     */
    public function it_restores_deleted_user(): void
    {
        $admin = $this->createAuthenticatedUser();
        $this->assignRole($admin, 'admin');
        
        $user = $this->createUser();
        $user->delete();
        $this->entityManager->flush();
        
        $response = $this->postJson("/api/v1/users/{$user->getId()->getValue()}/restore");
        
        $this->assertResponseOk($response);
        $data = $this->assertJsonSuccess($response);
        
        $this->assertFalse($data['data']['is_deleted']);
    }
    
    /**
     * @test
     */
    public function it_activates_and_deactivates_user(): void
    {
        $admin = $this->createAuthenticatedUser();
        $this->assignRole($admin, 'admin');
        
        $user = $this->createUser();
        
        // Deactivate
        $response = $this->postJson("/api/v1/users/{$user->getId()->getValue()}/deactivate");
        
        $this->assertResponseOk($response);
        $data = $this->assertJsonSuccess($response);
        $this->assertEquals('inactive', $data['data']['status']);
        
        // Activate
        $response = $this->postJson("/api/v1/users/{$user->getId()->getValue()}/activate");
        
        $this->assertResponseOk($response);
        $data = $this->assertJsonSuccess($response);
        $this->assertEquals('active', $data['data']['status']);
    }
    
    /**
     * @test
     */
    public function it_manages_user_roles(): void
    {
        $admin = $this->createAuthenticatedUser();
        $this->assignRole($admin, 'admin');
        
        $user = $this->createUser();
        
        // Assign roles
        $response = $this->postJson("/api/v1/users/{$user->getId()->getValue()}/roles", [
            'roles' => ['manager', 'employee'],
        ]);
        
        $this->assertResponseOk($response);
        $data = $this->assertJsonSuccess($response);
        
        $roleNames = array_column($data['data']['roles'], 'name');
        $this->assertContains('manager', $roleNames);
        $this->assertContains('employee', $roleNames);
        
        // Sync roles (replace all)
        $response = $this->putJson("/api/v1/users/{$user->getId()->getValue()}/roles", [
            'roles' => ['employee'],
        ]);
        
        $this->assertResponseOk($response);
        $data = $this->assertJsonSuccess($response);
        
        $roleNames = array_column($data['data']['roles'], 'name');
        $this->assertCount(1, $roleNames);
        $this->assertContains('employee', $roleNames);
        $this->assertNotContains('manager', $roleNames);
    }
    
    /**
     * @test
     */
    public function it_enforces_permissions(): void
    {
        // Manager can view but not create
        $manager = $this->createAuthenticatedUser();
        $this->assignRole($manager, 'manager');
        
        // Can view users
        $response = $this->getJson('/api/v1/users');
        $this->assertResponseOk($response);
        
        // Cannot create users
        $response = $this->postJson('/api/v1/users', [
            'email' => 'test@example.com',
            'firstName' => 'Test',
            'lastName' => 'User',
            'password' => 'Password123!',
        ]);
        
        $this->assertResponseForbidden($response);
        $data = $this->assertJsonError($response);
        $this->assertStringContainsString('permission', $data['message']);
    }
    
    /**
     * @test
     */
    public function it_gets_user_statistics(): void
    {
        $admin = $this->createAuthenticatedUser();
        $this->assignRole($admin, 'admin');
        
        // Create various users
        $this->createUser(['status' => 'active']);
        $this->createUser(['status' => 'active']);
        $user = $this->createUser();
        $user->deactivate();
        $this->entityManager->flush();
        
        $response = $this->getJson('/api/v1/users/statistics');
        
        $this->assertResponseOk($response);
        $data = $this->assertJsonSuccess($response);
        
        $stats = $data['data'];
        $this->assertEquals(4, $stats['total']); // 3 + admin
        $this->assertEquals(3, $stats['active']);
        $this->assertEquals(1, $stats['inactive']);
        $this->assertArrayHasKey('by_role', $stats);
        $this->assertArrayHasKey('by_department', $stats);
    }
    
    /**
     * @test
     */
    public function it_imports_users_from_csv(): void
    {
        $admin = $this->createAuthenticatedUser();
        $this->assignRole($admin, 'admin');
        
        // Simulate CSV upload
        $csvData = [
            ['email' => 'import1@example.com', 'firstName' => 'Import', 'lastName' => 'One'],
            ['email' => 'import2@example.com', 'firstName' => 'Import', 'lastName' => 'Two'],
        ];
        
        $response = $this->postJson('/api/v1/users/import', [
            'data' => $csvData,
            'send_welcome_email' => false,
        ]);
        
        $this->assertResponseOk($response);
        $data = $this->assertJsonSuccess($response);
        
        $this->assertEquals(2, $data['data']['imported']);
        $this->assertEquals(0, $data['data']['failed']);
    }
    
    private function assignRole($user, string $roleName): void
    {
        $role = $this->entityManager->getRepository(Role::class)
            ->findOneBy(['name' => $roleName]);
        
        $user->addRole($role);
        $this->entityManager->flush();
    }
} 