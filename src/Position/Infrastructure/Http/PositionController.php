<?php

declare(strict_types=1);

namespace App\Position\Infrastructure\Http;

use App\Common\Http\BaseController;
use App\Position\Application\Service\PositionService;
use App\Position\Application\DTO\CreatePositionDTO;
use App\Position\Application\DTO\UpdatePositionDTO;
use App\Common\Exceptions\NotFoundException;
use App\Common\Exceptions\ValidationException;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\JsonResponse;

class PositionController extends BaseController
{
    public function __construct(
        private readonly PositionService $positionService
    ) {
    }
    
    public function getPosition(string $id): JsonResponse
    {
        try {
            $position = $this->positionService->getById($id);
            return new JsonResponse([
                'status' => 'success',
                'data' => $position
            ]);
        } catch (NotFoundException $e) {
            return new JsonResponse([
                'status' => 'error',
                'message' => $e->getMessage()
            ], 404);
        }
    }
    
    public function createPosition(Request $request): JsonResponse
    {
        try {
            $data = json_decode($request->getContent(), true);
            
            // Validate input
            $errors = $this->validateCreatePosition($data);
            if (!empty($errors)) {
                return new JsonResponse([
                    'status' => 'error',
                    'message' => 'Validation failed',
                    'errors' => $errors
                ], 400);
            }
            
            $dto = new CreatePositionDTO(
                code: $data['code'],
                title: $data['title'],
                department: $data['department'],
                level: $data['level'],
                description: $data['description'],
                parentId: $data['parentId'] ?? null
            );
            
            $position = $this->positionService->createPosition($dto);
            return new JsonResponse([
                'status' => 'success',
                'data' => $position
            ], 201);
            
        } catch (\Exception $e) {
            return new JsonResponse([
                'status' => 'error',
                'message' => $e->getMessage()
            ], 500);
        }
    }
    
    public function updatePosition(string $id, Request $request): JsonResponse
    {
        try {
            $data = json_decode($request->getContent(), true);
            
            $dto = new UpdatePositionDTO(
                title: $data['title'],
                description: $data['description'],
                level: $data['level']
            );
            
            $position = $this->positionService->updatePosition($id, $dto);
            return new JsonResponse([
                'status' => 'success',
                'data' => $position
            ]);
            
        } catch (NotFoundException $e) {
            return new JsonResponse([
                'status' => 'error',
                'message' => $e->getMessage()
            ], 404);
        } catch (\Exception $e) {
            return new JsonResponse([
                'status' => 'error',
                'message' => $e->getMessage()
            ], 500);
        }
    }
    
    public function archivePosition(string $id): JsonResponse
    {
        try {
            $this->positionService->archivePosition($id);
            return new JsonResponse([
                'status' => 'success',
                'message' => 'Position archived successfully'
            ]);
        } catch (NotFoundException $e) {
            return new JsonResponse([
                'status' => 'error',
                'message' => $e->getMessage()
            ], 404);
        } catch (\Exception $e) {
            return new JsonResponse([
                'status' => 'error',
                'message' => $e->getMessage()
            ], 500);
        }
    }
    
    public function getPositionsByDepartment(string $department): JsonResponse
    {
        try {
            $positions = $this->positionService->getByDepartment($department);
            return new JsonResponse([
                'status' => 'success',
                'data' => $positions
            ]);
        } catch (\Exception $e) {
            return new JsonResponse([
                'status' => 'error',
                'message' => $e->getMessage()
            ], 500);
        }
    }
    
    public function getActivePositions(): JsonResponse
    {
        try {
            $positions = $this->positionService->getActivePositions();
            return new JsonResponse([
                'status' => 'success',
                'data' => $positions
            ]);
        } catch (\Exception $e) {
            return new JsonResponse([
                'status' => 'error',
                'message' => $e->getMessage()
            ], 500);
        }
    }
    
