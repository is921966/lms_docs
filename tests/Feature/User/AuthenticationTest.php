<?php

namespace Tests\Feature\User;

use Tests\FeatureTestCase;
use App\User\Domain\User;
use App\User\Domain\ValueObjects\Email;
use App\User\Domain\ValueObjects\Password;
use App\User\Domain\ValueObjects\UserId;

class AuthenticationTest extends FeatureTestCase
{
    /**
     * @test
     */
    public function it_authenticates_user_with_valid_credentials(): void
    {
        $password = 'ValidPassword123!';
        $user = $this->createUser([
            'email' => 'test@example.com',
            'password' => $password,
        ]);
        
        $response = $this->postJson('/api/v1/auth/login', [
            'email' => 'test@example.com',
            'password' => $password,
        ]);
        
        $this->assertResponseOk($response);
        
        $data = $this->assertJsonSuccess($response);
        
        $this->assertArrayHasKey('data', $data);
        $this->assertArrayHasKey('access_token', $data['data']);
        $this->assertArrayHasKey('refresh_token', $data['data']);
        $this->assertArrayHasKey('expires_in', $data['data']);
        $this->assertArrayHasKey('token_type', $data['data']);
        $this->assertEquals('Bearer', $data['data']['token_type']);
        
        $this->assertArrayHasKey('user', $data['data']);
        $this->assertEquals('test@example.com', $data['data']['user']['email']);
    }
    
    /**
     * @test
     */
    public function it_fails_authentication_with_invalid_email(): void
    {
        $response = $this->postJson('/api/v1/auth/login', [
            'email' => 'nonexistent@example.com',
            'password' => 'Password123!',
        ]);
        
        $this->assertResponseUnauthorized($response);
        
        $data = $this->assertJsonError($response);
        $this->assertEquals('Invalid credentials', $data['message']);
    }
    
    /**
     * @test
     */
    public function it_fails_authentication_with_invalid_password(): void
    {
        $user = $this->createUser([
            'email' => 'test@example.com',
            'password' => 'CorrectPassword123!',
        ]);
        
        $response = $this->postJson('/api/v1/auth/login', [
            'email' => 'test@example.com',
            'password' => 'WrongPassword123!',
        ]);
        
        $this->assertResponseUnauthorized($response);
        
        $data = $this->assertJsonError($response);
        $this->assertEquals('Invalid credentials', $data['message']);
    }
    
    /**
     * @test
     */
    public function it_validates_login_request(): void
    {
        $response = $this->postJson('/api/v1/auth/login', [
            'email' => 'invalid-email',
            'password' => '',
        ]);
        
        $this->assertResponseValidationError($response);
        
        $data = $this->assertJsonError($response);
        $this->assertArrayHasKey('errors', $data);
        $this->assertArrayHasKey('email', $data['errors']);
        $this->assertArrayHasKey('password', $data['errors']);
    }
    
    /**
     * @test
     */
    public function it_refreshes_access_token(): void
    {
        $user = $this->createUser();
        
        // First login to get refresh token
        $loginResponse = $this->postJson('/api/v1/auth/login', [
            'email' => $user->getEmail()->getValue(),
            'password' => 'Password123!',
        ]);
        
        $loginData = $this->assertJsonSuccess($loginResponse);
        $refreshToken = $loginData['data']['refresh_token'];
        
        // Use refresh token
        $response = $this->postJson('/api/v1/auth/refresh', [
            'refresh_token' => $refreshToken,
        ]);
        
        $this->assertResponseOk($response);
        
        $data = $this->assertJsonSuccess($response);
        $this->assertArrayHasKey('access_token', $data['data']);
        $this->assertArrayHasKey('refresh_token', $data['data']);
        
        // New tokens should be different
        $this->assertNotEquals($loginData['data']['access_token'], $data['data']['access_token']);
    }
    
    /**
     * @test
     */
    public function it_logs_out_user(): void
    {
        $user = $this->createAuthenticatedUser();
        
        $response = $this->postJson('/api/v1/auth/logout');
        
        $this->assertResponseOk($response);
        $this->assertJsonSuccess($response);
        
        // Token should be invalidated
        $meResponse = $this->getJson('/api/v1/me');
        $this->assertResponseUnauthorized($meResponse);
    }
    
    /**
     * @test
     */
    public function it_gets_authenticated_user(): void
    {
        $user = $this->createAuthenticatedUser([
            'email' => 'me@example.com',
            'firstName' => 'John',
            'lastName' => 'Doe',
        ]);
        
        $response = $this->getJson('/api/v1/me');
        
        $this->assertResponseOk($response);
        
        $data = $this->assertJsonSuccess($response);
        $this->assertArrayHasKey('data', $data);
        
        $userData = $data['data'];
        $this->assertEquals('me@example.com', $userData['email']);
        $this->assertEquals('John', $userData['first_name']);
        $this->assertEquals('Doe', $userData['last_name']);
        $this->assertArrayHasKey('roles', $userData);
        $this->assertArrayHasKey('permissions', $userData);
    }
    
