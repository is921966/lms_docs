<?php

declare(strict_types=1);

namespace Tests\Unit\Competency\Application\Service;

use App\Competency\Application\Service\AssessmentService;
use App\Competency\Domain\Repository\AssessmentRepositoryInterface;
use App\Competency\Domain\Repository\UserCompetencyRepositoryInterface;
use App\Competency\Domain\Service\CompetencyAssessmentService;
use App\Competency\Infrastructure\Repository\InMemoryAssessmentRepository;
use App\Competency\Infrastructure\Repository\InMemoryUserCompetencyRepository;
use App\User\Domain\ValueObjects\UserId;
use App\Competency\Domain\ValueObjects\CompetencyId;
use PHPUnit\Framework\TestCase;

class AssessmentServiceTest extends TestCase
{
    private AssessmentService $service;
    
    protected function setUp(): void
    {
        $assessmentRepository = new InMemoryAssessmentRepository();
        $userCompetencyRepository = new InMemoryUserCompetencyRepository();
        $domainService = new CompetencyAssessmentService();
        
        $this->service = new AssessmentService(
            $assessmentRepository,
            $userCompetencyRepository,
            $domainService
        );
    }
    
    public function testCreateAssessment(): void
    {
        // Generate valid IDs
        $userId = UserId::generate()->getValue();
        $competencyId = CompetencyId::generate()->getValue();
        $assessorId = UserId::generate()->getValue();
        
        $result = $this->service->createAssessment(
            userId: $userId,
            competencyId: $competencyId,
            assessorId: $assessorId,
            level: 'intermediate',
            score: 75,
            comment: 'Good progress'
        );
        
        $this->assertTrue($result['success']);
        $this->assertArrayHasKey('assessment_id', $result);
        $this->assertEquals($userId, $result['user_id']);
        $this->assertEquals($competencyId, $result['competency_id']);
        $this->assertEquals($assessorId, $result['assessor_id']);
        $this->assertEquals('intermediate', $result['level']);
        $this->assertEquals(75, $result['score']);
        $this->assertFalse($result['is_self_assessment']);
    }
    
    public function testCreateSelfAssessment(): void
    {
        $userId = UserId::generate()->getValue();
        $competencyId = CompetencyId::generate()->getValue();
        
        $result = $this->service->createAssessment(
            userId: $userId,
            competencyId: $competencyId,
            assessorId: $userId, // Same as userId
            level: 'beginner',
            score: 50,
            comment: 'Just starting'
        );
        
        $this->assertTrue($result['success']);
        $this->assertTrue($result['is_self_assessment']);
    }
    
    public function testCreateAssessmentWithInvalidLevel(): void
    {
        $result = $this->service->createAssessment(
            userId: UserId::generate()->getValue(),
            competencyId: CompetencyId::generate()->getValue(),
            assessorId: UserId::generate()->getValue(),
            level: 'invalid_level',
            score: 75,
            comment: null
        );
        
        $this->assertFalse($result['success']);
        $this->assertStringContainsString('Invalid level', $result['error']);
    }
    
    public function testCreateAssessmentWithInvalidScore(): void
    {
        $result = $this->service->createAssessment(
            userId: UserId::generate()->getValue(),
            competencyId: CompetencyId::generate()->getValue(),
            assessorId: UserId::generate()->getValue(),
            level: 'intermediate',
            score: 150, // Invalid score > 100
            comment: null
        );
        
        $this->assertFalse($result['success']);
        $this->assertStringContainsString('Score must be between 0 and 100', $result['error']);
    }
    
    public function testUpdateAssessment(): void
    {
        // Create assessment
        $createResult = $this->service->createAssessment(
            userId: UserId::generate()->getValue(),
            competencyId: CompetencyId::generate()->getValue(),
            assessorId: UserId::generate()->getValue(),
            level: 'beginner',
            score: 40,
            comment: 'Initial assessment'
        );
        
        // Update it
        $updateResult = $this->service->updateAssessment(
            assessmentId: $createResult['assessment_id'],
            level: 'intermediate',
            score: 70,
            comment: 'Improved significantly'
        );
        
        $this->assertTrue($updateResult['success']);
        $this->assertEquals('intermediate', $updateResult['level']);
        $this->assertEquals(70, $updateResult['score']);
    }
    
