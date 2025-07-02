<?php

namespace Competency\Application\Handlers;

use Competency\Application\Commands\CreateCompetencyCommand;
use Competency\Domain\Repositories\CompetencyRepositoryInterface;
use Competency\Domain\Repositories\CompetencyCategoryRepositoryInterface;
use Competency\Domain\Competency;
use Competency\Domain\ValueObjects\CompetencyId;
use Competency\Domain\ValueObjects\CompetencyCode;
use Competency\Domain\ValueObjects\CompetencyCategory;
use Competency\Domain\ValueObjects\CompetencyLevel;
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

        // Check if category is active (if method exists)
        if (method_exists($category, 'isActive') && !$category->isActive()) {
            throw new DomainException('Cannot create competency in inactive category');
        }

        // Check for duplicate name
        $existingCompetency = $this->competencyRepository->findByName($command->getName());
        if ($existingCompetency) {
            throw new DomainException('Competency with this name already exists');
        }

        // Create competency with proper parameters
        $competencyId = CompetencyId::generate();
        $competencyCode = $this->generateCompetencyCode($command->getCategoryId(), $command->getName());
        
        // Map category ID to CompetencyCategory value object
        $categoryVO = $this->mapCategoryToValueObject($command->getCategoryId());
        
        $competency = Competency::create(
            $competencyId,
            CompetencyCode::fromString($competencyCode),
            $command->getName(),
            $command->getDescription(),
            $categoryVO
        );

        // Add skill levels if provided
        if (!empty($command->getSkillLevels())) {
            $levels = [];
            foreach ($command->getSkillLevels() as $levelData) {
                $levels[] = new SkillLevel(
                    $levelData['level'],
                    $levelData['name'],
                    $levelData['description']
                );
            }
            $competency->updateLevels($levels);
        }

        // Save competency
        $this->competencyRepository->save($competency);

        return $competencyId->getValue();
    }

    private function generateCompetencyCode(string $categoryId, string $name): string
    {
        // Generate a simple code based on category and name
        $prefix = match($categoryId) {
            'technical' => 'TECH',
            'soft' => 'SOFT',
            'leadership' => 'LEAD',
            'business' => 'BUS',
            default => 'GEN'
        };
        
        $suffix = strtoupper(substr(preg_replace('/[^A-Za-z0-9]/', '', $name), 0, 3));
        $number = rand(100, 999);
        
        return "{$prefix}-{$suffix}-{$number}";
    }

    private function mapCategoryToValueObject(string $categoryId): CompetencyCategory
    {
        return match($categoryId) {
            'technical' => CompetencyCategory::technical(),
            'soft' => CompetencyCategory::soft(),
            'leadership' => CompetencyCategory::leadership(),
            'business' => CompetencyCategory::business(),
            default => CompetencyCategory::technical()
        };
    }
} 