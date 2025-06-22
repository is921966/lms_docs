<?php

declare(strict_types=1);

namespace App\User\Infrastructure\Http\Controllers;

use App\Common\Http\BaseController;
use App\User\Domain\Service\UserServiceInterface;
use App\User\Domain\ValueObjects\UserId;
use Psr\Http\Message\ResponseInterface;
use Psr\Http\Message\ServerRequestInterface;

/**
 * Controller for user role management
 */
class UserRoleController extends BaseController
{
    public function __construct(
        private UserServiceInterface $userService
    ) {
    }
    
    /**
     * Assign roles to user
     */
    public function assignRoles(ServerRequestInterface $request, ResponseInterface $response): ResponseInterface
    {
        $userId = $request->getAttribute('id');
        $data = $request->getParsedBody();
        
        if (empty($data['roles']) || !is_array($data['roles'])) {
            return $this->error($response, 'Roles must be provided as an array', 400);
        }
        
        try {
            $user = $this->userService->assignRoles(
                new UserId($userId),
                $data['roles']
            );
            
            return $this->json($response, [
                'data' => $user,
                'message' => 'Roles assigned successfully'
            ]);
        } catch (\Exception $e) {
            return $this->error($response, $e->getMessage(), 400);
        }
    }
    
    /**
     * Remove roles from user
     */
    public function removeRoles(ServerRequestInterface $request, ResponseInterface $response): ResponseInterface
    {
        $userId = $request->getAttribute('id');
        $data = $request->getParsedBody();
        
        if (empty($data['roles']) || !is_array($data['roles'])) {
            return $this->error($response, 'Roles must be provided as an array', 400);
        }
        
        try {
            $user = $this->userService->removeRoles(
                new UserId($userId),
                $data['roles']
            );
            
            return $this->json($response, [
                'data' => $user,
                'message' => 'Roles removed successfully'
            ]);
        } catch (\Exception $e) {
            return $this->error($response, $e->getMessage(), 400);
        }
    }
    
    /**
     * Sync user roles
     */
    public function syncRoles(ServerRequestInterface $request, ResponseInterface $response): ResponseInterface
    {
        $userId = $request->getAttribute('id');
        $data = $request->getParsedBody();
        
        if (!isset($data['roles']) || !is_array($data['roles'])) {
            return $this->error($response, 'Roles must be provided as an array', 400);
        }
        
        try {
            $user = $this->userService->syncRoles(
                new UserId($userId),
                $data['roles']
            );
            
            return $this->json($response, [
                'data' => $user,
                'message' => 'Roles synced successfully'
            ]);
        } catch (\Exception $e) {
            return $this->error($response, $e->getMessage(), 400);
        }
    }
} 