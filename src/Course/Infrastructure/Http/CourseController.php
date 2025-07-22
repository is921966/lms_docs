<?php

declare(strict_types=1);

namespace App\Course\Infrastructure\Http;

use App\Common\Http\ApiController;
use App\Course\Application\Services\CourseService;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Annotation\Route;
use Symfony\Component\Validator\Validator\ValidatorInterface;
use Symfony\Component\Validator\Constraints as Assert;

#[Route('/api/v1/courses')]
class CourseController extends ApiController
{
    public function __construct(
        private CourseService $courseService,
        private ValidatorInterface $validator
    ) {
    }
    
    #[Route('', name: 'courses_list', methods: ['GET'])]
    public function list(Request $request): JsonResponse
    {
        $status = $request->query->get('status');
        
        $courses = match ($status) {
            'published' => $this->courseService->getPublishedCourses(),
            default => $this->courseService->getAllCourses()
        };
        
        return $this->json([
            'data' => array_map(fn($dto) => $dto->toArray(), $courses),
            'meta' => [
                'total' => count($courses)
            ]
        ]);
    }
    
    #[Route('/{id}', name: 'courses_get', methods: ['GET'])]
    public function get(string $id): JsonResponse
    {
        try {
            $course = $this->courseService->getCourseById($id);
            return $this->json(['data' => $course->toArray()]);
        } catch (\Exception $e) {
            return $this->json(['error' => $e->getMessage()], Response::HTTP_NOT_FOUND);
        }
    }
    
    #[Route('', name: 'courses_create', methods: ['POST'])]
    public function create(Request $request): JsonResponse
    {
        $data = json_decode($request->getContent(), true);
        
        $constraints = new Assert\Collection([
            'code' => [
                new Assert\NotBlank(),
                new Assert\Length(['min' => 3, 'max' => 20])
            ],
            'title' => [
                new Assert\NotBlank(),
                new Assert\Length(['max' => 255])
            ],
            'description' => new Assert\NotBlank(),
            'duration_minutes' => [
                new Assert\NotBlank(),
                new Assert\Type('integer'),
                new Assert\GreaterThan(0)
            ],
            'price_amount' => [
                new Assert\NotBlank(),
                new Assert\Type('numeric'),
                new Assert\GreaterThanOrEqual(0)
            ],
            'price_currency' => [
                new Assert\Optional([
                    new Assert\Choice(['USD', 'EUR', 'GBP', 'RUB', 'JPY'])
                ])
            ]
        ]);
        
        $violations = $this->validator->validate($data, $constraints);
        
        if (count($violations) > 0) {
            return $this->validationError($violations);
        }
        
        try {
            $course = $this->courseService->createCourse(
                $data['code'],
                $data['title'],
                $data['description'],
                $data['duration_minutes'],
                (float)$data['price_amount'],
                $data['price_currency'] ?? 'USD'
            );
            
            return $this->json(
                ['data' => $course->toArray()],
                Response::HTTP_CREATED
            );
        } catch (\Exception $e) {
            return $this->json(
                ['error' => $e->getMessage()],
                Response::HTTP_BAD_REQUEST
            );
        }
    }
    
    #[Route('/{id}/publish', name: 'courses_publish', methods: ['POST'])]
    public function publish(string $id): JsonResponse
    {
        try {
            $this->courseService->publishCourse($id);
            return $this->json(['message' => 'Course published successfully']);
        } catch (\Exception $e) {
            return $this->json(
                ['error' => $e->getMessage()],
                Response::HTTP_BAD_REQUEST
            );
        }
    }
    
    #[Route('/{id}/archive', name: 'courses_archive', methods: ['POST'])]
    public function archive(string $id): JsonResponse
    {
        try {
            $this->courseService->archiveCourse($id);
            return $this->json(['message' => 'Course archived successfully']);
        } catch (\Exception $e) {
            return $this->json(
                ['error' => $e->getMessage()],
                Response::HTTP_BAD_REQUEST
            );
        }
    }
} 