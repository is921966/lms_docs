<?php

declare(strict_types=1);

namespace App\Course\Application\Services;

use App\Common\Exceptions\InvalidArgumentException;
use App\Course\Application\DTO\EnrollmentDTO;
use App\Course\Domain\Entities\Enrollment;
use App\Course\Domain\Repository\CourseRepositoryInterface;
use App\Course\Domain\Repository\EnrollmentRepositoryInterface;
use App\Course\Domain\ValueObjects\CourseId;

class EnrollmentService
{
    public function __construct(
        private CourseRepositoryInterface $courseRepository,
        private EnrollmentRepositoryInterface $enrollmentRepository
    ) {
    }
    
    public function enrollUser(string $userId, string $courseIdString): EnrollmentDTO
    {
        $courseId = new CourseId($courseIdString);
        
        // Check if course exists
        $course = $this->courseRepository->findById($courseId);
        if ($course === null) {
            throw new InvalidArgumentException('Course not found');
        }
        
        // Check if course is published
        if (!$course->isPublished()) {
            throw new InvalidArgumentException('Can only enroll in published courses');
        }
        
        // Check if already enrolled
        if ($this->enrollmentRepository->exists($userId, $courseId)) {
            throw new InvalidArgumentException('User is already enrolled in this course');
        }
        
        // Create enrollment
        $enrollment = new Enrollment($courseId, $userId);
        
        $this->enrollmentRepository->save($enrollment);
        
        return $this->mapToDTO($enrollment, $course->title(), $course->code()->value());
    }
    
    public function updateProgress(string $userId, string $courseIdString, int $progressPercent): void
    {
        $courseId = new CourseId($courseIdString);
        
        $enrollment = $this->enrollmentRepository->findByUserAndCourse($userId, $courseId);
        if ($enrollment === null) {
            throw new InvalidArgumentException('Enrollment not found');
        }
        
        $enrollment->updateProgress($progressPercent);
        
        $this->enrollmentRepository->save($enrollment);
    }
    
    public function completeCourse(string $userId, string $courseIdString): void
    {
        $courseId = new CourseId($courseIdString);
        
        $enrollment = $this->enrollmentRepository->findByUserAndCourse($userId, $courseId);
        if ($enrollment === null) {
            throw new InvalidArgumentException('Enrollment not found');
        }
        
        $enrollment->complete();
        
        $this->enrollmentRepository->save($enrollment);
    }
    
    public function suspendEnrollment(string $userId, string $courseIdString): void
    {
        $courseId = new CourseId($courseIdString);
        
        $enrollment = $this->enrollmentRepository->findByUserAndCourse($userId, $courseId);
        if ($enrollment === null) {
            throw new InvalidArgumentException('Enrollment not found');
        }
        
        $enrollment->suspend();
        
        $this->enrollmentRepository->save($enrollment);
    }
    
    public function resumeEnrollment(string $userId, string $courseIdString): void
    {
        $courseId = new CourseId($courseIdString);
        
        $enrollment = $this->enrollmentRepository->findByUserAndCourse($userId, $courseId);
        if ($enrollment === null) {
            throw new InvalidArgumentException('Enrollment not found');
        }
        
        $enrollment->resume();
        
        $this->enrollmentRepository->save($enrollment);
    }
    
    /**
     * @return EnrollmentDTO[]
     */
    public function getUserEnrollments(string $userId): array
    {
        $enrollments = $this->enrollmentRepository->findByUser($userId);
        
        return array_map(
            function (Enrollment $enrollment) {
                $course = $this->courseRepository->findById($enrollment->courseId());
                return $this->mapToDTO(
                    $enrollment,
                    $course?->title() ?? 'Unknown Course',
                    $course?->code()->value() ?? 'UNKNOWN'
                );
            },
            $enrollments
        );
    }
    
    /**
     * @return EnrollmentDTO[]
     */
    public function getCourseEnrollments(string $courseIdString): array
    {
        $courseId = new CourseId($courseIdString);
        $course = $this->courseRepository->findById($courseId);
        
        if ($course === null) {
            throw new InvalidArgumentException('Course not found');
        }
        
        $enrollments = $this->enrollmentRepository->findByCourse($courseId);
        
        return array_map(
            fn (Enrollment $enrollment) => $this->mapToDTO(
                $enrollment,
                $course->title(),
                $course->code()->value()
            ),
            $enrollments
        );
    }
    
    private function mapToDTO(Enrollment $enrollment, string $courseTitle, string $courseCode): EnrollmentDTO
    {
        return new EnrollmentDTO(
            id: $enrollment->id(),
            courseId: $enrollment->courseId()->value(),
            courseTitle: $courseTitle,
            courseCode: $courseCode,
            userId: $enrollment->userId(),
            status: $enrollment->status(),
            progressPercent: $enrollment->progressPercent(),
            enrolledAt: $enrollment->enrolledAt()->format('Y-m-d H:i:s'),
            completedAt: $enrollment->completedAt()?->format('Y-m-d H:i:s'),
            lastActivityAt: $enrollment->lastActivityAt()?->format('Y-m-d H:i:s')
        );
    }
} 