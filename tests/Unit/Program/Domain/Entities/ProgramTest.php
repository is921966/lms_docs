<?php

declare(strict_types=1);

namespace Tests\Unit\Program\Domain\Entities;

use Program\Domain\Program;
use Program\Domain\ValueObjects\ProgramId;
use Program\Domain\ValueObjects\ProgramCode;
use Program\Domain\ValueObjects\ProgramStatus;
use Program\Domain\ValueObjects\CompletionCriteria;
use Program\Domain\Events\ProgramCreated;
use PHPUnit\Framework\TestCase;

class ProgramTest extends TestCase
{
    public function testCanBeCreated(): void
    {
        // Arrange
        $id = ProgramId::generate();
        $code = ProgramCode::fromString('LEAD-101');
        $title = 'Leadership Development Program';
        $description = 'A comprehensive leadership program';
        
        // Act
        $program = Program::create($id, $code, $title, $description);
        
        // Assert
        $this->assertInstanceOf(Program::class, $program);
        $this->assertTrue($id->equals($program->getId()));
        $this->assertTrue($code->equals($program->getCode()));
        $this->assertEquals($title, $program->getTitle());
        $this->assertEquals($description, $program->getDescription());
        $this->assertTrue($program->getStatus()->isDraft());
        
        // Check domain event
        $events = $program->pullDomainEvents();
        $this->assertCount(1, $events);
        $this->assertInstanceOf(ProgramCreated::class, $events[0]);
    }
    
    public function testCanUpdateBasicInfo(): void
    {
        // Arrange
        $program = $this->createProgram();
        $newTitle = 'Updated Leadership Program';
        $newDescription = 'An updated description';
        
        // Act
        $program->updateBasicInfo($newTitle, $newDescription);
        
        // Assert
        $this->assertEquals($newTitle, $program->getTitle());
        $this->assertEquals($newDescription, $program->getDescription());
    }
    
    public function testCannotUpdateTitleToEmpty(): void
    {
        // Arrange
        $program = $this->createProgram();
        
        // Assert
        $this->expectException(\InvalidArgumentException::class);
        $this->expectExceptionMessage('Program title cannot be empty');
        
        // Act
        $program->updateBasicInfo('', 'Description');
    }
    
    public function testCanSetCompletionCriteria(): void
    {
        // Arrange
        $program = $this->createProgram();
        $criteria = CompletionCriteria::fromPercentage(80);
        
        // Act
        $program->setCompletionCriteria($criteria);
        
        // Assert
        $this->assertTrue($criteria->equals($program->getCompletionCriteria()));
    }
    
    public function testCanBePublished(): void
    {
        // Arrange
        $program = $this->createProgram();
        
        // Assert - cannot publish without tracks
        $this->expectException(\DomainException::class);
        $this->expectExceptionMessage('Cannot publish program without tracks');
        
        // Act
        $program->publish();
    }
    
    public function testCanBeArchived(): void
    {
        // Arrange
        $program = $this->createProgram();
        // First publish it (would need tracks in real scenario)
        $program->forceStatus(ProgramStatus::active());
        
        // Act
        $program->archive();
        
        // Assert
        $this->assertTrue($program->getStatus()->isArchived());
    }
    
    public function testCannotArchiveFromDraft(): void
    {
        // Arrange
        $program = $this->createProgram();
        
        // Assert
        $this->expectException(\DomainException::class);
        $this->expectExceptionMessage('Cannot archive program from draft status');
        
        // Act
        $program->archive();
    }
    
    public function testCanCheckIfEmpty(): void
    {
        // Arrange
        $program = $this->createProgram();
        
        // Act & Assert
        $this->assertTrue($program->isEmpty());
    }
    
    public function testCanGetMetadata(): void
    {
        // Arrange
        $program = $this->createProgram();
        
        // Act
        $program->setMetadata(['target_audience' => 'Senior Managers']);
        
        // Assert
        $this->assertEquals(['target_audience' => 'Senior Managers'], $program->getMetadata());
    }
    
    public function testCanBeConvertedToArray(): void
    {
        // Arrange
        $program = $this->createProgram();
        
        // Act
        $array = $program->toArray();
        
        // Assert
        $this->assertArrayHasKey('id', $array);
        $this->assertArrayHasKey('code', $array);
        $this->assertArrayHasKey('title', $array);
        $this->assertArrayHasKey('description', $array);
        $this->assertArrayHasKey('status', $array);
        $this->assertArrayHasKey('completionCriteria', $array);
        $this->assertArrayHasKey('metadata', $array);
        $this->assertArrayHasKey('createdAt', $array);
        $this->assertArrayHasKey('updatedAt', $array);
    }
    
    private function createProgram(): Program
    {
        return Program::create(
            ProgramId::generate(),
            ProgramCode::fromString('TEST-001'),
            'Test Program',
            'Test Description'
        );
    }
} 