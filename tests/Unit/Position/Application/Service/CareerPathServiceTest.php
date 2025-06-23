<?php

declare(strict_types=1);

namespace Tests\Unit\Position\Application\Service;

use App\Position\Application\Service\CareerPathService;
use App\Position\Application\DTO\CareerPathDTO;
use App\Position\Application\DTO\CreateCareerPathDTO;
use App\Position\Application\DTO\UpdateCareerPathDTO;
use App\Position\Application\DTO\CareerProgressDTO;
use App\Position\Domain\Repository\PositionRepositoryInterface;
use App\Position\Domain\Repository\CareerPathRepositoryInterface;
use App\Position\Domain\Service\CareerProgressionService;
use App\Position\Domain\Position;
use App\Position\Domain\CareerPath;
use App\Position\Domain\ValueObjects\PositionId;
use App\Position\Domain\ValueObjects\PositionCode;
use App\Position\Domain\ValueObjects\PositionLevel;
use App\Position\Domain\ValueObjects\Department;
use App\Common\Exceptions\NotFoundException;
use PHPUnit\Framework\TestCase;
use PHPUnit\Framework\MockObject\MockObject;

class CareerPathServiceTest extends TestCase
{
    private CareerPathService $service;
    private MockObject $positionRepository;
    private MockObject $careerPathRepository;
    private CareerProgressionService $progressionService;
    
    protected function setUp(): void
    {
        $this->positionRepository = $this->createMock(PositionRepositoryInterface::class);
        $this->careerPathRepository = $this->createMock(CareerPathRepositoryInterface::class);
        $this->progressionService = new CareerProgressionService();
        
        $this->service = new CareerPathService(
            $this->positionRepository,
            $this->careerPathRepository,
            $this->progressionService
        );
    }
    
    public function testCreateCareerPath(): void
    {
        $fromId = PositionId::generate();
        $toId = PositionId::generate();
        
        $fromPosition = $this->createPosition($fromId, 'Junior', 1);
        $toPosition = $this->createPosition($toId, 'Middle', 2);
        
        $createDTO = new CreateCareerPathDTO(
            fromPositionId: $fromId->getValue(),
            toPositionId: $toId->getValue(),
            requirements: ['2 years experience', 'Complete training'],
            estimatedDuration: 24
        );
        
        $this->positionRepository
            ->expects($this->exactly(2))
            ->method('findById')
            ->willReturnCallback(function ($id) use ($fromId, $toId, $fromPosition, $toPosition) {
                if ($id->equals($fromId)) {
                    return $fromPosition;
                } elseif ($id->equals($toId)) {
                    return $toPosition;
                }
                return null;
            });
            
        $this->careerPathRepository
            ->expects($this->once())
            ->method('findPath')
            ->willReturn(null);
            
        $this->careerPathRepository
            ->expects($this->once())
            ->method('save');
            
        $result = $this->service->createCareerPath($createDTO);
        
        $this->assertInstanceOf(CareerPathDTO::class, $result);
        $this->assertEquals($fromId->getValue(), $result->fromPositionId);
        $this->assertEquals($toId->getValue(), $result->toPositionId);
        $this->assertCount(2, $result->requirements);
        $this->assertEquals(24, $result->estimatedDuration);
    }
    
    public function testCannotCreateDuplicateCareerPath(): void
    {
        $fromId = PositionId::generate();
        $toId = PositionId::generate();
        
        $existingPath = CareerPath::create(
            fromPositionId: $fromId,
            toPositionId: $toId,
            requirements: [],
            estimatedDuration: 12
        );
        
        $createDTO = new CreateCareerPathDTO(
            fromPositionId: $fromId->getValue(),
            toPositionId: $toId->getValue(),
            requirements: [],
            estimatedDuration: 12
        );
        
        $this->positionRepository
            ->expects($this->any())
            ->method('findById')
            ->willReturn($this->createPosition(PositionId::generate(), 'Test', 1));
            
        $this->careerPathRepository
            ->expects($this->once())
            ->method('findPath')
            ->willReturn($existingPath);
            
        $this->expectException(\DomainException::class);
        $this->expectExceptionMessage('Career path already exists');
        
        $this->service->createCareerPath($createDTO);
    }
    
