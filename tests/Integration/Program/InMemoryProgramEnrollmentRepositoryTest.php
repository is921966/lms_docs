<?php

declare(strict_types=1);

namespace Tests\Integration\Program;

use Program\Infrastructure\Persistence\InMemoryProgramEnrollmentRepository;
use Program\Domain\ProgramEnrollment;
use Program\Domain\ValueObjects\ProgramId;
use User\Domain\ValueObjects\UserId;
use PHPUnit\Framework\TestCase;

class InMemoryProgramEnrollmentRepositoryTest extends TestCase
{
    private InMemoryProgramEnrollmentRepository $repository;
    
    protected function setUp(): void
    {
        $this->repository = new InMemoryProgramEnrollmentRepository();
    }
    
    public function testCanSaveAndFindEnrollment(): void
    {
        // Arrange
        $userId = UserId::generate();
        $programId = ProgramId::generate();
        $enrollment = ProgramEnrollment::create($userId, $programId);
        
        // Act
        $this->repository->save($enrollment);
        $found = $this->repository->findByUserAndProgram($userId, $programId);
        
        // Assert
        $this->assertNotNull($found);
        $this->assertTrue($userId->equals($found->getUserId()));
        $this->assertTrue($programId->equals($found->getProgramId()));
    }
    
    public function testReturnsNullWhenEnrollmentNotFound(): void
    {
        // Arrange
        $userId = UserId::generate();
        $programId = ProgramId::generate();
        
        // Act
        $found = $this->repository->findByUserAndProgram($userId, $programId);
        
        // Assert
        $this->assertNull($found);
    }
    
    public function testCanFindByUser(): void
    {
        // Arrange
        $userId = UserId::generate();
        $enrollment1 = ProgramEnrollment::create($userId, ProgramId::generate());
        $enrollment2 = ProgramEnrollment::create($userId, ProgramId::generate());
        $enrollment3 = ProgramEnrollment::create(UserId::generate(), ProgramId::generate());
        
        $this->repository->save($enrollment1);
        $this->repository->save($enrollment2);
        $this->repository->save($enrollment3);
        
        // Act
        $userEnrollments = $this->repository->findByUser($userId);
        
        // Assert
        $this->assertCount(2, $userEnrollments);
    }
    
    public function testCanFindByProgram(): void
    {
        // Arrange
        $programId = ProgramId::generate();
        $enrollment1 = ProgramEnrollment::create(UserId::generate(), $programId);
        $enrollment2 = ProgramEnrollment::create(UserId::generate(), $programId);
        $enrollment3 = ProgramEnrollment::create(UserId::generate(), ProgramId::generate());
        
        $this->repository->save($enrollment1);
        $this->repository->save($enrollment2);
        $this->repository->save($enrollment3);
        
        // Act
        $programEnrollments = $this->repository->findByProgram($programId);
        
        // Assert
        $this->assertCount(2, $programEnrollments);
    }
    
    public function testCanCountEnrollmentsByProgram(): void
    {
        // Arrange
        $programId = ProgramId::generate();
        $enrollment1 = ProgramEnrollment::create(UserId::generate(), $programId);
        $enrollment2 = ProgramEnrollment::create(UserId::generate(), $programId);
        $enrollment3 = ProgramEnrollment::create(UserId::generate(), $programId);
        
        $this->repository->save($enrollment1);
        $this->repository->save($enrollment2);
        $this->repository->save($enrollment3);
        
        // Act
        $count = $this->repository->countByProgram($programId);
        
        // Assert
        $this->assertEquals(3, $count);
    }
    
    public function testCanFindActiveEnrollments(): void
    {
        // Arrange
        $enrollment1 = ProgramEnrollment::create(UserId::generate(), ProgramId::generate());
        $enrollment2 = ProgramEnrollment::create(UserId::generate(), ProgramId::generate());
        $enrollment3 = ProgramEnrollment::create(UserId::generate(), ProgramId::generate());
        
        $enrollment2->start();
        $enrollment3->start();
        $enrollment3->complete();
        
        $this->repository->save($enrollment1);
        $this->repository->save($enrollment2);
        $this->repository->save($enrollment3);
        
        // Act
        $active = $this->repository->findActive();
        
        // Assert
        $this->assertCount(2, $active); // enrolled and in_progress
    }
    
    public function testUpdatesExistingEnrollment(): void
    {
        // Arrange
        $userId = UserId::generate();
        $programId = ProgramId::generate();
        $enrollment = ProgramEnrollment::create($userId, $programId);
        $this->repository->save($enrollment);
        
        // Act
        $enrollment->start();
        $enrollment->updateProgress(50);
        $this->repository->save($enrollment);
        
        $found = $this->repository->findByUserAndProgram($userId, $programId);
        
        // Assert
        $this->assertEquals('in_progress', $found->getStatus());
        $this->assertEquals(50, $found->getProgress());
    }
} 