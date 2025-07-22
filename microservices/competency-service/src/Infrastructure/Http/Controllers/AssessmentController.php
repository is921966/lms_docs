<?php

namespace CompetencyService\Infrastructure\Http\Controllers;

use CompetencyService\Application\Services\AssessmentService;
use CompetencyService\Application\DTOs\CreateAssessmentDTO;
use CompetencyService\Application\DTOs\CompleteAssessmentDTO;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Annotation\Route;

#[Route('/api/v1/assessments')]
class AssessmentController
{
    public function __construct(
        private readonly AssessmentService $assessmentService
    ) {}
    
    #[Route('', methods: ['POST'])]
    public function create(Request $request): JsonResponse
    {
        try {
            $data = json_decode($request->getContent(), true);
            
            $dto = new CreateAssessmentDTO(
                competencyId: $data['competency_id'] ?? '',
                userId: $data['user_id'] ?? '',
                assessorId: $data['assessor_id'] ?? ''
            );
            
            $assessment = $this->assessmentService->createAssessment($dto);
            
            return new JsonResponse(
                ['data' => $assessment],
                Response::HTTP_CREATED
            );
        } catch (\DomainException $e) {
            return new JsonResponse(
                ['error' => $e->getMessage()],
                Response::HTTP_BAD_REQUEST
            );
        }
    }
    
    #[Route('/{id}', methods: ['GET'])]
    public function show(string $id): JsonResponse
    {
        try {
            $assessment = $this->assessmentService->getAssessmentById($id);
            return new JsonResponse(['data' => $assessment]);
        } catch (\DomainException $e) {
            return new JsonResponse(
                ['error' => $e->getMessage()],
                Response::HTTP_NOT_FOUND
            );
        }
    }
    
    #[Route('/{id}/complete', methods: ['POST'])]
    public function complete(string $id, Request $request): JsonResponse
    {
        try {
            $data = json_decode($request->getContent(), true);
            
            $dto = new CompleteAssessmentDTO(
                assessmentId: $id,
                level: (int)($data['level'] ?? 0),
                feedback: $data['feedback'] ?? '',
                recommendations: $data['recommendations'] ?? ''
            );
            
            $assessment = $this->assessmentService->completeAssessment($dto);
            
            return new JsonResponse(['data' => $assessment]);
        } catch (\InvalidArgumentException $e) {
            return new JsonResponse(
                ['error' => $e->getMessage()],
                Response::HTTP_BAD_REQUEST
            );
        } catch (\DomainException $e) {
            return new JsonResponse(
                ['error' => $e->getMessage()],
                Response::HTTP_CONFLICT
            );
        }
    }
    
    #[Route('/{id}/cancel', methods: ['POST'])]
    public function cancel(string $id, Request $request): JsonResponse
    {
        try {
            $data = json_decode($request->getContent(), true);
            $reason = $data['reason'] ?? 'No reason provided';
            
            $assessment = $this->assessmentService->cancelAssessment($id, $reason);
            
            return new JsonResponse(['data' => $assessment]);
        } catch (\DomainException $e) {
            return new JsonResponse(
                ['error' => $e->getMessage()],
                Response::HTTP_CONFLICT
            );
        }
    }
    
    #[Route('/user/{userId}', methods: ['GET'])]
    public function userAssessments(string $userId): JsonResponse
    {
        $assessments = $this->assessmentService->getUserAssessments($userId);
        
        return new JsonResponse([
            'data' => $assessments,
            'total' => count($assessments)
        ]);
    }
    
    #[Route('/user/{userId}/progress', methods: ['GET'])]
    public function userProgress(string $userId): JsonResponse
    {
        $progress = $this->assessmentService->getUserCompetencyProgress($userId);
        
        return new JsonResponse([
            'data' => $progress,
            'total' => count($progress)
        ]);
    }
    
    #[Route('/competency/{competencyId}', methods: ['GET'])]
    public function competencyAssessments(string $competencyId): JsonResponse
    {
        try {
            $assessments = $this->assessmentService->getCompetencyAssessments($competencyId);
            
            return new JsonResponse([
                'data' => $assessments,
                'total' => count($assessments)
            ]);
        } catch (\Exception $e) {
            return new JsonResponse(
                ['error' => 'Invalid competency ID'],
                Response::HTTP_BAD_REQUEST
            );
        }
    }
    
    #[Route('/assessor/{assessorId}/pending', methods: ['GET'])]
    public function pendingAssessments(string $assessorId): JsonResponse
    {
        $assessments = $this->assessmentService->getPendingAssessmentsForAssessor($assessorId);
        
        return new JsonResponse([
            'data' => $assessments,
            'total' => count($assessments)
        ]);
    }
} 