<?php

declare(strict_types=1);

namespace Tests\Unit\Program\Application\UseCases;

use Program\Application\UseCases\PublishProgramUseCase;
use Program\Domain\Repository\ProgramRepositoryInterface;
use Program\Domain\Repository\TrackRepositoryInterface;
use Program\Domain\Program;
use Program\Domain\Track;
use Program\Domain\ValueObjects\ProgramId;
use Program\Domain\ValueObjects\ProgramCode;
use Program\Domain\ValueObjects\ProgramStatus;
use Program\Domain\ValueObjects\TrackId;
use Program\Domain\ValueObjects\TrackOrder;
use PHPUnit\Framework\TestCase;
use PHPUnit\Framework\MockObject\MockObject;

class PublishProgramUseCaseTest extends TestCase
{
    private PublishProgramUseCase $useCase;
    private ProgramRepositoryInterface&MockObject $programRepository;
    private TrackRepositoryInterface&MockObject $trackRepository;
    
    protected function setUp(): void
    {
        $this->programRepository = $this->createMock(ProgramRepositoryInterface::class);
        $this->trackRepository = $this->createMock(TrackRepositoryInterface::class);
        $this->useCase = new PublishProgramUseCase(
            $this->programRepository,
            $this->trackRepository
        );
    }
    
    public function testCanPublishProgramWithTracks(): void
    {
        // Arrange
        $programId = ProgramId::generate();
        $program = $this->createDraftProgram($programId);
        $tracks = $this->createTracks($programId, 2);
        
        $this->programRepository->expects($this->once())
            ->method('findById')
            ->with($programId)
            ->willReturn($program);
            
        $this->trackRepository->expects($this->once())
            ->method('findByProgramId')
            ->with($programId)
            ->willReturn($tracks);
            
        $this->programRepository->expects($this->once())
            ->method('save')
            ->with($this->callback(function ($savedProgram) {
                return $savedProgram->getStatus()->isActive();
            }));
        
        // Act
        $result = $this->useCase->execute($programId->getValue());
        
        // Assert
        $this->assertTrue($result);
    }
    
    public function testThrowsExceptionWhenProgramNotFound(): void
    {
        // Arrange
        $programId = ProgramId::generate();
        
        $this->programRepository->expects($this->once())
            ->method('findById')
            ->willReturn(null);
        
        // Assert
        $this->expectException(\DomainException::class);
        $this->expectExceptionMessage('Program not found');
        
        // Act
        $this->useCase->execute($programId->getValue());
    }
    
    public function testThrowsExceptionWhenProgramAlreadyPublished(): void
    {
        // Arrange
        $programId = ProgramId::generate();
        $program = $this->createActiveProgram($programId);
        
        $this->programRepository->expects($this->once())
            ->method('findById')
            ->willReturn($program);
        
        // Assert
        $this->expectException(\DomainException::class);
        $this->expectExceptionMessage('Program is already published');
        
        // Act
        $this->useCase->execute($programId->getValue());
    }
    
    public function testThrowsExceptionWhenNoTracks(): void
    {
        // Arrange
        $programId = ProgramId::generate();
        $program = $this->createDraftProgram($programId);
        
        $this->programRepository->expects($this->once())
            ->method('findById')
            ->willReturn($program);
            
        $this->trackRepository->expects($this->once())
            ->method('findByProgramId')
            ->willReturn([]);
        
        // Assert
        $this->expectException(\DomainException::class);
        $this->expectExceptionMessage('Cannot publish program without tracks');
        
        // Act
        $this->useCase->execute($programId->getValue());
    }
    
    public function testRaisesEventWhenPublished(): void
    {
        // Arrange
        $programId = ProgramId::generate();
        $program = $this->createDraftProgram($programId);
        $tracks = $this->createTracks($programId, 1);
        
        $this->programRepository->expects($this->once())
            ->method('findById')
            ->willReturn($program);
            
        $this->trackRepository->expects($this->once())
            ->method('findByProgramId')
            ->willReturn($tracks);
            
        $savedProgram = null;
        $this->programRepository->expects($this->once())
            ->method('save')
            ->willReturnCallback(function ($program) use (&$savedProgram) {
                $savedProgram = $program;
            });
        
        // Act
        $this->useCase->execute($programId->getValue());
        
        // Assert
        $this->assertNotNull($savedProgram);
        $events = $savedProgram->pullDomainEvents();
        $this->assertCount(2, $events); // ProgramCreated and ProgramPublished
        $this->assertEquals('program.published', $events[1]->getEventName());
    }
    
    private function createDraftProgram(ProgramId $id): Program
    {
        return Program::create(
            $id,
            ProgramCode::fromString('TEST-001'),
            'Test Program',
            'Test Description'
        );
    }
    
    private function createActiveProgram(ProgramId $id): Program
    {
        $program = $this->createDraftProgram($id);
        $program->forceStatus(ProgramStatus::active());
        return $program;
    }
    
    /**
     * @return Track[]
     */
    private function createTracks(ProgramId $programId, int $count): array
    {
        $tracks = [];
        for ($i = 0; $i < $count; $i++) {
            $tracks[] = Track::create(
                TrackId::generate(),
                $programId,
                "Track $i",
                "Description $i",
                TrackOrder::fromInt($i + 1)
            );
        }
        return $tracks;
    }
} 