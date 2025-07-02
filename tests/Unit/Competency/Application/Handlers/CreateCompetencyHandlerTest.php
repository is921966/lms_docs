<?php

namespace Tests\Unit\Competency\Application\Handlers;

use PHPUnit\Framework\TestCase;
use Competency\Application\Handlers\CreateCompetencyHandler;
use Competency\Application\Commands\CreateCompetencyCommand;
use Competency\Domain\Repositories\CompetencyRepositoryInterface;
use Competency\Domain\Repositories\CompetencyCategoryRepositoryInterface;
use Competency\Domain\ValueObjects\CompetencyCategory;
use Competency\Domain\ValueObjects\CompetencyCode;
use Competency\Domain\ValueObjects\CompetencyId;
use Competency\Domain\ValueObjects\CompetencyLevel;
use Competency\Domain\Competency;

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
        $categoryId = 'technical'; // Using predefined category value
        $command = new CreateCompetencyCommand(
            'Python Development',
            'Python programming skills',
            $categoryId
        );

        // Mock that category exists
        $this->categoryRepository->expects($this->once())
            ->method('findById')
            ->with($categoryId)
            ->willReturn((object)['id' => $categoryId, 'name' => 'Technical Skills']);

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
        $categoryId = 'technical';
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
            ->willReturn((object)['id' => $categoryId, 'name' => 'Technical Skills']);

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
        $levels = $savedCompetency->getLevels();
        $this->assertCount(2, $levels);
        
        // Check first level
        $firstLevel = $levels[0];
        $this->assertEquals(1, $firstLevel->getValue());
        $this->assertEquals('Beginner', $firstLevel->getName());
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

    public function testHandleWithDuplicateName()
    {
        // Arrange
        $categoryId = 'technical';
        
        $existingCompetency = Competency::create(
            CompetencyId::generate(),
            CompetencyCode::fromString('PHP-001'),
            'PHP Development',
            'Existing competency',
            CompetencyCategory::technical()
        );

        $command = new CreateCompetencyCommand(
            'PHP Development',
            'New description',
            $categoryId
        );

        $this->categoryRepository->expects($this->once())
            ->method('findById')
            ->willReturn((object)['id' => $categoryId, 'name' => 'Technical Skills']);

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