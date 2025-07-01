<?php

namespace Tests\Unit\Competency\Domain\Entities;

use PHPUnit\Framework\TestCase;
use Competency\Domain\Entities\Competency;
use Competency\Domain\Entities\CompetencyCategory;
use Competency\Domain\ValueObjects\CompetencyId;
use Competency\Domain\ValueObjects\SkillLevel;

class CompetencyTest extends TestCase
{
    public function testCreateCompetency()
    {
        // Arrange
        $category = CompetencyCategory::create('Technical', 'Technical skills');
        
        // Act
        $competency = Competency::create(
            'PHP Development',
            'Proficiency in PHP programming language',
            $category
        );

        // Assert
        $this->assertInstanceOf(Competency::class, $competency);
        $this->assertInstanceOf(CompetencyId::class, $competency->getId());
        $this->assertEquals('PHP Development', $competency->getName());
        $this->assertEquals('Proficiency in PHP programming language', $competency->getDescription());
        $this->assertTrue($competency->getCategory()->equals($category));
        $this->assertTrue($competency->isActive());
    }

    public function testUpdateCompetencyDetails()
    {
        // Arrange
        $category = CompetencyCategory::create('Technical', 'Technical skills');
        $competency = Competency::create('Java', 'Java programming', $category);

        // Act
        $competency->updateDetails(
            'Java Development',
            'Proficiency in Java programming language and ecosystem'
        );

        // Assert
        $this->assertEquals('Java Development', $competency->getName());
        $this->assertEquals('Proficiency in Java programming language and ecosystem', $competency->getDescription());
    }

    public function testChangeCategory()
    {
        // Arrange
        $techCategory = CompetencyCategory::create('Technical', 'Technical skills');
        $softCategory = CompetencyCategory::create('Soft Skills', 'Interpersonal skills');
        $competency = Competency::create('Communication', 'Communication skills', $techCategory);

        // Act
        $competency->changeCategory($softCategory);

        // Assert
        $this->assertTrue($competency->getCategory()->equals($softCategory));
    }

    public function testDefineSkillLevels()
    {
        // Arrange
        $category = CompetencyCategory::create('Technical', 'Technical skills');
        $competency = Competency::create('Docker', 'Container technology', $category);

        $levels = [
            new SkillLevel(1, 'Beginner', 'Basic understanding of Docker concepts'),
            new SkillLevel(2, 'Elementary', 'Can run and manage simple containers'),
            new SkillLevel(3, 'Intermediate', 'Can create Dockerfiles and compose files'),
            new SkillLevel(4, 'Advanced', 'Can optimize images and orchestrate containers'),
            new SkillLevel(5, 'Expert', 'Can design and implement complex containerized systems')
        ];

        // Act
        foreach ($levels as $level) {
            $competency->addSkillLevel($level);
        }

        // Assert
        $this->assertCount(5, $competency->getSkillLevels());
        $this->assertTrue($competency->hasSkillLevel(3));
        $this->assertNotNull($competency->getSkillLevel(3));
        $this->assertEquals('Intermediate', $competency->getSkillLevel(3)->getName());
    }

    public function testDeactivateCompetency()
    {
        // Arrange
        $category = CompetencyCategory::create('Technical', 'Technical skills');
        $competency = Competency::create('Legacy System', 'Old technology', $category);

        // Act
        $competency->deactivate();

        // Assert
        $this->assertFalse($competency->isActive());
    }

    public function testReactivateCompetency()
    {
        // Arrange
        $category = CompetencyCategory::create('Technical', 'Technical skills');
        $competency = Competency::create('Python', 'Python programming', $category);
        $competency->deactivate();

        // Act
        $competency->activate();

        // Assert
        $this->assertTrue($competency->isActive());
    }

    public function testAddRequiredForPosition()
    {
        // Arrange
        $category = CompetencyCategory::create('Technical', 'Technical skills');
        $competency = Competency::create('Leadership', 'Leadership skills', $category);

        // Act
        $competency->addRequiredForPosition('senior-developer', 4);
        $competency->addRequiredForPosition('team-lead', 5);

        // Assert
        $this->assertTrue($competency->isRequiredForPosition('senior-developer'));
        $this->assertEquals(4, $competency->getRequiredLevelForPosition('senior-developer'));
        $this->assertEquals(5, $competency->getRequiredLevelForPosition('team-lead'));
    }

    public function testRemoveRequiredForPosition()
    {
        // Arrange
        $category = CompetencyCategory::create('Technical', 'Technical skills');
        $competency = Competency::create('Project Management', 'PM skills', $category);
        $competency->addRequiredForPosition('developer', 2);

        // Act
        $competency->removeRequiredForPosition('developer');

        // Assert
        $this->assertFalse($competency->isRequiredForPosition('developer'));
        $this->assertNull($competency->getRequiredLevelForPosition('developer'));
    }

    public function testCompetencyEquality()
    {
        // Arrange
        $category = CompetencyCategory::create('Technical', 'Technical skills');
        $competency1 = Competency::create('Testing', 'Testing skills', $category);
        $competency2 = Competency::createWithId(
            $competency1->getId(),
            'Testing',
            'Testing skills',
            $category
        );

        // Act & Assert
        $this->assertTrue($competency1->equals($competency2));
    }

    public function testPreventDuplicateSkillLevels()
    {
        // Arrange
        $category = CompetencyCategory::create('Technical', 'Technical skills');
        $competency = Competency::create('React', 'React framework', $category);
        
        $level1 = new SkillLevel(3, 'Intermediate', 'Can build components');
        $level2 = new SkillLevel(3, 'Mid-level', 'Different name, same level');

        // Act
        $competency->addSkillLevel($level1);
        $competency->addSkillLevel($level2); // Should replace the first one

        // Assert
        $this->assertCount(1, $competency->getSkillLevels());
        $this->assertEquals('Mid-level', $competency->getSkillLevel(3)->getName());
    }
} 