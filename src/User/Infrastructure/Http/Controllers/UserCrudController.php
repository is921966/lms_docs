<?php

declare(strict_types=1);

namespace App\User\Infrastructure\Http\Controllers;

use App\Common\Http\BaseController;
use App\User\Domain\Service\UserServiceInterface;
use App\User\Domain\ValueObjects\UserId;
use Psr\Http\Message\ResponseInterface;
use Psr\Http\Message\ServerRequestInterface;

/**
 * Controller for basic user CRUD operations
 */
class UserCrudController extends BaseController
{
    public function __construct(
        private UserServiceInterface $userService
    ) {
    }
    
    /**
     * List users
     */
    public function index(ServerRequestInterface $request, ResponseInterface $response): ResponseInterface
    {
        $params = $request->getQueryParams();
        
        $criteria = [];
        
        if (!empty($params['status'])) {
            $criteria['status'] = $params['status'];
        }
        
        if (!empty($params['role'])) {
            $criteria['role'] = $params['role'];
        }
        
        if (!empty($params['search'])) {
            $criteria['search'] = $params['search'];
        }
        
        $page = (int) ($params['page'] ?? 1);
        $limit = (int) ($params['limit'] ?? 10);
        
        $criteria['limit'] = $limit;
        $criteria['offset'] = ($page - 1) * $limit;
        
        $users = $this->userService->searchUsers($criteria);
        
        return $this->json($response, [
            'data' => $users,
            'page' => $page,
            'limit' => $limit
        ]);
    }
    
    /**
     * Get user by ID
     */
    public function show(ServerRequestInterface $request, ResponseInterface $response): ResponseInterface
    {
        $userId = $request->getAttribute('id');
        
        try {
            $user = $this->userService->getUser(new UserId($userId));
            
            return $this->json($response, [
                'data' => $user
            ]);
        } catch (\Exception $e) {
            return $this->error($response, $e->getMessage(), 404);
        }
    }
    
    /**
     * Create new user
     */
    public function store(ServerRequestInterface $request, ResponseInterface $response): ResponseInterface
    {
        $data = $request->getParsedBody();
        
        try {
            $user = $this->userService->createUser($data);
            
            return $this->json($response, [
                'data' => $user,
                'message' => 'User created successfully'
            ], 201);
        } catch (\Exception $e) {
            return $this->error($response, $e->getMessage(), 400);
        }
    }
    
    /**
     * Update user
     */
    public function update(ServerRequestInterface $request, ResponseInterface $response): ResponseInterface
    {
        $userId = $request->getAttribute('id');
        $data = $request->getParsedBody();
        
        try {
            $user = $this->userService->updateUser(new UserId($userId), $data);
            
            return $this->json($response, [
                'data' => $user,
                'message' => 'User updated successfully'
            ]);
        } catch (\Exception $e) {
            return $this->error($response, $e->getMessage(), 400);
        }
    }
    
    /**
     * Delete user
     */
    public function destroy(ServerRequestInterface $request, ResponseInterface $response): ResponseInterface
    {
        $userId = $request->getAttribute('id');
        
        try {
            $this->userService->deleteUser(new UserId($userId));
            
            return $this->json($response, [
                'message' => 'User deleted successfully'
            ]);
        } catch (\Exception $e) {
            return $this->error($response, $e->getMessage(), 400);
        }
    }
    
    /**
     * Get user statistics
     */
    public function statistics(ServerRequestInterface $request, ResponseInterface $response): ResponseInterface
    {
        try {
            $stats = $this->userService->getStatistics();
            
            return $this->json($response, [
                'data' => $stats
            ]);
        } catch (\Exception $e) {
            return $this->error($response, $e->getMessage(), 500);
        }
    }
} 