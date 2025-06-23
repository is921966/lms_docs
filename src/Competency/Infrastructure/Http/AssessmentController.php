<?php

declare(strict_types=1);

namespace App\Competency\Infrastructure\Http;

use App\Competency\Application\DTO\AssessmentDTO;
use App\Competency\Application\Service\AssessmentService;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;

class AssessmentController
{
    public function __construct(
        private readonly AssessmentService $assessmentService
    ) {
    }
    
    public function create(Request $request): JsonResponse
    {
        try {
            $data = $this->getJsonData($request);
            
            $result = $this->assessmentService->createAssessment(
                userId: $data['user_id'] ?? '',
                competencyId: $data['competency_id'] ?? '',
                assessorId: $data['assessor_id'] ?? '',
                level: $data['level'] ?? '',
                score: $data['score'] ?? 0,
                comment: $data['comment'] ?? null
            );
            
            if (!$result['success']) {
                return $this->json($result, Response::HTTP_BAD_REQUEST);
            }
            
            // Prepare data for DTO
            $assessmentData = [
                'id' => $result['assessment_id'],
                'user_id' => $result['user_id'],
                'competency_id' => $result['competency_id'],
                'assessor_id' => $result['assessor_id'],
                'level' => $result['level'],
                'score' => $result['score'],
                'comment' => $result['comment'],
                'is_self_assessment' => $result['is_self_assessment'],
                'is_confirmed' => false,
                'assessed_at' => $result['assessed_at']
            ];
            
            // Convert to DTO
            $dto = AssessmentDTO::fromArray($assessmentData);
            
            return $this->json([
                'success' => true,
                'data' => $dto->toArray()
            ], Response::HTTP_CREATED);
            
        } catch (\Exception $e) {
            return $this->json([
                'success' => false,
                'error' => $e->getMessage()
            ], Response::HTTP_BAD_REQUEST);
        }
    }
    
    public function getUserAssessments(string $userId): JsonResponse
    {
        $result = $this->assessmentService->getUserAssessments($userId);
        
        if (!$result['success']) {
            return $this->json($result, Response::HTTP_BAD_REQUEST);
        }
        
        // Convert to DTOs
        $dtos = array_map(
            fn($assessment) => AssessmentDTO::fromArray($assessment)->toArray(),
            $result['data']
        );
        
        return $this->json([
            'success' => true,
            'data' => $dtos
        ]);
    }
    
    public function update(string $id, Request $request): JsonResponse
    {
        try {
            $data = $this->getJsonData($request);
            
            $result = $this->assessmentService->updateAssessment(
                assessmentId: $id,
                level: $data['level'] ?? '',
                score: $data['score'] ?? 0,
                comment: $data['comment'] ?? null
            );
            
            if (!$result['success']) {
                return $this->json($result, Response::HTTP_BAD_REQUEST);
            }
            
            // Need to get full assessment data
            $assessment = $this->assessmentService->getUserAssessments($id);
            
            // For now, return simple response
            return $this->json([
                'success' => true,
                'data' => [
                    'assessment_id' => $result['assessment_id'],
                    'level' => $result['level'],
                    'score' => $result['score'],
                    'comment' => $result['comment']
                ]
            ]);
            
        } catch (\Exception $e) {
            return $this->json([
                'success' => false,
                'error' => $e->getMessage()
            ], Response::HTTP_BAD_REQUEST);
        }
    }
    
    public function confirm(string $id, Request $request): JsonResponse
    {
        try {
            $data = $this->getJsonData($request);
            
            $result = $this->assessmentService->confirmAssessment(
                assessmentId: $id,
                confirmerId: $data['confirmer_id'] ?? ''
            );
            
            if (!$result['success']) {
                return $this->json($result, Response::HTTP_BAD_REQUEST);
            }
            
            return $this->json([
                'success' => true,
                'data' => [
                    'assessment_id' => $result['assessment_id'],
                    'is_confirmed' => $result['is_confirmed'],
                    'confirmed_at' => $result['confirmed_at'],
                    'confirmed_by' => $result['confirmed_by']
                ]
            ]);
            
        } catch (\Exception $e) {
            return $this->json([
                'success' => false,
                'error' => $e->getMessage()
            ], Response::HTTP_BAD_REQUEST);
        }
    }
    
    public function getHistory(string $userId, string $competencyId): JsonResponse
    {
        $result = $this->assessmentService->getAssessmentHistory(
            userId: $userId,
            competencyId: $competencyId,
            limit: 10
        );
        
        if (!$result['success']) {
            return $this->json($result, Response::HTTP_BAD_REQUEST);
        }
        
        // Convert to DTOs
        $dtos = array_map(
            fn($assessment) => AssessmentDTO::fromArray($assessment)->toArray(),
            $result['data']
        );
        
        return $this->json([
            'success' => true,
            'data' => $dtos
        ]);
    }
    
    private function getJsonData(Request $request): array
    {
        $content = $request->getContent();
        if (empty($content)) {
            return [];
        }
        
        return json_decode($content, true) ?? [];
    }
    
    private function json(array $data, int $status = Response::HTTP_OK): JsonResponse
    {
        return new JsonResponse($data, $status);
    }
} 