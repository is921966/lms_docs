<?php

namespace Tests\Unit\Competency\Application\Commands;

use PHPUnit\Framework\TestCase;
use Competency\Application\Commands\CreateCompetencyCommand;

class CreateCompetencyCommandTest extends TestCase
{
    public function testCreateCommand()
    {
        // Act
        $command = new CreateCompetencyCommand(
            'PHP Development',
            'Proficiency in PHP programming language',
            'technical-skills'
        );

        // Assert
        $this->assertEquals('PHP Development', $command->getName());
        $this->assertEquals('Proficiency in PHP programming language', $command->getDescription());
        $this->assertEquals('technical-skills', $command->getCategoryId());
    }

    public function testCreateCommandWithSkillLevels()
    {
        // Arrange
        $skillLevels = [
            ['level' => 1, 'name' => 'Beginner', 'description' => 'Basic PHP syntax'],
            ['level' => 2, 'name' => 'Elementary', 'description' => 'Can write simple scripts'],
            ['level' => 3, 'name' => 'Intermediate', 'description' => 'OOP and frameworks'],
            ['level' => 4, 'name' => 'Advanced', 'description' => 'Architecture patterns'],
            ['level' => 5, 'name' => 'Expert', 'description' => 'Language internals']
        ];

        // Act
        $command = new CreateCompetencyCommand(
            'PHP Development',
            'Proficiency in PHP programming language',
            'technical-skills',
            $skillLevels
        );

        // Assert
        $this->assertCount(5, $command->getSkillLevels());
        $this->assertEquals('Beginner', $command->getSkillLevels()[0]['name']);
        $this->assertEquals(5, $command->getSkillLevels()[4]['level']);
    }

    public function testCommandValidation()
    {
        // Assert
        $this->expectException(\InvalidArgumentException::class);
        $this->expectExceptionMessage('Competency name cannot be empty');

        // Act
        new CreateCompetencyCommand('', 'Description', 'category-id');
    }

    public function testCommandWithEmptyDescription()
    {
        // Assert
        $this->expectException(\InvalidArgumentException::class);
        $this->expectExceptionMessage('Competency description cannot be empty');

        // Act
        new CreateCompetencyCommand('Name', '', 'category-id');
    }

    public function testCommandWithEmptyCategory()
    {
        // Assert
        $this->expectException(\InvalidArgumentException::class);
        $this->expectExceptionMessage('Category ID cannot be empty');

        // Act
        new CreateCompetencyCommand('Name', 'Description', '');
    }

    public function testCommandWithInvalidSkillLevels()
    {
        // Arrange
        $invalidLevels = [
            ['level' => 6, 'name' => 'Invalid', 'description' => 'Too high']
        ];

        // Assert
        $this->expectException(\InvalidArgumentException::class);
        $this->expectExceptionMessage('Skill level must be between 1 and 5');

        // Act
        new CreateCompetencyCommand(
            'PHP',
            'PHP skills',
            'tech',
            $invalidLevels
        );
    }

    public function testCommandToArray()
    {
        // Arrange
        $command = new CreateCompetencyCommand(
            'Docker',
            'Container technology',
            'devops'
        );

        // Act
        $array = $command->toArray();

        // Assert
        $this->assertEquals([
            'name' => 'Docker',
            'description' => 'Container technology',
            'categoryId' => 'devops',
            'skillLevels' => []
        ], $array);
    }
} 