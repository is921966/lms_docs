<?php

declare(strict_types=1);

namespace Learning\Infrastructure\Repository;

use Learning\Domain\Repository\EnrollmentRepositoryInterface;
use Learning\Domain\Enrollment;
use Learning\Domain\ValueObjects\EnrollmentId;
use Learning\Domain\ValueObjects\CourseId;
use Learning\Domain\ValueObjects\EnrollmentStatus;
use User\Domain\ValueObjects\UserId;

class InMemoryEnrollmentRepository implements EnrollmentRepositoryInterface
{
    /** @var array<string, Enrollment> */
    private array $enrollments = [];
    
    public function save(Enrollment $enrollment): void
    {
        $this->enrollments[$enrollment->getId()->getValue()] = $enrollment;
    }
    
    public function findById(EnrollmentId $id): ?Enrollment
    {
        return $this->enrollments[$id->getValue()] ?? null;
    }
    
    public function findByUserAndCourse(UserId $userId, CourseId $courseId): ?Enrollment
    {
        foreach ($this->enrollments as $enrollment) {
            if ($enrollment->getUserId()->getValue() === $userId->getValue() &&
                $enrollment->getCourseId()->getValue() === $courseId->getValue()) {
                return $enrollment;
            }
        }
        
        return null;
    }
    
    public function findByUser(UserId $userId, ?EnrollmentStatus $status = null): array
    {
        $enrollments = array_filter(
            $this->enrollments,
            fn(Enrollment $enrollment) => $enrollment->getUserId()->getValue() === $userId->getValue()
        );
        
        if ($status !== null) {
            $enrollments = array_filter(
                $enrollments,
                fn(Enrollment $enrollment) => $enrollment->getStatus()->value === $status->value
            );
        }
        
        return array_values($enrollments);
    }
    
    public function findByCourse(CourseId $courseId, ?EnrollmentStatus $status = null): array
    {
        $enrollments = array_filter(
            $this->enrollments,
            fn(Enrollment $enrollment) => $enrollment->getCourseId()->getValue() === $courseId->getValue()
        );
        
        if ($status !== null) {
            $enrollments = array_filter(
                $enrollments,
                fn(Enrollment $enrollment) => $enrollment->getStatus()->value === $status->value
            );
        }
        
        return array_values($enrollments);
    }
    
    public function findByStatus(EnrollmentStatus $status): array
    {
        return array_values(array_filter(
            $this->enrollments,
            fn(Enrollment $enrollment) => $enrollment->getStatus()->value === $status->value
        ));
    }
    
    public function findExpired(\DateTimeImmutable $date): array
    {
        return array_values(array_filter(
            $this->enrollments,
            function (Enrollment $enrollment) use ($date) {
                $expiryDate = $enrollment->getExpiryDate();
                return $expiryDate !== null && $expiryDate < $date && 
                       $enrollment->getStatus()->value === EnrollmentStatus::ACTIVE->value;
            }
        ));
    }
    
    public function countByCourse(CourseId $courseId, ?EnrollmentStatus $status = null): int
    {
        return count($this->findByCourse($courseId, $status));
    }
    
    public function isUserEnrolled(UserId $userId, CourseId $courseId): bool
    {
        $enrollment = $this->findByUserAndCourse($userId, $courseId);
        return $enrollment !== null && $enrollment->getStatus()->value === EnrollmentStatus::ACTIVE->value;
    }
    
    public function getUserStatistics(UserId $userId): array
    {
        $userEnrollments = array_filter(
            $this->enrollments,
            fn(Enrollment $enrollment) => $enrollment->getUserId()->getValue() === $userId->getValue()
        );
        
        $stats = [
            'total' => 0,
            'active' => 0,
            'completed' => 0,
            'cancelled' => 0
        ];
        
        foreach ($userEnrollments as $enrollment) {
            $stats['total']++;
            
            switch ($enrollment->getStatus()->value) {
                case EnrollmentStatus::ACTIVE->value:
                    $stats['active']++;
                    break;
                case EnrollmentStatus::COMPLETED->value:
                    $stats['completed']++;
                    break;
                case EnrollmentStatus::CANCELLED->value:
                    $stats['cancelled']++;
                    break;
            }
        }
        
        return $stats;
    }
    
    public function delete(Enrollment $enrollment): void
    {
        unset($this->enrollments[$enrollment->getId()->getValue()]);
    }
    
    public function getNextId(): EnrollmentId
    {
        return EnrollmentId::generate();
    }
} 