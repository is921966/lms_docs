<?php

declare(strict_types=1);

namespace App\Position\Application\Service;

use App\Position\Application\DTO\ProfileDTO;
use App\Position\Application\DTO\CreateProfileDTO;
use App\Position\Application\DTO\UpdateProfileDTO;
use App\Position\Application\DTO\CompetencyRequirementDTO;
use App\Position\Domain\Repository\PositionRepositoryInterface;
use App\Position\Domain\Repository\PositionProfileRepositoryInterface;
use App\Position\Domain\PositionProfile;
use App\Position\Domain\ValueObjects\PositionId;
use App\Competency\Domain\ValueObjects\CompetencyId;
use App\Competency\Domain\ValueObjects\CompetencyLevel;
use App\Common\Exceptions\NotFoundException;

class ProfileService
{
    public function __construct(
        private readonly PositionRepositoryInterface $positionRepository,
        private readonly PositionProfileRepositoryInterface $profileRepository
    ) {
    }
    
    public function createProfile(CreateProfileDTO $dto): ProfileDTO
    {
        $positionId = PositionId::fromString($dto->positionId);
        
        // Check if position exists
        $position = $this->positionRepository->findById($positionId);
        if ($position === null) {
            throw new NotFoundException("Position not found");
        }
        
        // Check if profile already exists
        $existingProfile = $this->profileRepository->findByPositionId($positionId);
        if ($existingProfile !== null) {
            throw new \DomainException("Profile already exists for this position");
        }
        
        $profile = PositionProfile::create(
            positionId: $positionId,
            responsibilities: $dto->responsibilities,
            requirements: $dto->requirements
        );
        
        $this->profileRepository->save($profile);
        
        return ProfileDTO::fromDomain($profile);
    }
    
    public function updateProfile(string $positionId, UpdateProfileDTO $dto): ProfileDTO
    {
        $profile = $this->getProfileEntity($positionId);
        
        $profile->updateResponsibilities($dto->responsibilities);
        $profile->updateRequirements($dto->requirements);
        
        $this->profileRepository->save($profile);
        
        return ProfileDTO::fromDomain($profile);
    }
    
    public function addCompetencyRequirement(string $positionId, CompetencyRequirementDTO $dto): void
    {
        $profile = $this->getProfileEntity($positionId);
        
        $competencyId = CompetencyId::fromString($dto->competencyId);
        $level = CompetencyLevel::fromValue($dto->minimumLevel);
        
        if ($dto->isRequired) {
            $profile->addRequiredCompetency($competencyId, $level);
        } else {
            $profile->addDesiredCompetency($competencyId, $level);
        }
        
        $this->profileRepository->save($profile);
    }
    
    public function removeCompetencyRequirement(string $positionId, string $competencyId): void
    {
        $profile = $this->getProfileEntity($positionId);
        
        $competencyIdVO = CompetencyId::fromString($competencyId);
        
        // Check if competency requirement exists
        if (!$profile->hasCompetencyRequirement($competencyIdVO)) {
            throw new NotFoundException("Competency requirement not found");
        }
        
        // Try to remove from both lists
        $profile->removeRequiredCompetency($competencyIdVO);
        $profile->removeDesiredCompetency($competencyIdVO);
        
        $this->profileRepository->save($profile);
    }
    
    public function getByPositionId(string $positionId): ProfileDTO
    {
        $profile = $this->getProfileEntity($positionId);
        return ProfileDTO::fromDomain($profile);
    }
    
    /**
     * @return ProfileDTO[]
     */
    public function getByCompetencyId(string $competencyId): array
    {
        $profiles = $this->profileRepository->findByCompetencyId(
            CompetencyId::fromString($competencyId)
        );
        
        return array_map(
            fn(PositionProfile $profile) => ProfileDTO::fromDomain($profile),
            $profiles
        );
    }
    
    private function getProfileEntity(string $positionId): PositionProfile
    {
        $profile = $this->profileRepository->findByPositionId(
            PositionId::fromString($positionId)
        );
        
        if ($profile === null) {
            throw new NotFoundException("Profile not found");
        }
        
        return $profile;
    }
} 