<?php
declare(strict_types=1);

namespace Tests\Unit\OrgStructure\Domain\ValueObjects;

use PHPUnit\Framework\TestCase;
use App\OrgStructure\Domain\ValueObjects\DepartmentId;

class DepartmentIdTest extends TestCase
{
    public function test_generate_creates_unique_id(): void
    {
        // Act
        $id1 = DepartmentId::generate();
        $id2 = DepartmentId::generate();

        // Assert
        $this->assertInstanceOf(DepartmentId::class, $id1);
        $this->assertInstanceOf(DepartmentId::class, $id2);
        $this->assertNotEquals($id1->getValue(), $id2->getValue());
    }

    public function test_create_from_string(): void
    {
        // Arrange
        $uuid = 'a1b2c3d4-e5f6-4321-8765-123456789abc';

        // Act
        $id = DepartmentId::fromString($uuid);

        // Assert
        $this->assertEquals($uuid, $id->getValue());
    }

    public function test_equals_returns_true_for_same_value(): void
    {
        // Arrange
        $uuid = 'a1b2c3d4-e5f6-4321-8765-123456789abc';
        $id1 = DepartmentId::fromString($uuid);
        $id2 = DepartmentId::fromString($uuid);

        // Act & Assert
        $this->assertTrue($id1->equals($id2));
    }
} 