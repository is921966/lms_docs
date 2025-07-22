<?php

namespace Tests\Unit\OrgStructure\Domain;

use PHPUnit\Framework\TestCase;
use App\OrgStructure\Domain\Entity\Department;
use App\OrgStructure\Domain\ValueObject\DepartmentCode;
use App\OrgStructure\Domain\Exception\InvalidDepartmentCodeException;
use App\OrgStructure\Domain\Exception\InvalidDepartmentDataException;

class DepartmentTest extends TestCase
{
    /** @test */
    public function it_creates_department_with_valid_data(): void
    {
        // Arrange
        $id = 'dept-123';
        $name = 'Департамент информационных технологий';
        $code = new DepartmentCode('АП.3.2');
        $parentId = 'dept-parent';
        
        // Act
        $department = new Department($id, $name, $code, $parentId);
        
        // Assert
        $this->assertEquals($id, $department->getId());
        $this->assertEquals($name, $department->getName());
        $this->assertEquals($code, $department->getCode());
        $this->assertEquals($parentId, $department->getParentId());
        $this->assertEquals(2, $department->getLevel());
    }
    
    /** @test */
    public function it_creates_root_department_without_parent(): void
    {
        // Arrange & Act
        $department = new Department(
            'dept-root',
            'Генеральный менеджер',
            new DepartmentCode('АП'),
            null
        );
        
        // Assert
        $this->assertNull($department->getParentId());
        $this->assertEquals(0, $department->getLevel());
        $this->assertTrue($department->isRoot());
    }
    
    /** @test */
    public function it_throws_exception_for_empty_name(): void
    {
        // Arrange & Act & Assert
        $this->expectException(InvalidDepartmentDataException::class);
        $this->expectExceptionMessage('Department name cannot be empty');
        
        new Department(
            'dept-123',
            '',
            new DepartmentCode('АП.3.2'),
            null
        );
    }
    
    /** @test */
    public function it_calculates_level_from_code(): void
    {
        // Arrange
        $testCases = [
            ['АП', 0],
            ['АП.3', 1],
            ['АП.3.2', 2],
            ['АП.3.2.1', 3],
            ['АП.3.2.1.1', 4],
        ];
        
        // Act & Assert
        foreach ($testCases as [$codeStr, $expectedLevel]) {
            $department = new Department(
                'dept-test',
                'Test Department',
                new DepartmentCode($codeStr),
                null
            );
            
            $this->assertEquals(
                $expectedLevel,
                $department->getLevel(),
                "Code $codeStr should have level $expectedLevel"
            );
        }
    }
    
    /** @test */
    public function it_can_add_child_department(): void
    {
        // Arrange
        $parent = new Department(
            'dept-parent',
            'Parent Department',
            new DepartmentCode('АП.3'),
            null
        );
        
        $child = new Department(
            'dept-child',
            'Child Department',
            new DepartmentCode('АП.3.1'),
            'dept-parent'
        );
        
        // Act
        $parent->addChild($child);
        
        // Assert
        $this->assertCount(1, $parent->getChildren());
        $this->assertTrue($parent->hasChildren());
        $this->assertContains($child, $parent->getChildren());
    }
    
    /** @test */
    public function it_can_count_total_employees(): void
    {
        // Arrange
        $department = new Department(
            'dept-123',
            'IT Department',
            new DepartmentCode('АП.3.2'),
            null
        );
        
        // Act
        $department->setEmployeeCount(10);
        
        // Assert
        $this->assertEquals(10, $department->getEmployeeCount());
    }
    
    /** @test */
    public function it_can_update_department_name(): void
    {
        // Arrange
        $department = new Department(
            'dept-123',
            'Old Name',
            new DepartmentCode('АП.3.2'),
            null
        );
        
        // Act
        $department->updateName('New Department Name');
        
        // Assert
        $this->assertEquals('New Department Name', $department->getName());
    }
    
    /** @test */
    public function it_can_get_full_path_to_root(): void
    {
        // Note: This test assumes we have a method to build full path
        // In real implementation, this might require repository
        $department = new Department(
            'dept-123',
            'Отдел автоматизации',
            new DepartmentCode('АП.3.2.6'),
            'dept-parent'
        );
        
        $path = $department->getCodePath();
        
        $this->assertEquals(['АП', 'АП.3', 'АП.3.2', 'АП.3.2.6'], $path);
    }
} 