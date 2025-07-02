<?php

declare(strict_types=1);

namespace User\Infrastructure\Http;

use App\Common\Http\BaseController;
use App\User\Domain\Service\UserServiceInterface;
use App\User\Infrastructure\Http\Controllers\UserCrudController;
use App\User\Infrastructure\Http\Controllers\UserStatusController;
use App\User\Infrastructure\Http\Controllers\UserRoleController;
use App\User\Infrastructure\Http\Controllers\UserImportExportController;
use Psr\Http\Message\ResponseInterface;
use Psr\Http\Message\ServerRequestInterface;

/**
 * Main user controller - routes to specialized controllers
 */
class UserController extends BaseController
{
    private UserCrudController $crudController;
    private UserStatusController $statusController;
    private UserRoleController $roleController;
    private UserImportExportController $importExportController;
    
    public function __construct(
        UserServiceInterface $userService
    ) {
        $this->crudController = new UserCrudController($userService);
        $this->statusController = new UserStatusController($userService);
        $this->roleController = new UserRoleController($userService);
        $this->importExportController = new UserImportExportController($userService);
    }
    
    // CRUD operations
    
    public function index(ServerRequestInterface $request, ResponseInterface $response): ResponseInterface
    {
        return $this->crudController->index($request, $response);
    }
    
    public function show(ServerRequestInterface $request, ResponseInterface $response): ResponseInterface
    {
        return $this->crudController->show($request, $response);
    }
    
    public function store(ServerRequestInterface $request, ResponseInterface $response): ResponseInterface
    {
        return $this->crudController->store($request, $response);
    }
    
    public function update(ServerRequestInterface $request, ResponseInterface $response): ResponseInterface
    {
        return $this->crudController->update($request, $response);
    }
    
    public function destroy(ServerRequestInterface $request, ResponseInterface $response): ResponseInterface
    {
        return $this->crudController->destroy($request, $response);
    }
    
    public function statistics(ServerRequestInterface $request, ResponseInterface $response): ResponseInterface
    {
        return $this->crudController->statistics($request, $response);
    }
    
    // Status operations
    
    public function restore(ServerRequestInterface $request, ResponseInterface $response): ResponseInterface
    {
        return $this->statusController->restore($request, $response);
    }
    
    public function activate(ServerRequestInterface $request, ResponseInterface $response): ResponseInterface
    {
        return $this->statusController->activate($request, $response);
    }
    
    public function deactivate(ServerRequestInterface $request, ResponseInterface $response): ResponseInterface
    {
        return $this->statusController->deactivate($request, $response);
    }
    
    public function suspend(ServerRequestInterface $request, ResponseInterface $response): ResponseInterface
    {
        return $this->statusController->suspend($request, $response);
    }
    
    // Role operations
    
    public function assignRoles(ServerRequestInterface $request, ResponseInterface $response): ResponseInterface
    {
        return $this->roleController->assignRoles($request, $response);
    }
    
    public function removeRoles(ServerRequestInterface $request, ResponseInterface $response): ResponseInterface
    {
        return $this->roleController->removeRoles($request, $response);
    }
    
    public function syncRoles(ServerRequestInterface $request, ResponseInterface $response): ResponseInterface
    {
        return $this->roleController->syncRoles($request, $response);
    }
    
    // Import/Export operations
    
    public function import(ServerRequestInterface $request, ResponseInterface $response): ResponseInterface
    {
        return $this->importExportController->import($request, $response);
    }
    
    public function export(ServerRequestInterface $request, ResponseInterface $response): ResponseInterface
    {
        return $this->importExportController->export($request, $response);
    }
    
    // Password reset (stays in main controller as it's a simple operation)
    
    public function resetPassword(ServerRequestInterface $request, ResponseInterface $response): ResponseInterface
    {
        $userId = $request->getAttribute('id');
        
        try {
            $tempPassword = $this->userService->resetPassword(new \App\User\Domain\ValueObjects\UserId($userId));
            
            return $this->json($response, [
                'data' => ['temp_password' => $tempPassword],
                'message' => 'Password reset successfully'
            ]);
        } catch (\Exception $e) {
            return $this->error($response, $e->getMessage(), 400);
        }
    }
} 