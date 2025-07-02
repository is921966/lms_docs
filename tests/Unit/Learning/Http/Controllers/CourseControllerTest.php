<?php

declare(strict_types=1);

namespace Tests\Unit\Learning\Http\Controllers;

use Learning\Http\Controllers\CourseController;
use Learning\Application\Commands\CreateCourseCommand;
use Learning\Application\Commands\UpdateCourseCommand;
use Learning\Application\Commands\PublishCourseCommand;
use Learning\Application\Queries\GetCourseByIdQuery;
use Learning\Application\Queries\ListCoursesQuery;
use Learning\Application\DTO\CourseDTO;
use Learning\Domain\Services\CommandBusInterface;
use Learning\Domain\Services\QueryBusInterface;
use Learning\Domain\Services\CourseCacheInterface;
use PHPUnit\Framework\TestCase;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\JsonResponse;

class CourseControllerTest extends TestCase
{
    private CommandBusInterface $commandBus;
    private QueryBusInterface $queryBus;
    private CourseCacheInterface $cache;
    private CourseController $controller;
    
    protected function setUp(): void
    {
        $this->commandBus = $this->createMock(CommandBusInterface::class);
        $this->queryBus = $this->createMock(QueryBusInterface::class);
        $this->cache = $this->createMock(CourseCacheInterface::class);
        
        $this->controller = new CourseController(
            $this->commandBus,
            $this->queryBus,
            $this->cache
        );
    }
    
    public function testListCourses(): void
    {
        // Arrange
        $request = Request::create('/api/v1/courses', 'GET', [
            'status' => 'published',
            'page' => 1,
            'limit' => 10
        ]);
        
        $courses = [
            $this->createCourseDTO('course-1', 'PHP Basics'),
            $this->createCourseDTO('course-2', 'JavaScript Advanced')
        ];
        
        $this->queryBus->expects($this->once())
            ->method('handle')
            ->with($this->isInstanceOf(ListCoursesQuery::class))
            ->willReturn($courses);
        
        // Act
        $response = $this->controller->list($request);
        
        // Assert
        $this->assertInstanceOf(JsonResponse::class, $response);
        $this->assertEquals(200, $response->getStatusCode());
        
        $data = json_decode($response->getContent(), true);
        $this->assertArrayHasKey('data', $data);
        $this->assertArrayHasKey('meta', $data);
        $this->assertCount(2, $data['data']);
    }
    
    public function testGetCourseById(): void
    {
        // Arrange
        $courseId = 'course-123';
        $courseDTO = $this->createCourseDTO($courseId, 'PHP Basics');
        
        $this->queryBus->expects($this->once())
            ->method('handle')
            ->with($this->callback(function ($query) use ($courseId) {
                return $query instanceof GetCourseByIdQuery
                    && $query->getCourseId() === $courseId;
            }))
            ->willReturn($courseDTO);
        
        // Act
        $response = $this->controller->show($courseId);
        
        // Assert
        $this->assertInstanceOf(JsonResponse::class, $response);
        $this->assertEquals(200, $response->getStatusCode());
        
        $data = json_decode($response->getContent(), true);
        $this->assertEquals($courseId, $data['data']['id']);
    }
    
    public function testGetCourseByIdNotFound(): void
    {
        // Arrange
        $courseId = 'non-existent';
        
        $this->queryBus->expects($this->once())
            ->method('handle')
            ->willReturn(null);
        
        // Act
        $response = $this->controller->show($courseId);
        
        // Assert
        $this->assertEquals(404, $response->getStatusCode());
        
        $data = json_decode($response->getContent(), true);
        $this->assertEquals('Course not found', $data['error']['message']);
    }
    
    public function testCreateCourse(): void
    {
        // Arrange
        $request = Request::create('/api/v1/courses', 'POST', [], [], [], [], json_encode([
            'course_code' => 'PHP-101',
            'title' => 'PHP Basics',
            'description' => 'Learn PHP from scratch',
            'duration_hours' => 10,
            'instructor_id' => 'instructor-123'
        ]));
        $request->headers->set('Content-Type', 'application/json');
        
        $courseId = 'course-123';
        
        $this->commandBus->expects($this->once())
            ->method('handle')
            ->with($this->isInstanceOf(CreateCourseCommand::class))
            ->willReturn($courseId);
        
        $courseDTO = $this->createCourseDTO($courseId, 'PHP Basics');
        
        $this->queryBus->expects($this->once())
            ->method('handle')
            ->willReturn($courseDTO);
        
        // Act
        $response = $this->controller->create($request);
        
        // Assert
        $this->assertEquals(201, $response->getStatusCode());
        $this->assertEquals('/api/v1/courses/' . $courseId, $response->headers->get('Location'));
        
        $data = json_decode($response->getContent(), true);
        $this->assertEquals($courseId, $data['data']['id']);
    }
    
