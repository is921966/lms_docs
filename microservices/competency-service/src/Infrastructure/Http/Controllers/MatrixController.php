<?php

namespace CompetencyService\Infrastructure\Http\Controllers;

use CompetencyService\Application\Services\MatrixCalculatorService;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Annotation\Route;

#[Route('/api/v1/matrix')]
class MatrixController
{
    public function __construct(
        private readonly MatrixCalculatorService $matrixCalculator
    ) {}
    
    #[Route('/user/{userId}/matrix/{matrixId}/progress', methods: ['GET'])]
    public function userProgress(string $userId, string $matrixId): JsonResponse
    {
        try {
            $progress = $this->matrixCalculator->calculateUserMatrixProgress($userId, $matrixId);
            return new JsonResponse(['data' => $progress]);
        } catch (\DomainException $e) {
            return new JsonResponse(
                ['error' => $e->getMessage()],
                Response::HTTP_NOT_FOUND
            );
        }
    }
    
    #[Route('/user/{userId}/matrix/{matrixId}/gaps', methods: ['GET'])]
    public function gapAnalysis(string $userId, string $matrixId): JsonResponse
    {
        try {
            $gaps = $this->matrixCalculator->getCompetencyGapAnalysis($userId, $matrixId);
            return new JsonResponse(['data' => $gaps]);
        } catch (\DomainException $e) {
            return new JsonResponse(
                ['error' => $e->getMessage()],
                Response::HTTP_NOT_FOUND
            );
        }
    }
    
    #[Route('/position/{positionId}/compare', methods: ['POST'])]
    public function compareUsers(string $positionId, Request $request): JsonResponse
    {
        try {
            $data = json_decode($request->getContent(), true);
            $userIds = $data['user_ids'] ?? [];
            
            if (empty($userIds)) {
                return new JsonResponse(
                    ['error' => 'No user IDs provided'],
                    Response::HTTP_BAD_REQUEST
                );
            }
            
            $comparison = $this->matrixCalculator->compareUsersForPosition($positionId, $userIds);
            return new JsonResponse(['data' => $comparison]);
        } catch (\DomainException $e) {
            return new JsonResponse(
                ['error' => $e->getMessage()],
                Response::HTTP_NOT_FOUND
            );
        }
    }
} 