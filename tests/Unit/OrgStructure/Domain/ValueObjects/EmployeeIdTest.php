<?php
declare(strict_types=1);

namespace Tests\Unit\OrgStructure\Domain\ValueObjects;

use PHPUnit\Framework\TestCase;
use App\OrgStructure\Domain\ValueObjects\EmployeeId;

class EmployeeIdTest extends TestCase
{
    public function test_generate_creates_unique_id(): void
    {
        // Act
        $id1 = EmployeeId::generate();
        $id2 = EmployeeId::generate();

        // Assert
        $this->assertInstanceOf(EmployeeId::class, $id1);
        $this->assertInstanceOf(EmployeeId::class, $id2);
        $this->assertNotEquals($id1->getValue(), $id2->getValue());
    }

    public function test_create_from_string(): void
    {
        // Arrange
        $uuid = 'f47ac10b-58cc-4372-a567-0e02b2c3d479';

        // Act
        $id = EmployeeId::fromString($uuid);

        // Assert
        $this->assertEquals($uuid, $id->getValue());
    }

    public function test_equals_returns_true_for_same_value(): void
    {
        // Arrange
        $uuid = 'f47ac10b-58cc-4372-a567-0e02b2c3d479';
        $id1 = EmployeeId::fromString($uuid);
        $id2 = EmployeeId::fromString($uuid);

        // Act & Assert
        $this->assertTrue($id1->equals($id2));
    }

    public function test_equals_returns_false_for_different_values(): void
    {
        // Arrange
        $id1 = EmployeeId::generate();
        $id2 = EmployeeId::generate();

        // Act & Assert
        $this->assertFalse($id1->equals($id2));
    }
} 