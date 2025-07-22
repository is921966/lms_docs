<?php

namespace CompetencyService\Application\Services;

use CompetencyService\Application\DTOs\CreateCompetencyDTO;
use CompetencyService\Application\DTOs\UpdateCompetencyDTO;
use CompetencyService\Application\DTOs\CompetencyDTO;
use CompetencyService\Domain\Repositories\CompetencyRepositoryInterface;
use CompetencyService\Domain\Entities\Competency;
use CompetencyService\Domain\ValueObjects\CompetencyId;
use CompetencyService\Domain\ValueObjects\CompetencyCode;
use CompetencyService\Domain\ValueObjects\CompetencyLevel;
use DomainException;

class CompetencyService
{
    public function __construct(
        private readonly CompetencyRepositoryInterface $repository
    ) {}
    
    public function createCompetency(CreateCompetencyDTO $dto): CompetencyDTO
    {
        // Check for duplicate code
        $code = new CompetencyCode($dto->code);
        $existing = $this->repository->findByCode($code);
        
        if ($existing !== null) {
            throw new DomainException("Competency with code {$dto->code} already exists");
        }
        
        // Create competency
        $competency = new Competency(
            CompetencyId::generate(),
            $code,
            $dto->name,
            $dto->description,
            $dto->category
        );
        
        // Add levels if provided
        foreach ($dto->levels as $levelData) {
            $level = new CompetencyLevel(
                $levelData['level'],
                $levelData['name'],
                $levelData['description'],
                $levelData['criteria'] ?? []
            );
            $competency->addLevel($level);
        }
        
        // Save
        $this->repository->save($competency);
        
        return CompetencyDTO::fromEntity($competency);
    }
    
    public function updateCompetency(UpdateCompetencyDTO $dto): CompetencyDTO
    {
        $competency = $this->repository->findById(
            CompetencyId::fromString($dto->id)
        );
        
        if ($competency === null) {
            throw new DomainException("Competency with id {$dto->id} not found");
        }
        
        $competency->update($dto->name, $dto->description);
        
        $this->repository->save($competency);
        
        return CompetencyDTO::fromEntity($competency);
    }
    
    public function getCompetencyById(string $id): CompetencyDTO
    {
        $competency = $this->repository->findById(
            CompetencyId::fromString($id)
        );
        
        if ($competency === null) {
            throw new DomainException("Competency with id {$id} not found");
        }
        
        return CompetencyDTO::fromEntity($competency);
    }
    
    public function getCompetencyByCode(string $code): CompetencyDTO
    {
        $competency = $this->repository->findByCode(
            new CompetencyCode($code)
        );
        
        if ($competency === null) {
            throw new DomainException("Competency with code {$code} not found");
        }
        
        return CompetencyDTO::fromEntity($competency);
    }
    
    public function getAllCompetencies(): array
    {
        $competencies = $this->repository->findAll();
        
        return array_map(
            fn(Competency $competency) => CompetencyDTO::fromEntity($competency),
            $competencies
        );
    }
    
    public function getCompetenciesByCategory(string $category): array
    {
        $competencies = $this->repository->findByCategory($category);
        
        return array_map(
            fn(Competency $competency) => CompetencyDTO::fromEntity($competency),
            $competencies
        );
    }
    
    public function deactivateCompetency(string $id): CompetencyDTO
    {
        $competency = $this->repository->findById(
            CompetencyId::fromString($id)
        );
        
        if ($competency === null) {
            throw new DomainException("Competency with id {$id} not found");
        }
        
        $competency->deactivate();
        $this->repository->save($competency);
        
        return CompetencyDTO::fromEntity($competency);
    }
    
    public function activateCompetency(string $id): CompetencyDTO
    {
        $competency = $this->repository->findById(
            CompetencyId::fromString($id)
        );
        
        if ($competency === null) {
            throw new DomainException("Competency with id {$id} not found");
        }
        
        $competency->activate();
        $this->repository->save($competency);
        
        return CompetencyDTO::fromEntity($competency);
    }
} 