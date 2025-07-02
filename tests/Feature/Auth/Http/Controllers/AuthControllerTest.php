<?php

namespace Tests\Feature\Auth\Http\Controllers;

use Tests\FeatureTestCase;
use User\Domain\User;
use User\Domain\ValueObjects\Email;
use User\Domain\ValueObjects\Password;
use User\Infrastructure\Repositories\MySQLUserRepository;
use Auth\Infrastructure\Repositories\InMemoryTokenRepository;

class AuthControllerTest extends FeatureTestCase
{
    private MySQLUserRepository $userRepository;
    private InMemoryTokenRepository $tokenRepository;

    protected function setUp(): void
    {
        parent::setUp();
        
        $this->userRepository = new MySQLUserRepository($this->connection);
        $this->tokenRepository = new InMemoryTokenRepository();
        
        // Create test user
        $user = User::create(
            new Email('test@example.com'),
            'Test',
            'User'
        );
        $user->setPassword(Password::fromPlainText('password123'));
        $this->userRepository->save($user);
    }

    public function testLoginWithValidCredentials()
    {
        // Arrange
        $data = [
            'email' => 'test@example.com',
            'password' => 'password123'
        ];

        // Act
        $response = $this->postJson('/api/auth/login', $data);

        // Assert
        $response->assertStatus(200);
        $response->assertJsonStructure([
            'access_token',
            'refresh_token',
            'token_type',
            'expires_in'
        ]);
        $this->assertEquals('Bearer', $response->json('token_type'));
        $this->assertEquals(900, $response->json('expires_in'));
    }

    public function testLoginWithInvalidCredentials()
    {
        // Arrange
        $data = [
            'email' => 'test@example.com',
            'password' => 'wrong-password'
        ];

        // Act
        $response = $this->postJson('/api/auth/login', $data);

        // Assert
        $response->assertStatus(401);
        $response->assertJson([
            'error' => 'Unauthorized',
            'message' => 'Invalid credentials'
        ]);
    }

    public function testLoginValidation()
    {
        // Test missing email
        $response = $this->postJson('/api/auth/login', ['password' => 'password']);
        $response->assertStatus(422);
        $response->assertJsonValidationErrors(['email']);

        // Test invalid email format
        $response = $this->postJson('/api/auth/login', [
            'email' => 'invalid-email',
            'password' => 'password'
        ]);
        $response->assertStatus(422);
        $response->assertJsonValidationErrors(['email']);

        // Test missing password
        $response = $this->postJson('/api/auth/login', ['email' => 'test@example.com']);
        $response->assertStatus(422);
        $response->assertJsonValidationErrors(['password']);
    }

    public function testRefreshToken()
    {
        // First login to get tokens
        $loginResponse = $this->postJson('/api/auth/login', [
            'email' => 'test@example.com',
            'password' => 'password123'
        ]);
        
        $refreshToken = $loginResponse->json('refresh_token');

        // Act - refresh token
        $response = $this->postJson('/api/auth/refresh', [
            'refresh_token' => $refreshToken
        ]);

        // Assert
        $response->assertStatus(200);
        $response->assertJsonStructure([
            'access_token',
            'refresh_token',
            'token_type',
            'expires_in'
        ]);
        
        // New tokens should be different
        $this->assertNotEquals($loginResponse->json('access_token'), $response->json('access_token'));
        $this->assertNotEquals($refreshToken, $response->json('refresh_token'));
    }

    public function testRefreshWithInvalidToken()
    {
        // Act
        $response = $this->postJson('/api/auth/refresh', [
            'refresh_token' => 'invalid-token'
        ]);

        // Assert
        $response->assertStatus(401);
        $response->assertJson([
            'error' => 'Unauthorized',
            'message' => 'Invalid refresh token'
        ]);
    }

    public function testLogout()
    {
        // First login
        $loginResponse = $this->postJson('/api/auth/login', [
            'email' => 'test@example.com',
            'password' => 'password123'
        ]);
        
        $accessToken = $loginResponse->json('access_token');

        // Act - logout
        $response = $this->postJson('/api/auth/logout', [], [
            'Authorization' => 'Bearer ' . $accessToken
        ]);

        // Assert
        $response->assertStatus(200);
        $response->assertJson([
            'message' => 'Successfully logged out'
        ]);
    }

    public function testProtectedRoute()
    {
        // Try without token
        $response = $this->getJson('/api/users');
        $response->assertStatus(401);

        // Login and get token
        $loginResponse = $this->postJson('/api/auth/login', [
            'email' => 'test@example.com',
            'password' => 'password123'
        ]);
        
        $accessToken = $loginResponse->json('access_token');

        // Try with token
        $response = $this->getJson('/api/users', [
            'Authorization' => 'Bearer ' . $accessToken
        ]);
        $response->assertStatus(200);
    }
} 