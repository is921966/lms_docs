<?php

namespace CompetencyService\Tests\Unit\Application;

use PHPUnit\Framework\TestCase;
use CompetencyService\Application\Services\AssessmentService;
use CompetencyService\Application\DTOs\CreateAssessmentDTO;
use CompetencyService\Application\DTOs\CompleteAssessmentDTO;
use CompetencyService\Application\DTOs\AssessmentDTO;
use CompetencyService\Domain\Repositories\AssessmentRepositoryInterface;
use CompetencyService\Domain\Repositories\CompetencyRepositoryInterface;
use CompetencyService\Domain\Entities\Assessment;
use CompetencyService\Domain\Entities\Competency;
use CompetencyService\Domain\ValueObjects\AssessmentId;
use CompetencyService\Domain\ValueObjects\CompetencyId;
use CompetencyService\Domain\ValueObjects\CompetencyCode;
use CompetencyService\Domain\ValueObjects\UserId;

class AssessmentServiceTest extends TestCase
{
    private AssessmentRepositoryInterface $assessmentRepository;
    private CompetencyRepositoryInterface $competencyRepository;
    private AssessmentService $service;
    
    protected function setUp(): void
    {
        $this->assessmentRepository = $this->createMock(AssessmentRepositoryInterface::class);
        $this->competencyRepository = $this->createMock(CompetencyRepositoryInterface::class);
        $this->service = new AssessmentService(
            $this->assessmentRepository,
            $this->competencyRepository
        );
    }
    
    public function testCreateAssessment(): void
    {
        // Arrange
        $competencyId = CompetencyId::generate();
        $competency = new Competency(
            $competencyId,
            new CompetencyCode('TECH-001'),
            'Software Development',
            'Description',
            'Technical'
        );
        
        $dto = new CreateAssessmentDTO(
            competencyId: $competencyId->toString(),
            userId: 'user-123',
            assessorId: 'assessor-456'
        );
        
        $this->competencyRepository->expects($this->once())
            ->method('findById')
            ->willReturn($competency);
            
        $this->assessmentRepository->expects($this->once())
            ->method('save');
        
        // Act
        $result = $this->service->createAssessment($dto);
        
        // Assert
        $this->assertInstanceOf(AssessmentDTO::class, $result);
        $this->assertEquals($competencyId->toString(), $result->competencyId);
        $this->assertEquals('user-123', $result->userId);
        $this->assertEquals('assessor-456', $result->assessorId);
        $this->assertEquals('pending', $result->status);
    }
    
    public function testCompleteAssessment(): void
    {
        // Arrange
        $assessmentId = AssessmentId::generate();
        $assessment = new Assessment(
            $assessmentId,
            CompetencyId::generate(),
            new UserId('user-123'),
            new UserId('assessor-456')
        );
        
        $dto = new CompleteAssessmentDTO(
            assessmentId: $assessmentId->toString(),
            level: 3,
            feedback: 'Good performance',
            recommendations: 'Keep improving'
        );
        
        $this->assessmentRepository->expects($this->once())
            ->method('findById')
            ->willReturn($assessment);
            
        $this->assessmentRepository->expects($this->once())
            ->method('save');
        
        // Act
        $result = $this->service->completeAssessment($dto);
        
        // Assert
        $this->assertEquals('completed', $result->status);
        $this->assertNotNull($result->score);
        $this->assertEquals(3, $result->score['level']);
    }
    
    public function testGetUserAssessments(): void
    {
        // Arrange
        $userId = new UserId('user-123');
        $assessments = [
            new Assessment(
                AssessmentId::generate(),
                CompetencyId::generate(),
                $userId,
                new UserId('assessor-456')
            ),
            new Assessment(
                AssessmentId::generate(),
                CompetencyId::generate(),
                $userId,
                new UserId('assessor-789')
            )
        ];
        
        $this->assessmentRepository->expects($this->once())
            ->method('findByUser')
            ->with($userId)
            ->willReturn($assessments);
        
        // Act
        $result = $this->service->getUserAssessments('user-123');
        
        // Assert
        $this->assertCount(2, $result);
        $this->assertInstanceOf(AssessmentDTO::class, $result[0]);
        $this->assertInstanceOf(AssessmentDTO::class, $result[1]);
    }
} 