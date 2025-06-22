<?php

declare(strict_types=1);

namespace Tests\Unit\Competency\Domain\Service;

use App\Competency\Domain\CompetencyAssessment;
use App\Competency\Domain\Service\CompetencyAssessmentService;
use App\Competency\Domain\ValueObjects\AssessmentScore;
use App\Competency\Domain\ValueObjects\CompetencyId;
use App\Competency\Domain\ValueObjects\CompetencyLevel;
use App\User\Domain\ValueObjects\UserId;
use PHPUnit\Framework\TestCase;

class CompetencyAssessmentServiceTest extends TestCase
{
    private CompetencyAssessmentService $service;
    
    protected function setUp(): void
    {
        $this->service = new CompetencyAssessmentService();
    }
    
    public function testCreateAssessmentWithAutoId(): void
    {
        $competencyId = CompetencyId::generate();
        $userId = UserId::generate();
        $assessorId = UserId::generate();
        $level = CompetencyLevel::intermediate();
        $score = AssessmentScore::fromPercentage(75);
        $comment = 'Good progress';
        
        $assessment = $this->service->createAssessment(
            competencyId: $competencyId,
            userId: $userId,
            assessorId: $assessorId,
            level: $level,
            score: $score,
            comment: $comment
        );
        
        $this->assertNotEmpty($assessment->getId());
        $this->assertStringStartsWith('ASSESS-', $assessment->getId());
        $this->assertEquals($competencyId, $assessment->getCompetencyId());
        $this->assertEquals($userId, $assessment->getUserId());
        $this->assertEquals($assessorId, $assessment->getAssessorId());
        $this->assertEquals($level, $assessment->getLevel());
        $this->assertEquals($score, $assessment->getScore());
        $this->assertEquals($comment, $assessment->getComment());
    }
    
    public function testCalculateProgressBetweenLevels(): void
    {
        $fromLevel = CompetencyLevel::beginner();
        $toLevel = CompetencyLevel::advanced();
        
        $progress = $this->service->calculateProgress($fromLevel, $toLevel);
        
        // From Beginner (1) to Advanced (4) = 3 level gap
        $this->assertEquals(3, $progress['gap']);
        $this->assertEquals(0, $progress['percentage']);
        $this->assertEquals('Beginner', $progress['from']);
        $this->assertEquals('Advanced', $progress['to']);
    }
    
    public function testCalculateProgressWithCurrentLevel(): void
    {
        $startLevel = CompetencyLevel::beginner();
        $currentLevel = CompetencyLevel::intermediate();
        $targetLevel = CompetencyLevel::expert();
        
        $progress = $this->service->calculateProgressWithCurrent(
            $startLevel,
            $currentLevel,
            $targetLevel
        );
        
        // From Beginner (1) to Expert (5) = 4 levels total
        // Current at Intermediate (3) = 2 levels completed
        // Progress = 2/4 = 50%
        $this->assertEquals(4, $progress['total_gap']);
        $this->assertEquals(2, $progress['completed']);
        $this->assertEquals(2, $progress['remaining']);
        $this->assertEquals(50, $progress['percentage']);
    }
    
    public function testIsAssessmentValid(): void
    {
        $validAssessment = CompetencyAssessment::create(
            id: 'ASSESS-001',
            competencyId: CompetencyId::generate(),
            userId: UserId::generate(),
            assessorId: UserId::generate(),
            level: CompetencyLevel::intermediate(),
            score: AssessmentScore::fromPercentage(70)
        );
        
        $this->assertTrue($this->service->isAssessmentValid($validAssessment));
        
        // Test with very old assessment (more than 365 days)
        $oldAssessment = CompetencyAssessment::createWithDate(
            id: 'ASSESS-002',
            competencyId: CompetencyId::generate(),
            userId: UserId::generate(),
            assessorId: UserId::generate(),
            level: CompetencyLevel::intermediate(),
            score: AssessmentScore::fromPercentage(70),
            assessedAt: new \DateTimeImmutable('-400 days')
        );
        
        $this->assertFalse($this->service->isAssessmentValid($oldAssessment));
    }
    
