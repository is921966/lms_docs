<?php

declare(strict_types=1);

namespace App\User\Infrastructure\Http;

use App\Common\Http\BaseController;
use App\User\Domain\Service\UserServiceInterface;
use App\User\Domain\ValueObjects\UserId;
use Psr\Http\Message\ResponseInterface;
use Psr\Http\Message\ServerRequestInterface;

/**
 * User profile controller
 */
class ProfileController extends BaseController
{
    public function __construct(
        private UserServiceInterface $userService
    ) {
    }
    
    /**
     * Get current user profile
     */
    public function show(ServerRequestInterface $request, ResponseInterface $response): ResponseInterface
    {
        $user = $this->getAuthUser($request);
        
        if (!$user) {
            return $this->error($response, 'Not authenticated', [], 401);
        }
        
        return $this->success($response, $this->transformProfile($user));
    }
    
    /**
     * Update current user profile
     */
    public function update(ServerRequestInterface $request, ResponseInterface $response): ResponseInterface
    {
        $user = $this->getAuthUser($request);
        
        if (!$user) {
            return $this->error($response, 'Not authenticated', [], 401);
        }
        
        $data = $this->getValidatedData($request);
        
        // Only allow updating certain fields
        $allowedFields = ['firstName', 'lastName', 'middleName', 'phone'];
        $updateData = array_intersect_key($data, array_flip($allowedFields));
        
        try {
            $updatedUser = $this->userService->updateUser(
                new UserId($user->getId()->getValue()),
                $updateData
            );
            
            return $this->success($response, $this->transformProfile($updatedUser), 'Profile updated successfully');
        } catch (\App\Common\Exceptions\ValidationException $e) {
            return $this->error($response, 'Validation failed', $e->getErrors(), 422);
        } catch (\Exception $e) {
            return $this->error($response, $e->getMessage(), [], 400);
        }
    }
    
    /**
     * Upload profile avatar
     */
    public function uploadAvatar(ServerRequestInterface $request, ResponseInterface $response): ResponseInterface
    {
        $user = $this->getAuthUser($request);
        
        if (!$user) {
            return $this->error($response, 'Not authenticated', [], 401);
        }
        
        $uploadedFiles = $request->getUploadedFiles();
        $avatarFile = $uploadedFiles['avatar'] ?? null;
        
        if (!$avatarFile || $avatarFile->getError() !== UPLOAD_ERR_OK) {
            return $this->error($response, 'Valid image file is required', [], 422);
        }
        
        // Validate file type
        $allowedTypes = ['image/jpeg', 'image/png', 'image/gif'];
        $fileType = $avatarFile->getClientMediaType();
        
        if (!in_array($fileType, $allowedTypes)) {
            return $this->error($response, 'Invalid file type. Only JPEG, PNG and GIF are allowed', [], 422);
        }
        
        // Validate file size (max 5MB)
        if ($avatarFile->getSize() > 5 * 1024 * 1024) {
            return $this->error($response, 'File size must not exceed 5MB', [], 422);
        }
        
        try {
            // Generate unique filename
            $extension = pathinfo($avatarFile->getClientFilename(), PATHINFO_EXTENSION);
            $filename = $user->getId()->getValue() . '_' . time() . '.' . $extension;
            $uploadPath = '/uploads/avatars/' . $filename;
            
            // Move uploaded file
            $avatarFile->moveTo($_ENV['UPLOAD_PATH'] . $uploadPath);
            
            // Update user avatar path
            $updatedUser = $this->userService->updateUser(
                new UserId($user->getId()->getValue()),
                ['avatarPath' => $uploadPath]
            );
            
            return $this->success($response, [
                'avatar_url' => $_ENV['APP_URL'] . $uploadPath
            ], 'Avatar uploaded successfully');
            
        } catch (\Exception $e) {
            return $this->error($response, 'Failed to upload avatar', [], 500);
        }
    }
    
