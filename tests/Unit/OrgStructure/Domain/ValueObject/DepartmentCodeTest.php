<?php

namespace Tests\Unit\OrgStructure\Domain\ValueObject;

use PHPUnit\Framework\TestCase;
use App\OrgStructure\Domain\ValueObject\DepartmentCode;
use App\OrgStructure\Domain\Exception\InvalidDepartmentCodeException;

class DepartmentCodeTest extends TestCase
{
    /** @test */
    public function it_creates_valid_department_code(): void
    {
        // Arrange & Act
        $code = new DepartmentCode('АП.3.2');
        
        // Assert
        $this->assertEquals('АП.3.2', $code->getValue());
        $this->assertEquals('АП.3.2', (string)$code);
    }
    
    /** @test */
    public function it_validates_code_format(): void
    {
        // Arrange
        $validCodes = [
            'АП',
            'АП.1',
            'АП.3.2',
            'АП.3.2.1',
            'АП.3.2.1.1',
            'АП.10.20.30.40',
        ];
        
        // Act & Assert
        foreach ($validCodes as $validCode) {
            $code = new DepartmentCode($validCode);
            $this->assertEquals($validCode, $code->getValue());
        }
    }
    
    /** @test */
    public function it_throws_exception_for_invalid_format(): void
    {
        // Arrange
        $invalidCodes = [
            '',
            'AP', // Latin letters
            'АП.',
            '.3.2',
            'АП..3',
            'АП.3.2.',
            'АП.3.2.a',
            'АП-3-2',
            'АП 3 2',
        ];
        
        // Act & Assert
        foreach ($invalidCodes as $invalidCode) {
            try {
                new DepartmentCode($invalidCode);
                $this->fail("Expected exception for code: $invalidCode");
            } catch (InvalidDepartmentCodeException $e) {
                $this->assertStringContainsString('Invalid department code format', $e->getMessage());
            }
        }
    }
    
    /** @test */
    public function it_can_get_parent_code(): void
    {
        // Arrange
        $testCases = [
            ['АП', null],
            ['АП.3', 'АП'],
            ['АП.3.2', 'АП.3'],
            ['АП.3.2.1', 'АП.3.2'],
            ['АП.3.2.1.1', 'АП.3.2.1'],
        ];
        
        // Act & Assert
        foreach ($testCases as [$codeStr, $expectedParent]) {
            $code = new DepartmentCode($codeStr);
            $parent = $code->getParentCode();
            
            if ($expectedParent === null) {
                $this->assertNull($parent);
            } else {
                $this->assertEquals($expectedParent, $parent->getValue());
            }
        }
    }
    
    /** @test */
    public function it_can_get_level(): void
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
            $code = new DepartmentCode($codeStr);
            $this->assertEquals($expectedLevel, $code->getLevel());
        }
    }
    
    /** @test */
    public function it_can_check_if_root(): void
    {
        // Arrange & Act & Assert
        $rootCode = new DepartmentCode('АП');
        $this->assertTrue($rootCode->isRoot());
        
        $childCode = new DepartmentCode('АП.3.2');
        $this->assertFalse($childCode->isRoot());
    }
    
    /** @test */
    public function it_can_check_if_child_of(): void
    {
        // Arrange
        $parent = new DepartmentCode('АП.3');
        $child = new DepartmentCode('АП.3.2');
        $grandchild = new DepartmentCode('АП.3.2.1');
        $sibling = new DepartmentCode('АП.3.1');
        $unrelated = new DepartmentCode('АП.4.1');
        
        // Act & Assert
        $this->assertTrue($child->isChildOf($parent));
        $this->assertTrue($grandchild->isChildOf($parent)); // Indirect child
        $this->assertFalse($sibling->isChildOf($child));
        $this->assertFalse($unrelated->isChildOf($parent));
        $this->assertFalse($parent->isChildOf($child)); // Parent can't be child
    }
    
    /** @test */
    public function it_can_get_segments(): void
    {
        // Arrange
        $code = new DepartmentCode('АП.3.2.1');
        
        // Act
        $segments = $code->getSegments();
        
        // Assert
        $this->assertEquals(['АП', '3', '2', '1'], $segments);
    }
    
    /** @test */
    public function it_can_create_child_code(): void
    {
        // Arrange
        $parent = new DepartmentCode('АП.3.2');
        
        // Act
        $child = $parent->createChildCode(5);
        
        // Assert
        $this->assertEquals('АП.3.2.5', $child->getValue());
        $this->assertTrue($child->isChildOf($parent));
    }
} 