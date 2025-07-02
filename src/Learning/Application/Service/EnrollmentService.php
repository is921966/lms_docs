<?php

declare(strict_types=1);

namespace Learning\Application\Service;

use Common\Exceptions\BusinessLogicException;
use Common\Exceptions\NotFoundException;
use Learning\Application\DTO\EnrollmentDTO;
use Learning\Domain\Enrollment;
use Learning\Domain\Repository\EnrollmentRepositoryInterface;
use Learning\Domain\Repository\CourseRepositoryInterface;
use Learning\Domain\ValueObjects\CourseId;
use User\Domain\ValueObjects\UserId;

class EnrollmentService
{
    public function __construct(
        private readonly EnrollmentRepositoryInterface $enrollmentRepository,
        private readonly CourseRepositoryInterface $courseRepository
    ) {}
    
    public function enroll(string $userId, string $courseId, ?string $enrolledById = null): EnrollmentDTO
    {
        $userIdVO = UserId::fromString($userId);
        $courseIdVO = CourseId::fromString($courseId);
        $enrolledByVO = $enrolledById ? UserId::fromString($enrolledById) : $userIdVO;
        
        // Check if course exists
        $course = $this->courseRepository->findById($courseIdVO);
        if (!$course) {
            throw new NotFoundException("Course with ID {$courseId} not found");
        }
        
        // Check if already enrolled
        $existingEnrollment = $this->enrollmentRepository->findByUserAndCourse($userIdVO, $courseIdVO);
        if ($existingEnrollment) {
            throw new BusinessLogicException("User is already enrolled in this course");
        }
        
        $enrollment = Enrollment::create(
            userId: $userIdVO,
            courseId: $courseIdVO,
            enrolledBy: $enrolledByVO
        );
        
        // Automatically activate for self-enrollment
        if ($userId === ($enrolledById ?? $userId)) {
            $enrollment->activate();
        }
        
        $this->enrollmentRepository->save($enrollment);
        
        return EnrollmentDTO::fromEntity($enrollment);
    }
    
    public function complete(string $userId, string $courseId, float $completionScore): bool
    {
        $enrollment = $this->findEnrollment($userId, $courseId);
        
        $enrollment->complete($completionScore);
        $this->enrollmentRepository->save($enrollment);
        
        return true;
    }
    
    public function cancel(string $userId, string $courseId, string $reason): bool
    {
        $enrollment = $this->findEnrollment($userId, $courseId);
        
        $enrollment->cancel($reason);
        $this->enrollmentRepository->save($enrollment);
        
        return true;
    }
    
    public function activate(string $userId, string $courseId): bool
    {
        $enrollment = $this->findEnrollment($userId, $courseId);
        
        $enrollment->activate();
        $this->enrollmentRepository->save($enrollment);
        
        return true;
    }
    
    public function findUserEnrollments(string $userId): array
    {
        $userIdVO = UserId::fromString($userId);
        $enrollments = $this->enrollmentRepository->findByUser($userIdVO);
        
        return array_map(
            fn(Enrollment $enrollment) => EnrollmentDTO::fromEntity($enrollment),
            $enrollments
        );
    }
    
    public function findCourseEnrollments(string $courseId): array
    {
        $courseIdVO = CourseId::fromString($courseId);
        $enrollments = $this->enrollmentRepository->findByCourse($courseIdVO);
        
        return array_map(
            fn(Enrollment $enrollment) => EnrollmentDTO::fromEntity($enrollment),
            $enrollments
        );
    }
    
    public function updateProgress(string $userId, string $courseId, float $percentage): bool
    {
        $enrollment = $this->findEnrollment($userId, $courseId);
        
        $enrollment->updateProgress($percentage);
        $this->enrollmentRepository->save($enrollment);
        
        return true;
    }
    
    private function findEnrollment(string $userId, string $courseId): Enrollment
    {
        $userIdVO = UserId::fromString($userId);
        $courseIdVO = CourseId::fromString($courseId);
        
        $enrollment = $this->enrollmentRepository->findByUserAndCourse($userIdVO, $courseIdVO);
        
        if (!$enrollment) {
            throw new NotFoundException("Enrollment not found for user {$userId} and course {$courseId}");
        }
        
        return $enrollment;
    }
} 