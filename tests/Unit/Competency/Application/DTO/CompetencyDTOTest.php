<?php

namespace Tests\Unit\Competency\Application\DTO;

use PHPUnit\Framework\TestCase;
use Competency\Application\DTO\CompetencyDTO;
use Competency\Domain\Competency;
use Competency\Domain\ValueObjects\CompetencyCategory;
use Competency\Domain\ValueObjects\CompetencyCode;
use Competency\Domain\ValueObjects\CompetencyId;
use Competency\Domain\ValueObjects\CompetencyLevel;

class CompetencyDTOTest extends TestCase
{
    public function testCreateFromEntity()
    {
        // Arrange
        $competency = Competency::create(
            CompetencyId::fromString('b1ffcd00-0d1e-4ef8-cc7e-7cc0ce491b22'),
            CompetencyCode::fromString('JS-001'),
            'JavaScript Development',
            'JavaScript programming skills',
            CompetencyCategory::technical()
        );

        // Act
        $dto = CompetencyDTO::fromEntity($competency);

        // Assert
        $this->assertEquals('b1ffcd00-0d1e-4ef8-cc7e-7cc0ce491b22', $dto->id);
        $this->assertEquals('JavaScript Development', $dto->name);
        $this->assertEquals('JavaScript programming skills', $dto->description);
        $this->assertEquals('technical', $dto->categoryId);
        $this->assertEquals('Technical', $dto->categoryName);
        $this->assertTrue($dto->isActive);
        $this->assertCount(5, $dto->skillLevels); // Default levels
    }

    public function testSkillLevelsInDTO()
    {
        // Arrange - создаем с кастомными уровнями
        $customLevels = [
            CompetencyLevel::beginner(),
            CompetencyLevel::intermediate()
        ];
        
        $competency = Competency::create(
            CompetencyId::generate(),
            CompetencyCode::fromString('COMM-001'),
            'Communication',
            'Communication skills',
            CompetencyCategory::soft(),
            null,
            $customLevels
        );

        // Act
        $dto = CompetencyDTO::fromEntity($competency);

        // Assert
        $this->assertCount(2, $dto->skillLevels);
        $this->assertEquals(1, $dto->skillLevels[0]['level']);
        $this->assertEquals('Beginner', $dto->skillLevels[0]['name']);
    }

    public function testInactiveCompetencyDTO()
    {
        // Arrange
        $competency = Competency::create(
            CompetencyId::generate(),
            CompetencyCode::fromString('COBOL-001'),
            'COBOL',
            'COBOL programming',
            CompetencyCategory::technical()
        );
        $competency->deactivate();

        // Act
        $dto = CompetencyDTO::fromEntity($competency);

        // Assert
        $this->assertFalse($dto->isActive);
    }

    public function testToArray()
    {
        // Arrange
        $competency = Competency::create(
            CompetencyId::generate(),
            CompetencyCode::fromString('DOCKER-001'),
            'Docker',
            'Container technology',
            CompetencyCategory::technical()
        );

        $dto = CompetencyDTO::fromEntity($competency);

        // Act
        $array = $dto->toArray();

        // Assert
        $this->assertArrayHasKey('id', $array);
        $this->assertArrayHasKey('name', $array);
        $this->assertArrayHasKey('description', $array);
        $this->assertArrayHasKey('categoryId', $array);
        $this->assertArrayHasKey('categoryName', $array);
        $this->assertArrayHasKey('isActive', $array);
        $this->assertArrayHasKey('skillLevels', $array);
        $this->assertArrayHasKey('requiredForPositions', $array);
        $this->assertEquals('Docker', $array['name']);
        $this->assertTrue($array['isActive']);
    }

    public function testCreateFromArray()
    {
        // Arrange
        $data = [
            'id' => 'test-id-123',
            'name' => 'Test Competency',
            'description' => 'Test description',
            'categoryId' => 'technical',
            'categoryName' => 'Technical',
            'isActive' => true,
            'skillLevels' => [
                ['level' => 1, 'name' => 'Level 1', 'description' => 'Desc 1']
            ],
            'requiredForPositions' => []
        ];

        // Act
        $dto = CompetencyDTO::fromArray($data);

        // Assert
        $this->assertEquals('test-id-123', $dto->id);
        $this->assertEquals('Test Competency', $dto->name);
        $this->assertEquals('Test description', $dto->description);
        $this->assertEquals('technical', $dto->categoryId);
        $this->assertEquals('Technical', $dto->categoryName);
        $this->assertTrue($dto->isActive);
        $this->assertCount(1, $dto->skillLevels);
        $this->assertCount(0, $dto->requiredForPositions);
    }
} 