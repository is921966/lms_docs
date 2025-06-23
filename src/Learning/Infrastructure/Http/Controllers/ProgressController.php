<?php

declare(strict_types=1);

namespace App\Learning\Infrastructure\Http\Controllers;

use App\Learning\Application\Service\ProgressService;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\HttpFoundation\JsonResponse;

class ProgressController
{
    public function __construct(
        private readonly ProgressService $progressService
    ) {}
    
    public function startLesson(Request $request): JsonResponse
    {
        try {
            $data = json_decode($request->getContent(), true);
            
            if (!$data || !isset($data['userId']) || !isset($data['courseId']) || !isset($data['lessonId'])) {
                return new JsonResponse(['error' => 'Missing required fields'], Response::HTTP_BAD_REQUEST);
            }
            
            $progress = $this->progressService->startLesson(
                $data['userId'],
                $data['courseId'],
                $data['lessonId']
            );
            
            return new JsonResponse(['data' => $progress]);
        } catch (\App\Common\Exceptions\NotFoundException $e) {
            return new JsonResponse(['error' => $e->getMessage()], Response::HTTP_NOT_FOUND);
        } catch (\App\Common\Exceptions\BusinessLogicException $e) {
            return new JsonResponse(['error' => $e->getMessage()], Response::HTTP_BAD_REQUEST);
        } catch (\Exception $e) {
            return new JsonResponse(['error' => 'Internal server error'], Response::HTTP_INTERNAL_SERVER_ERROR);
        }
    }
    
    public function updateProgress(Request $request): JsonResponse
    {
        try {
            $data = json_decode($request->getContent(), true);
            
            if (!$data || !isset($data['enrollmentId']) || !isset($data['lessonId']) || !isset($data['percentage'])) {
                return new JsonResponse(['error' => 'Missing required fields'], Response::HTTP_BAD_REQUEST);
            }
            
            $result = $this->progressService->updateProgress(
                $data['enrollmentId'],
                $data['lessonId'],
                (float) $data['percentage']
            );
            
            if ($result) {
                return new JsonResponse(['message' => 'Progress updated successfully']);
            }
            
            return new JsonResponse(['error' => 'Failed to update progress'], Response::HTTP_BAD_REQUEST);
        } catch (\App\Common\Exceptions\NotFoundException $e) {
            return new JsonResponse(['error' => $e->getMessage()], Response::HTTP_NOT_FOUND);
        } catch (\Exception $e) {
            return new JsonResponse(['error' => 'Internal server error'], Response::HTTP_INTERNAL_SERVER_ERROR);
        }
    }
    
    public function completeLesson(Request $request): JsonResponse
    {
        try {
            $data = json_decode($request->getContent(), true);
            
            if (!$data || !isset($data['enrollmentId']) || !isset($data['lessonId']) || !isset($data['score'])) {
                return new JsonResponse(['error' => 'Missing required fields'], Response::HTTP_BAD_REQUEST);
            }
            
            $result = $this->progressService->completeLesson(
                $data['enrollmentId'],
                $data['lessonId'],
                (float) $data['score']
            );
            
            if ($result) {
                return new JsonResponse(['message' => 'Lesson completed successfully']);
            }
            
            return new JsonResponse(['error' => 'Failed to complete lesson'], Response::HTTP_BAD_REQUEST);
        } catch (\App\Common\Exceptions\NotFoundException $e) {
            return new JsonResponse(['error' => $e->getMessage()], Response::HTTP_NOT_FOUND);
        } catch (\Exception $e) {
            return new JsonResponse(['error' => 'Internal server error'], Response::HTTP_INTERNAL_SERVER_ERROR);
        }
    }
    
    public function enrollmentProgress(string $enrollmentId): JsonResponse
    {
        try {
            $progresses = $this->progressService->getEnrollmentProgress($enrollmentId);
            
            return new JsonResponse(['data' => $progresses]);
        } catch (\Exception $e) {
            return new JsonResponse(['error' => 'Internal server error'], Response::HTTP_INTERNAL_SERVER_ERROR);
        }
    }
    
    public function lessonProgress(string $lessonId): JsonResponse
    {
        try {
            $progresses = $this->progressService->getLessonProgress($lessonId);
            
            return new JsonResponse(['data' => $progresses]);
        } catch (\Exception $e) {
            return new JsonResponse(['error' => 'Internal server error'], Response::HTTP_INTERNAL_SERVER_ERROR);
        }
    }
} 