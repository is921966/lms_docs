<?php

declare(strict_types=1);

namespace Learning\Http\Controllers;

use Learning\Application\Commands\CreateCourseCommand;
use Learning\Application\Commands\UpdateCourseCommand;
use Learning\Application\Commands\PublishCourseCommand;
use Learning\Application\Commands\ArchiveCourseCommand;
use Learning\Application\Commands\EnrollUserCommand;
use Learning\Application\Queries\GetCourseByIdQuery;
use Learning\Application\Queries\ListCoursesQuery;
use Learning\Domain\Services\CommandBusInterface;
use Learning\Domain\Services\QueryBusInterface;
use Learning\Domain\Services\CourseCacheInterface;
use Learning\Domain\ValueObjects\CourseId;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\JsonResponse;
use Symfony\Component\HttpFoundation\Response;

final class CourseController
{
    public function __construct(
        private readonly CommandBusInterface $commandBus,
        private readonly QueryBusInterface $queryBus,
        private readonly CourseCacheInterface $cache
    ) {
    }
    
    public function list(Request $request): JsonResponse
    {
        $filters = [];
        if ($status = $request->query->get('status')) {
            $filters['status'] = $status;
        }
        if ($instructorId = $request->query->get('instructor_id')) {
            $filters['instructor_id'] = $instructorId;
        }
        if ($category = $request->query->get('category')) {
            $filters['category'] = $category;
        }
        
        $query = new ListCoursesQuery(
            'system', // TODO: Get from auth context
            $filters,
            (int) $request->query->get('page', 1),
            (int) $request->query->get('limit', 10),
            $request->query->get('sort', 'created_at'),
            $request->query->get('order', 'desc')
        );
        
        $courses = $this->queryBus->handle($query);
        
        return new JsonResponse([
            'data' => array_map(fn($course) => $this->serializeCourse($course), $courses),
            'meta' => [
                'page' => $query->getPage(),
                'limit' => $query->getPerPage(),
                'total' => count($courses) // In real app, this would be from a separate count query
            ]
        ]);
    }
    
    public function show(string $id): JsonResponse
    {
        $query = new GetCourseByIdQuery($id, 'system'); // TODO: Get from auth context
        $course = $this->queryBus->handle($query);
        
        if ($course === null) {
            return new JsonResponse([
                'error' => [
                    'message' => 'Course not found',
                    'code' => 'COURSE_NOT_FOUND'
                ]
            ], Response::HTTP_NOT_FOUND);
        }
        
        return new JsonResponse([
            'data' => $this->serializeCourse($course)
        ]);
    }
    
    public function create(Request $request): JsonResponse
    {
        $data = json_decode($request->getContent(), true);
        
        // Validation
        $errors = $this->validateCreateRequest($data);
        if (!empty($errors)) {
            return new JsonResponse([
                'errors' => $errors
            ], Response::HTTP_BAD_REQUEST);
        }
        
        $command = new CreateCourseCommand(
            $data['course_code'],
            $data['title'],
            $data['description'],
            $data['duration_hours'],
            $data['instructor_id'],
            $data['metadata'] ?? []
        );
        
        $courseId = $this->commandBus->handle($command);
        
        // Fetch the created course
        $query = new GetCourseByIdQuery($courseId, 'system');
        $course = $this->queryBus->handle($query);
        
        return new JsonResponse([
            'data' => $this->serializeCourse($course)
        ], Response::HTTP_CREATED, [
            'Location' => '/api/v1/courses/' . $courseId
        ]);
    }
    
    public function update(string $id, Request $request): JsonResponse
    {
        $data = json_decode($request->getContent(), true);
        
        $updates = [];
        if (isset($data['title'])) {
            $updates['title'] = $data['title'];
        }
        if (isset($data['description'])) {
            $updates['description'] = $data['description'];
        }
        if (isset($data['metadata'])) {
            $updates['metadata'] = $data['metadata'];
        }
        
        $command = new UpdateCourseCommand($id, $updates, 'system'); // TODO: Get from auth context
        
        $this->commandBus->handle($command);
        
        // Invalidate cache
        $this->cache->invalidateCourse(CourseId::fromString($id));
        
        // Fetch updated course
        $query = new GetCourseByIdQuery($id, 'system');
        $course = $this->queryBus->handle($query);
        
        return new JsonResponse([
            'data' => $this->serializeCourse($course)
        ]);
    }
    
    public function publish(string $id, Request $request): JsonResponse
    {
        $command = new PublishCourseCommand($id, 'system'); // TODO: Get from auth context
        $this->commandBus->handle($command);
        
        // Invalidate cache
        $this->cache->invalidateCourse(CourseId::fromString($id));
        
        // Fetch updated course
        $query = new GetCourseByIdQuery($id, 'system');
        $course = $this->queryBus->handle($query);
        
        return new JsonResponse([
            'data' => $this->serializeCourse($course)
        ]);
    }
    
    public function archive(string $id): Response
    {
        $command = new ArchiveCourseCommand($id);
        $this->commandBus->handle($command);
        
        // Invalidate cache
        $this->cache->invalidateCourse(CourseId::fromString($id));
        
        return new Response(null, Response::HTTP_NO_CONTENT);
    }
    
    public function enroll(string $courseId, Request $request): JsonResponse
    {
        $data = json_decode($request->getContent(), true);
        
        $command = new EnrollUserCommand(
            $data['user_id'],
            $courseId,
            $data['enrolled_by'] ?? $data['user_id'], // Default to self-enrollment
            $data['enrollment_type'] ?? 'voluntary'
        );
        
        $enrollmentId = $this->commandBus->handle($command);
        
        return new JsonResponse([
            'data' => [
                'enrollment_id' => $enrollmentId,
                'course_id' => $courseId,
                'user_id' => $data['user_id'],
                'enrollment_type' => $data['enrollment_type'] ?? 'voluntary',
                'status' => 'active'
            ]
        ], Response::HTTP_CREATED, [
            'Location' => '/api/v1/enrollments/' . $enrollmentId
        ]);
    }
    
    private function validateCreateRequest(?array $data): array
    {
        $errors = [];
        
        if (empty($data['course_code'])) {
            $errors['course_code'] = 'Course code is required';
        }
        
        if (empty($data['title'])) {
            $errors['title'] = 'Title is required';
        }
        
        if (empty($data['description'])) {
            $errors['description'] = 'Description is required';
        }
        
        if (empty($data['duration_hours'])) {
            $errors['duration_hours'] = 'Duration is required';
        }
        
        if (empty($data['instructor_id'])) {
            $errors['instructor_id'] = 'Instructor ID is required';
        }
        
        return $errors;
    }
    
    private function serializeCourse($course): array
    {
        if (method_exists($course, 'toArray')) {
            return $course->toArray();
        }
        
        // For CourseDTO
        return [
            'id' => $course->id,
            'course_code' => $course->courseCode,
            'title' => $course->title,
            'description' => $course->description,
            'status' => $course->status,
            'duration_hours' => $course->durationHours,
            'metadata' => $course->metadata,
            'created_at' => $course->createdAt,
            'updated_at' => $course->updatedAt
        ];
    }
} 