    /**
     * Delete profile avatar
     */
    public function deleteAvatar(ServerRequestInterface $request, ResponseInterface $response): ResponseInterface
    {
        $user = $this->getAuthUser($request);
        
        if (!$user) {
            return $this->error($response, 'Not authenticated', [], 401);
        }
        
        try {
            // Remove avatar path
            $updatedUser = $this->userService->updateUser(
                new UserId($user->getId()->getValue()),
                ['avatarPath' => null]
            );
            
            return $this->success($response, null, 'Avatar deleted successfully');
        } catch (\Exception $e) {
            return $this->error($response, $e->getMessage(), [], 400);
        }
    }
    
    /**
     * Get user activities
     */
    public function activities(ServerRequestInterface $request, ResponseInterface $response): ResponseInterface
    {
        $user = $this->getAuthUser($request);
        
        if (!$user) {
            return $this->error($response, 'Not authenticated', [], 401);
        }
        
        // TODO: Implement activity tracking
        $activities = [
            [
                'type' => 'login',
                'description' => 'Logged in',
                'timestamp' => $user->getLastLoginAt()?->format('c'),
                'ip_address' => '127.0.0.1'
            ]
        ];
        
        return $this->success($response, $activities);
    }
    
    /**
     * Get user notifications preferences
     */
    public function notificationPreferences(ServerRequestInterface $request, ResponseInterface $response): ResponseInterface
    {
        $user = $this->getAuthUser($request);
        
        if (!$user) {
            return $this->error($response, 'Not authenticated', [], 401);
        }
        
        // TODO: Implement notification preferences
        $preferences = [
            'email_notifications' => true,
            'push_notifications' => false,
            'sms_notifications' => false,
            'notification_types' => [
                'course_assignments' => true,
                'course_deadlines' => true,
                'test_results' => true,
                'system_updates' => false
            ]
        ];
        
        return $this->success($response, $preferences);
    }
    
    /**
     * Update notification preferences
     */
    public function updateNotificationPreferences(ServerRequestInterface $request, ResponseInterface $response): ResponseInterface
    {
        $user = $this->getAuthUser($request);
        
        if (!$user) {
            return $this->error($response, 'Not authenticated', [], 401);
        }
        
        $data = $this->getValidatedData($request);
        
        // TODO: Implement notification preferences update
        
        return $this->success($response, $data, 'Notification preferences updated successfully');
    }
    
    /**
     * Transform user profile for response
     */
    private function transformProfile($user): array
    {
        return [
            'id' => $user->getId()->getValue(),
            'email' => $user->getEmail()->getValue(),
            'first_name' => $user->getFirstName(),
            'last_name' => $user->getLastName(),
            'middle_name' => $user->getMiddleName(),
            'full_name' => $user->getFullName(),
            'phone' => $user->getPhone(),
            'department' => $user->getDepartment(),
            'position_id' => $user->getPositionId(),
            'manager_id' => $user->getManagerId()?->getValue(),
            'avatar_url' => $user->getAvatarPath() ? $_ENV['APP_URL'] . $user->getAvatarPath() : null,
            'status' => $user->getStatus(),
            'is_admin' => $user->isAdmin(),
            'email_verified' => $user->isEmailVerified(),
            'two_factor_enabled' => $user->isTwoFactorEnabled(),
            'requires_password_change' => $user->requiresPasswordChange(),
            'created_at' => $user->getCreatedAt()->format('c'),
            'last_login_at' => $user->getLastLoginAt()?->format('c'),
            'roles' => array_map(fn($role) => [
                'id' => $role->getId(),
                'name' => $role->getName(),
                'description' => $role->getDescription()
            ], $user->getRoles()),
            'permissions' => $user->getPermissionIds(),
            'statistics' => [
                'courses_completed' => 0, // TODO: Implement
                'courses_in_progress' => 0, // TODO: Implement
                'average_score' => 0, // TODO: Implement
                'certificates_earned' => 0 // TODO: Implement
            ]
        ];
    }
} 