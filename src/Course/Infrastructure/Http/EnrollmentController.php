<?php

declare(strict_types=1);

namespace App\Course\Infrastructure\Http;

use App\Common\Http\ApiController;
use App\Course\Application\Services\EnrollmentService;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Annotation\Route;
use Symfony\Component\Validator\Validator\ValidatorInterface;
use Symfony\Component\Validator\Constraints as Assert;

#[Route('/api/v1/enrollments')]
class EnrollmentController extends ApiController
{
    public function __construct(
        private EnrollmentService $enrollmentService,
        private ValidatorInterface $validator
    ) {
    }
    
    #[Route('', name: 'enrollments_create', methods: ['POST'])]
    public function enroll(Request $request): JsonResponse
    {
        $data = json_decode($request->getContent(), true);
        
        $constraints = new Assert\Collection([
            'user_id' => new Assert\NotBlank(),
            'course_id' => new Assert\NotBlank()
        ]);
        
        $violations = $this->validator->validate($data, $constraints);
        
        if (count($violations) > 0) {
            return $this->validationError($violations);
        }
        
        try {
            $enrollment = $this->enrollmentService->enrollUser(
                $data['user_id'],
                $data['course_id']
            );
            
            return $this->json(
                ['data' => $enrollment->toArray()],
                Response::HTTP_CREATED
            );
        } catch (\Exception $e) {
            return $this->json(
                ['error' => $e->getMessage()],
                Response::HTTP_BAD_REQUEST
            );
        }
    }
    
    #[Route('/user/{userId}', name: 'enrollments_user_list', methods: ['GET'])]
    public function userEnrollments(string $userId): JsonResponse
    {
        $enrollments = $this->enrollmentService->getUserEnrollments($userId);
        
        return $this->json([
            'data' => array_map(fn($dto) => $dto->toArray(), $enrollments),
            'meta' => [
                'total' => count($enrollments)
            ]
        ]);
    }
    
    #[Route('/course/{courseId}', name: 'enrollments_course_list', methods: ['GET'])]
    public function courseEnrollments(string $courseId): JsonResponse
    {
        try {
            $enrollments = $this->enrollmentService->getCourseEnrollments($courseId);
            
            return $this->json([
                'data' => array_map(fn($dto) => $dto->toArray(), $enrollments),
                'meta' => [
                    'total' => count($enrollments)
                ]
            ]);
        } catch (\Exception $e) {
            return $this->json(
                ['error' => $e->getMessage()],
                Response::HTTP_NOT_FOUND
            );
        }
    }
    
    #[Route('/{userId}/{courseId}/progress', name: 'enrollments_update_progress', methods: ['PUT'])]
    public function updateProgress(string $userId, string $courseId, Request $request): JsonResponse
    {
        $data = json_decode($request->getContent(), true);
        
        $constraints = new Assert\Collection([
            'progress_percent' => [
                new Assert\NotBlank(),
                new Assert\Type('integer'),
                new Assert\Range(['min' => 0, 'max' => 100])
            ]
        ]);
        
        $violations = $this->validator->validate($data, $constraints);
        
        if (count($violations) > 0) {
            return $this->validationError($violations);
        }
        
        try {
            $this->enrollmentService->updateProgress(
                $userId,
                $courseId,
                $data['progress_percent']
            );
            
            return $this->json(['message' => 'Progress updated successfully']);
        } catch (\Exception $e) {
            return $this->json(
                ['error' => $e->getMessage()],
                Response::HTTP_BAD_REQUEST
            );
        }
    }
    
    #[Route('/{userId}/{courseId}/complete', name: 'enrollments_complete', methods: ['POST'])]
    public function complete(string $userId, string $courseId): JsonResponse
    {
        try {
            $this->enrollmentService->completeCourse($userId, $courseId);
            return $this->json(['message' => 'Course completed successfully']);
        } catch (\Exception $e) {
            return $this->json(
                ['error' => $e->getMessage()],
                Response::HTTP_BAD_REQUEST
            );
        }
    }
    
    #[Route('/{userId}/{courseId}/suspend', name: 'enrollments_suspend', methods: ['POST'])]
    public function suspend(string $userId, string $courseId): JsonResponse
    {
        try {
            $this->enrollmentService->suspendEnrollment($userId, $courseId);
            return $this->json(['message' => 'Enrollment suspended successfully']);
        } catch (\Exception $e) {
            return $this->json(
                ['error' => $e->getMessage()],
                Response::HTTP_BAD_REQUEST
            );
        }
    }
    
    #[Route('/{userId}/{courseId}/resume', name: 'enrollments_resume', methods: ['POST'])]
    public function resume(string $userId, string $courseId): JsonResponse
    {
        try {
            $this->enrollmentService->resumeEnrollment($userId, $courseId);
            return $this->json(['message' => 'Enrollment resumed successfully']);
        } catch (\Exception $e) {
            return $this->json(
                ['error' => $e->getMessage()],
                Response::HTTP_BAD_REQUEST
            );
        }
    }
} 