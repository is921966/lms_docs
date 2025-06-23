<?php

declare(strict_types=1);

namespace App\Position\Infrastructure\Http;

use App\Common\Http\BaseController;
use App\Position\Application\Service\CareerPathService;
use App\Position\Application\DTO\CreateCareerPathDTO;
use App\Position\Application\DTO\AddMilestoneDTO;
use App\Common\Exceptions\NotFoundException;
use App\Common\Exceptions\ValidationException;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\JsonResponse;

class CareerPathController extends BaseController
{
    public function __construct(
        private readonly CareerPathService $careerPathService
    ) {
    }
    
    // Integration test methods
    public function createCareerPath(): array
    {
        try {
            $data = $_POST;
            
            $dto = new CreateCareerPathDTO(
                fromPositionId: $data['fromPositionId'],
                toPositionId: $data['toPositionId'],
                requirements: $data['requirements'] ?? [],
                estimatedDuration: (int)$data['estimatedDuration']
            );
            
            $careerPath = $this->careerPathService->createCareerPath($dto);
            return [
                'status' => 'success',
                'data' => $careerPath->toArray()
            ];
        } catch (NotFoundException $e) {
            return [
                'status' => 'error',
                'message' => $e->getMessage()
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
    
    public function getCareerPath(string $fromPositionId, string $toPositionId): array
    {
        try {
            $careerPath = $this->careerPathService->getCareerPath($fromPositionId, $toPositionId);
            return [
                'status' => 'success',
                'data' => $careerPath->toArray()
            ];
        } catch (NotFoundException $e) {
            return [
                'status' => 'error',
                'message' => $e->getMessage()
            ];
        }
    }
    
    public function addMilestone(string $id): array
    {
        try {
            $data = $_POST;
            
            $this->careerPathService->addMilestone(
                $id,
                $data['title'],
                $data['description'],
                (int)$data['monthsFromStart']
            );
            
            return [
                'status' => 'success',
                'message' => 'Milestone added successfully'
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
    
    public function getCareerProgress(string $fromPositionId, string $toPositionId): array
    {
        try {
            $employeeId = $_POST['employeeId'] ?? $_GET['employeeId'] ?? '';
            $monthsCompleted = (int)($_POST['monthsCompleted'] ?? $_GET['monthsCompleted'] ?? 0);
            
            $progress = $this->careerPathService->getCareerProgress(
                $fromPositionId,
                $toPositionId,
                $employeeId,
                $monthsCompleted
            );
            
            return [
                'status' => 'success',
                'data' => $progress->toArray()
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
    
    public function getActiveCareerPaths(): array
    {
        try {
            $paths = $this->careerPathService->getActiveCareerPaths();
            return [
                'status' => 'success',
                'data' => array_map(fn($path) => $path->toArray(), $paths)
            ];
        } catch (\Exception $e) {
            return [
                'status' => 'error',
                'message' => $e->getMessage()
            ];
        }
    }
    
    public function getCareerPathsFromPosition(string $positionId): array
    {
        try {
            $paths = $this->careerPathService->getCareerPathsFromPosition($positionId);
            return [
                'status' => 'success',
                'data' => array_map(fn($path) => $path->toArray(), $paths)
            ];
        } catch (\Exception $e) {
            return [
                'status' => 'error',
                'message' => $e->getMessage()
            ];
        }
    }
    
    public function deactivateCareerPath(string $id): array
    {
        try {
            $this->careerPathService->deactivateCareerPath($id);
            return [
                'status' => 'success',
                'message' => 'Career path deactivated successfully'
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
    
    public function activateCareerPath(string $id): array
    {
        try {
            $this->careerPathService->activateCareerPath($id);
            return [
                'status' => 'success',
                'message' => 'Career path activated successfully'
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
    
    public function getActiveByPositions(string $positionId): array
    {
        try {
            $paths = $this->careerPathService->getCareerPathsFromPosition($positionId);
            $activePaths = array_filter($paths, fn($path) => $path->isActive);
            
            return [
                'status' => 'success',
                'data' => array_map(fn($path) => $path->toArray(), array_values($activePaths))
            ];
        } catch (\Exception $e) {
            return [
                'status' => 'error',
                'message' => $e->getMessage()
            ];
        }
    }
} 