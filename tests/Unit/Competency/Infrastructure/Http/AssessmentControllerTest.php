<?php

declare(strict_types=1);

namespace Tests\Unit\Competency\Infrastructure\Http;

use Competency\Application\Service\AssessmentService;
use Competency\Domain\Repository\AssessmentRepositoryInterface;
use Competency\Domain\Repository\UserCompetencyRepositoryInterface;
use Competency\Domain\Service\CompetencyAssessmentService;
use Competency\Infrastructure\Http\AssessmentController;
use Competency\Infrastructure\Repository\InMemoryAssessmentRepository;
use Competency\Infrastructure\Repository\InMemoryUserCompetencyRepository;
use User\Domain\ValueObjects\UserId;
use Competency\Domain\ValueObjects\CompetencyId;
use PHPUnit\Framework\TestCase;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;

class AssessmentControllerTest extends TestCase
{
    private AssessmentController $controller;
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
        
        $this->controller = new AssessmentController($this->service);
    }
    
    public function testCreateAssessment(): void
    {
        $requestData = [
            'user_id' => UserId::generate()->getValue(),
            'competency_id' => CompetencyId::generate()->getValue(),
            'assessor_id' => UserId::generate()->getValue(),
            'level' => 'intermediate',
            'score' => 75,
            'comment' => 'Good progress'
        ];
        
        $request = new Request([], [], [], [], [], [], json_encode($requestData));
        $request->headers->set('Content-Type', 'application/json');
        
        $response = $this->controller->create($request);
        
        $this->assertEquals(Response::HTTP_CREATED, $response->getStatusCode());
        
        $responseData = json_decode($response->getContent(), true);
        $this->assertTrue($responseData['success']);
        $this->assertArrayHasKey('data', $responseData);
        $this->assertEquals('intermediate', $responseData['data']['level']);
        $this->assertEquals(75, $responseData['data']['score']);
    }
    
    public function testGetUserAssessments(): void
    {
        $userId = UserId::generate()->getValue();
        
        // Create some assessments
        $this->service->createAssessment(
            userId: $userId,
            competencyId: CompetencyId::generate()->getValue(),
            assessorId: UserId::generate()->getValue(),
            level: 'beginner',
            score: 40,
            comment: null
        );
        
        $this->service->createAssessment(
            userId: $userId,
            competencyId: CompetencyId::generate()->getValue(),
            assessorId: UserId::generate()->getValue(),
            level: 'intermediate',
            score: 70,
            comment: null
        );
        
        // Get assessments
        $response = $this->controller->getUserAssessments($userId);
        
        $this->assertEquals(Response::HTTP_OK, $response->getStatusCode());
        
        $responseData = json_decode($response->getContent(), true);
        $this->assertTrue($responseData['success']);
        $this->assertCount(2, $responseData['data']);
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
        
        $assessmentId = $createResult['assessment_id'];
        
        // Update it
        $requestData = [
            'level' => 'intermediate',
            'score' => 70,
            'comment' => 'Improved significantly'
        ];
        
        $request = new Request([], [], [], [], [], [], json_encode($requestData));
        $request->headers->set('Content-Type', 'application/json');
        
        $response = $this->controller->update($assessmentId, $request);
        
        $this->assertEquals(Response::HTTP_OK, $response->getStatusCode());
        
        $responseData = json_decode($response->getContent(), true);
        $this->assertTrue($responseData['success']);
        $this->assertEquals('intermediate', $responseData['data']['level']);
        $this->assertEquals(70, $responseData['data']['score']);
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
        
        $assessmentId = $createResult['assessment_id'];
        
        // Confirm it
        $requestData = [
            'confirmer_id' => UserId::generate()->getValue()
        ];
        
        $request = new Request([], [], [], [], [], [], json_encode($requestData));
        $request->headers->set('Content-Type', 'application/json');
        
        $response = $this->controller->confirm($assessmentId, $request);
        
        $this->assertEquals(Response::HTTP_OK, $response->getStatusCode());
        
        $responseData = json_decode($response->getContent(), true);
        $this->assertTrue($responseData['success']);
        $this->assertTrue($responseData['data']['is_confirmed']);
    }
    
    public function testGetAssessmentHistory(): void
    {
        $userId = UserId::generate()->getValue();
        $competencyId = CompetencyId::generate()->getValue();
        
        // Create assessments
        for ($i = 0; $i < 3; $i++) {
            $this->service->createAssessment(
                userId: $userId,
                competencyId: $competencyId,
                assessorId: UserId::generate()->getValue(),
                level: 'intermediate',
                score: 60 + $i * 5,
                comment: null
            );
        }
        
        // Get history
        $response = $this->controller->getHistory($userId, $competencyId);
        
        $this->assertEquals(Response::HTTP_OK, $response->getStatusCode());
        
        $responseData = json_decode($response->getContent(), true);
        $this->assertTrue($responseData['success']);
        $this->assertCount(3, $responseData['data']);
    }
} 