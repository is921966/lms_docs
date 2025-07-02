<?php

declare(strict_types=1);

namespace Tests\Unit\Learning\Application\Service;

use Learning\Application\Service\EnrollmentService;
use Learning\Application\DTO\EnrollmentDTO;
use Learning\Domain\Enrollment;
use Learning\Domain\Repository\EnrollmentRepositoryInterface;
use Learning\Domain\Repository\CourseRepositoryInterface;
use Learning\Domain\Course;
use Learning\Domain\ValueObjects\CourseId;
use Learning\Domain\ValueObjects\CourseCode;
use Learning\Domain\ValueObjects\Duration;
use User\Domain\ValueObjects\UserId;
use PHPUnit\Framework\TestCase;
use PHPUnit\Framework\MockObject\MockObject;

class EnrollmentServiceTest extends TestCase
{
    private EnrollmentRepositoryInterface&MockObject $enrollmentRepository;
    private CourseRepositoryInterface&MockObject $courseRepository;
    private EnrollmentService $service;
    
    protected function setUp(): void
    {
        $this->enrollmentRepository = $this->createMock(EnrollmentRepositoryInterface::class);
        $this->courseRepository = $this->createMock(CourseRepositoryInterface::class);
        $this->service = new EnrollmentService(
            $this->enrollmentRepository,
            $this->courseRepository
        );
    }
    
    public function testCanEnrollUserInCourse(): void
    {
        $userId = UserId::generate();
        $courseId = CourseId::generate();
        $course = $this->createTestCourse();
        
        $this->courseRepository
            ->expects($this->once())
            ->method('findById')
            ->with($courseId)
            ->willReturn($course);
        
        $this->enrollmentRepository
            ->expects($this->once())
            ->method('findByUserAndCourse')
            ->with($userId, $courseId)
            ->willReturn(null);
        
        $this->enrollmentRepository
            ->expects($this->once())
            ->method('save')
            ->with($this->isInstanceOf(Enrollment::class));
        
        $dto = $this->service->enroll($userId->getValue(), $courseId->getValue());
        
        $this->assertInstanceOf(EnrollmentDTO::class, $dto);
        $this->assertEquals($userId->getValue(), $dto->userId);
        $this->assertEquals($courseId->getValue(), $dto->courseId);
        $this->assertEquals('active', $dto->status); // Self-enrollment activates automatically
    }
    
    public function testCannotEnrollTwice(): void
    {
        $userId = UserId::generate();
        $courseId = CourseId::generate();
        $course = $this->createTestCourse();
        $existingEnrollment = $this->createTestEnrollment($userId, $courseId);
        
        $this->courseRepository
            ->expects($this->once())
            ->method('findById')
            ->with($courseId)
            ->willReturn($course);
        
        $this->enrollmentRepository
            ->expects($this->once())
            ->method('findByUserAndCourse')
            ->willReturn($existingEnrollment);
        
        $this->expectException(\Common\Exceptions\BusinessLogicException::class);
        $this->expectExceptionMessage('already enrolled');
        
        $this->service->enroll($userId->getValue(), $courseId->getValue());
    }
    
    public function testCanCompleteEnrollment(): void
    {
        $userId = UserId::generate();
        $courseId = CourseId::generate();
        $enrollment = $this->createTestEnrollment($userId, $courseId);
        $enrollment->activate(); // Must be active to complete
        
        $this->enrollmentRepository
            ->expects($this->once())
            ->method('findByUserAndCourse')
            ->willReturn($enrollment);
        
        $this->enrollmentRepository
            ->expects($this->once())
            ->method('save')
            ->with($enrollment);
        
        $result = $this->service->complete($userId->getValue(), $courseId->getValue(), 85.0);
        
        $this->assertTrue($result);
    }
    
    public function testCanFindUserEnrollments(): void
    {
        $userId = UserId::generate();
        $enrollments = [
            $this->createTestEnrollment($userId, CourseId::generate()),
            $this->createTestEnrollment($userId, CourseId::generate())
        ];
        
        $this->enrollmentRepository
            ->expects($this->once())
            ->method('findByUser')
            ->with($userId, null)
            ->willReturn($enrollments);
        
        $dtos = $this->service->findUserEnrollments($userId->getValue());
        
        $this->assertCount(2, $dtos);
        $this->assertContainsOnlyInstancesOf(EnrollmentDTO::class, $dtos);
    }
    
    public function testCanCancelEnrollment(): void
    {
        $userId = UserId::generate();
        $courseId = CourseId::generate();
        $enrollment = $this->createTestEnrollment($userId, $courseId);
        
        $this->enrollmentRepository
            ->expects($this->once())
            ->method('findByUserAndCourse')
            ->willReturn($enrollment);
        
        $this->enrollmentRepository
            ->expects($this->once())
            ->method('save')
            ->with($enrollment);
        
        $result = $this->service->cancel($userId->getValue(), $courseId->getValue(), 'Violation of terms');
        
        $this->assertTrue($result);
    }
    
    public function testThrowsExceptionWhenEnrollmentNotFound(): void
    {
        $userId = UserId::generate();
        $courseId = CourseId::generate();
        
        $this->enrollmentRepository
            ->expects($this->once())
            ->method('findByUserAndCourse')
            ->willReturn(null);
        
        $this->expectException(\Common\Exceptions\NotFoundException::class);
        
        $this->service->complete($userId->getValue(), $courseId->getValue(), 80.0);
    }
    
    private function createTestCourse(): Course
    {
        return Course::create(
            id: CourseId::generate(),
            code: CourseCode::fromString('CRS-001'),
            title: 'Test Course',
            description: 'Test Description',
            duration: Duration::fromHours(40)
        );
    }
    
    private function createTestEnrollment(UserId $userId, CourseId $courseId): Enrollment
    {
        return Enrollment::create(
            userId: $userId,
            courseId: $courseId,
            enrolledBy: $userId // Self-enrollment
        );
    }
} 