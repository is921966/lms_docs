<?php

namespace Tests\Feature\Api;

use Tests\FeatureTestCase;
use App\User\Domain\User;
use App\User\Domain\Role;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Symfony\Component\HttpFoundation\Response;

class UserApiTest extends FeatureTestCase
{
    use RefreshDatabase;

    private User $adminUser;
    private User $regularUser;
    private string $adminToken;
    private string $userToken;

    protected function setUp(): void
    {
        parent::setUp();

        // Create admin user
        $this->adminUser = User::create([
            'email' => 'admin@test.com',
            'name' => 'Admin User',
            'password' => bcrypt('password'),
            'role' => 'admin'
        ]);

        // Create regular user
        $this->regularUser = User::create([
            'email' => 'user@test.com',
            'name' => 'Regular User',
            'password' => bcrypt('password'),
            'role' => 'user'
        ]);

        // Get tokens
        $this->adminToken = $this->getTokenForUser($this->adminUser);
        $this->userToken = $this->getTokenForUser($this->regularUser);
    }

    /** @test */
    public function testGetAllUsers()
    {
        // Create additional test users
        User::factory()->count(5)->create();

        // Test as admin
        $response = $this->withToken($this->adminToken)
            ->getJson('/api/v1/users');

        $response->assertStatus(Response::HTTP_OK)
            ->assertJsonStructure([
                'data' => [
                    '*' => [
                        'id',
                        'email',
                        'name',
                        'role',
                        'created_at',
                        'updated_at'
                    ]
                ],
                'meta' => [
                    'current_page',
                    'total',
                    'per_page'
                ]
            ]);

        $this->assertCount(7, $response->json('data')); // 2 setup + 5 created
    }

    /** @test */
    public function testGetAllUsersRequiresAuthentication()
    {
        $response = $this->getJson('/api/v1/users');

        $response->assertStatus(Response::HTTP_UNAUTHORIZED);
    }

    /** @test */
    public function testGetAllUsersWithPagination()
    {
        User::factory()->count(25)->create();

        $response = $this->withToken($this->adminToken)
            ->getJson('/api/v1/users?page=2&per_page=10');

        $response->assertStatus(Response::HTTP_OK)
            ->assertJsonPath('meta.current_page', 2)
            ->assertJsonPath('meta.per_page', 10);

        $this->assertCount(10, $response->json('data'));
    }

    /** @test */
    public function testCreateUser()
    {
        $userData = [
            'email' => 'newuser@test.com',
            'name' => 'New User',
            'password' => 'password123',
            'password_confirmation' => 'password123',
            'role' => 'user'
        ];

        $response = $this->withToken($this->adminToken)
            ->postJson('/api/v1/users', $userData);

        $response->assertStatus(Response::HTTP_CREATED)
            ->assertJsonStructure([
                'data' => [
                    'id',
                    'email',
                    'name',
                    'role',
                    'created_at'
                ]
            ])
            ->assertJsonPath('data.email', 'newuser@test.com')
            ->assertJsonPath('data.name', 'New User');

        $this->assertDatabaseHas('users', [
            'email' => 'newuser@test.com',
            'name' => 'New User'
        ]);
    }

    /** @test */
    public function testCreateUserValidation()
    {
        $invalidData = [
            'email' => 'invalid-email',
            'name' => '',
            'password' => '123', // Too short
            'role' => 'invalid_role'
        ];

        $response = $this->withToken($this->adminToken)
            ->postJson('/api/v1/users', $invalidData);

        $response->assertStatus(Response::HTTP_UNPROCESSABLE_ENTITY)
            ->assertJsonValidationErrors(['email', 'name', 'password', 'role']);
    }

    /** @test */
    public function testCreateUserRequiresAdminRole()
    {
        $userData = [
            'email' => 'newuser@test.com',
            'name' => 'New User',
            'password' => 'password123',
            'password_confirmation' => 'password123',
            'role' => 'user'
        ];

        $response = $this->withToken($this->userToken)
            ->postJson('/api/v1/users', $userData);

        $response->assertStatus(Response::HTTP_FORBIDDEN);
    }

