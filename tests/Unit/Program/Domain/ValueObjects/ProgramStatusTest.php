<?php

declare(strict_types=1);

namespace Tests\Unit\Program\Domain\ValueObjects;

use Program\Domain\ValueObjects\ProgramStatus;
use PHPUnit\Framework\TestCase;

class ProgramStatusTest extends TestCase
{
    public function testCanCreateDraftStatus(): void
    {
        // Act
        $status = ProgramStatus::draft();
        
        // Assert
        $this->assertInstanceOf(ProgramStatus::class, $status);
        $this->assertEquals('draft', $status->getValue());
        $this->assertTrue($status->isDraft());
        $this->assertFalse($status->isActive());
        $this->assertFalse($status->isArchived());
    }
    
    public function testCanCreateActiveStatus(): void
    {
        // Act
        $status = ProgramStatus::active();
        
        // Assert
        $this->assertEquals('active', $status->getValue());
        $this->assertFalse($status->isDraft());
        $this->assertTrue($status->isActive());
        $this->assertFalse($status->isArchived());
    }
    
    public function testCanCreateArchivedStatus(): void
    {
        // Act
        $status = ProgramStatus::archived();
        
        // Assert
        $this->assertEquals('archived', $status->getValue());
        $this->assertFalse($status->isDraft());
        $this->assertFalse($status->isActive());
        $this->assertTrue($status->isArchived());
    }
    
    public function testCanCreateFromString(): void
    {
        // Act & Assert
        $draft = ProgramStatus::fromString('draft');
        $this->assertTrue($draft->isDraft());
        
        $active = ProgramStatus::fromString('active');
        $this->assertTrue($active->isActive());
        
        $archived = ProgramStatus::fromString('archived');
        $this->assertTrue($archived->isArchived());
    }
    
    public function testThrowsExceptionForInvalidStatus(): void
    {
        // Assert
        $this->expectException(\InvalidArgumentException::class);
        $this->expectExceptionMessage('Invalid program status: invalid');
        
        // Act
        ProgramStatus::fromString('invalid');
    }
    
    public function testCanCheckTransitions(): void
    {
        // Arrange
        $draft = ProgramStatus::draft();
        $active = ProgramStatus::active();
        $archived = ProgramStatus::archived();
        
        // Act & Assert
        // Draft can transition to active
        $this->assertTrue($draft->canTransitionTo($active));
        // Draft cannot transition to archived
        $this->assertFalse($draft->canTransitionTo($archived));
        
        // Active can transition to archived
        $this->assertTrue($active->canTransitionTo($archived));
        // Active cannot transition to draft
        $this->assertFalse($active->canTransitionTo($draft));
        
        // Archived cannot transition to anything
        $this->assertFalse($archived->canTransitionTo($draft));
        $this->assertFalse($archived->canTransitionTo($active));
    }
    
    public function testCanCheckIfCanBePublished(): void
    {
        // Arrange
        $draft = ProgramStatus::draft();
        $active = ProgramStatus::active();
        $archived = ProgramStatus::archived();
        
        // Act & Assert
        $this->assertTrue($draft->canBePublished());
        $this->assertFalse($active->canBePublished());
        $this->assertFalse($archived->canBePublished());
    }
    
    public function testCanBeCompared(): void
    {
        // Arrange
        $status1 = ProgramStatus::draft();
        $status2 = ProgramStatus::draft();
        $status3 = ProgramStatus::active();
        
        // Act & Assert
        $this->assertTrue($status1->equals($status2));
        $this->assertFalse($status1->equals($status3));
    }
    
    public function testIsJsonSerializable(): void
    {
        // Arrange
        $status = ProgramStatus::active();
        
        // Act
        $json = json_encode(['status' => $status]);
        
        // Assert
        $this->assertEquals('{"status":"active"}', $json);
    }
} 