    public function testCreateCourseValidationError(): void
    {
        // Arrange
        $request = Request::create('/api/v1/courses', 'POST', [], [], [], [], json_encode([
            'title' => 'PHP Basics' // Missing required fields
        ]));
        $request->headers->set('Content-Type', 'application/json');
        
        // Act
        $response = $this->controller->create($request);
        
        // Assert
        $this->assertEquals(400, $response->getStatusCode());
        
        $data = json_decode($response->getContent(), true);
        $this->assertArrayHasKey('errors', $data);
        $this->assertArrayHasKey('course_code', $data['errors']);
    }
    
    public function testUpdateCourse(): void
    {
        // Arrange
        $courseId = 'course-123';
        $request = Request::create('/api/v1/courses/' . $courseId, 'PUT', [], [], [], [], json_encode([
            'title' => 'PHP Advanced',
            'description' => 'Advanced PHP concepts'
        ]));
        $request->headers->set('Content-Type', 'application/json');
        
        $this->commandBus->expects($this->once())
            ->method('handle')
            ->with($this->isInstanceOf(UpdateCourseCommand::class));
        
        $courseDTO = $this->createCourseDTO($courseId, 'PHP Advanced');
        
        $this->queryBus->expects($this->once())
            ->method('handle')
            ->willReturn($courseDTO);
        
        $this->cache->expects($this->once())
            ->method('invalidateCourse');
        
        // Act
        $response = $this->controller->update($courseId, $request);
        
        // Assert
        $this->assertEquals(200, $response->getStatusCode());
        
        $data = json_decode($response->getContent(), true);
        $this->assertEquals('PHP Advanced', $data['data']['title']);
    }
    
    public function testPublishCourse(): void
    {
        // Arrange
        $courseId = 'course-123';
        $request = Request::create('/api/v1/courses/' . $courseId . '/publish', 'POST');
        
        $this->commandBus->expects($this->once())
            ->method('handle')
            ->with($this->isInstanceOf(PublishCourseCommand::class));
        
        $courseDTO = $this->createCourseDTO($courseId, 'PHP Basics', 'published');
        
        $this->queryBus->expects($this->once())
            ->method('handle')
            ->willReturn($courseDTO);
        
        $this->cache->expects($this->once())
            ->method('invalidateCourse');
        
        // Act
        $response = $this->controller->publish($courseId, $request);
        
        // Assert
        $this->assertEquals(200, $response->getStatusCode());
        
        $data = json_decode($response->getContent(), true);
        $this->assertEquals('published', $data['data']['status']);
    }
    
    public function testArchiveCourse(): void
    {
        // Arrange
        $courseId = 'course-123';
        
        $this->commandBus->expects($this->once())
            ->method('handle')
            ->with($this->callback(function ($command) use ($courseId) {
                return $command->getCourseId() === $courseId;
            }));
        
        $this->cache->expects($this->once())
            ->method('invalidateCourse');
        
        // Act
        $response = $this->controller->archive($courseId);
        
        // Assert
        $this->assertEquals(204, $response->getStatusCode());
    }
    
    public function testEnrollInCourse(): void
    {
        // Arrange
        $courseId = 'course-123';
        $request = Request::create('/api/v1/courses/' . $courseId . '/enroll', 'POST', [], [], [], [], json_encode([
            'user_id' => 'user-456',
            'enrollment_type' => 'voluntary'
        ]));
        $request->headers->set('Content-Type', 'application/json');
        
        $enrollmentId = 'enrollment-789';
        
        $this->commandBus->expects($this->once())
            ->method('handle')
            ->willReturn($enrollmentId);
        
        // Act
        $response = $this->controller->enroll($courseId, $request);
        
        // Assert
        $this->assertEquals(201, $response->getStatusCode());
        $this->assertEquals('/api/v1/enrollments/' . $enrollmentId, $response->headers->get('Location'));
        
        $data = json_decode($response->getContent(), true);
        $this->assertEquals($enrollmentId, $data['data']['enrollment_id']);
    }
    
    private function createCourseDTO(string $id, string $title, string $status = 'draft'): CourseDTO
    {
        return new CourseDTO(
            id: $id,
            courseCode: 'PHP-101',
            title: $title,
            description: 'Description',
            durationHours: 10,
            instructorId: 'instructor-123',
            status: $status,
            metadata: ['some' => 'data'],
            createdAt: (new \DateTimeImmutable())->format('c'),
            updatedAt: null
        );
    }
} 