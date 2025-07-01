<?php

namespace Tests\Unit\Competency\Application\DTO;

use PHPUnit\Framework\TestCase;
use Competency\Application\DTO\CompetencyDTO;
use Competency\Domain\Entities\Competency;
use Competency\Domain\Entities\CompetencyCategory;
use Competency\Domain\ValueObjects\CompetencyId;
use Competency\Domain\ValueObjects\CategoryId;
use Competency\Domain\ValueObjects\SkillLevel;

class CompetencyDTOTest extends TestCase
{
    public function testCreateFromEntity()
    {
        // Arrange
        $category = CompetencyCategory::createWithId(
            CategoryId::fromString('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11'),
            'Technical Skills',
            'Technical competencies'
        );

        $competency = Competency::createWithId(
            CompetencyId::fromString('b1ffcd00-0d1e-4ef8-cc7e-7cc0ce491b22'),
            'JavaScript Development',
            'JavaScript programming skills',
            $category
        );

        // Add skill levels
        $competency->addSkillLevel(new SkillLevel(1, 'Beginner', 'Basic JS syntax'));
        $competency->addSkillLevel(new SkillLevel(2, 'Elementary', 'DOM manipulation'));
        $competency->addSkillLevel(new SkillLevel(3, 'Intermediate', 'ES6+ and frameworks'));

        // Act
        $dto = CompetencyDTO::fromEntity($competency);

        // Assert
        $this->assertEquals('b1ffcd00-0d1e-4ef8-cc7e-7cc0ce491b22', $dto->id);
        $this->assertEquals('JavaScript Development', $dto->name);
        $this->assertEquals('JavaScript programming skills', $dto->description);
        $this->assertEquals('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', $dto->categoryId);
        $this->assertEquals('Technical Skills', $dto->categoryName);
        $this->assertTrue($dto->isActive);
        $this->assertCount(3, $dto->skillLevels);
    }

    public function testSkillLevelsInDTO()
    {
        // Arrange
        $category = CompetencyCategory::create('Soft Skills', 'Interpersonal skills');
        $competency = Competency::create('Communication', 'Communication skills', $category);
        
        $competency->addSkillLevel(new SkillLevel(1, 'Basic', 'Can communicate simple ideas'));
        $competency->addSkillLevel(new SkillLevel(2, 'Good', 'Clear communication'));

        // Act
        $dto = CompetencyDTO::fromEntity($competency);

        // Assert
        $this->assertCount(2, $dto->skillLevels);
        $this->assertEquals(1, $dto->skillLevels[0]['level']);
        $this->assertEquals('Basic', $dto->skillLevels[0]['name']);
        $this->assertEquals('Can communicate simple ideas', $dto->skillLevels[0]['description']);
    }

    public function testInactiveCompetencyDTO()
    {
        // Arrange
        $category = CompetencyCategory::create('Legacy', 'Old skills');
        $competency = Competency::create('COBOL', 'COBOL programming', $category);
        $competency->deactivate();

        // Act
        $dto = CompetencyDTO::fromEntity($competency);

        // Assert
        $this->assertFalse($dto->isActive);
    }

    public function testRequiredForPositionsInDTO()
    {
        // Arrange
        $category = CompetencyCategory::create('Leadership', 'Leadership skills');
        $competency = Competency::create('Team Management', 'Managing teams', $category);
        
        $competency->addRequiredForPosition('team-lead', 4);
        $competency->addRequiredForPosition('department-head', 5);

        // Act
        $dto = CompetencyDTO::fromEntity($competency);

        // Assert
        $this->assertCount(2, $dto->requiredForPositions);
        $this->assertEquals(4, $dto->requiredForPositions['team-lead']);
        $this->assertEquals(5, $dto->requiredForPositions['department-head']);
    }

    public function testToArray()
    {
        // Arrange
        $category = CompetencyCategory::create('Technical', 'Tech skills');
        $competency = Competency::create('Docker', 'Container technology', $category);
        $competency->addSkillLevel(SkillLevel::beginner());

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
            'categoryId' => 'cat-id-456',
            'categoryName' => 'Test Category',
            'isActive' => true,
            'skillLevels' => [
                ['level' => 1, 'name' => 'Level 1', 'description' => 'Desc 1']
            ],
            'requiredForPositions' => ['position-1' => 3]
        ];

        // Act
        $dto = CompetencyDTO::fromArray($data);

        // Assert
        $this->assertEquals('test-id-123', $dto->id);
        $this->assertEquals('Test Competency', $dto->name);
        $this->assertEquals('Test description', $dto->description);
        $this->assertEquals('cat-id-456', $dto->categoryId);
        $this->assertEquals('Test Category', $dto->categoryName);
        $this->assertTrue($dto->isActive);
        $this->assertCount(1, $dto->skillLevels);
        $this->assertCount(1, $dto->requiredForPositions);
    }
} 