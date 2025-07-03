<?php

declare(strict_types=1);

namespace Tests\Unit\Competency\Domain;

use Competency\Domain\ValueObjects\AssessmentId;
use Competency\Domain\CompetencyAssessment;
use Competency\Domain\ValueObjects\AssessmentScore;
use Competency\Domain\ValueObjects\CompetencyId;
use Competency\Domain\ValueObjects\CompetencyLevel;
use Competency\Domain\Events\AssessmentCreated;
use Competency\Domain\Events\AssessmentConfirmed;
use Competency\Domain\Events\AssessmentUpdated;
use User\Domain\ValueObjects\UserId;
use PHPUnit\Framework\TestCase;

class CompetencyAssessmentTest extends TestCase
{
    public function testCreateAssessment(): void
    {
        $assessmentId = 'ASSESS-001';
        $competencyId = CompetencyId::generate();
        $userId = UserId::generate();
        $assessorId = UserId::generate();
        $level = CompetencyLevel::intermediate();
        $score = AssessmentScore::fromPercentage(75);
        $comment = 'Good progress in PHP development';
        
        $assessment = CompetencyAssessment::create(
            id: $assessmentId,
            competencyId: $competencyId,
            userId: $userId,
            assessorId: $assessorId,
            level: $level,
            score: $score,
            comment: $comment
        );
        
        $this->assertEquals($assessmentId, $assessment->getId());
        $this->assertEquals($competencyId, $assessment->getCompetencyId());
        $this->assertEquals($userId, $assessment->getUserId());
        $this->assertEquals($assessorId, $assessment->getAssessorId());
        $this->assertEquals($level, $assessment->getLevel());
        $this->assertEquals($score, $assessment->getScore());
        $this->assertEquals($comment, $assessment->getComment());
        $this->assertInstanceOf(\DateTimeImmutable::class, $assessment->getAssessedAt());
        $this->assertNull($assessment->getConfirmedBy());
        $this->assertNull($assessment->getConfirmedAt());
        $this->assertFalse($assessment->isConfirmed());
        
        // Check domain event
        $events = $assessment->pullDomainEvents();
        $this->assertCount(1, $events);
        $this->assertInstanceOf(AssessmentCreated::class, $events[0]);
    }
    
    public function testCreateAssessmentWithoutComment(): void
    {
        $assessment = CompetencyAssessment::create(
            id: 'ASSESS-002',
            competencyId: CompetencyId::generate(),
            userId: UserId::generate(),
            assessorId: UserId::generate(),
            level: CompetencyLevel::beginner(),
            score: AssessmentScore::fromPercentage(50)
        );
        
        $this->assertNull($assessment->getComment());
    }
    
    public function testCreateSelfAssessment(): void
    {
        $userId = UserId::generate();
        
        $assessment = CompetencyAssessment::create(
            id: 'ASSESS-003',
            competencyId: CompetencyId::generate(),
            userId: $userId,
            assessorId: $userId,
            level: CompetencyLevel::advanced(),
            score: AssessmentScore::fromPercentage(85)
        );
        
        $this->assertTrue($assessment->isSelfAssessment());
    }
    
    public function testConfirmAssessment(): void
    {
        $assessment = $this->createSampleAssessment();
        $assessment->pullDomainEvents(); // Clear creation event
        
        $confirmerId = UserId::generate();
        $assessment->confirm($confirmerId);
        
        $this->assertTrue($assessment->isConfirmed());
        $this->assertEquals($confirmerId, $assessment->getConfirmedBy());
        $this->assertInstanceOf(\DateTimeImmutable::class, $assessment->getConfirmedAt());
        
        // Check domain event
        $events = $assessment->pullDomainEvents();
        $this->assertCount(1, $events);
        $this->assertInstanceOf(AssessmentConfirmed::class, $events[0]);
    }
    
    public function testCannotConfirmAlreadyConfirmedAssessment(): void
    {
        $assessment = $this->createSampleAssessment();
        $confirmerId = UserId::generate();
        $assessment->confirm($confirmerId);
        
        $this->expectException(\DomainException::class);
        $this->expectExceptionMessage('Assessment is already confirmed');
        
        $assessment->confirm(UserId::generate());
    }
    
