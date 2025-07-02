<?php

declare(strict_types=1);

namespace User\Infrastructure\Http\Controllers;

use App\Common\Http\BaseController;
use App\User\Domain\Service\UserServiceInterface;
use App\User\Domain\ValueObjects\UserId;
use Psr\Http\Message\ResponseInterface;
use Psr\Http\Message\ServerRequestInterface;

/**
 * Controller for user status management
 */
class UserStatusController extends BaseController
{
    public function __construct(
        private UserServiceInterface $userService
    ) {
    }
    
    /**
     * Restore deleted user
     */
    public function restore(ServerRequestInterface $request, ResponseInterface $response): ResponseInterface
    {
        $userId = $request->getAttribute('id');
        
        try {
            $user = $this->userService->restoreUser(new UserId($userId));
            
            return $this->json($response, [
                'data' => $user,
                'message' => 'User restored successfully'
            ]);
        } catch (\Exception $e) {
            return $this->error($response, $e->getMessage(), 400);
        }
    }
    
    /**
     * Activate user
     */
    public function activate(ServerRequestInterface $request, ResponseInterface $response): ResponseInterface
    {
        $userId = $request->getAttribute('id');
        
        try {
            $user = $this->userService->activateUser(new UserId($userId));
            
            return $this->json($response, [
                'data' => $user,
                'message' => 'User activated successfully'
            ]);
        } catch (\Exception $e) {
            return $this->error($response, $e->getMessage(), 400);
        }
    }
    
    /**
     * Deactivate user
     */
    public function deactivate(ServerRequestInterface $request, ResponseInterface $response): ResponseInterface
    {
        $userId = $request->getAttribute('id');
        
        try {
            $user = $this->userService->deactivateUser(new UserId($userId));
            
            return $this->json($response, [
                'data' => $user,
                'message' => 'User deactivated successfully'
            ]);
        } catch (\Exception $e) {
            return $this->error($response, $e->getMessage(), 400);
        }
    }
    
    /**
     * Suspend user
     */
    public function suspend(ServerRequestInterface $request, ResponseInterface $response): ResponseInterface
    {
        $userId = $request->getAttribute('id');
        $data = $request->getParsedBody();
        
        try {
            $user = $this->userService->suspendUser(
                new UserId($userId),
                $data['reason'] ?? null
            );
            
            return $this->json($response, [
                'data' => $user,
                'message' => 'User suspended successfully'
            ]);
        } catch (\Exception $e) {
            return $this->error($response, $e->getMessage(), 400);
        }
    }
} 