<?php

declare(strict_types=1);

namespace App\Position\Infrastructure\Http;

use App\Common\Http\BaseController;
use App\Position\Application\Service\ProfileService;
use App\Position\Application\DTO\CreateProfileDTO;
use App\Position\Application\DTO\UpdateProfileDTO;
use App\Position\Application\DTO\CompetencyRequirementDTO;
use App\Common\Exceptions\NotFoundException;
use App\Common\Exceptions\ValidationException;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\JsonResponse;

class ProfileController extends BaseController
{
    public function __construct(
        private readonly ProfileService $profileService
    ) {
    }
    
    // Integration test methods
    public function getProfile(string $positionId): array
    {
        try {
            $profile = $this->profileService->getByPositionId($positionId);
            return [
                'status' => 'success',
                'data' => $profile->toArray()
            ];
        } catch (NotFoundException $e) {
            return [
                'status' => 'error',
                'message' => $e->getMessage()
            ];
        }
    }
    
    public function createProfile(): array
    {
        try {
            $data = $_POST;
            
            $dto = new CreateProfileDTO(
                positionId: $data['positionId'],
                responsibilities: $data['responsibilities'] ?? [],
                requirements: $data['requirements'] ?? []
            );
            
            $profile = $this->profileService->createProfile($dto);
            return [
                'status' => 'success',
                'data' => $profile->toArray()
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
    
    public function updateProfile(string $positionId): array
    {
        try {
            $data = $_POST;
            
            $dto = new UpdateProfileDTO(
                responsibilities: $data['responsibilities'] ?? [],
                requirements: $data['requirements'] ?? []
            );
            
            $profile = $this->profileService->updateProfile($positionId, $dto);
            return [
                'status' => 'success',
                'data' => $profile->toArray()
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
    
    public function addCompetencyRequirement(string $positionId): array
    {
        try {
            $data = $_POST;
            
            $dto = new CompetencyRequirementDTO(
                competencyId: $data['competencyId'],
                minimumLevel: (int)$data['minimumLevel'],
                isRequired: $data['isRequired'] ?? true
            );
            
            $this->profileService->addCompetencyRequirement($positionId, $dto);
            return [
                'status' => 'success',
                'message' => 'Competency requirement added successfully'
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
    
    public function removeCompetencyRequirement(string $positionId, string $competencyId): array
    {
        try {
            $this->profileService->removeCompetencyRequirement($positionId, $competencyId);
            return [
                'status' => 'success',
                'message' => 'Competency requirement removed successfully'
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
    
    public function getProfilesByCompetency(string $competencyId): JsonResponse
    {
        try {
            $profiles = $this->profileService->getByCompetencyId($competencyId);
            
            return new JsonResponse([
                'status' => 'success',
                'data' => $profiles
            ]);
        } catch (\Exception $e) {
            return new JsonResponse([
                'status' => 'error',
                'message' => $e->getMessage()
            ], 500);
        }
    }
} 