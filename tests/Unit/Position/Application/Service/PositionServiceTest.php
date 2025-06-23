<?php

declare(strict_types=1);

namespace Tests\Unit\Position\Application\Service;

use App\Position\Application\Service\PositionService;
use App\Position\Application\DTO\PositionDTO;
use App\Position\Application\DTO\CreatePositionDTO;
use App\Position\Application\DTO\UpdatePositionDTO;
use App\Position\Domain\Repository\PositionRepositoryInterface;
use App\Position\Domain\Repository\PositionProfileRepositoryInterface;
use App\Position\Domain\Position;
use App\Position\Domain\ValueObjects\PositionId;
use App\Position\Domain\ValueObjects\PositionCode;
use App\Position\Domain\ValueObjects\PositionLevel;
use App\Position\Domain\ValueObjects\Department;
use PHPUnit\Framework\TestCase;
use PHPUnit\Framework\MockObject\MockObject;

class PositionServiceTest extends TestCase
{
    private PositionService $service;
    private MockObject $positionRepository;
    private MockObject $profileRepository;
    
    protected function setUp(): void
    {
        $this->positionRepository = $this->createMock(PositionRepositoryInterface::class);
        $this->profileRepository = $this->createMock(PositionProfileRepositoryInterface::class);
        
        $this->service = new PositionService(
            $this->positionRepository,
            $this->profileRepository
        );
    }
    
    public function testCreatePosition(): void
    {
        $createDTO = new CreatePositionDTO(
            code: 'DEV-001',
            title: 'Senior Developer',
            department: 'IT',
            level: 3,
            description: 'Senior software developer'
        );
        
        $this->positionRepository
            ->expects($this->once())
            ->method('findByCode')
            ->willReturn(null);
            
        $this->positionRepository
            ->expects($this->once())
            ->method('save');
            
        $result = $this->service->createPosition($createDTO);
        
        $this->assertInstanceOf(PositionDTO::class, $result);
        $this->assertEquals('DEV-001', $result->code);
        $this->assertEquals('Senior Developer', $result->title);
        $this->assertEquals('IT', $result->department);
        $this->assertEquals(3, $result->level);
    }
    
    public function testCannotCreateDuplicatePosition(): void
    {
        $createDTO = new CreatePositionDTO(
            code: 'DEV-001',
            title: 'Developer',
            department: 'IT',
            level: 2,
            description: 'Developer'
        );
        
        $existingPosition = Position::create(
            id: PositionId::generate(),
            code: PositionCode::fromString('DEV-001'),
            title: 'Existing Developer',
            department: Department::fromString('IT'),
            level: PositionLevel::fromValue(2),
            description: 'Existing'
        );
        
        $this->positionRepository
            ->expects($this->once())
            ->method('findByCode')
            ->willReturn($existingPosition);
            
        $this->expectException(\DomainException::class);
        $this->expectExceptionMessage('Position with code DEV-001 already exists');
        
        $this->service->createPosition($createDTO);
    }
    
    public function testUpdatePosition(): void
    {
        $positionId = PositionId::generate();
        $position = Position::create(
            id: $positionId,
            code: PositionCode::fromString('DEV-001'),
            title: 'Developer',
            department: Department::fromString('IT'),
            level: PositionLevel::fromValue(2),
            description: 'Developer'
        );
        
        $updateDTO = new UpdatePositionDTO(
            title: 'Senior Developer',
            description: 'Senior developer position',
            level: 3
        );
        
        $this->positionRepository
            ->expects($this->once())
            ->method('findById')
            ->with($positionId)
            ->willReturn($position);
            
        $this->positionRepository
            ->expects($this->once())
            ->method('save');
            
        $result = $this->service->updatePosition($positionId->getValue(), $updateDTO);
        
        $this->assertEquals('Senior Developer', $result->title);
        $this->assertEquals('Senior developer position', $result->description);
        $this->assertEquals(3, $result->level);
    }
    
    public function testGetPositionById(): void
    {
        $positionId = PositionId::generate();
        $position = Position::create(
            id: $positionId,
            code: PositionCode::fromString('DEV-001'),
            title: 'Developer',
            department: Department::fromString('IT'),
            level: PositionLevel::fromValue(2),
            description: 'Developer position'
        );
        
        $this->positionRepository
            ->expects($this->once())
            ->method('findById')
            ->with($positionId)
            ->willReturn($position);
            
        $result = $this->service->getById($positionId->getValue());
        
        $this->assertInstanceOf(PositionDTO::class, $result);
        $this->assertEquals('DEV-001', $result->code);
        $this->assertEquals('Developer', $result->title);
    }
    
    public function testGetPositionByIdNotFound(): void
    {
        $positionId = PositionId::generate();
        
        $this->positionRepository
            ->expects($this->once())
            ->method('findById')
            ->willReturn(null);
            
        $this->expectException(\App\Common\Exceptions\NotFoundException::class);
        
        $this->service->getById($positionId->getValue());
    }
    
    public function testArchivePosition(): void
    {
        $positionId = PositionId::generate();
        $position = Position::create(
            id: $positionId,
            code: PositionCode::fromString('DEV-001'),
            title: 'Developer',
            department: Department::fromString('IT'),
            level: PositionLevel::fromValue(2),
            description: 'Developer'
        );
        
        $this->positionRepository
            ->expects($this->once())
            ->method('findById')
            ->willReturn($position);
            
        $this->positionRepository
            ->expects($this->once())
            ->method('save');
            
        $this->service->archivePosition($positionId->getValue());
        
        $this->assertFalse($position->isActive());
    }
} 