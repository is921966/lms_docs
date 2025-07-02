<?php

declare(strict_types=1);

namespace Learning\Infrastructure\Http\Controllers;

use Learning\Application\Service\CourseService;
use Learning\Application\DTO\CourseDTO;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\HttpFoundation\JsonResponse;

class CourseController
{
    public function __construct(
        private readonly CourseService $courseService
    ) {}
    
    public function index(Request $request): JsonResponse
    {
        try {
            $limit = (int) $request->query->get('limit', 10);
            $offset = (int) $request->query->get('offset', 0);
            
            $courses = $this->courseService->findPublished($limit, $offset);
            
            return new JsonResponse(['data' => $courses]);
        } catch (\Exception $e) {
            return new JsonResponse(['error' => 'Internal server error'], Response::HTTP_INTERNAL_SERVER_ERROR);
        }
    }
    
    public function show(string $id): JsonResponse
    {
        try {
            $course = $this->courseService->findById($id);
            
            if (!$course) {
                return new JsonResponse(['error' => 'Course not found'], Response::HTTP_NOT_FOUND);
            }
            
            return new JsonResponse(['data' => $course]);
        } catch (\Exception $e) {
            return new JsonResponse(['error' => 'Internal server error'], Response::HTTP_INTERNAL_SERVER_ERROR);
        }
    }
    
    public function create(Request $request): JsonResponse
    {
        try {
            $data = json_decode($request->getContent(), true);
            
            if (!$data) {
                return new JsonResponse(['error' => 'Invalid JSON'], Response::HTTP_BAD_REQUEST);
            }
            
            $dto = CourseDTO::fromArray($data);
            $course = $this->courseService->create($dto);
            
            return new JsonResponse(['data' => $course], Response::HTTP_CREATED);
        } catch (\InvalidArgumentException $e) {
            return new JsonResponse(['error' => $e->getMessage()], Response::HTTP_BAD_REQUEST);
        } catch (\Exception $e) {
            return new JsonResponse(['error' => 'Internal server error'], Response::HTTP_INTERNAL_SERVER_ERROR);
        }
    }
    
    public function update(string $id, Request $request): JsonResponse
    {
        try {
            $data = json_decode($request->getContent(), true);
            
            if (!$data) {
                return new JsonResponse(['error' => 'Invalid JSON'], Response::HTTP_BAD_REQUEST);
            }
            
            $course = $this->courseService->update($id, $data);
            
            return new JsonResponse(['data' => $course]);
        } catch (\Common\Exceptions\NotFoundException $e) {
            return new JsonResponse(['error' => $e->getMessage()], Response::HTTP_NOT_FOUND);
        } catch (\InvalidArgumentException $e) {
            return new JsonResponse(['error' => $e->getMessage()], Response::HTTP_BAD_REQUEST);
        } catch (\Exception $e) {
            return new JsonResponse(['error' => 'Internal server error'], Response::HTTP_INTERNAL_SERVER_ERROR);
        }
    }
    
    public function publish(string $id): JsonResponse
    {
        try {
            $result = $this->courseService->publish($id);
            
            if ($result) {
                return new JsonResponse(['message' => 'Course published successfully']);
            }
            
            return new JsonResponse(['error' => 'Failed to publish course'], Response::HTTP_BAD_REQUEST);
        } catch (\Common\Exceptions\NotFoundException $e) {
            return new JsonResponse(['error' => $e->getMessage()], Response::HTTP_NOT_FOUND);
        } catch (\Exception $e) {
            return new JsonResponse(['error' => 'Internal server error'], Response::HTTP_INTERNAL_SERVER_ERROR);
        }
    }
    
    public function archive(string $id): JsonResponse
    {
        try {
            $result = $this->courseService->archive($id);
            
            if ($result) {
                return new JsonResponse(['message' => 'Course archived successfully']);
            }
            
            return new JsonResponse(['error' => 'Failed to archive course'], Response::HTTP_BAD_REQUEST);
        } catch (\Common\Exceptions\NotFoundException $e) {
            return new JsonResponse(['error' => $e->getMessage()], Response::HTTP_NOT_FOUND);
        } catch (\Exception $e) {
            return new JsonResponse(['error' => 'Internal server error'], Response::HTTP_INTERNAL_SERVER_ERROR);
        }
    }
} 