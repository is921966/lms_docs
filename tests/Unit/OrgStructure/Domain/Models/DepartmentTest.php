<?php
declare(strict_types=1);

namespace Tests\Unit\OrgStructure\Domain\Models;

use PHPUnit\Framework\TestCase;
use App\OrgStructure\Domain\Models\Department;
use App\OrgStructure\Domain\ValueObjects\DepartmentId;
use App\OrgStructure\Domain\ValueObjects\DepartmentCode;
use App\OrgStructure\Domain\Exceptions\InvalidDepartmentException;

class DepartmentTest extends TestCase
{
    public function test_create_department_with_valid_data(): void
    {
        // Arrange
        $id = DepartmentId::generate();
        $code = new DepartmentCode('IT001');
        $name = 'IT Department';

        // Act
        $department = new Department($id, $code, $name);

        // Assert
        $this->assertEquals($id, $department->getId());
        $this->assertEquals($code, $department->getCode());
        $this->assertEquals($name, $department->getName());
        $this->assertNull($department->getParent());
        $this->assertEquals(1, $department->getLevel());
        $this->assertEmpty($department->getChildren());
    }

    public function test_create_department_from_csv_data(): void
    {
        // Arrange
        $csvData = [
            'department_code' => 'HR002',
            'department_name' => 'Human Resources',
            'parent_code' => 'HEAD001',
            'level' => '2'
        ];

        // Act
        $department = Department::createFromCsvData($csvData);

        // Assert
        $this->assertEquals('HR002', $department->getCode()->getValue());
        $this->assertEquals('Human Resources', $department->getName());
        $this->assertArrayHasKey('parent_code', $department->getMetadata());
    }

    public function test_department_hierarchy(): void
    {
        // Arrange
        $parent = new Department(
            DepartmentId::generate(),
            new DepartmentCode('MAIN'),
            'Main Office'
        );
        
        $child = new Department(
            DepartmentId::generate(),
            new DepartmentCode('SUB1'),
            'Sub Office'
        );

        // Act
        $parent->addChild($child);

        // Assert
        $this->assertCount(1, $parent->getChildren());
        $this->assertEquals($parent, $child->getParent());
        $this->assertEquals(2, $child->getLevel());
    }

    public function test_department_cannot_be_its_own_child(): void
    {
        // Arrange
        $department = new Department(
            DepartmentId::generate(),
            new DepartmentCode('DEPT1'),
            'Department'
        );

        // Assert
        $this->expectException(InvalidDepartmentException::class);
        $this->expectExceptionMessage('Department cannot be its own child');

        // Act
        $department->addChild($department);
    }

    public function test_circular_reference_prevention(): void
    {
        // Arrange
        $dept1 = new Department(DepartmentId::generate(), new DepartmentCode('D1'), 'Dept 1');
        $dept2 = new Department(DepartmentId::generate(), new DepartmentCode('D2'), 'Dept 2');
        $dept3 = new Department(DepartmentId::generate(), new DepartmentCode('D3'), 'Dept 3');

        $dept1->addChild($dept2);
        $dept2->addChild($dept3);

        // Assert
        $this->expectException(InvalidDepartmentException::class);
        $this->expectExceptionMessage('Circular reference detected');

        // Act - Try to make dept3 parent of dept1
        $dept3->addChild($dept1);
    }

    public function test_get_full_path(): void
    {
        // Arrange
        $root = new Department(DepartmentId::generate(), new DepartmentCode('ROOT'), 'Company');
        $level1 = new Department(DepartmentId::generate(), new DepartmentCode('L1'), 'Division');
        $level2 = new Department(DepartmentId::generate(), new DepartmentCode('L2'), 'Department');

        $root->addChild($level1);
        $level1->addChild($level2);

        // Act
        $path = $level2->getFullPath();

        // Assert
        $this->assertEquals('Company / Division / Department', $path);
    }
} 