<?php

declare(strict_types=1);

namespace Tests\Unit\Learning\Infrastructure\Http\Controllers;

use App\Learning\Infrastructure\Http\Controllers\CourseController;
use App\Learning\Application\Service\CourseService;
use App\Learning\Application\DTO\CourseDTO;
use PHPUnit\Framework\TestCase;
use PHPUnit\Framework\MockObject\MockObject;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\HttpFoundation\JsonResponse;

class CourseControllerTest extends TestCase
{
    private CourseService&MockObject $courseService;
    private CourseController $controller;
    
    protected function setUp(): void
    {
        $this->courseService = $this->createMock(CourseService::class);
        $this->controller = new CourseController($this->courseService);
    }
    
    public function testCanGetCourse(): void
    {
        $courseId = 'c1d2e3f4-a5b6-4789-0123-456789abcdef';
        $courseDto = $this->createCourseDto($courseId);
        
        $this->courseService
            ->expects($this->once())
            ->method('findById')
            ->with($courseId)
            ->willReturn($courseDto);
        
        $response = $this->controller->show($courseId);
        
        $this->assertInstanceOf(JsonResponse::class, $response);
        $this->assertEquals(Response::HTTP_OK, $response->getStatusCode());
        
        $data = json_decode($response->getContent(), true);
        $this->assertEquals($courseId, $data['data']['id']);
        $this->assertEquals('Test Course', $data['data']['title']);
    }
    
    public function testReturns404WhenCourseNotFound(): void
    {
        $courseId = 'nonexistent-id';
        
        $this->courseService
            ->expects($this->once())
            ->method('findById')
            ->with($courseId)
            ->willReturn(null);
        
        $response = $this->controller->show($courseId);
        
        $this->assertEquals(Response::HTTP_NOT_FOUND, $response->getStatusCode());
        
        $data = json_decode($response->getContent(), true);
        $this->assertEquals('Course not found', $data['error']);
    }
    
    public function testCanCreateCourse(): void
    {
        $requestData = [
            'code' => 'CRS-001',
            'title' => 'New Course',
            'description' => 'Course Description',
            'type' => 'online',
            'durationHours' => 40,
            'tags' => ['tag1', 'tag2']
        ];
        
        $courseDto = $this->createCourseDto('new-course-id', $requestData);
        
        $this->courseService
            ->expects($this->once())
            ->method('create')
            ->with($this->isInstanceOf(CourseDTO::class))
            ->willReturn($courseDto);
        
        $request = Request::create('/', 'POST', [], [], [], [], json_encode($requestData));
        $response = $this->controller->create($request);
        
        $this->assertEquals(Response::HTTP_CREATED, $response->getStatusCode());
        
        $data = json_decode($response->getContent(), true);
        $this->assertEquals('new-course-id', $data['data']['id']);
    }
    
    public function testCanUpdateCourse(): void
    {
        $courseId = 'c1d2e3f4-a5b6-4789-0123-456789abcdef';
        $updateData = [
            'title' => 'Updated Title',
            'description' => 'Updated Description'
        ];
        
        $updatedDto = $this->createCourseDto($courseId, $updateData);
        
        $this->courseService
            ->expects($this->once())
            ->method('update')
            ->with($courseId, $updateData)
            ->willReturn($updatedDto);
        
        $request = Request::create('/', 'PUT', [], [], [], [], json_encode($updateData));
        $response = $this->controller->update($courseId, $request);
        
        $this->assertEquals(Response::HTTP_OK, $response->getStatusCode());
    }
    
    public function testCanListPublishedCourses(): void
    {
        $courses = [
            $this->createCourseDto('id1'),
            $this->createCourseDto('id2')
        ];
        
        $this->courseService
            ->expects($this->once())
            ->method('findPublished')
            ->with(10, 0)
            ->willReturn($courses);
        
        $request = Request::create('/', 'GET', ['limit' => 10, 'offset' => 0]);
        $response = $this->controller->index($request);
        
        $this->assertEquals(Response::HTTP_OK, $response->getStatusCode());
        
        $data = json_decode($response->getContent(), true);
        $this->assertCount(2, $data['data']);
    }
    
    public function testCanPublishCourse(): void
    {
        $courseId = 'c1d2e3f4-a5b6-4789-0123-456789abcdef';
        
        $this->courseService
            ->expects($this->once())
            ->method('publish')
            ->with($courseId)
            ->willReturn(true);
        
        $response = $this->controller->publish($courseId);
        
        $this->assertEquals(Response::HTTP_OK, $response->getStatusCode());
        
        $data = json_decode($response->getContent(), true);
        $this->assertEquals('Course published successfully', $data['message']);
    }
    
    public function testHandlesExceptionGracefully(): void
    {
        $courseId = 'test-id';
        
        $this->courseService
            ->expects($this->once())
            ->method('findById')
            ->willThrowException(new \Exception('Database error'));
        
        $response = $this->controller->show($courseId);
        
        $this->assertEquals(Response::HTTP_INTERNAL_SERVER_ERROR, $response->getStatusCode());
        
        $data = json_decode($response->getContent(), true);
        $this->assertEquals('Internal server error', $data['error']);
    }
    
    private function createCourseDto(string $id, array $overrides = []): CourseDTO
    {
        return new CourseDTO(
            id: $id,
            code: $overrides['code'] ?? 'CRS-001',
            title: $overrides['title'] ?? 'Test Course',
            description: $overrides['description'] ?? 'Test Description',
            type: $overrides['type'] ?? 'online',
            status: $overrides['status'] ?? 'draft',
            durationHours: $overrides['durationHours'] ?? 40,
            maxStudents: null,
            price: null,
            tags: $overrides['tags'] ?? [],
            prerequisites: [],
            imageUrl: null,
            createdAt: '2024-01-01T00:00:00+00:00',
            updatedAt: '2024-01-01T00:00:00+00:00'
        );
    }
} 