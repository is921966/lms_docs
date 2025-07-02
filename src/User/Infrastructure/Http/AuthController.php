<?php

declare(strict_types=1);

namespace User\Infrastructure\Http;

use App\Common\Http\BaseController;
use App\User\Domain\Service\AuthServiceInterface;
use App\User\Domain\Service\UserServiceInterface;
use App\User\Domain\ValueObjects\UserId;
use Psr\Http\Message\ResponseInterface;
use Psr\Http\Message\ServerRequestInterface;

/**
 * Authentication controller
 */
class AuthController extends BaseController
{
    public function __construct(
        private AuthServiceInterface $authService,
        private UserServiceInterface $userService
    ) {
    }
    
    /**
     * Login with email and password
     */
    public function login(ServerRequestInterface $request, ResponseInterface $response): ResponseInterface
    {
        $data = $this->getValidatedData($request);
        
        if (empty($data['email']) || empty($data['password'])) {
            return $this->error($response, 'Email and password are required', [], 422);
        }
        
        try {
            $tokens = $this->authService->authenticate($data['email'], $data['password']);
            return $this->success($response, $tokens, 'Login successful');
        } catch (\App\Common\Exceptions\AuthorizationException $e) {
            return $this->error($response, $e->getMessage(), [], 401);
        } catch (\Exception $e) {
            return $this->error($response, 'Authentication failed', [], 401);
        }
    }
    
    /**
     * Login with LDAP
     */
    public function ldapLogin(ServerRequestInterface $request, ResponseInterface $response): ResponseInterface
    {
        $data = $this->getValidatedData($request);
        
        if (empty($data['username']) || empty($data['password'])) {
            return $this->error($response, 'Username and password are required', [], 422);
        }
        
        try {
            $tokens = $this->authService->authenticateWithLdap($data['username'], $data['password']);
            return $this->success($response, $tokens, 'Login successful');
        } catch (\App\Common\Exceptions\AuthorizationException $e) {
            return $this->error($response, $e->getMessage(), [], 401);
        } catch (\Exception $e) {
            return $this->error($response, 'LDAP authentication failed', [], 401);
        }
    }
    
    /**
     * Refresh access token
     */
    public function refresh(ServerRequestInterface $request, ResponseInterface $response): ResponseInterface
    {
        $data = $this->getValidatedData($request);
        
        if (empty($data['refresh_token'])) {
            return $this->error($response, 'Refresh token is required', [], 422);
        }
        
        try {
            $tokens = $this->authService->refreshToken($data['refresh_token']);
            return $this->success($response, $tokens, 'Token refreshed successfully');
        } catch (\App\Common\Exceptions\AuthorizationException $e) {
            return $this->error($response, $e->getMessage(), [], 401);
        } catch (\Exception $e) {
            return $this->error($response, 'Token refresh failed', [], 401);
        }
    }
    
    /**
     * Logout
     */
    public function logout(ServerRequestInterface $request, ResponseInterface $response): ResponseInterface
    {
        $authHeader = $request->getHeaderLine('Authorization');
        
        if (empty($authHeader) || !str_starts_with($authHeader, 'Bearer ')) {
            return $this->error($response, 'No authentication token provided', [], 401);
        }
        
        $token = substr($authHeader, 7);
        
        try {
            $this->authService->logout($token);
            return $this->success($response, null, 'Logout successful');
        } catch (\Exception $e) {
            // Even if logout fails, we consider it successful
            return $this->success($response, null, 'Logout successful');
        }
    }
    
    /**
     * Get current user
     */
    public function me(ServerRequestInterface $request, ResponseInterface $response): ResponseInterface
    {
        $user = $this->getAuthUser($request);
        
        if (!$user) {
            return $this->error($response, 'Not authenticated', [], 401);
        }
        
        return $this->success($response, $this->transformUser($user));
    }
    
    /**
     * Change password
     */
    public function changePassword(ServerRequestInterface $request, ResponseInterface $response): ResponseInterface
    {
        $user = $this->getAuthUser($request);
        
        if (!$user) {
            return $this->error($response, 'Not authenticated', [], 401);
        }
        
        $data = $this->getValidatedData($request);
        
        if (empty($data['current_password']) || empty($data['new_password'])) {
            return $this->error($response, 'Current password and new password are required', [], 422);
        }
        
        if ($data['new_password'] !== ($data['new_password_confirmation'] ?? '')) {
            return $this->error($response, 'New password confirmation does not match', [], 422);
        }
        
        try {
            $this->userService->changePassword(
                new UserId($user->getId()->getValue()),
                $data['current_password'],
                $data['new_password']
            );
            
            return $this->success($response, null, 'Password changed successfully');
        } catch (\App\Common\Exceptions\ValidationException $e) {
            return $this->error($response, 'Validation failed', $e->getErrors(), 422);
        } catch (\Exception $e) {
            return $this->error($response, $e->getMessage(), [], 400);
        }
    }
    