    /**
     * @test
     */
    public function it_requires_authentication_for_protected_routes(): void
    {
        $response = $this->getJson('/api/v1/users');
        
        $this->assertResponseUnauthorized($response);
        
        $data = $this->assertJsonError($response);
        $this->assertEquals('Unauthorized', $data['message']);
    }
    
    /**
     * @test
     */
    public function it_changes_user_password(): void
    {
        $currentPassword = 'CurrentPassword123!';
        $newPassword = 'NewPassword123!';
        
        $user = $this->createAuthenticatedUser([
            'password' => $currentPassword,
        ]);
        
        $response = $this->postJson('/api/v1/me/change-password', [
            'current_password' => $currentPassword,
            'new_password' => $newPassword,
            'new_password_confirmation' => $newPassword,
        ]);
        
        $this->assertResponseOk($response);
        $this->assertJsonSuccess($response);
        
        // Try to login with new password
        $loginResponse = $this->postJson('/api/v1/auth/login', [
            'email' => $user->getEmail()->getValue(),
            'password' => $newPassword,
        ]);
        
        $this->assertResponseOk($loginResponse);
    }
    
    /**
     * @test
     */
    public function it_handles_password_reset_flow(): void
    {
        $user = $this->createUser([
            'email' => 'reset@example.com',
        ]);
        
        // Request password reset
        $response = $this->postJson('/api/v1/auth/forgot-password', [
            'email' => 'reset@example.com',
        ]);
        
        $this->assertResponseOk($response);
        $data = $this->assertJsonSuccess($response);
        $this->assertEquals('Password reset link sent', $data['message']);
        
        // In real test, we would get the token from email/database
        $resetToken = 'test-reset-token';
        
        // Reset password
        $newPassword = 'NewResetPassword123!';
        $resetResponse = $this->postJson('/api/v1/auth/reset-password', [
            'token' => $resetToken,
            'password' => $newPassword,
            'password_confirmation' => $newPassword,
        ]);
        
        $this->assertResponseOk($resetResponse);
    }
    
    /**
     * @test
     */
    public function it_verifies_email_address(): void
    {
        $user = $this->createUser([
            'email' => 'unverified@example.com',
        ]);
        
        // User should not be verified
        $this->assertFalse($user->isEmailVerified());
        
        // In real test, we would get the token from email
        $verificationToken = 'test-verification-token';
        
        $response = $this->getJson('/api/v1/auth/verify-email/' . $verificationToken);
        
        $this->assertResponseOk($response);
        $data = $this->assertJsonSuccess($response);
        $this->assertEquals('Email verified successfully', $data['message']);
    }
    
    /**
     * @test
     */
    public function it_handles_two_factor_authentication(): void
    {
        $user = $this->createAuthenticatedUser();
        
        // Enable 2FA
        $enableResponse = $this->postJson('/api/v1/me/2fa/enable');
        
        $this->assertResponseOk($enableResponse);
        $data = $this->assertJsonSuccess($enableResponse);
        $this->assertArrayHasKey('secret', $data['data']);
        $this->assertArrayHasKey('qr_code', $data['data']);
        
        // Login should now require 2FA
        $loginResponse = $this->postJson('/api/v1/auth/login', [
            'email' => $user->getEmail()->getValue(),
            'password' => 'Password123!',
        ]);
        
        $this->assertResponseOk($loginResponse);
        $loginData = $this->assertJsonSuccess($loginResponse);
        $this->assertTrue($loginData['data']['requires_2fa']);
        
        // Verify 2FA code
        $verifyResponse = $this->postJson('/api/v1/auth/2fa/verify', [
            'user_id' => $user->getId()->getValue(),
            'code' => '123456', // In real test, generate valid TOTP
        ]);
        
        $this->assertResponseOk($verifyResponse);
        $verifyData = $this->assertJsonSuccess($verifyResponse);
        $this->assertArrayHasKey('access_token', $verifyData['data']);
    }
    
    /**
     * @test
     */
    public function it_blocks_inactive_users(): void
    {
        $user = $this->createUser([
            'email' => 'inactive@example.com',
            'password' => 'Password123!',
        ]);
        
        // Deactivate user
        $user->deactivate();
        $this->entityManager->flush();
        
        $response = $this->postJson('/api/v1/auth/login', [
            'email' => 'inactive@example.com',
            'password' => 'Password123!',
        ]);
        
        $this->assertResponseUnauthorized($response);
        $data = $this->assertJsonError($response);
        $this->assertEquals('Account is not active', $data['message']);
    }
} 