    public function testUpdateAssessment(): void
    {
        $assessment = $this->createSampleAssessment();
        $assessment->pullDomainEvents(); // Clear creation event
        
        $newLevel = CompetencyLevel::advanced();
        $newScore = AssessmentScore::fromPercentage(90);
        $newComment = 'Excellent improvement';
        
        $assessment->update($newLevel, $newScore, $newComment);
        
        $this->assertEquals($newLevel, $assessment->getLevel());
        $this->assertEquals($newScore, $assessment->getScore());
        $this->assertEquals($newComment, $assessment->getComment());
        
        // Check domain event
        $events = $assessment->pullDomainEvents();
        $this->assertCount(1, $events);
        $this->assertInstanceOf(AssessmentUpdated::class, $events[0]);
    }
    
    public function testCannotUpdateConfirmedAssessment(): void
    {
        $assessment = $this->createSampleAssessment();
        $assessment->confirm(UserId::generate());
        
        $this->expectException(\DomainException::class);
        $this->expectExceptionMessage('Cannot update confirmed assessment');
        
        $assessment->update(
            CompetencyLevel::expert(),
            AssessmentScore::fromPercentage(95),
            'New comment'
        );
    }
    
    public function testGetAssessmentType(): void
    {
        // Self assessment
        $userId = UserId::generate();
        $selfAssessment = CompetencyAssessment::create(
            id: 'ASSESS-004',
            competencyId: CompetencyId::generate(),
            userId: $userId,
            assessorId: $userId,
            level: CompetencyLevel::intermediate(),
            score: AssessmentScore::fromPercentage(70)
        );
        
        $this->assertEquals('self', $selfAssessment->getAssessmentType());
        
        // Manager assessment
        $managerAssessment = CompetencyAssessment::create(
            id: 'ASSESS-005',
            competencyId: CompetencyId::generate(),
            userId: UserId::generate(),
            assessorId: UserId::generate(),
            level: CompetencyLevel::intermediate(),
            score: AssessmentScore::fromPercentage(70)
        );
        
        $this->assertEquals('manager', $managerAssessment->getAssessmentType());
    }
    
    public function testGetGapToTarget(): void
    {
        $assessment = CompetencyAssessment::create(
            id: 'ASSESS-006',
            competencyId: CompetencyId::generate(),
            userId: UserId::generate(),
            assessorId: UserId::generate(),
            level: CompetencyLevel::beginner(),
            score: AssessmentScore::fromPercentage(40)
        );
        
        $targetLevel = CompetencyLevel::advanced();
        $gap = $assessment->getGapToTarget($targetLevel);
        
        $this->assertEquals(3, $gap); // From Beginner (1) to Advanced (4)
    }
    
    public function testIsAboveLevel(): void
    {
        $assessment = CompetencyAssessment::create(
            id: 'ASSESS-007',
            competencyId: CompetencyId::generate(),
            userId: UserId::generate(),
            assessorId: UserId::generate(),
            level: CompetencyLevel::advanced(),
            score: AssessmentScore::fromPercentage(85)
        );
        
        $this->assertTrue($assessment->isAboveLevel(CompetencyLevel::beginner()));
        $this->assertTrue($assessment->isAboveLevel(CompetencyLevel::intermediate()));
        $this->assertFalse($assessment->isAboveLevel(CompetencyLevel::expert()));
        $this->assertFalse($assessment->isAboveLevel(CompetencyLevel::advanced()));
    }
    
    public function testGetDaysSinceAssessment(): void
    {
        $assessedAt = new \DateTimeImmutable('-30 days');
        
        $assessment = CompetencyAssessment::createWithDate(
            id: 'ASSESS-008',
            competencyId: CompetencyId::generate(),
            userId: UserId::generate(),
            assessorId: UserId::generate(),
            level: CompetencyLevel::intermediate(),
            score: AssessmentScore::fromPercentage(70),
            assessedAt: $assessedAt
        );
        
        $daysSince = $assessment->getDaysSinceAssessment();
        $this->assertGreaterThanOrEqual(29, $daysSince);
        $this->assertLessThanOrEqual(31, $daysSince);
    }
    
    private function createSampleAssessment(): CompetencyAssessment
    {
        return CompetencyAssessment::create(
            id: 'ASSESS-TEST',
            competencyId: CompetencyId::generate(),
            userId: UserId::generate(),
            assessorId: UserId::generate(),
            level: CompetencyLevel::intermediate(),
            score: AssessmentScore::fromPercentage(75),
            comment: 'Test assessment'
        );
    }
} 