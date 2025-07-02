<?php

declare(strict_types=1);

namespace Tests\Integration\Competency;

use Competency\Application\Commands\CreateCompetencyCommand;
use Competency\Application\Handlers\CreateCompetencyHandler;
use Competency\Domain\ValueObjects\CompetencyCategory;
use Competency\Infrastructure\Repositories\InMemoryCompetencyRepository;
use Competency\Infrastructure\Repositories\InMemoryCompetencyCategoryRepository;
use PHPUnit\Framework\TestCase;

class CompetencyRepositoryIntegrationTest extends TestCase
{
    private InMemoryCompetencyRepository $competencyRepository;
    private InMemoryCompetencyCategoryRepository $categoryRepository;
    private CreateCompetencyHandler $handler;

    protected function setUp(): void
    {
        $this->competencyRepository = new InMemoryCompetencyRepository();
        $this->categoryRepository = new InMemoryCompetencyCategoryRepository();
        
        // Clear repositories to ensure clean state
        $this->competencyRepository->clear();
        $this->categoryRepository->clear();
        
        $this->handler = new CreateCompetencyHandler(
            $this->competencyRepository,
            $this->categoryRepository
        );
    }

    public function testCreateCompetencyWithCategory(): void
    {
        // Arrange
        $category = CompetencyCategory::create(
            'Technical Skills',
            'Technical competencies for developers'
        );
        $this->categoryRepository->save($category);

        $command = new CreateCompetencyCommand(
            'PHP Development',
            'Advanced PHP programming skills',
            $category->getId()->getValue()
        );

        // Act
        $competencyId = $this->handler->handle($command);

        // Assert
        $competency = $this->competencyRepository->findById($competencyId);
        $this->assertNotNull($competency);
        $this->assertEquals('PHP Development', $competency->getName());
        $this->assertTrue($competency->getCategory()->equals($category));
    }

    public function testFindCompetenciesByCategory(): void
    {
        // Arrange
        $category1 = CompetencyCategory::create('Technical', 'Technical skills');
        $category2 = CompetencyCategory::create('Soft Skills', 'Soft skills');
        
        $this->categoryRepository->save($category1);
        $this->categoryRepository->save($category2);

        // Create competencies in different categories
        $this->createCompetency('PHP', 'PHP skills', $category1->getId()->getValue());
        $this->createCompetency('JavaScript', 'JS skills', $category1->getId()->getValue());
        $this->createCompetency('Communication', 'Communication skills', $category2->getId()->getValue());

        // Act
        $technicalCompetencies = $this->competencyRepository->findByCategory($category1->getId()->getValue());
        $softSkillsCompetencies = $this->competencyRepository->findByCategory($category2->getId()->getValue());

        // Assert
        $this->assertCount(2, $technicalCompetencies);
        $this->assertCount(1, $softSkillsCompetencies);
        $this->assertEquals('PHP', $technicalCompetencies[0]->getName());
        $this->assertEquals('JavaScript', $technicalCompetencies[1]->getName());
        $this->assertEquals('Communication', $softSkillsCompetencies[0]->getName());
    }

    public function testCategoryHierarchy(): void
    {
        // Arrange
        $parentCategory = CompetencyCategory::create('IT', 'Information Technology');
        $childCategory1 = CompetencyCategory::create('Development', 'Software Development');
        $childCategory2 = CompetencyCategory::create('Infrastructure', 'IT Infrastructure');
        
        $childCategory1->setParent($parentCategory);
        $childCategory2->setParent($parentCategory);
        
        $this->categoryRepository->save($parentCategory);
        $this->categoryRepository->save($childCategory1);
        $this->categoryRepository->save($childCategory2);

        // Act
        $children = $this->categoryRepository->findByParentId($parentCategory->getId()->getValue());
        $roots = $this->categoryRepository->findByParentId(null);

        // Assert
        $this->assertCount(2, $children);
        $this->assertCount(1, $roots);
        $this->assertTrue($children[0]->hasParent());
        $this->assertTrue($children[0]->getParent()->equals($parentCategory));
    }

    public function testDeactivateCategory(): void
    {
        // Arrange
        $category1 = CompetencyCategory::create('Active', 'Active category');
        $category2 = CompetencyCategory::create('Inactive', 'Inactive category');
        
        $category2->deactivate();
        
        $this->categoryRepository->save($category1);
        $this->categoryRepository->save($category2);

        // Act
        $activeCategories = $this->categoryRepository->findActive();
        $allCategories = $this->categoryRepository->findAll();

        // Assert
        $this->assertCount(1, $activeCategories);
        $this->assertCount(2, $allCategories);
        $this->assertEquals('Active', $activeCategories[0]->getName());
    }

    public function testRepositoryCleanup(): void
    {
        // Arrange
        $category = CompetencyCategory::create('Test', 'Test category');
        $this->categoryRepository->save($category);
        $this->createCompetency('Test', 'Test competency', $category->getId()->getValue());

        // Act & Assert
        $this->assertCount(1, $this->competencyRepository->findAll());
        $this->assertCount(1, $this->categoryRepository->findAll());

        $this->competencyRepository->clear();
        $this->categoryRepository->clear();

        $this->assertCount(0, $this->competencyRepository->findAll());
        $this->assertCount(0, $this->categoryRepository->findAll());
    }

    private function createCompetency(string $name, string $description, ?string $categoryId): void
    {
        if ($categoryId === null) {
            $category = CompetencyCategory::create('Default', 'Default category');
            $this->categoryRepository->save($category);
            $categoryId = $category->getId()->getValue();
        }

        $command = new CreateCompetencyCommand($name, $description, $categoryId);
        $this->handler->handle($command);
    }
}
