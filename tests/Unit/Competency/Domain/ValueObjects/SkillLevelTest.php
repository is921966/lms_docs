<?php

namespace Tests\Unit\Competency\Domain\ValueObjects;

use PHPUnit\Framework\TestCase;
use Competency\Domain\ValueObjects\SkillLevel;

class SkillLevelTest extends TestCase
{
    public function testCreateSkillLevel()
    {
        // Act
        $level = new SkillLevel(3, 'Intermediate', 'Can work independently on most tasks');

        // Assert
        $this->assertInstanceOf(SkillLevel::class, $level);
        $this->assertEquals(3, $level->getLevel());
        $this->assertEquals('Intermediate', $level->getName());
        $this->assertEquals('Can work independently on most tasks', $level->getDescription());
    }

    public function testInvalidLevelTooLow()
    {
        // Assert
        $this->expectException(\InvalidArgumentException::class);
        $this->expectExceptionMessage('Skill level must be between 1 and 5');

        // Act
        new SkillLevel(0, 'Invalid', 'Invalid level');
    }

    public function testInvalidLevelTooHigh()
    {
        // Assert
        $this->expectException(\InvalidArgumentException::class);
        $this->expectExceptionMessage('Skill level must be between 1 and 5');

        // Act
        new SkillLevel(6, 'Invalid', 'Invalid level');
    }

    public function testEmptyNameThrowsException()
    {
        // Assert
        $this->expectException(\InvalidArgumentException::class);
        $this->expectExceptionMessage('Skill level name cannot be empty');

        // Act
        new SkillLevel(3, '', 'Description');
    }

    public function testEmptyDescriptionThrowsException()
    {
        // Assert
        $this->expectException(\InvalidArgumentException::class);
        $this->expectExceptionMessage('Skill level description cannot be empty');

        // Act
        new SkillLevel(3, 'Intermediate', '');
    }

    public function testSkillLevelEquality()
    {
        // Arrange
        $level1 = new SkillLevel(3, 'Intermediate', 'Can work independently');
        $level2 = new SkillLevel(3, 'Intermediate', 'Can work independently');

        // Act & Assert
        $this->assertTrue($level1->equals($level2));
    }

    public function testSkillLevelInequalityByLevel()
    {
        // Arrange
        $level1 = new SkillLevel(2, 'Elementary', 'Basic knowledge');
        $level2 = new SkillLevel(3, 'Intermediate', 'Can work independently');

        // Act & Assert
        $this->assertFalse($level1->equals($level2));
    }

    public function testSkillLevelComparison()
    {
        // Arrange
        $beginner = new SkillLevel(1, 'Beginner', 'Just starting');
        $intermediate = new SkillLevel(3, 'Intermediate', 'Can work independently');
        $expert = new SkillLevel(5, 'Expert', 'Deep expertise');

        // Act & Assert
        $this->assertTrue($beginner->isLowerThan($intermediate));
        $this->assertTrue($intermediate->isHigherThan($beginner));
        $this->assertTrue($intermediate->isLowerThan($expert));
        $this->assertTrue($expert->isHigherThan($intermediate));
        $this->assertFalse($intermediate->isLowerThan($intermediate));
        $this->assertFalse($intermediate->isHigherThan($intermediate));
    }

    public function testPredefinedLevels()
    {
        // Act
        $beginner = SkillLevel::beginner();
        $elementary = SkillLevel::elementary();
        $intermediate = SkillLevel::intermediate();
        $advanced = SkillLevel::advanced();
        $expert = SkillLevel::expert();

        // Assert
        $this->assertEquals(1, $beginner->getLevel());
        $this->assertEquals('Beginner', $beginner->getName());
        
        $this->assertEquals(2, $elementary->getLevel());
        $this->assertEquals('Elementary', $elementary->getName());
        
        $this->assertEquals(3, $intermediate->getLevel());
        $this->assertEquals('Intermediate', $intermediate->getName());
        
        $this->assertEquals(4, $advanced->getLevel());
        $this->assertEquals('Advanced', $advanced->getName());
        
        $this->assertEquals(5, $expert->getLevel());
        $this->assertEquals('Expert', $expert->getName());
    }

    public function testToString()
    {
        // Arrange
        $level = new SkillLevel(3, 'Intermediate', 'Can work independently');

        // Act & Assert
        $this->assertEquals('Intermediate (Level 3)', (string)$level);
    }

    public function testToArray()
    {
        // Arrange
        $level = new SkillLevel(4, 'Advanced', 'Can mentor others');

        // Act
        $array = $level->toArray();

        // Assert
        $this->assertEquals([
            'level' => 4,
            'name' => 'Advanced',
            'description' => 'Can mentor others'
        ], $array);
    }
} 