    public function testCompareAssessments(): void
    {
        $assessment1 = CompetencyAssessment::create(
            id: 'ASSESS-001',
            competencyId: CompetencyId::generate(),
            userId: UserId::generate(),
            assessorId: UserId::generate(),
            level: CompetencyLevel::beginner(),
            score: AssessmentScore::fromPercentage(40)
        );
        
        $assessment2 = CompetencyAssessment::create(
            id: 'ASSESS-002',
            competencyId: $assessment1->getCompetencyId(),
            userId: $assessment1->getUserId(),
            assessorId: $assessment1->getAssessorId(),
            level: CompetencyLevel::intermediate(),
            score: AssessmentScore::fromPercentage(70)
        );
        
        $comparison = $this->service->compareAssessments($assessment1, $assessment2);
        
        $this->assertEquals(2, $comparison['level_change']); // From 1 to 3
        $this->assertEquals(30, $comparison['score_change']); // From 40% to 70%
        $this->assertEquals('improvement', $comparison['direction']);
        $this->assertTrue($comparison['is_progress']);
    }
    
    public function testCompareAssessmentsRegression(): void
    {
        $assessment1 = CompetencyAssessment::create(
            id: 'ASSESS-001',
            competencyId: CompetencyId::generate(),
            userId: UserId::generate(),
            assessorId: UserId::generate(),
            level: CompetencyLevel::advanced(),
            score: AssessmentScore::fromPercentage(85)
        );
        
        $assessment2 = CompetencyAssessment::create(
            id: 'ASSESS-002',
            competencyId: $assessment1->getCompetencyId(),
            userId: $assessment1->getUserId(),
            assessorId: $assessment1->getAssessorId(),
            level: CompetencyLevel::intermediate(),
            score: AssessmentScore::fromPercentage(65)
        );
        
        $comparison = $this->service->compareAssessments($assessment1, $assessment2);
        
        $this->assertEquals(-1, $comparison['level_change']); // From 4 to 3
        $this->assertEquals(-20, $comparison['score_change']); // From 85% to 65%
        $this->assertEquals('regression', $comparison['direction']);
        $this->assertFalse($comparison['is_progress']);
    }
    
    public function testGenerateAssessmentId(): void
    {
        $id1 = $this->service->generateAssessmentId();
        $id2 = $this->service->generateAssessmentId();
        
        $this->assertStringStartsWith('ASSESS-', $id1);
        $this->assertStringStartsWith('ASSESS-', $id2);
        $this->assertNotEquals($id1, $id2);
        
        // Check format ASSESS-YYYYMMDD-XXXX
        $this->assertMatchesRegularExpression('/^ASSESS-\d{8}-\d{4}$/', $id1);
    }
    
    public function testRecommendNextLevel(): void
    {
        // High score at current level
        $assessment1 = CompetencyAssessment::create(
            id: 'ASSESS-001',
            competencyId: CompetencyId::generate(),
            userId: UserId::generate(),
            assessorId: UserId::generate(),
            level: CompetencyLevel::intermediate(),
            score: AssessmentScore::fromPercentage(90)
        );
        
        $nextLevel1 = $this->service->recommendNextLevel($assessment1);
        $this->assertEquals(CompetencyLevel::advanced(), $nextLevel1);
        
        // Low score at current level
        $assessment2 = CompetencyAssessment::create(
            id: 'ASSESS-002',
            competencyId: CompetencyId::generate(),
            userId: UserId::generate(),
            assessorId: UserId::generate(),
            level: CompetencyLevel::intermediate(),
            score: AssessmentScore::fromPercentage(55)
        );
        
        $nextLevel2 = $this->service->recommendNextLevel($assessment2);
        $this->assertEquals(CompetencyLevel::intermediate(), $nextLevel2);
        
        // Already at expert level
        $assessment3 = CompetencyAssessment::create(
            id: 'ASSESS-003',
            competencyId: CompetencyId::generate(),
            userId: UserId::generate(),
            assessorId: UserId::generate(),
            level: CompetencyLevel::expert(),
            score: AssessmentScore::fromPercentage(95)
        );
        
        $nextLevel3 = $this->service->recommendNextLevel($assessment3);
        $this->assertEquals(CompetencyLevel::expert(), $nextLevel3);
    }
} 