    /**
     * Request password reset
     */
    public function forgotPassword(ServerRequestInterface $request, ResponseInterface $response): ResponseInterface
    {
        $data = $this->getValidatedData($request);
        
        if (empty($data['email'])) {
            return $this->error($response, 'Email is required', [], 422);
        }
        
        try {
            $this->authService->requestPasswordReset($data['email']);
            // Always return success to not reveal if email exists
            return $this->success($response, null, 'If the email exists, a password reset link has been sent');
        } catch (\Exception $e) {
            // Still return success for security
            return $this->success($response, null, 'If the email exists, a password reset link has been sent');
        }
    }
    
    /**
     * Reset password with token
     */
    public function resetPassword(ServerRequestInterface $request, ResponseInterface $response): ResponseInterface
    {
        $data = $this->getValidatedData($request);
        
        if (empty($data['token']) || empty($data['password'])) {
            return $this->error($response, 'Token and password are required', [], 422);
        }
        
        if ($data['password'] !== ($data['password_confirmation'] ?? '')) {
            return $this->error($response, 'Password confirmation does not match', [], 422);
        }
        
        try {
            $this->authService->resetPasswordWithToken($data['token'], $data['password']);
            return $this->success($response, null, 'Password reset successfully');
        } catch (\App\Common\Exceptions\ValidationException $e) {
            return $this->error($response, 'Validation failed', $e->getErrors(), 422);
        } catch (\Exception $e) {
            return $this->error($response, $e->getMessage(), [], 400);
        }
    }
    
    /**
     * Verify email
     */
    public function verifyEmail(ServerRequestInterface $request, ResponseInterface $response): ResponseInterface
    {
        $token = $this->getRouteParam($request, 'token');
        
        if (!$token) {
            return $this->error($response, 'Verification token is required', [], 400);
        }
        
        try {
            $this->authService->verifyEmail($token);
            return $this->success($response, null, 'Email verified successfully');
        } catch (\App\Common\Exceptions\ValidationException $e) {
            return $this->error($response, 'Validation failed', $e->getErrors(), 422);
        } catch (\Exception $e) {
            return $this->error($response, $e->getMessage(), [], 400);
        }
    }
    
    /**
     * Enable two-factor authentication
     */
    public function enableTwoFactor(ServerRequestInterface $request, ResponseInterface $response): ResponseInterface
    {
        $user = $this->getAuthUser($request);
        
        if (!$user) {
            return $this->error($response, 'Not authenticated', [], 401);
        }
        
        try {
            $result = $this->authService->enableTwoFactor($user);
            return $this->success($response, $result, 'Two-factor authentication enabled');
        } catch (\Exception $e) {
            return $this->error($response, $e->getMessage(), [], 400);
        }
    }
    
    /**
     * Disable two-factor authentication
     */
    public function disableTwoFactor(ServerRequestInterface $request, ResponseInterface $response): ResponseInterface
    {
        $user = $this->getAuthUser($request);
        
        if (!$user) {
            return $this->error($response, 'Not authenticated', [], 401);
        }
        
        $data = $this->getValidatedData($request);
        
        if (empty($data['password'])) {
            return $this->error($response, 'Password is required', [], 422);
        }
        
        try {
            $this->authService->disableTwoFactor($user, $data['password']);
            return $this->success($response, null, 'Two-factor authentication disabled');
        } catch (\App\Common\Exceptions\AuthorizationException $e) {
            return $this->error($response, $e->getMessage(), [], 401);
        } catch (\Exception $e) {
            return $this->error($response, $e->getMessage(), [], 400);
        }
    }
    
    /**
     * Verify two-factor code
     */
    public function verifyTwoFactor(ServerRequestInterface $request, ResponseInterface $response): ResponseInterface
    {
        $data = $this->getValidatedData($request);
        
        if (empty($data['code']) || empty($data['token'])) {
            return $this->error($response, 'Code and token are required', [], 422);
        }
        
        try {
            $tokens = $this->authService->verifyTwoFactorCode($data['code'], $data['token']);
            return $this->success($response, $tokens, 'Two-factor verification successful');
        } catch (\App\Common\Exceptions\AuthorizationException $e) {
            return $this->error($response, $e->getMessage(), [], 401);
        } catch (\Exception $e) {
            return $this->error($response, 'Two-factor verification failed', [], 401);
        }
    }
    
    /**
     * Transform user for response
     */
    private function transformUser($user): array
    {
        return [
            'id' => $user->getId()->getValue(),
            'email' => $user->getEmail()->getValue(),
            'first_name' => $user->getFirstName(),
            'last_name' => $user->getLastName(),
            'full_name' => $user->getFullName(),
            'department' => $user->getDepartment(),
            'position_id' => $user->getPositionId(),
            'is_admin' => $user->isAdmin(),
            'email_verified' => $user->isEmailVerified(),
            'two_factor_enabled' => $user->isTwoFactorEnabled(),
            'requires_password_change' => $user->requiresPasswordChange(),
            'roles' => array_map(fn($role) => [
                'id' => $role->getId(),
                'name' => $role->getName(),
                'description' => $role->getDescription()
            ], $user->getRoles()),
            'permissions' => $user->getPermissionIds()
        ];
    }
} 