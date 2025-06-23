<?php

declare(strict_types=1);

namespace Tests\Unit\Position\Domain;

use App\Position\Domain\Position;
use App\Position\Domain\ValueObjects\PositionId;
use App\Position\Domain\ValueObjects\PositionCode;
use App\Position\Domain\ValueObjects\PositionLevel;
use App\Position\Domain\ValueObjects\Department;
use App\Position\Domain\Events\PositionCreated;
use App\Position\Domain\Events\PositionUpdated;
use App\Position\Domain\Events\PositionArchived;
use PHPUnit\Framework\TestCase;

class PositionTest extends TestCase
{
    public function testCreatePosition(): void
    {
        $id = PositionId::generate();
        $code = PositionCode::fromString('DEV-001');
        $department = Department::fromString('Engineering');
        $level = PositionLevel::middle();
        
        $position = Position::create(
            id: $id,
            code: $code,
            title: 'Software Developer',
            department: $department,
            level: $level,
            description: 'Develops software applications'
        );
        
        $this->assertEquals($id, $position->getId());
        $this->assertEquals($code, $position->getCode());
        $this->assertEquals('Software Developer', $position->getTitle());
        $this->assertEquals($department, $position->getDepartment());
        $this->assertEquals($level, $position->getLevel());
        $this->assertEquals('Develops software applications', $position->getDescription());
        $this->assertTrue($position->isActive());
        $this->assertNull($position->getParentId());
        
        // Check domain event
        $events = $position->releaseEvents();
        $this->assertCount(1, $events);
        $this->assertInstanceOf(PositionCreated::class, $events[0]);
    }
    
    public function testCreatePositionWithParent(): void
    {
        $parentId = PositionId::generate();
        
        $position = Position::create(
            id: PositionId::generate(),
            code: PositionCode::fromString('DEV-002'),
            title: 'Junior Developer',
            department: Department::fromString('Engineering'),
            level: PositionLevel::junior(),
            description: 'Entry level developer',
            parentId: $parentId
        );
        
        $this->assertEquals($parentId, $position->getParentId());
    }
    
    public function testUpdatePosition(): void
    {
        $position = Position::create(
            id: PositionId::generate(),
            code: PositionCode::fromString('DEV-001'),
            title: 'Software Developer',
            department: Department::fromString('Engineering'),
            level: PositionLevel::middle(),
            description: 'Develops software'
        );
        
        // Clear creation event
        $position->releaseEvents();
        
        $position->update(
            title: 'Senior Software Developer',
            description: 'Leads development projects',
            level: PositionLevel::senior()
        );
        
        $this->assertEquals('Senior Software Developer', $position->getTitle());
        $this->assertEquals('Leads development projects', $position->getDescription());
        $this->assertEquals(PositionLevel::senior(), $position->getLevel());
        
        // Check update event
        $events = $position->releaseEvents();
        $this->assertCount(1, $events);
        $this->assertInstanceOf(PositionUpdated::class, $events[0]);
    }
    
    public function testChangeParent(): void
    {
        $position = Position::create(
            id: PositionId::generate(),
            code: PositionCode::fromString('DEV-001'),
            title: 'Developer',
            department: Department::fromString('Engineering'),
            level: PositionLevel::middle(),
            description: 'Developer'
        );
        
        $newParentId = PositionId::generate();
        $position->changeParent($newParentId);
        
        $this->assertEquals($newParentId, $position->getParentId());
    }
    
    public function testRemoveParent(): void
    {
        $parentId = PositionId::generate();
        
        $position = Position::create(
            id: PositionId::generate(),
            code: PositionCode::fromString('DEV-001'),
            title: 'Developer',
            department: Department::fromString('Engineering'),
            level: PositionLevel::middle(),
            description: 'Developer',
            parentId: $parentId
        );
        
        $position->removeParent();
        
        $this->assertNull($position->getParentId());
    }
    
    public function testArchivePosition(): void
    {
        $position = Position::create(
            id: PositionId::generate(),
            code: PositionCode::fromString('DEV-001'),
            title: 'Developer',
            department: Department::fromString('Engineering'),
            level: PositionLevel::middle(),
            description: 'Developer'
        );
        
        $position->releaseEvents(); // Clear creation event
        
        $position->archive();
        
        $this->assertFalse($position->isActive());
        
        // Check archive event
        $events = $position->releaseEvents();
        $this->assertCount(1, $events);
        $this->assertInstanceOf(PositionArchived::class, $events[0]);
    }
    
    public function testRestorePosition(): void
    {
        $position = Position::create(
            id: PositionId::generate(),
            code: PositionCode::fromString('DEV-001'),
            title: 'Developer',
            department: Department::fromString('Engineering'),
            level: PositionLevel::middle(),
            description: 'Developer'
        );
        
        $position->archive();
        $position->restore();
        
        $this->assertTrue($position->isActive());
    }
    
    public function testCannotArchiveAlreadyArchivedPosition(): void
    {
        $position = Position::create(
            id: PositionId::generate(),
            code: PositionCode::fromString('DEV-001'),
            title: 'Developer',
            department: Department::fromString('Engineering'),
            level: PositionLevel::middle(),
            description: 'Developer'
        );
        
        $position->archive();
        
        $this->expectException(\DomainException::class);
        $this->expectExceptionMessage('Position is already archived');
        
        $position->archive();
    }
    
    public function testPositionEquality(): void
    {
        $id = PositionId::generate();
        
        $position1 = Position::create(
            id: $id,
            code: PositionCode::fromString('DEV-001'),
            title: 'Developer',
            department: Department::fromString('Engineering'),
            level: PositionLevel::middle(),
            description: 'Developer'
        );
        
        $position2 = Position::create(
            id: PositionId::generate(),
            code: PositionCode::fromString('DEV-002'),
            title: 'Another Developer',
            department: Department::fromString('Engineering'),
            level: PositionLevel::senior(),
            description: 'Senior Developer'
        );
        
        $this->assertTrue($position1->equals($position1));
        $this->assertFalse($position1->equals($position2));
    }
    
    public function testGetRequiredCompetencyCount(): void
    {
        $position = Position::create(
            id: PositionId::generate(),
            code: PositionCode::fromString('DEV-001'),
            title: 'Developer',
            department: Department::fromString('Engineering'),
            level: PositionLevel::middle(),
            description: 'Developer'
        );
        
        // Initially no competencies
        $this->assertEquals(0, $position->getRequiredCompetencyCount());
    }
} 