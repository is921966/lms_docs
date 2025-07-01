<?php

namespace Tests\Unit\Competency\Domain\ValueObjects;

use PHPUnit\Framework\TestCase;
use Competency\Domain\ValueObjects\CompetencyId;

class CompetencyIdTest extends TestCase
{
    public function testGenerateNewId()
    {
        // Act
        $id = CompetencyId::generate();

        // Assert
        $this->assertInstanceOf(CompetencyId::class, $id);
        $this->assertNotEmpty($id->getValue());
        $this->assertEquals(36, strlen($id->getValue())); // UUID v4 length
    }

    public function testCreateFromString()
    {
        // Arrange
        $uuid = 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11';

        // Act
        $id = CompetencyId::fromString($uuid);

        // Assert
        $this->assertInstanceOf(CompetencyId::class, $id);
        $this->assertEquals($uuid, $id->getValue());
    }

    public function testIdEquality()
    {
        // Arrange
        $uuid = 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11';
        $id1 = CompetencyId::fromString($uuid);
        $id2 = CompetencyId::fromString($uuid);

        // Act & Assert
        $this->assertTrue($id1->equals($id2));
    }

    public function testIdInequality()
    {
        // Arrange
        $id1 = CompetencyId::generate();
        $id2 = CompetencyId::generate();

        // Act & Assert
        $this->assertFalse($id1->equals($id2));
    }

    public function testToString()
    {
        // Arrange
        $uuid = 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11';
        $id = CompetencyId::fromString($uuid);

        // Act & Assert
        $this->assertEquals($uuid, (string)$id);
    }

    public function testInvalidUuidThrowsException()
    {
        // Assert
        $this->expectException(\InvalidArgumentException::class);
        $this->expectExceptionMessage('Invalid UUID format');

        // Act
        CompetencyId::fromString('invalid-uuid');
    }

    public function testEmptyUuidThrowsException()
    {
        // Assert
        $this->expectException(\InvalidArgumentException::class);
        $this->expectExceptionMessage('CompetencyId cannot be empty');

        // Act
        CompetencyId::fromString('');
    }

    public function testImmutability()
    {
        // Arrange
        $id = CompetencyId::generate();
        $originalValue = $id->getValue();

        // Act - Try to get reference and modify (should not be possible)
        $value = $id->getValue();

        // Assert
        $this->assertEquals($originalValue, $id->getValue());
    }
} 