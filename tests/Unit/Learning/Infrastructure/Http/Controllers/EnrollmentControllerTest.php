<?php

declare(strict_types=1);

namespace Tests\Unit\Learning\Infrastructure\Http\Controllers;

use App\Learning\Infrastructure\Http\Controllers\EnrollmentController;
use App\Learning\Application\Service\EnrollmentService;
use App\Learning\Application\DTO\EnrollmentDTO;
use PHPUnit\Framework\TestCase;
use PHPUnit\Framework\MockObject\MockObject;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\HttpFoundation\JsonResponse;

class EnrollmentControllerTest extends TestCase
{
    private EnrollmentService&MockObject $enrollmentService;
    private EnrollmentController $controller;
    
    protected function setUp(): void
    {
        $this->enrollmentService = $this->createMock(EnrollmentService::class);
        $this->controller = new EnrollmentController($this->enrollmentService);
    }
    
    public function testCanEnrollUser(): void
    {
        $requestData = [
            'userId' => 'f47ac10b-58cc-4372-a567-0e02b2c3d479',
            'courseId' => 'c1d2e3f4-a5b6-4789-0123-456789abcdef'
        ];
        
        $enrollmentDto = $this->createEnrollmentDto($requestData['userId'], $requestData['courseId']);
        
        $this->enrollmentService
            ->expects($this->once())
            ->method('enroll')
            ->with($requestData['userId'], $requestData['courseId'], null)
            ->willReturn($enrollmentDto);
        
        $request = Request::create('/', 'POST', [], [], [], [], json_encode($requestData));
        $response = $this->controller->enroll($request);
        
        $this->assertEquals(Response::HTTP_CREATED, $response->getStatusCode());
        
        $data = json_decode($response->getContent(), true);
        $this->assertEquals($requestData['userId'], $data['data']['userId']);
        $this->assertEquals($requestData['courseId'], $data['data']['courseId']);
    }
    
    public function testCanGetUserEnrollments(): void
    {
        $userId = 'f47ac10b-58cc-4372-a567-0e02b2c3d479';
        $enrollments = [
            $this->createEnrollmentDto($userId, 'course-1'),
            $this->createEnrollmentDto($userId, 'course-2')
        ];
        
        $this->enrollmentService
            ->expects($this->once())
            ->method('findUserEnrollments')
            ->with($userId)
            ->willReturn($enrollments);
        
        $response = $this->controller->userEnrollments($userId);
        
        $this->assertEquals(Response::HTTP_OK, $response->getStatusCode());
        
        $data = json_decode($response->getContent(), true);
        $this->assertCount(2, $data['data']);
    }
    
    public function testCanCompleteEnrollment(): void
    {
        $requestData = [
            'userId' => 'f47ac10b-58cc-4372-a567-0e02b2c3d479',
            'courseId' => 'c1d2e3f4-a5b6-4789-0123-456789abcdef',
            'score' => 85.5
        ];
        
        $this->enrollmentService
            ->expects($this->once())
            ->method('complete')
            ->with($requestData['userId'], $requestData['courseId'], $requestData['score'])
            ->willReturn(true);
        
        $request = Request::create('/', 'POST', [], [], [], [], json_encode($requestData));
        $response = $this->controller->complete($request);
        
        $this->assertEquals(Response::HTTP_OK, $response->getStatusCode());
        
        $data = json_decode($response->getContent(), true);
        $this->assertEquals('Enrollment completed successfully', $data['message']);
    }
    
    public function testCanUpdateProgress(): void
    {
        $requestData = [
            'userId' => 'f47ac10b-58cc-4372-a567-0e02b2c3d479',
            'courseId' => 'c1d2e3f4-a5b6-4789-0123-456789abcdef',
            'percentage' => 75.0
        ];
        
        $this->enrollmentService
            ->expects($this->once())
            ->method('updateProgress')
            ->with($requestData['userId'], $requestData['courseId'], $requestData['percentage'])
            ->willReturn(true);
        
        $request = Request::create('/', 'PUT', [], [], [], [], json_encode($requestData));
        $response = $this->controller->updateProgress($request);
        
        $this->assertEquals(Response::HTTP_OK, $response->getStatusCode());
    }
    
    public function testHandlesBusinessException(): void
    {
        $requestData = [
            'userId' => 'f47ac10b-58cc-4372-a567-0e02b2c3d479',
            'courseId' => 'c1d2e3f4-a5b6-4789-0123-456789abcdef'
        ];
        
        $this->enrollmentService
            ->expects($this->once())
            ->method('enroll')
            ->willThrowException(new \App\Common\Exceptions\BusinessLogicException('User is already enrolled'));
        
        $request = Request::create('/', 'POST', [], [], [], [], json_encode($requestData));
        $response = $this->controller->enroll($request);
        
        $this->assertEquals(Response::HTTP_BAD_REQUEST, $response->getStatusCode());
        
        $data = json_decode($response->getContent(), true);
        $this->assertEquals('User is already enrolled', $data['error']);
    }
    
    private function createEnrollmentDto(string $userId, string $courseId): EnrollmentDTO
    {
        return new EnrollmentDTO(
            id: 'enrollment-' . substr($userId, 0, 8),
            userId: $userId,
            courseId: $courseId,
            enrolledBy: $userId,
            status: 'active',
            progressPercentage: 0.0,
            completionScore: null,
            expiryDate: null,
            activatedAt: '2024-01-01T00:00:00+00:00',
            completedAt: null,
            cancelledAt: null,
            expiredAt: null,
            cancellationReason: null,
            createdAt: '2024-01-01T00:00:00+00:00',
            updatedAt: '2024-01-01T00:00:00+00:00'
        );
    }
} 