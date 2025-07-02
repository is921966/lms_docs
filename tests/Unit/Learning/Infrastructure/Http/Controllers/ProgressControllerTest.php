<?php

declare(strict_types=1);

namespace Tests\Unit\Learning\Infrastructure\Http\Controllers;

use Learning\Infrastructure\Http\Controllers\ProgressController;
use Learning\Application\Service\ProgressService;
use Learning\Application\DTO\ProgressDTO;
use PHPUnit\Framework\TestCase;
use PHPUnit\Framework\MockObject\MockObject;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\HttpFoundation\JsonResponse;

class ProgressControllerTest extends TestCase
{
    private ProgressService&MockObject $progressService;
    private ProgressController $controller;
    
    protected function setUp(): void
    {
        $this->progressService = $this->createMock(ProgressService::class);
        $this->controller = new ProgressController($this->progressService);
    }
    
    public function testCanStartLesson(): void
    {
        $requestData = [
            'userId' => 'f47ac10b-58cc-4372-a567-0e02b2c3d479',
            'courseId' => 'c1d2e3f4-a5b6-4789-0123-456789abcdef',
            'lessonId' => 'l1d2e3f4-a5b6-4789-0123-456789abcdef'
        ];
        
        $progressDto = $this->createProgressDto();
        
        $this->progressService
            ->expects($this->once())
            ->method('startLesson')
            ->with($requestData['userId'], $requestData['courseId'], $requestData['lessonId'])
            ->willReturn($progressDto);
        
        $request = Request::create('/', 'POST', [], [], [], [], json_encode($requestData));
        $response = $this->controller->startLesson($request);
        
        $this->assertEquals(Response::HTTP_OK, $response->getStatusCode());
        
        $data = json_decode($response->getContent(), true);
        $this->assertEquals('in_progress', $data['data']['status']);
    }
    
    public function testCanGetEnrollmentProgress(): void
    {
        $enrollmentId = 'e1d2e3f4-a5b6-4789-0123-456789abcdef';
        $progresses = [
            $this->createProgressDto(),
            $this->createProgressDto()
        ];
        
        $this->progressService
            ->expects($this->once())
            ->method('getEnrollmentProgress')
            ->with($enrollmentId)
            ->willReturn($progresses);
        
        $response = $this->controller->enrollmentProgress($enrollmentId);
        
        $this->assertEquals(Response::HTTP_OK, $response->getStatusCode());
        
        $data = json_decode($response->getContent(), true);
        $this->assertCount(2, $data['data']);
    }
    
    public function testCanCompleteLesson(): void
    {
        $requestData = [
            'enrollmentId' => 'e1d2e3f4-a5b6-4789-0123-456789abcdef',
            'lessonId' => 'l1d2e3f4-a5b6-4789-0123-456789abcdef',
            'score' => 90.0
        ];
        
        $this->progressService
            ->expects($this->once())
            ->method('completeLesson')
            ->with($requestData['enrollmentId'], $requestData['lessonId'], $requestData['score'])
            ->willReturn(true);
        
        $request = Request::create('/', 'POST', [], [], [], [], json_encode($requestData));
        $response = $this->controller->completeLesson($request);
        
        $this->assertEquals(Response::HTTP_OK, $response->getStatusCode());
        
        $data = json_decode($response->getContent(), true);
        $this->assertEquals('Lesson completed successfully', $data['message']);
    }
    
    private function createProgressDto(): ProgressDTO
    {
        return new ProgressDTO(
            id: 'progress-123',
            enrollmentId: 'e1d2e3f4-a5b6-4789-0123-456789abcdef',
            lessonId: 'l1d2e3f4-a5b6-4789-0123-456789abcdef',
            status: 'in_progress',
            percentage: 0.0,
            score: null,
            highestScore: null,
            attemptCount: 1,
            timeSpentMinutes: 0,
            startedAt: '2024-01-01T00:00:00+00:00',
            completedAt: null,
            failedAt: null,
            createdAt: '2024-01-01T00:00:00+00:00',
            updatedAt: '2024-01-01T00:00:00+00:00'
        );
    }
} 