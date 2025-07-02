<?php

declare(strict_types=1);

namespace Tests\Unit\Program\Application\UseCases;

use Program\Application\UseCases\CreateProgramUseCase;
use Program\Application\Requests\CreateProgramRequest;
use Program\Application\DTO\ProgramDTO;
use Program\Domain\Repository\ProgramRepositoryInterface;
use Program\Domain\ValueObjects\ProgramId;
use Program\Domain\ValueObjects\ProgramCode;
use PHPUnit\Framework\TestCase;
use PHPUnit\Framework\MockObject\MockObject;

class CreateProgramUseCaseTest extends TestCase
{
    private CreateProgramUseCase $useCase;
    private ProgramRepositoryInterface&MockObject $repository;
    
    protected function setUp(): void
    {
        $this->repository = $this->createMock(ProgramRepositoryInterface::class);
        $this->useCase = new CreateProgramUseCase($this->repository);
    }
    
    public function testCanCreateProgram(): void
    {
        // Arrange
        $request = new CreateProgramRequest(
            code: 'LEAD-101',
            title: 'Leadership Development',
            description: 'A comprehensive leadership program',
            completionPercentage: 80,
            requireAllCourses: false
        );
        
        $programId = ProgramId::generate();
        
        $this->repository->expects($this->once())
            ->method('nextIdentity')
            ->willReturn($programId);
            
        $this->repository->expects($this->once())
            ->method('findByCode')
            ->with($this->isInstanceOf(ProgramCode::class))
            ->willReturn(null);
            
        $this->repository->expects($this->once())
            ->method('save')
            ->with($this->callback(function ($program) use ($request) {
                return $program->getCode()->getValue() === $request->code &&
                       $program->getTitle() === $request->title &&
                       $program->getDescription() === $request->description;
            }));
        
        // Act
        $result = $this->useCase->execute($request);
        
        // Assert
        $this->assertInstanceOf(ProgramDTO::class, $result);
        $this->assertEquals($request->code, $result->code);
        $this->assertEquals($request->title, $result->title);
        $this->assertEquals($request->description, $result->description);
        $this->assertEquals('draft', $result->status);
        $this->assertEquals(80, $result->completionCriteria['percentage']);
        $this->assertFalse($result->completionCriteria['requireAll']);
    }
    
    public function testThrowsExceptionForInvalidRequest(): void
    {
        // Arrange
        $request = new CreateProgramRequest(
            code: 'invalid-code',
            title: 'Test',
            description: 'Test'
        );
        
        // Assert
        $this->expectException(\InvalidArgumentException::class);
        $this->expectExceptionMessage('Invalid request');
        
        // Act
        $this->useCase->execute($request);
    }
    
    public function testThrowsExceptionForDuplicateCode(): void
    {
        // Arrange
        $request = new CreateProgramRequest(
            code: 'LEAD-101',
            title: 'Leadership Development',
            description: 'A comprehensive leadership program'
        );
        
        $existingProgram = $this->createMock(\Program\Domain\Program::class);
        
        $this->repository->expects($this->once())
            ->method('findByCode')
            ->with($this->isInstanceOf(ProgramCode::class))
            ->willReturn($existingProgram);
        
        // Assert
        $this->expectException(\DomainException::class);
        $this->expectExceptionMessage('Program with code LEAD-101 already exists');
        
        // Act
        $this->useCase->execute($request);
    }
} 