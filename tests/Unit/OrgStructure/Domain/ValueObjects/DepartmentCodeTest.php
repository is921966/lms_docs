<?php
declare(strict_types=1);

namespace Tests\Unit\OrgStructure\Domain\ValueObjects;

use PHPUnit\Framework\TestCase;
use App\OrgStructure\Domain\ValueObjects\DepartmentCode;
use App\OrgStructure\Domain\Exceptions\InvalidDepartmentCodeException;

class DepartmentCodeTest extends TestCase
{
    public function test_create_valid_department_code(): void
    {
        // Act
        $code = new DepartmentCode('IT001');

        // Assert
        $this->assertEquals('IT001', $code->getValue());
    }

    public function test_department_code_cannot_be_empty(): void
    {
        // Assert
        $this->expectException(InvalidDepartmentCodeException::class);
        $this->expectExceptionMessage('Department code cannot be empty');

        // Act
        new DepartmentCode('');
    }

    public function test_department_code_is_trimmed(): void
    {
        // Act
        $code = new DepartmentCode('  HR002  ');

        // Assert
        $this->assertEquals('HR002', $code->getValue());
    }

    public function test_equals_returns_true_for_same_code(): void
    {
        // Arrange
        $code1 = new DepartmentCode('DEPT001');
        $code2 = new DepartmentCode('DEPT001');

        // Act & Assert
        $this->assertTrue($code1->equals($code2));
    }
} 