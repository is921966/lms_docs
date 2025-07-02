<?php

declare(strict_types=1);

namespace Tests\Unit\Program\Application\UseCases;

use Program\Application\UseCases\EnrollUserUseCase;
use Program\Application\Requests\EnrollUserRequest;
use Program\Application\DTO\ProgramEnrollmentDTO;
use Program\Domain\Repository\ProgramRepositoryInterface;
use Program\Domain\Repository\ProgramEnrollmentRepositoryInterface;
use Program\Domain\Program;
use Program\Domain\ValueObjects\ProgramId;
use Program\Domain\ValueObjects\ProgramCode;
use Program\Domain\ValueObjects\ProgramStatus;
use User\Domain\ValueObjects\UserId;
use PHPUnit\Framework\TestCase;
use PHPUnit\Framework\MockObject\MockObject;

class EnrollUserUseCaseTest extends TestCase
{
    private EnrollUserUseCase $useCase;
    private ProgramRepositoryInterface&MockObject $programRepository;
    private ProgramEnrollmentRepositoryInterface&MockObject $enrollmentRepository;
    
    protected function setUp(): void
    {
        $this->programRepository = $this->createMock(ProgramRepositoryInterface::class);
        $this->enrollmentRepository = $this->createMock(ProgramEnrollmentRepositoryInterface::class);
        $this->useCase = new EnrollUserUseCase(
            $this->programRepository,
            $this->enrollmentRepository
        );
    }
    
    public function testCanEnrollUserInProgram(): void
    {
        // Arrange
        $request = new EnrollUserRequest(
            userId: 'f47ac10b-58cc-4372-a567-0e02b2c3d479',
            programId: 'a1b2c3d4-e5f6-7890-abcd-ef1234567890'
        );
        
        $program = $this->createActiveProgram($request->programId);
        
        $this->programRepository->expects($this->once())
            ->method('findById')
            ->with($this->isInstanceOf(ProgramId::class))
            ->willReturn($program);
            
        $this->enrollmentRepository->expects($this->once())
            ->method('findByUserAndProgram')
            ->willReturn(null);
            
        $this->enrollmentRepository->expects($this->once())
            ->method('save')
            ->with($this->callback(function ($enrollment) use ($request) {
                return $enrollment->getUserId()->getValue() === $request->userId &&
                       $enrollment->getProgramId()->getValue() === $request->programId &&
                       $enrollment->getStatus() === 'enrolled';
            }));
        
        // Act
        $result = $this->useCase->execute($request);
        
        // Assert
        $this->assertInstanceOf(ProgramEnrollmentDTO::class, $result);
        $this->assertEquals($request->userId, $result->userId);
        $this->assertEquals($request->programId, $result->programId);
        $this->assertEquals('enrolled', $result->status);
        $this->assertEquals(0, $result->progress);
    }
    
    public function testThrowsExceptionForInvalidRequest(): void
    {
        // Arrange
        $request = new EnrollUserRequest(
            userId: 'invalid-id',
            programId: 'a1b2c3d4-e5f6-7890-abcd-ef1234567890'
        );
        
        // Assert
        $this->expectException(\InvalidArgumentException::class);
        $this->expectExceptionMessage('Invalid request');
        
        // Act
        $this->useCase->execute($request);
    }
    
    public function testThrowsExceptionWhenProgramNotFound(): void
    {
        // Arrange
        $request = new EnrollUserRequest(
            userId: 'f47ac10b-58cc-4372-a567-0e02b2c3d479',
            programId: 'a1b2c3d4-e5f6-7890-abcd-ef1234567890'
        );
        
        $this->programRepository->expects($this->once())
            ->method('findById')
            ->willReturn(null);
        
        // Assert
        $this->expectException(\DomainException::class);
        $this->expectExceptionMessage('Program not found');
        
        // Act
        $this->useCase->execute($request);
    }
    
    public function testThrowsExceptionWhenProgramNotActive(): void
    {
        // Arrange
        $request = new EnrollUserRequest(
            userId: 'f47ac10b-58cc-4372-a567-0e02b2c3d479',
            programId: 'a1b2c3d4-e5f6-7890-abcd-ef1234567890'
        );
        
        $program = $this->createDraftProgram($request->programId);
        
        $this->programRepository->expects($this->once())
            ->method('findById')
            ->willReturn($program);
        
        // Assert
        $this->expectException(\DomainException::class);
        $this->expectExceptionMessage('Cannot enroll in program that is not active');
        
        // Act
        $this->useCase->execute($request);
    }
    
    public function testThrowsExceptionWhenAlreadyEnrolled(): void
    {
        // Arrange
        $request = new EnrollUserRequest(
            userId: 'f47ac10b-58cc-4372-a567-0e02b2c3d479',
            programId: 'a1b2c3d4-e5f6-7890-abcd-ef1234567890'
        );
        
        $program = $this->createActiveProgram($request->programId);
        $existingEnrollment = $this->createMock(\Program\Domain\ProgramEnrollment::class);
        
        $this->programRepository->expects($this->once())
            ->method('findById')
            ->willReturn($program);
            
        $this->enrollmentRepository->expects($this->once())
            ->method('findByUserAndProgram')
            ->willReturn($existingEnrollment);
        
        // Assert
        $this->expectException(\DomainException::class);
        $this->expectExceptionMessage('User already enrolled in this program');
        
        // Act
        $this->useCase->execute($request);
    }
    
    private function createActiveProgram(string $id): Program
    {
        $program = Program::create(
            ProgramId::fromString($id),
            ProgramCode::fromString('TEST-001'),
            'Test Program',
            'Test Description'
        );
        $program->forceStatus(ProgramStatus::active());
        
        return $program;
    }
    
    private function createDraftProgram(string $id): Program
    {
        return Program::create(
            ProgramId::fromString($id),
            ProgramCode::fromString('TEST-001'),
            'Test Program',
            'Test Description'
        );
    }
} 