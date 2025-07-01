<?php

namespace Tests\Unit\Competency\Application\Commands;

use PHPUnit\Framework\TestCase;
use Competency\Application\Commands\AssessCompetencyCommand;

class AssessCompetencyCommandTest extends TestCase
{
    public function testCreateCommand()
    {
        // Act
        $command = new AssessCompetencyCommand(
            'user-123',
            'competency-456',
            3,
            'assessor-789',
            'Good progress in intermediate skills'
        );

        // Assert
        $this->assertEquals('user-123', $command->getUserId());
        $this->assertEquals('competency-456', $command->getCompetencyId());
        $this->assertEquals(3, $command->getLevel());
        $this->assertEquals('assessor-789', $command->getAssessorId());
        $this->assertEquals('Good progress in intermediate skills', $command->getComment());
    }

    public function testCreateSelfAssessment()
    {
        // Act
        $command = new AssessCompetencyCommand(
            'user-123',
            'competency-456',
            2,
            'user-123', // Same as user ID
            'Self-assessment: Elementary level'
        );

        // Assert
        $this->assertTrue($command->isSelfAssessment());
    }

    public function testCreateManagerAssessment()
    {
        // Act
        $command = new AssessCompetencyCommand(
            'user-123',
            'competency-456',
            4,
            'manager-999',
            'Ready for advanced tasks'
        );

        // Assert
        $this->assertFalse($command->isSelfAssessment());
    }

    public function testCommandWithoutComment()
    {
        // Act
        $command = new AssessCompetencyCommand(
            'user-123',
            'competency-456',
            5,
            'assessor-789'
        );

        // Assert
        $this->assertNull($command->getComment());
    }

    public function testInvalidLevelTooLow()
    {
        // Assert
        $this->expectException(\InvalidArgumentException::class);
        $this->expectExceptionMessage('Assessment level must be between 1 and 5');

        // Act
        new AssessCompetencyCommand(
            'user-123',
            'competency-456',
            0,
            'assessor-789'
        );
    }

    public function testInvalidLevelTooHigh()
    {
        // Assert
        $this->expectException(\InvalidArgumentException::class);
        $this->expectExceptionMessage('Assessment level must be between 1 and 5');

        // Act
        new AssessCompetencyCommand(
            'user-123',
            'competency-456',
            6,
            'assessor-789'
        );
    }

    public function testEmptyUserId()
    {
        // Assert
        $this->expectException(\InvalidArgumentException::class);
        $this->expectExceptionMessage('User ID cannot be empty');

        // Act
        new AssessCompetencyCommand(
            '',
            'competency-456',
            3,
            'assessor-789'
        );
    }

    public function testEmptyCompetencyId()
    {
        // Assert
        $this->expectException(\InvalidArgumentException::class);
        $this->expectExceptionMessage('Competency ID cannot be empty');

        // Act
        new AssessCompetencyCommand(
            'user-123',
            '',
            3,
            'assessor-789'
        );
    }

    public function testEmptyAssessorId()
    {
        // Assert
        $this->expectException(\InvalidArgumentException::class);
        $this->expectExceptionMessage('Assessor ID cannot be empty');

        // Act
        new AssessCompetencyCommand(
            'user-123',
            'competency-456',
            3,
            ''
        );
    }

    public function testToArray()
    {
        // Arrange
        $command = new AssessCompetencyCommand(
            'user-123',
            'competency-456',
            4,
            'assessor-789',
            'Advanced level achieved'
        );

        // Act
        $array = $command->toArray();

        // Assert
        $this->assertEquals([
            'userId' => 'user-123',
            'competencyId' => 'competency-456',
            'level' => 4,
            'assessorId' => 'assessor-789',
            'comment' => 'Advanced level achieved',
            'isSelfAssessment' => false
        ], $array);
    }
} 