<?php

declare(strict_types=1);

namespace Tests\Unit\Program\Application\UseCases;

use Program\Application\UseCases\UpdateProgramUseCase;
use Program\Application\Requests\UpdateProgramRequest;
use Program\Application\DTO\ProgramDTO;
use Program\Domain\Repository\ProgramRepositoryInterface;
use Program\Domain\Program;
use Program\Domain\ValueObjects\ProgramId;
use Program\Domain\ValueObjects\ProgramCode;
use Program\Domain\ValueObjects\ProgramStatus;
use PHPUnit\Framework\TestCase;
use PHPUnit\Framework\MockObject\MockObject;

class UpdateProgramUseCaseTest extends TestCase
{
    private UpdateProgramUseCase $useCase;
    private ProgramRepositoryInterface&MockObject $programRepository;
    
    protected function setUp(): void
    {
        $this->programRepository = $this->createMock(ProgramRepositoryInterface::class);
        $this->useCase = new UpdateProgramUseCase($this->programRepository);
    }
    
    public function testCanUpdateDraftProgram(): void
    {
        // Arrange
        $programId = 'a1b2c3d4-e5f6-7890-abcd-ef1234567890';
        $request = new UpdateProgramRequest(
            programId: $programId,
            title: 'Updated Program Title',
            description: 'Updated program description with more details',
            metadata: ['category' => 'leadership']
        );
        
        $program = $this->createDraftProgram($programId);
        
        $this->programRepository->expects($this->once())
            ->method('findById')
            ->with($this->isInstanceOf(ProgramId::class))
            ->willReturn($program);
            
        $this->programRepository->expects($this->once())
            ->method('save')
            ->with($this->callback(function ($savedProgram) use ($request) {
                return $savedProgram->getTitle() === $request->title &&
                       $savedProgram->getDescription() === $request->description &&
                       $savedProgram->getMetadata() === $request->metadata;
            }));
        
        // Act
        $result = $this->useCase->execute($request);
        
        // Assert
        $this->assertInstanceOf(ProgramDTO::class, $result);
        $this->assertEquals($request->title, $result->title);
        $this->assertEquals($request->description, $result->description);
    }
    
    public function testThrowsExceptionForInvalidRequest(): void
    {
        // Arrange
        $request = new UpdateProgramRequest(
            programId: 'invalid-id',
            title: 'OK',
            description: 'Short'
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
        $request = new UpdateProgramRequest(
            programId: 'a1b2c3d4-e5f6-7890-abcd-ef1234567890',
            title: 'Valid Title',
            description: 'Valid description with enough characters'
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
    
    public function testThrowsExceptionWhenProgramNotDraft(): void
    {
        // Arrange
        $programId = 'a1b2c3d4-e5f6-7890-abcd-ef1234567890';
        $request = new UpdateProgramRequest(
            programId: $programId,
            title: 'Updated Title',
            description: 'Updated description with enough characters'
        );
        
        $program = $this->createActiveProgram($programId);
        
        $this->programRepository->expects($this->once())
            ->method('findById')
            ->willReturn($program);
        
        // Assert
        $this->expectException(\DomainException::class);
        $this->expectExceptionMessage('Only draft programs can be updated');
        
        // Act
        $this->useCase->execute($request);
    }
    
    public function testUpdatesMetadataWhenProvided(): void
    {
        // Arrange
        $programId = 'a1b2c3d4-e5f6-7890-abcd-ef1234567890';
        $metadata = [
            'category' => 'technical',
            'level' => 'advanced',
            'duration' => '6 months'
        ];
        
        $request = new UpdateProgramRequest(
            programId: $programId,
            title: 'Technical Leadership Program',
            description: 'Advanced technical leadership development program',
            metadata: $metadata
        );
        
        $program = $this->createDraftProgram($programId);
        
        $this->programRepository->expects($this->once())
            ->method('findById')
            ->willReturn($program);
            
        $this->programRepository->expects($this->once())
            ->method('save')
            ->with($this->callback(function ($savedProgram) use ($metadata) {
                return $savedProgram->getMetadata() === $metadata;
            }));
        
        // Act
        $result = $this->useCase->execute($request);
        
        // Assert
        $this->assertEquals($metadata, $result->metadata);
    }
    
    private function createDraftProgram(string $id): Program
    {
        return Program::create(
            ProgramId::fromString($id),
            ProgramCode::fromString('TEST-001'),
            'Original Title',
            'Original Description'
        );
    }
    
    private function createActiveProgram(string $id): Program
    {
        $program = $this->createDraftProgram($id);
        $program->forceStatus(ProgramStatus::active());
        return $program;
    }
} 