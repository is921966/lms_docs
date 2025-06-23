<?php

declare(strict_types=1);

namespace App\Learning\Infrastructure\Http\Controllers;

use App\Learning\Application\Service\EnrollmentService;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\HttpFoundation\JsonResponse;

class EnrollmentController
{
    public function __construct(
        private readonly EnrollmentService $enrollmentService
    ) {}
    
    public function enroll(Request $request): JsonResponse
    {
        try {
            $data = json_decode($request->getContent(), true);
            
            if (!$data || !isset($data['userId']) || !isset($data['courseId'])) {
                return new JsonResponse(['error' => 'Missing required fields'], Response::HTTP_BAD_REQUEST);
            }
            
            $enrollment = $this->enrollmentService->enroll(
                $data['userId'],
                $data['courseId'],
                $data['enrolledBy'] ?? null
            );
            
            return new JsonResponse(['data' => $enrollment], Response::HTTP_CREATED);
        } catch (\App\Common\Exceptions\BusinessLogicException $e) {
            return new JsonResponse(['error' => $e->getMessage()], Response::HTTP_BAD_REQUEST);
        } catch (\App\Common\Exceptions\NotFoundException $e) {
            return new JsonResponse(['error' => $e->getMessage()], Response::HTTP_NOT_FOUND);
        } catch (\Exception $e) {
            return new JsonResponse(['error' => 'Internal server error'], Response::HTTP_INTERNAL_SERVER_ERROR);
        }
    }
    
    public function userEnrollments(string $userId): JsonResponse
    {
        try {
            $enrollments = $this->enrollmentService->findUserEnrollments($userId);
            
            return new JsonResponse(['data' => $enrollments]);
        } catch (\Exception $e) {
            return new JsonResponse(['error' => 'Internal server error'], Response::HTTP_INTERNAL_SERVER_ERROR);
        }
    }
    
    public function courseEnrollments(string $courseId): JsonResponse
    {
        try {
            $enrollments = $this->enrollmentService->findCourseEnrollments($courseId);
            
            return new JsonResponse(['data' => $enrollments]);
        } catch (\Exception $e) {
            return new JsonResponse(['error' => 'Internal server error'], Response::HTTP_INTERNAL_SERVER_ERROR);
        }
    }
    
    public function complete(Request $request): JsonResponse
    {
        try {
            $data = json_decode($request->getContent(), true);
            
            if (!$data || !isset($data['userId']) || !isset($data['courseId']) || !isset($data['score'])) {
                return new JsonResponse(['error' => 'Missing required fields'], Response::HTTP_BAD_REQUEST);
            }
            
            $result = $this->enrollmentService->complete(
                $data['userId'],
                $data['courseId'],
                (float) $data['score']
            );
            
            if ($result) {
                return new JsonResponse(['message' => 'Enrollment completed successfully']);
            }
            
            return new JsonResponse(['error' => 'Failed to complete enrollment'], Response::HTTP_BAD_REQUEST);
        } catch (\App\Common\Exceptions\NotFoundException $e) {
            return new JsonResponse(['error' => $e->getMessage()], Response::HTTP_NOT_FOUND);
        } catch (\Exception $e) {
            return new JsonResponse(['error' => 'Internal server error'], Response::HTTP_INTERNAL_SERVER_ERROR);
        }
    }
    
    public function cancel(Request $request): JsonResponse
    {
        try {
            $data = json_decode($request->getContent(), true);
            
            if (!$data || !isset($data['userId']) || !isset($data['courseId']) || !isset($data['reason'])) {
                return new JsonResponse(['error' => 'Missing required fields'], Response::HTTP_BAD_REQUEST);
            }
            
            $result = $this->enrollmentService->cancel(
                $data['userId'],
                $data['courseId'],
                $data['reason']
            );
            
            if ($result) {
                return new JsonResponse(['message' => 'Enrollment cancelled successfully']);
            }
            
            return new JsonResponse(['error' => 'Failed to cancel enrollment'], Response::HTTP_BAD_REQUEST);
        } catch (\App\Common\Exceptions\NotFoundException $e) {
            return new JsonResponse(['error' => $e->getMessage()], Response::HTTP_NOT_FOUND);
        } catch (\Exception $e) {
            return new JsonResponse(['error' => 'Internal server error'], Response::HTTP_INTERNAL_SERVER_ERROR);
        }
    }
    
    public function updateProgress(Request $request): JsonResponse
    {
        try {
            $data = json_decode($request->getContent(), true);
            
            if (!$data || !isset($data['userId']) || !isset($data['courseId']) || !isset($data['percentage'])) {
                return new JsonResponse(['error' => 'Missing required fields'], Response::HTTP_BAD_REQUEST);
            }
            
            $result = $this->enrollmentService->updateProgress(
                $data['userId'],
                $data['courseId'],
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
} 