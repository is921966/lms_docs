<?php

declare(strict_types=1);

namespace Tests\Unit\Learning\Application\Service;

use Learning\Application\Service\ProgressService;
use Learning\Application\DTO\ProgressDTO;
use Learning\Domain\Progress;
use Learning\Domain\Repository\ProgressRepositoryInterface;
use Learning\Domain\Repository\EnrollmentRepositoryInterface;
use Learning\Domain\Enrollment;
use Learning\Domain\ValueObjects\EnrollmentId;
use Learning\Domain\ValueObjects\LessonId;
use Learning\Domain\ValueObjects\CourseId;
use User\Domain\ValueObjects\UserId;
use PHPUnit\Framework\TestCase;
use PHPUnit\Framework\MockObject\MockObject;

class ProgressServiceTest extends TestCase
{
    private ProgressRepositoryInterface&MockObject $progressRepository;
    private EnrollmentRepositoryInterface&MockObject $enrollmentRepository;
    private ProgressService $service;
    
    protected function setUp(): void
    {
        $this->progressRepository = $this->createMock(ProgressRepositoryInterface::class);
        $this->enrollmentRepository = $this->createMock(EnrollmentRepositoryInterface::class);
        $this->service = new ProgressService(
            $this->progressRepository,
            $this->enrollmentRepository
        );
    }
    
    public function testCanStartLessonProgress(): void
    {
        $userId = UserId::generate();
        $courseId = CourseId::generate();
        $lessonId = LessonId::generate();
        $enrollmentId = EnrollmentId::generate();
        
        $enrollment = $this->createActiveEnrollment($userId, $courseId, $enrollmentId);
        
        $this->enrollmentRepository
            ->expects($this->once())
            ->method('findByUserAndCourse')
            ->with($userId, $courseId)
            ->willReturn($enrollment);
        
        $this->progressRepository
            ->expects($this->once())
            ->method('findByEnrollmentAndLesson')
            ->with($enrollmentId, $lessonId)
            ->willReturn(null);
        
        $this->progressRepository
            ->expects($this->once())
            ->method('save')
            ->with($this->isInstanceOf(Progress::class));
        
        $dto = $this->service->startLesson(
            $userId->getValue(),
            $courseId->getValue(),
            $lessonId->getValue()
        );
        
        $this->assertInstanceOf(ProgressDTO::class, $dto);
        $this->assertEquals($enrollmentId->getValue(), $dto->enrollmentId);
        $this->assertEquals($lessonId->getValue(), $dto->lessonId);
        $this->assertEquals('in_progress', $dto->status);
    }
    
    public function testCanUpdateProgress(): void
    {
        $enrollmentId = EnrollmentId::generate();
        $lessonId = LessonId::generate();
        $progress = $this->createTestProgress($enrollmentId, $lessonId);
        $progress->start();
        
        $this->progressRepository
            ->expects($this->once())
            ->method('findByEnrollmentAndLesson')
            ->with($enrollmentId, $lessonId)
            ->willReturn($progress);
        
        $this->progressRepository
            ->expects($this->once())
            ->method('save')
            ->with($progress);
        
        $result = $this->service->updateProgress(
            $enrollmentId->getValue(),
            $lessonId->getValue(),
            75.5
        );
        
        $this->assertTrue($result);
    }
    
    public function testCanCompleteLesson(): void
    {
        $enrollmentId = EnrollmentId::generate();
        $lessonId = LessonId::generate();
        $progress = $this->createTestProgress($enrollmentId, $lessonId);
        $progress->start();
        
        $this->progressRepository
            ->expects($this->once())
            ->method('findByEnrollmentAndLesson')
            ->with($enrollmentId, $lessonId)
            ->willReturn($progress);
        
        $this->progressRepository
            ->expects($this->once())
            ->method('save')
            ->with($progress);
        
        $result = $this->service->completeLesson(
            $enrollmentId->getValue(),
            $lessonId->getValue(),
            90.0
        );
        
        $this->assertTrue($result);
    }
    
    public function testCanGetEnrollmentProgress(): void
    {
        $enrollmentId = EnrollmentId::generate();
        $progresses = [
            $this->createTestProgress($enrollmentId, LessonId::generate()),
            $this->createTestProgress($enrollmentId, LessonId::generate())
        ];
        
        $this->progressRepository
            ->expects($this->once())
            ->method('findByEnrollment')
            ->with($enrollmentId)
            ->willReturn($progresses);
        
        $dtos = $this->service->getEnrollmentProgress($enrollmentId->getValue());
        
        $this->assertCount(2, $dtos);
        $this->assertContainsOnlyInstancesOf(ProgressDTO::class, $dtos);
    }
    
    public function testThrowsExceptionWhenEnrollmentNotFound(): void
    {
        $userId = UserId::generate();
        $courseId = CourseId::generate();
        $lessonId = LessonId::generate();
        
        $this->enrollmentRepository
            ->expects($this->once())
            ->method('findByUserAndCourse')
            ->willReturn(null);
        
        $this->expectException(\Common\Exceptions\NotFoundException::class);
        $this->expectExceptionMessage('Enrollment not found');
        
        $this->service->startLesson(
            $userId->getValue(),
            $courseId->getValue(),
            $lessonId->getValue()
        );
    }
    
    public function testThrowsExceptionWhenEnrollmentNotActive(): void
    {
        $userId = UserId::generate();
        $courseId = CourseId::generate();
        $lessonId = LessonId::generate();
        
        $enrollment = Enrollment::create($userId, $courseId, $userId);
        // Enrollment is PENDING by default, not ACTIVE
        
        $this->enrollmentRepository
            ->expects($this->once())
            ->method('findByUserAndCourse')
            ->willReturn($enrollment);
        
        $this->expectException(\Common\Exceptions\BusinessLogicException::class);
        $this->expectExceptionMessage('Enrollment is not active');
        
        $this->service->startLesson(
            $userId->getValue(),
            $courseId->getValue(),
            $lessonId->getValue()
        );
    }
    
    private function createActiveEnrollment(UserId $userId, CourseId $courseId, EnrollmentId $enrollmentId): Enrollment
    {
        $enrollment = Enrollment::create($userId, $courseId, $userId);
        $enrollment->activate();
        
        // Use reflection to set the ID
        $reflection = new \ReflectionClass($enrollment);
        $property = $reflection->getProperty('id');
        $property->setAccessible(true);
        $property->setValue($enrollment, $enrollmentId);
        
        return $enrollment;
    }
    
    private function createTestProgress(EnrollmentId $enrollmentId, LessonId $lessonId): Progress
    {
        return Progress::create($enrollmentId, $lessonId);
    }
} 