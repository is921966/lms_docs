<?php

namespace CompetencyService\Tests\Unit\Domain;

use PHPUnit\Framework\TestCase;
use CompetencyService\Domain\Entities\Assessment;
use CompetencyService\Domain\ValueObjects\AssessmentId;
use CompetencyService\Domain\ValueObjects\CompetencyId;
use CompetencyService\Domain\ValueObjects\UserId;
use CompetencyService\Domain\ValueObjects\AssessmentScore;
use CompetencyService\Domain\Events\AssessmentCreated;
use CompetencyService\Domain\Events\AssessmentCompleted;

class AssessmentTest extends TestCase
{
    public function testCreateAssessment(): void
    {
        // Arrange
        $id = AssessmentId::generate();
        $competencyId = CompetencyId::generate();
        $userId = new UserId('user-123');
        $assessorId = new UserId('assessor-456');
        
        // Act
        $assessment = new Assessment($id, $competencyId, $userId, $assessorId);
        
        // Assert
        $this->assertEquals($id, $assessment->getId());
        $this->assertEquals($competencyId, $assessment->getCompetencyId());
        $this->assertEquals($userId, $assessment->getUserId());
        $this->assertEquals($assessorId, $assessment->getAssessorId());
        $this->assertEquals('pending', $assessment->getStatus());
        $this->assertNull($assessment->getScore());
        
        // Check domain event
        $events = $assessment->pullDomainEvents();
        $this->assertCount(1, $events);
        $this->assertInstanceOf(AssessmentCreated::class, $events[0]);
    }
    
    public function testCompleteAssessment(): void
    {
        // Arrange
        $assessment = $this->createAssessment();
        $score = new AssessmentScore(3, 'Good performance', 'Continue current approach');
        
        // Act
        $assessment->complete($score);
        
        // Assert
        $this->assertEquals('completed', $assessment->getStatus());
        $this->assertEquals($score, $assessment->getScore());
        $this->assertNotNull($assessment->getCompletedAt());
        
        // Check domain event
        $events = $assessment->pullDomainEvents();
        $this->assertCount(1, $events);
        $this->assertInstanceOf(AssessmentCompleted::class, $events[0]);
    }
    
    public function testCancelAssessment(): void
    {
        // Arrange
        $assessment = $this->createAssessment();
        $reason = 'Employee left the company';
        
        // Act
        $assessment->cancel($reason);
        
        // Assert
        $this->assertEquals('cancelled', $assessment->getStatus());
        $this->assertEquals($reason, $assessment->getCancellationReason());
    }
    
    public function testCannotCompleteCompletedAssessment(): void
    {
        // Arrange
        $assessment = $this->createAssessment();
        $score = new AssessmentScore(3, 'Good', 'Keep going');
        $assessment->complete($score);
        
        // Assert
        $this->expectException(\DomainException::class);
        
        // Act
        $assessment->complete($score);
    }
    
    private function createAssessment(): Assessment
    {
        return new Assessment(
            AssessmentId::generate(),
            CompetencyId::generate(),
            new UserId('user-123'),
            new UserId('assessor-456')
        );
    }
} 