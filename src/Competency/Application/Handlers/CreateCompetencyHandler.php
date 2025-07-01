<?php

namespace Competency\Application\Handlers;

use Competency\Application\Commands\CreateCompetencyCommand;
use Competency\Domain\Repositories\CompetencyRepositoryInterface;
use Competency\Domain\Repositories\CompetencyCategoryRepositoryInterface;
use Competency\Domain\Entities\Competency;
use Competency\Domain\ValueObjects\SkillLevel;
use DomainException;

class CreateCompetencyHandler
{
    private CompetencyRepositoryInterface $competencyRepository;
    private CompetencyCategoryRepositoryInterface $categoryRepository;

    public function __construct(
        CompetencyRepositoryInterface $competencyRepository,
        CompetencyCategoryRepositoryInterface $categoryRepository
    ) {
        $this->competencyRepository = $competencyRepository;
        $this->categoryRepository = $categoryRepository;
    }

    public function handle(CreateCompetencyCommand $command): string
    {
        // Find category
        $category = $this->categoryRepository->findById($command->getCategoryId());
        if (!$category) {
            throw new DomainException('Category not found');
        }

        // Check if category is active
        if (!$category->isActive()) {
            throw new DomainException('Cannot create competency in inactive category');
        }

        // Check for duplicate name
        $existingCompetency = $this->competencyRepository->findByName($command->getName());
        if ($existingCompetency) {
            throw new DomainException('Competency with this name already exists');
        }

        // Create competency
        $competency = Competency::create(
            $command->getName(),
            $command->getDescription(),
            $category
        );

        // Add skill levels if provided
        foreach ($command->getSkillLevels() as $levelData) {
            $skillLevel = new SkillLevel(
                $levelData['level'],
                $levelData['name'],
                $levelData['description']
            );
            $competency->addSkillLevel($skillLevel);
        }

        // Save competency
        $this->competencyRepository->save($competency);

        return $competency->getId()->getValue();
    }
} 