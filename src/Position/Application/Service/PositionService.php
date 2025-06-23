<?php

declare(strict_types=1);

namespace App\Position\Application\Service;

use App\Position\Application\DTO\CreatePositionDTO;
use App\Position\Application\DTO\UpdatePositionDTO;
use App\Position\Application\DTO\PositionDTO;
use App\Position\Domain\Repository\PositionRepositoryInterface;
use App\Position\Domain\Repository\PositionProfileRepositoryInterface;
use App\Position\Domain\Position;
use App\Position\Domain\ValueObjects\PositionId;
use App\Position\Domain\ValueObjects\PositionCode;
use App\Position\Domain\ValueObjects\PositionLevel;
use App\Position\Domain\ValueObjects\Department;
use App\Common\Exceptions\NotFoundException;

class PositionService
{
    public function __construct(
        private readonly PositionRepositoryInterface $positionRepository,
        private readonly PositionProfileRepositoryInterface $profileRepository
    ) {
    }
    
    public function createPosition(CreatePositionDTO $dto): PositionDTO
    {
        // Check if position with code already exists
        $existingPosition = $this->positionRepository->findByCode(
            PositionCode::fromString($dto->code)
        );
        
        if ($existingPosition !== null) {
            throw new \DomainException("Position with code {$dto->code} already exists");
        }
        
        $position = Position::create(
            id: PositionId::generate(),
            code: PositionCode::fromString($dto->code),
            title: $dto->title,
            department: Department::fromString($dto->department),
            level: PositionLevel::fromValue($dto->level),
            description: $dto->description,
            parentId: $dto->parentId ? PositionId::fromString($dto->parentId) : null
        );
        
        $this->positionRepository->save($position);
        
        return PositionDTO::fromDomain($position);
    }
    
    public function updatePosition(string $id, UpdatePositionDTO $dto): PositionDTO
    {
        $position = $this->positionRepository->findById(PositionId::fromString($id));
        
        if ($position === null) {
            throw new NotFoundException("Position not found");
        }
        
        $position->update(
            title: $dto->title,
            description: $dto->description,
            level: PositionLevel::fromValue($dto->level)
        );
        
        $this->positionRepository->save($position);
        
        return PositionDTO::fromDomain($position);
    }
    
    public function getById(string $id): PositionDTO
    {
        $position = $this->positionRepository->findById(PositionId::fromString($id));
        
        if ($position === null) {
            throw new NotFoundException("Position not found");
        }
        
        return PositionDTO::fromDomain($position);
    }
    
    public function getByCode(string $code): PositionDTO
    {
        $position = $this->positionRepository->findByCode(PositionCode::fromString($code));
        
        if ($position === null) {
            throw new NotFoundException("Position not found");
        }
        
        return PositionDTO::fromDomain($position);
    }
    
    /**
     * @return PositionDTO[]
     */
    public function getByDepartment(string $department): array
    {
        $positions = $this->positionRepository->findByDepartment(
            Department::fromString($department)
        );
        
        return array_map(
            fn(Position $position) => PositionDTO::fromDomain($position),
            $positions
        );
    }
    
    /**
     * @return PositionDTO[]
     */
    public function getActivePositions(): array
    {
        $positions = $this->positionRepository->findActive();
        
        return array_map(
            fn(Position $position) => PositionDTO::fromDomain($position),
            $positions
        );
    }
    
    public function archivePosition(string $id): void
    {
        $position = $this->positionRepository->findById(PositionId::fromString($id));
        
        if ($position === null) {
            throw new NotFoundException("Position not found");
        }
        
        $position->archive();
        $this->positionRepository->save($position);
    }
    
    public function restorePosition(string $id): void
    {
        $position = $this->positionRepository->findById(PositionId::fromString($id));
        
        if ($position === null) {
            throw new NotFoundException("Position not found");
        }
        
        $position->restore();
        $this->positionRepository->save($position);
    }
} 