    /** @test */
    public function testUpdateUser()
    {
        $updateData = [
            'name' => 'Updated Name',
            'role' => 'instructor'
        ];

        $response = $this->withToken($this->adminToken)
            ->putJson("/api/v1/users/{$this->regularUser->id}", $updateData);

        $response->assertStatus(Response::HTTP_OK)
            ->assertJsonPath('data.name', 'Updated Name')
            ->assertJsonPath('data.role', 'instructor');

        $this->assertDatabaseHas('users', [
            'id' => $this->regularUser->id,
            'name' => 'Updated Name',
            'role' => 'instructor'
        ]);
    }

    /** @test */
    public function testUpdateUserEmailMustBeUnique()
    {
        $updateData = [
            'email' => $this->adminUser->email // Try to use admin's email
        ];

        $response = $this->withToken($this->adminToken)
            ->putJson("/api/v1/users/{$this->regularUser->id}", $updateData);

        $response->assertStatus(Response::HTTP_UNPROCESSABLE_ENTITY)
            ->assertJsonValidationErrors(['email']);
    }

    /** @test */
    public function testDeleteUser()
    {
        $userToDelete = User::factory()->create();

        $response = $this->withToken($this->adminToken)
            ->deleteJson("/api/v1/users/{$userToDelete->id}");

        $response->assertStatus(Response::HTTP_NO_CONTENT);

        $this->assertDatabaseMissing('users', [
            'id' => $userToDelete->id
        ]);
    }

    /** @test */
    public function testDeleteUserRequiresAdminRole()
    {
        $userToDelete = User::factory()->create();

        $response = $this->withToken($this->userToken)
            ->deleteJson("/api/v1/users/{$userToDelete->id}");

        $response->assertStatus(Response::HTTP_FORBIDDEN);

        // User should still exist
        $this->assertDatabaseHas('users', [
            'id' => $userToDelete->id
        ]);
    }

    /** @test */
    public function testUserSearch()
    {
        // Create users with specific names
        User::factory()->create(['name' => 'John Doe']);
        User::factory()->create(['name' => 'Jane Doe']);
        User::factory()->create(['name' => 'Bob Smith']);

        $response = $this->withToken($this->adminToken)
            ->getJson('/api/v1/users?search=Doe');

        $response->assertStatus(Response::HTTP_OK);

        $users = $response->json('data');
        $this->assertCount(2, $users);
        
        foreach ($users as $user) {
            $this->assertStringContainsString('Doe', $user['name']);
        }
    }

    /** @test */
    public function testUserFiltering()
    {
        // Create users with different roles
        User::factory()->count(3)->create(['role' => 'student']);
        User::factory()->count(2)->create(['role' => 'instructor']);

        $response = $this->withToken($this->adminToken)
            ->getJson('/api/v1/users?role=student');

        $response->assertStatus(Response::HTTP_OK);

        $users = $response->json('data');
        $this->assertCount(3, $users);
        
        foreach ($users as $user) {
            $this->assertEquals('student', $user['role']);
        }
    }

    /** @test */
    public function testGetUserProfile()
    {
        $response = $this->withToken($this->userToken)
            ->getJson('/api/v1/users/profile');

        $response->assertStatus(Response::HTTP_OK)
            ->assertJsonStructure([
                'data' => [
                    'id',
                    'email',
                    'name',
                    'role',
                    'permissions',
                    'created_at'
                ]
            ])
            ->assertJsonPath('data.email', $this->regularUser->email);
    }

    /** @test */
    public function testUpdateOwnProfile()
    {
        $updateData = [
            'name' => 'My New Name',
            'current_password' => 'password',
            'password' => 'newpassword123',
            'password_confirmation' => 'newpassword123'
        ];

        $response = $this->withToken($this->userToken)
            ->putJson('/api/v1/users/profile', $updateData);

        $response->assertStatus(Response::HTTP_OK)
            ->assertJsonPath('data.name', 'My New Name');

        // Test login with new password
        $loginResponse = $this->postJson('/api/v1/auth/login', [
            'email' => $this->regularUser->email,
            'password' => 'newpassword123'
        ]);

        $loginResponse->assertStatus(Response::HTTP_OK)
            ->assertJsonStructure(['access_token']);
    }

    /**
     * Helper method to get JWT token for user
     */
    private function getTokenForUser(User $user): string
    {
        $response = $this->postJson('/api/v1/auth/login', [
            'email' => $user->email,
            'password' => 'password'
        ]);

        return $response->json('access_token');
    }
} 