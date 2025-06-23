<?php

declare(strict_types=1);

namespace Tests\Unit\Position\Domain\Service;

use App\Position\Domain\Service\PositionHierarchyService;
use App\Position\Domain\Position;
use App\Position\Domain\ValueObjects\PositionId;
use App\Position\Domain\ValueObjects\PositionCode;
use App\Position\Domain\ValueObjects\PositionLevel;
use App\Position\Domain\ValueObjects\Department;
use PHPUnit\Framework\TestCase;

class PositionHierarchyServiceTest extends TestCase
{
    private PositionHierarchyService $service;
    
    protected function setUp(): void
    {
        $this->service = new PositionHierarchyService();
    }
    
    public function testIsSubordinatePosition(): void
    {
        $juniorPosition = $this->createPosition('Junior Developer', 1);
        $middlePosition = $this->createPosition('Middle Developer', 2);
        $seniorPosition = $this->createPosition('Senior Developer', 3);
        
        $this->assertTrue(
            $this->service->isSubordinate($juniorPosition, $middlePosition)
        );
        $this->assertTrue(
            $this->service->isSubordinate($middlePosition, $seniorPosition)
        );
        $this->assertTrue(
            $this->service->isSubordinate($juniorPosition, $seniorPosition)
        );
        
        // Not subordinate
        $this->assertFalse(
            $this->service->isSubordinate($seniorPosition, $juniorPosition)
        );
        $this->assertFalse(
            $this->service->isSubordinate($middlePosition, $juniorPosition)
        );
    }
    
    public function testIsSameLevelPositions(): void
    {
        $dev1 = $this->createPosition('Backend Developer', 2);
        $dev2 = $this->createPosition('Frontend Developer', 2);
        
        $this->assertTrue(
            $this->service->isSameLevel($dev1, $dev2)
        );
    }
    
    public function testGetLevelDifference(): void
    {
        $junior = $this->createPosition('Junior', 1);
        $senior = $this->createPosition('Senior', 3);
        
        $this->assertEquals(2, $this->service->getLevelDifference($junior, $senior));
        $this->assertEquals(-2, $this->service->getLevelDifference($senior, $junior));
        $this->assertEquals(0, $this->service->getLevelDifference($junior, $junior));
    }
    
    public function testCanBePromotedDirectly(): void
    {
        $junior = $this->createPosition('Junior', 1);
        $middle = $this->createPosition('Middle', 2);
        $senior = $this->createPosition('Senior', 3);
        $lead = $this->createPosition('Lead', 4);
        
        // Direct promotion (1 level)
        $this->assertTrue(
            $this->service->canBePromotedDirectly($junior, $middle)
        );
        $this->assertTrue(
            $this->service->canBePromotedDirectly($middle, $senior)
        );
        
        // Cannot skip levels
        $this->assertFalse(
            $this->service->canBePromotedDirectly($junior, $senior)
        );
        $this->assertFalse(
            $this->service->canBePromotedDirectly($junior, $lead)
        );
        
        // Cannot promote to lower level
        $this->assertFalse(
            $this->service->canBePromotedDirectly($senior, $middle)
        );
    }
    
    public function testIsSameDepartment(): void
    {
        $dept = Department::fromString('IT');
        $pos1 = Position::create(
            id: PositionId::generate(),
            code: PositionCode::fromString('DEV-001'),
            title: 'Developer',
            department: $dept,
            level: PositionLevel::fromValue(2),
            description: 'Software Developer'
        );
        
        $pos2 = Position::create(
            id: PositionId::generate(),
            code: PositionCode::fromString('DEV-002'),
            title: 'Senior Developer',
            department: $dept,
            level: PositionLevel::fromValue(3),
            description: 'Senior Software Developer'
        );
        
        $pos3 = Position::create(
            id: PositionId::generate(),
            code: PositionCode::fromString('HR-001'),
            title: 'HR Manager',
            department: Department::fromString('HR'),
            level: PositionLevel::fromValue(3),
            description: 'Human Resources Manager'
        );
        
        $this->assertTrue($this->service->isSameDepartment($pos1, $pos2));
        $this->assertFalse($this->service->isSameDepartment($pos1, $pos3));
    }
    
    public function testGetHierarchyPath(): void
    {
        $positions = [
            $this->createPosition('Junior', 1),
            $this->createPosition('Middle', 2),
            $this->createPosition('Senior', 3),
            $this->createPosition('Lead', 4)
        ];
        
        $path = $this->service->getHierarchyPath($positions[0], $positions[3], $positions);
        
        $this->assertCount(4, $path);
        $this->assertEquals('Junior', $path[0]->getTitle());
        $this->assertEquals('Middle', $path[1]->getTitle());
        $this->assertEquals('Senior', $path[2]->getTitle());
        $this->assertEquals('Lead', $path[3]->getTitle());
    }
    
    public function testGetHierarchyPathReturnsEmptyForInvalidPath(): void
    {
        $junior = $this->createPosition('Junior', 1);
        $senior = $this->createPosition('Senior', 3);
        
        // Missing middle position
        $path = $this->service->getHierarchyPath($junior, $senior, [$junior, $senior]);
        
        $this->assertEmpty($path);
    }
    
    private function createPosition(string $title, int $level): Position
    {
        // Generate code that matches pattern: 2-5 uppercase letters, hyphen, 3-5 digits
        $prefix = strtoupper(substr(str_replace(' ', '', $title), 0, 3));
        if (strlen($prefix) < 2) {
            $prefix = 'POS';
        }
        $code = $prefix . '-' . str_pad((string)($level * 100), 3, '0', STR_PAD_LEFT);
        
        return Position::create(
            id: PositionId::generate(),
            code: PositionCode::fromString($code),
            title: $title,
            department: Department::fromString('IT'),
            level: PositionLevel::fromValue($level),
            description: $title . ' position'
        );
    }
} 