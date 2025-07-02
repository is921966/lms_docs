<?php

declare(strict_types=1);

namespace Tests\Unit\Program\Domain\Entities;

use Program\Domain\ProgramEnrollment;
use Program\Domain\ValueObjects\ProgramId;
use User\Domain\ValueObjects\UserId;
use Program\Domain\Events\UserEnrolledInProgram;
use PHPUnit\Framework\TestCase;

class ProgramEnrollmentTest extends TestCase
{
    public function testCanBeCreated(): void
    {
        // Arrange
        $userId = UserId::generate();
        $programId = ProgramId::generate();
        
        // Act
        $enrollment = ProgramEnrollment::create($userId, $programId);
        
        // Assert
        $this->assertInstanceOf(ProgramEnrollment::class, $enrollment);
        $this->assertTrue($userId->equals($enrollment->getUserId()));
        $this->assertTrue($programId->equals($enrollment->getProgramId()));
        $this->assertEquals('enrolled', $enrollment->getStatus());
        $this->assertInstanceOf(\DateTimeImmutable::class, $enrollment->getEnrolledAt());
        $this->assertNull($enrollment->getCompletedAt());
        
        // Check domain event
        $events = $enrollment->pullDomainEvents();
        $this->assertCount(1, $events);
        $this->assertInstanceOf(UserEnrolledInProgram::class, $events[0]);
    }
    
    public function testCanStartProgram(): void
    {
        // Arrange
        $enrollment = $this->createEnrollment();
        
        // Act
        $enrollment->start();
        
        // Assert
        $this->assertEquals('in_progress', $enrollment->getStatus());
        $this->assertInstanceOf(\DateTimeImmutable::class, $enrollment->getStartedAt());
    }
    
    public function testCannotStartAlreadyStartedProgram(): void
    {
        // Arrange
        $enrollment = $this->createEnrollment();
        $enrollment->start();
        
        // Assert
        $this->expectException(\DomainException::class);
        $this->expectExceptionMessage('Program already started');
        
        // Act
        $enrollment->start();
    }
    
    public function testCanCompleteProgram(): void
    {
        // Arrange
        $enrollment = $this->createEnrollment();
        $enrollment->start();
        
        // Act
        $enrollment->complete();
        
        // Assert
        $this->assertEquals('completed', $enrollment->getStatus());
        $this->assertInstanceOf(\DateTimeImmutable::class, $enrollment->getCompletedAt());
    }
    
    public function testCannotCompleteNotStartedProgram(): void
    {
        // Arrange
        $enrollment = $this->createEnrollment();
        
        // Assert
        $this->expectException(\DomainException::class);
        $this->expectExceptionMessage('Cannot complete program that has not been started');
        
        // Act
        $enrollment->complete();
    }
    
    public function testCanSuspendProgram(): void
    {
        // Arrange
        $enrollment = $this->createEnrollment();
        $enrollment->start();
        
        // Act
        $enrollment->suspend();
        
        // Assert
        $this->assertEquals('suspended', $enrollment->getStatus());
    }
    
    public function testCanResumeProgram(): void
    {
        // Arrange
        $enrollment = $this->createEnrollment();
        $enrollment->start();
        $enrollment->suspend();
        
        // Act
        $enrollment->resume();
        
        // Assert
        $this->assertEquals('in_progress', $enrollment->getStatus());
    }
    
    public function testCannotResumeNotSuspendedProgram(): void
    {
        // Arrange
        $enrollment = $this->createEnrollment();
        $enrollment->start();
        
        // Assert
        $this->expectException(\DomainException::class);
        $this->expectExceptionMessage('Can only resume suspended programs');
        
        // Act
        $enrollment->resume();
    }
    
    public function testCanCalculateProgress(): void
    {
        // Arrange
        $enrollment = $this->createEnrollment();
        
        // Act & Assert
        $this->assertEquals(0, $enrollment->getProgress());
        
        $enrollment->updateProgress(50);
        $this->assertEquals(50, $enrollment->getProgress());
        
        $enrollment->updateProgress(100);
        $this->assertEquals(100, $enrollment->getProgress());
    }
    
    public function testCannotSetInvalidProgress(): void
    {
        // Arrange
        $enrollment = $this->createEnrollment();
        
        // Assert
        $this->expectException(\InvalidArgumentException::class);
        $this->expectExceptionMessage('Progress must be between 0 and 100');
        
        // Act
        $enrollment->updateProgress(101);
    }
    
    public function testCanBeConvertedToArray(): void
    {
        // Arrange
        $enrollment = $this->createEnrollment();
        $enrollment->start();
        
        // Act
        $array = $enrollment->toArray();
        
        // Assert
        $this->assertArrayHasKey('userId', $array);
        $this->assertArrayHasKey('programId', $array);
        $this->assertArrayHasKey('status', $array);
        $this->assertArrayHasKey('progress', $array);
        $this->assertArrayHasKey('enrolledAt', $array);
        $this->assertArrayHasKey('startedAt', $array);
        $this->assertArrayHasKey('completedAt', $array);
    }
    
    private function createEnrollment(): ProgramEnrollment
    {
        return ProgramEnrollment::create(
            UserId::generate(),
            ProgramId::generate()
        );
    }
} 