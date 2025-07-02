<?php

namespace Tests\Unit\Competency\Application\Handlers;

use PHPUnit\Framework\TestCase;
use Competency\Application\Handlers\CreateCompetencyHandler;
use Competency\Application\Commands\CreateCompetencyCommand;
use Competency\Domain\Repositories\CompetencyRepositoryInterface;
use Competency\Domain\Repositories\CompetencyCategoryRepositoryInterface;
use Competency\Domain\ValueObjects\CompetencyCategory;
use Competency\Domain\Competency;
use Competency\Domain\ValueObjects\CompetencyId;

class CreateCompetencyHandlerTest extends TestCase
{
    private CompetencyRepositoryInterface $competencyRepository;
    private CompetencyCategoryRepositoryInterface $categoryRepository;
    private CreateCompetencyHandler $handler;

    protected function setUp(): void
    {
        $this->competencyRepository = $this->createMock(CompetencyRepositoryInterface::class);
        $this->categoryRepository = $this->createMock(CompetencyCategoryRepositoryInterface::class);
        $this->handler = new CreateCompetencyHandler(
            $this->competencyRepository,
            $this->categoryRepository
        );
    }

    public function testHandleCreateCompetency()
    {
        // Arrange
        $categoryId = 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11';
        $category = CompetencyCategory::createWithId(
            CategoryId::fromString($categoryId),
            'Technical Skills',
            'Technical competencies'
        );

        $command = new CreateCompetencyCommand(
            'Python Development',
            'Python programming skills',
            $categoryId
        );

        $this->categoryRepository->expects($this->once())
            ->method('findById')
            ->with($categoryId)
            ->willReturn($category);

        $this->competencyRepository->expects($this->once())
            ->method('save')
            ->with($this->isInstanceOf(Competency::class));

        // Act
        $competencyId = $this->handler->handle($command);

        // Assert
        $this->assertNotEmpty($competencyId);
        $this->assertIsString($competencyId);
    }

    public function testHandleWithSkillLevels()
    {
        // Arrange
        $categoryId = 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11';
        $category = CompetencyCategory::createWithId(
            CategoryId::fromString($categoryId),
            'Technical Skills',
            'Technical competencies'
        );

        $skillLevels = [
            ['level' => 1, 'name' => 'Beginner', 'description' => 'Basic knowledge'],
            ['level' => 2, 'name' => 'Elementary', 'description' => 'Can perform simple tasks']
        ];

        $command = new CreateCompetencyCommand(
            'React Development',
            'React framework skills',
            $categoryId,
            $skillLevels
        );

        $this->categoryRepository->expects($this->once())
            ->method('findById')
            ->with($categoryId)
            ->willReturn($category);

        $savedCompetency = null;
        $this->competencyRepository->expects($this->once())
            ->method('save')
            ->willReturnCallback(function($competency) use (&$savedCompetency) {
                $savedCompetency = $competency;
            });

        // Act
        $competencyId = $this->handler->handle($command);

        // Assert
        $this->assertNotNull($savedCompetency);
        $this->assertCount(2, $savedCompetency->getLevels());
        $this->assertEquals('Beginner', $savedCompetency->getLevels()[1)->getName());
    }

    public function testHandleWithNonExistentCategory()
    {
        // Arrange
        $categoryId = 'non-existent-id';
        $command = new CreateCompetencyCommand(
            'Java Development',
            'Java programming skills',
            $categoryId
        );

        $this->categoryRepository->expects($this->once())
            ->method('findById')
            ->with($categoryId)
            ->willReturn(null);

        // Assert
        $this->expectException(\DomainException::class);
        $this->expectExceptionMessage('Category not found');

        // Act
        $this->handler->handle($command);
    }

    public function testHandleWithInactiveCategory()
    {
        // Arrange
        $categoryId = 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11';
        $category = CompetencyCategory::createWithId(
            CategoryId::fromString($categoryId),
            'Legacy Skills',
            'Old competencies'
        );
        $category->deactivate();

        $command = new CreateCompetencyCommand(
            'COBOL Development',
            'COBOL programming skills',
            $categoryId
        );

        $this->categoryRepository->expects($this->once())
            ->method('findById')
            ->with($categoryId)
            ->willReturn($category);

        // Assert
        $this->expectException(\DomainException::class);
        $this->expectExceptionMessage('Cannot create competency in inactive category');

        // Act
        $this->handler->handle($command);
    }

    public function testHandleWithDuplicateName()
    {
        // Arrange
        $categoryId = 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11';
        $category = CompetencyCategory::createWithId(
            CategoryId::fromString($categoryId),
            'Technical Skills',
            'Technical competencies'
        );

        $existingCompetency = Competency::create(
            'PHP Development',
            'Existing competency',
            $category
        );

        $command = new CreateCompetencyCommand(
            'PHP Development',
            'New description',
            $categoryId
        );

        $this->categoryRepository->expects($this->once())
            ->method('findById')
            ->willReturn($category);

        $this->competencyRepository->expects($this->once())
            ->method('findByName')
            ->with('PHP Development')
            ->willReturn($existingCompetency);

        // Assert
        $this->expectException(\DomainException::class);
        $this->expectExceptionMessage('Competency with this name already exists');

        // Act
        $this->handler->handle($command);
    }
} 