    public function testConfirmAssessment(): void
    {
        // Create assessment
        $createResult = $this->service->createAssessment(
            userId: UserId::generate()->getValue(),
            competencyId: CompetencyId::generate()->getValue(),
            assessorId: UserId::generate()->getValue(),
            level: 'intermediate',
            score: 70,
            comment: null
        );
        
        // Confirm it
        $confirmResult = $this->service->confirmAssessment(
            assessmentId: $createResult['assessment_id'],
            confirmerId: UserId::generate()->getValue()
        );
        
        $this->assertTrue($confirmResult['success']);
        $this->assertTrue($confirmResult['is_confirmed']);
        $this->assertNotNull($confirmResult['confirmed_at']);
    }
    
    public function testGetUserAssessments(): void
    {
        $userId = UserId::generate();
        
        // Create multiple assessments
        $this->service->createAssessment(
            userId: $userId->getValue(),
            competencyId: CompetencyId::generate()->getValue(),
            assessorId: UserId::generate()->getValue(),
            level: 'beginner',
            score: 40,
            comment: null
        );
        
        $this->service->createAssessment(
            userId: $userId->getValue(),
            competencyId: CompetencyId::generate()->getValue(),
            assessorId: UserId::generate()->getValue(),
            level: 'intermediate',
            score: 70,
            comment: null
        );
        
        $result = $this->service->getUserAssessments($userId->getValue());
        
        $this->assertTrue($result['success']);
        $this->assertCount(2, $result['data']);
    }
    
    public function testGetAssessmentHistory(): void
    {
        $userId = UserId::generate();
        $competencyId = CompetencyId::generate();
        
        // Create assessments for same competency
        for ($i = 0; $i < 5; $i++) {
            $this->service->createAssessment(
                userId: $userId->getValue(),
                competencyId: $competencyId->getValue(),
                assessorId: UserId::generate()->getValue(),
                level: 'intermediate',
                score: 60 + $i * 5,
                comment: null
            );
        }
        
        $result = $this->service->getAssessmentHistory(
            userId: $userId->getValue(),
            competencyId: $competencyId->getValue(),
            limit: 3
        );
        
        $this->assertTrue($result['success']);
        $this->assertCount(3, $result['data']);
    }
    
    public function testGetUserCompetencyStats(): void
    {
        $userId = UserId::generate();
        
        // Create assessments
        $assessment1 = $this->service->createAssessment(
            userId: $userId->getValue(),
            competencyId: CompetencyId::generate()->getValue(),
            assessorId: UserId::generate()->getValue(),
            level: 'intermediate',
            score: 70,
            comment: null
        );
        
        $assessment2 = $this->service->createAssessment(
            userId: $userId->getValue(),
            competencyId: CompetencyId::generate()->getValue(),
            assessorId: $userId->getValue(), // Self-assessment
            level: 'beginner',
            score: 50,
            comment: null
        );
        
        // Confirm one
        $this->service->confirmAssessment(
            assessmentId: $assessment1['assessment_id'],
            confirmerId: UserId::generate()->getValue()
        );
        
        $result = $this->service->getUserCompetencyStats($userId->getValue());
        
        $this->assertTrue($result['success']);
        $this->assertEquals(2, $result['stats']['total']);
        $this->assertEquals(1, $result['stats']['confirmed']);
        $this->assertEquals(1, $result['stats']['self_assessments']);
        $this->assertEquals(60.0, $result['stats']['average_score']);
    }
    
    public function testUpdateConfirmedAssessmentFails(): void
    {
        // Create and confirm assessment
        $createResult = $this->service->createAssessment(
            userId: UserId::generate()->getValue(),
            competencyId: CompetencyId::generate()->getValue(),
            assessorId: UserId::generate()->getValue(),
            level: 'intermediate',
            score: 70,
            comment: null
        );
        
        $this->service->confirmAssessment(
            assessmentId: $createResult['assessment_id'],
            confirmerId: UserId::generate()->getValue()
        );
        
        // Try to update confirmed assessment
        $updateResult = $this->service->updateAssessment(
            assessmentId: $createResult['assessment_id'],
            level: 'advanced',
            score: 80,
            comment: 'Try to update'
        );
        
        $this->assertFalse($updateResult['success']);
        $this->assertStringContainsString('Cannot update confirmed assessment', $updateResult['error']);
    }
} 