    // Methods expected by integration tests
    public function index(): array
    {
        try {
            $positions = $this->positionService->getActivePositions();
            return [
                'status' => 'success',
                'data' => array_map(fn($dto) => $dto->toArray(), $positions)
            ];
        } catch (\Exception $e) {
            return [
                'status' => 'error',
                'message' => $e->getMessage()
            ];
        }
    }
    
    public function show(string $id): array
    {
        try {
            $position = $this->positionService->getById($id);
            return [
                'status' => 'success',
                'data' => $position->toArray()
            ];
        } catch (NotFoundException $e) {
            return [
                'status' => 'error',
                'message' => $e->getMessage()
            ];
        } catch (\Exception $e) {
            return [
                'status' => 'error', 
                'message' => $e->getMessage()
            ];
        }
    }
    
    public function store(): array
    {
        try {
            $data = $_POST;
            
            // Validate input
            $errors = $this->validateCreatePosition($data);
            if (!empty($errors)) {
                throw new ValidationException('Validation failed', $errors);
            }
            
            $dto = new CreatePositionDTO(
                code: $data['code'],
                title: $data['title'],
                department: $data['department'],
                level: (int)$data['level'],
                description: $data['description'],
                parentId: $data['parentId'] ?? null
            );
            
            $position = $this->positionService->createPosition($dto);
            return [
                'status' => 'success',
                'data' => $position->toArray()
            ];
            
        } catch (ValidationException $e) {
            return [
                'status' => 'error',
                'message' => $e->getMessage(),
                'errors' => $e->getErrors()
            ];
        } catch (\DomainException $e) {
            return [
                'status' => 'error',
                'message' => $e->getMessage()
            ];
        } catch (\Exception $e) {
            return [
                'status' => 'error',
                'message' => $e->getMessage()
            ];
        }
    }
    
    public function update(string $id): array
    {
        try {
            $data = $_POST;
            
            $dto = new UpdatePositionDTO(
                title: $data['title'],
                description: $data['description'],
                level: (int)$data['level']
            );
            
            $position = $this->positionService->updatePosition($id, $dto);
            return [
                'status' => 'success',
                'data' => $position->toArray()
            ];
            
        } catch (NotFoundException $e) {
            return [
                'status' => 'error',
                'message' => $e->getMessage()
            ];
        } catch (\Exception $e) {
            return [
                'status' => 'error',
                'message' => $e->getMessage()
            ];
        }
    }
    
    public function archive(string $id): array
    {
        try {
            $this->positionService->archivePosition($id);
            return [
                'status' => 'success',
                'message' => 'Position archived successfully'
            ];
        } catch (NotFoundException $e) {
            return [
                'status' => 'error',
                'message' => $e->getMessage()
            ];
        } catch (\Exception $e) {
            return [
                'status' => 'error',
                'message' => $e->getMessage()
            ];
        }
    }
    
    public function getByDepartment(string $department): array
    {
        try {
            $positions = $this->positionService->getByDepartment($department);
            return [
                'status' => 'success',
                'data' => array_map(fn($dto) => $dto->toArray(), $positions)
            ];
        } catch (\Exception $e) {
            return [
                'status' => 'error',
                'message' => $e->getMessage()
            ];
        }
    }
    
    private function validateCreatePosition(?array $data): array
    {
        $errors = [];
        
        if (!$data) {
            return ['general' => 'Invalid JSON data'];
        }
        
        if (empty($data['code']) || !preg_match('/^[A-Z]{2,5}-\d{3}$/', $data['code'])) {
            $errors['code'] = 'Invalid code format. Expected: 2-5 uppercase letters, hyphen, 3 digits';
        }
        
        if (empty($data['title'])) {
            $errors['title'] = 'Title is required';
        }
        
        if (empty($data['department'])) {
            $errors['department'] = 'Department is required';
        }
        
        if (empty($data['level']) || $data['level'] < 1 || $data['level'] > 6) {
            $errors['level'] = 'Level must be between 1 and 6';
        }
        
        if (empty($data['description'])) {
            $errors['description'] = 'Description is required';
        }
        
        return $errors;
    }
} 