    public function testAddMilestone(): void
    {
        $pathId = 'path-123';
        $careerPath = CareerPath::create(
            fromPositionId: PositionId::generate(),
            toPositionId: PositionId::generate(),
            requirements: [],
            estimatedDuration: 24
        );
        
        $this->careerPathRepository
            ->expects($this->once())
            ->method('findById')
            ->with($pathId)
            ->willReturn($careerPath);
            
        $this->careerPathRepository
            ->expects($this->once())
            ->method('save');
            
        $this->service->addMilestone(
            $pathId,
            'Complete training',
            'Finish all required courses',
            6
        );
        
        $this->assertCount(1, $careerPath->getMilestones());
    }
    
    public function testGetCareerProgress(): void
    {
        $fromId = PositionId::generate();
        $toId = PositionId::generate();
        $employeeId = 'emp-123';
        
        $careerPath = CareerPath::create(
            fromPositionId: $fromId,
            toPositionId: $toId,
            requirements: ['Requirement 1', 'Requirement 2'],
            estimatedDuration: 24
        );
        
        $careerPath->addMilestone('Milestone 1', 'First milestone', 6);
        $careerPath->addMilestone('Milestone 2', 'Second milestone', 12);
        
        $this->careerPathRepository
            ->expects($this->once())
            ->method('findPath')
            ->willReturn($careerPath);
            
        $result = $this->service->getCareerProgress(
            $fromId->getValue(),
            $toId->getValue(),
            $employeeId,
            12 // months completed
        );
        
        $this->assertInstanceOf(CareerProgressDTO::class, $result);
        $this->assertEquals(50, $result->progressPercentage);
        $this->assertEquals(12, $result->remainingMonths);
        $this->assertCount(2, $result->completedMilestones);
        $this->assertNull($result->nextMilestone);
        $this->assertFalse($result->isEligibleForPromotion);
    }
    
    public function testGetActiveCareerPaths(): void
    {
        $path1 = CareerPath::create(
            fromPositionId: PositionId::generate(),
            toPositionId: PositionId::generate(),
            requirements: [],
            estimatedDuration: 12
        );
        
        $path2 = CareerPath::create(
            fromPositionId: PositionId::generate(),
            toPositionId: PositionId::generate(),
            requirements: [],
            estimatedDuration: 24
        );
        
        $this->careerPathRepository
            ->expects($this->once())
            ->method('findActive')
            ->willReturn([$path1, $path2]);
            
        $result = $this->service->getActiveCareerPaths();
        
        $this->assertCount(2, $result);
        $this->assertContainsOnlyInstancesOf(CareerPathDTO::class, $result);
    }
    
    public function testDeactivateCareerPath(): void
    {
        $pathId = 'path-123';
        $careerPath = CareerPath::create(
            fromPositionId: PositionId::generate(),
            toPositionId: PositionId::generate(),
            requirements: [],
            estimatedDuration: 24
        );
        
        $this->careerPathRepository
            ->expects($this->once())
            ->method('findById')
            ->willReturn($careerPath);
            
        $this->careerPathRepository
            ->expects($this->once())
            ->method('save');
            
        $this->service->deactivateCareerPath($pathId);
        
        $this->assertFalse($careerPath->isActive());
    }
    
    private function createPosition(PositionId $id, string $title, int $level): Position
    {
        return Position::create(
            id: $id,
            code: PositionCode::fromString('POS-' . str_pad((string)$level, 3, '0', STR_PAD_LEFT)),
            title: $title,
            department: Department::fromString('IT'),
            level: PositionLevel::fromValue($level),
            description: $title . ' position'
        );
    }
} 