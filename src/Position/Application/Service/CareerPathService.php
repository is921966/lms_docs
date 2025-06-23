<?php

declare(strict_types=1);

namespace App\Position\Application\Service;

use App\Position\Application\DTO\CareerPathDTO;
use App\Position\Application\DTO\CreateCareerPathDTO;
use App\Position\Application\DTO\UpdateCareerPathDTO;
use App\Position\Application\DTO\CareerProgressDTO;
use App\Position\Domain\Repository\PositionRepositoryInterface;
use App\Position\Domain\Repository\CareerPathRepositoryInterface;
use App\Position\Domain\Service\CareerProgressionService;
use App\Position\Domain\CareerPath;
use App\Position\Domain\ValueObjects\PositionId;
use App\Common\Exceptions\NotFoundException;
use Ramsey\Uuid\Uuid;

class CareerPathService
{
    public function __construct(
        private readonly PositionRepositoryInterface $positionRepository,
        private readonly CareerPathRepositoryInterface $careerPathRepository,
        private readonly CareerProgressionService $progressionService
    ) {
    }
    
    public function createCareerPath(CreateCareerPathDTO $dto): CareerPathDTO
    {
        $fromPositionId = PositionId::fromString($dto->fromPositionId);
        $toPositionId = PositionId::fromString($dto->toPositionId);
        
        // Validate positions exist
        $fromPosition = $this->positionRepository->findById($fromPositionId);
        $toPosition = $this->positionRepository->findById($toPositionId);
        
        if ($fromPosition === null || $toPosition === null) {
            throw new NotFoundException("Position not found");
        }
        
        // Check if path already exists
        $existingPath = $this->careerPathRepository->findPath($fromPositionId, $toPositionId);
        if ($existingPath !== null) {
            throw new \DomainException("Career path already exists");
        }
        
        $careerPath = CareerPath::create(
            fromPositionId: $fromPositionId,
            toPositionId: $toPositionId,
            requirements: $dto->requirements,
            estimatedDuration: $dto->estimatedDuration
        );
        
        // Generate ID for saving
        $id = Uuid::uuid4()->toString();
        
        $this->careerPathRepository->save($careerPath, $id);
        
        return CareerPathDTO::fromDomain($careerPath, $id);
    }
    
    public function addMilestone(
        string $careerPathId,
        string $title,
        string $description,
        int $monthsFromStart
    ): void {
        $careerPath = $this->getCareerPathEntity($careerPathId);
        
        $careerPath->addMilestone($title, $description, $monthsFromStart);
        
        $this->careerPathRepository->save($careerPath);
    }
    
    public function getCareerProgress(
        string $fromPositionId,
        string $toPositionId,
        string $employeeId,
        int $monthsCompleted
    ): CareerProgressDTO {
        $careerPath = $this->careerPathRepository->findPath(
            PositionId::fromString($fromPositionId),
            PositionId::fromString($toPositionId)
        );
        
        if ($careerPath === null) {
            throw new NotFoundException("Career path not found");
        }
        
        $progressPercentage = $this->progressionService->calculateProgress($careerPath, $monthsCompleted);
        $remainingMonths = $this->progressionService->getRemainingMonths($careerPath, $monthsCompleted);
        $isEligible = $this->progressionService->isEligibleForPromotion($careerPath, $monthsCompleted);
        $completedMilestones = $this->progressionService->getCompletedMilestones($careerPath, $monthsCompleted);
        $nextMilestone = $this->progressionService->getNextMilestone($careerPath, $monthsCompleted);
        
        $startDate = (new \DateTimeImmutable())->modify("-{$monthsCompleted} months");
        $estimatedCompletion = $this->progressionService->getEstimatedCompletionDate(
            $careerPath,
            $startDate,
            $monthsCompleted
        );
        
        return new CareerProgressDTO(
            employeeId: $employeeId,
            fromPositionId: $fromPositionId,
            toPositionId: $toPositionId,
            monthsCompleted: $monthsCompleted,
            progressPercentage: $progressPercentage,
            remainingMonths: $remainingMonths,
            isEligibleForPromotion: $isEligible,
            completedMilestones: $completedMilestones,
            nextMilestone: $nextMilestone,
            requirements: $careerPath->getRequirements(),
            estimatedCompletionDate: $estimatedCompletion
        );
    }
    
    /**
     * @return CareerPathDTO[]
     */
    public function getActiveCareerPaths(): array
    {
        $careerPaths = $this->careerPathRepository->findActive();
        
        return array_map(
            fn(CareerPath $path) => CareerPathDTO::fromDomain($path, Uuid::uuid4()->toString()),
            $careerPaths
        );
    }
    
    /**
     * @return CareerPathDTO[]
     */
    public function getCareerPathsFromPosition(string $positionId): array
    {
        $careerPaths = $this->careerPathRepository->findByFromPosition(
            PositionId::fromString($positionId)
        );
        
        return array_map(
            fn(CareerPath $path) => CareerPathDTO::fromDomain($path, Uuid::uuid4()->toString()),
            $careerPaths
        );
    }
    
    public function getCareerPath(string $fromPositionId, string $toPositionId): CareerPathDTO
    {
        $careerPath = $this->careerPathRepository->findPath(
            PositionId::fromString($fromPositionId),
            PositionId::fromString($toPositionId)
        );
        
        if ($careerPath === null) {
            throw new NotFoundException("Career path not found");
        }
        
        return CareerPathDTO::fromDomain($careerPath, Uuid::uuid4()->toString());
    }
    
    public function deactivateCareerPath(string $careerPathId): void
    {
        $careerPath = $this->getCareerPathEntity($careerPathId);
        
        $careerPath->deactivate();
        
        $this->careerPathRepository->save($careerPath);
    }
    
    public function activateCareerPath(string $careerPathId): void
    {
        $careerPath = $this->getCareerPathEntity($careerPathId);
        
        $careerPath->activate();
        
        $this->careerPathRepository->save($careerPath);
    }
    
    private function getCareerPathEntity(string $id): CareerPath
    {
        $careerPath = $this->careerPathRepository->findById($id);
        
        if ($careerPath === null) {
            throw new NotFoundException("Career path not found");
        }
        
        return $careerPath;
    }
} 