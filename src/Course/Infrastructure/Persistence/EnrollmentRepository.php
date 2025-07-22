<?php

declare(strict_types=1);

namespace App\Course\Infrastructure\Persistence;

use App\Course\Domain\Entities\Enrollment;
use App\Course\Domain\Repository\EnrollmentRepositoryInterface;
use App\Course\Domain\ValueObjects\CourseId;
use Doctrine\DBAL\Connection;

class EnrollmentRepository implements EnrollmentRepositoryInterface
{
    public function __construct(
        private Connection $connection
    ) {
    }
    
    public function save(Enrollment $enrollment): void
    {
        $exists = $this->connection->fetchOne(
            "SELECT COUNT(*) FROM course_enrollments WHERE id = :id",
            ['id' => $enrollment->id()]
        ) > 0;
        
        $data = [
            'id' => $enrollment->id(),
            'course_id' => $enrollment->courseId()->value(),
            'user_id' => $enrollment->userId(),
            'status' => $enrollment->status(),
            'progress_percent' => $enrollment->progressPercent(),
            'enrolled_at' => $enrollment->enrolledAt()->format('Y-m-d H:i:s'),
            'completed_at' => $enrollment->completedAt()?->format('Y-m-d H:i:s'),
            'last_activity_at' => $enrollment->lastActivityAt()?->format('Y-m-d H:i:s'),
        ];
        
        if ($exists) {
            $this->connection->update('course_enrollments', $data, ['id' => $enrollment->id()]);
        } else {
            $this->connection->insert('course_enrollments', $data);
        }
        
        // Handle domain events if needed
        $events = $enrollment->pullDomainEvents();
        // Events would be published to message bus here
    }
    
    public function findById(string $id): ?Enrollment
    {
        $sql = "SELECT * FROM course_enrollments WHERE id = :id";
        $row = $this->connection->fetchAssociative($sql, ['id' => $id]);
        
        if ($row === false) {
            return null;
        }
        
        return $this->hydrateEnrollment($row);
    }
    
    public function findByUserAndCourse(string $userId, CourseId $courseId): ?Enrollment
    {
        $sql = "SELECT * FROM course_enrollments WHERE user_id = :user_id AND course_id = :course_id";
        $row = $this->connection->fetchAssociative($sql, [
            'user_id' => $userId,
            'course_id' => $courseId->value()
        ]);
        
        if ($row === false) {
            return null;
        }
        
        return $this->hydrateEnrollment($row);
    }
    
    public function findByUser(string $userId): array
    {
        $sql = "SELECT * FROM course_enrollments WHERE user_id = :user_id ORDER BY enrolled_at DESC";
        $rows = $this->connection->fetchAllAssociative($sql, ['user_id' => $userId]);
        
        return array_map(fn($row) => $this->hydrateEnrollment($row), $rows);
    }
    
    public function findByCourse(CourseId $courseId): array
    {
        $sql = "SELECT * FROM course_enrollments WHERE course_id = :course_id ORDER BY enrolled_at DESC";
        $rows = $this->connection->fetchAllAssociative($sql, ['course_id' => $courseId->value()]);
        
        return array_map(fn($row) => $this->hydrateEnrollment($row), $rows);
    }
    
    public function findActiveByUser(string $userId): array
    {
        $sql = "SELECT * FROM course_enrollments WHERE user_id = :user_id AND status = 'active' ORDER BY enrolled_at DESC";
        $rows = $this->connection->fetchAllAssociative($sql, ['user_id' => $userId]);
        
        return array_map(fn($row) => $this->hydrateEnrollment($row), $rows);
    }
    
    public function findCompletedByUser(string $userId): array
    {
        $sql = "SELECT * FROM course_enrollments WHERE user_id = :user_id AND status = 'completed' ORDER BY completed_at DESC";
        $rows = $this->connection->fetchAllAssociative($sql, ['user_id' => $userId]);
        
        return array_map(fn($row) => $this->hydrateEnrollment($row), $rows);
    }
    
    public function countByCourse(CourseId $courseId): int
    {
        $sql = "SELECT COUNT(*) FROM course_enrollments WHERE course_id = :course_id";
        return (int)$this->connection->fetchOne($sql, ['course_id' => $courseId->value()]);
    }
    
    public function countCompletedByCourse(CourseId $courseId): int
    {
        $sql = "SELECT COUNT(*) FROM course_enrollments WHERE course_id = :course_id AND status = 'completed'";
        return (int)$this->connection->fetchOne($sql, ['course_id' => $courseId->value()]);
    }
    
    public function exists(string $userId, CourseId $courseId): bool
    {
        $sql = "SELECT COUNT(*) FROM course_enrollments WHERE user_id = :user_id AND course_id = :course_id";
        $count = $this->connection->fetchOne($sql, [
            'user_id' => $userId,
            'course_id' => $courseId->value()
        ]);
        
        return $count > 0;
    }
    
    private function hydrateEnrollment(array $row): Enrollment
    {
        // Reconstruct enrollment from database data
        $reflection = new \ReflectionClass(Enrollment::class);
        $enrollment = $reflection->newInstanceWithoutConstructor();
        
        // Set properties via reflection
        $this->setPrivateProperty($enrollment, 'id', $row['id']);
        $this->setPrivateProperty($enrollment, 'courseId', new CourseId($row['course_id']));
        $this->setPrivateProperty($enrollment, 'userId', $row['user_id']);
        $this->setPrivateProperty($enrollment, 'status', $row['status']);
        $this->setPrivateProperty($enrollment, 'progressPercent', (int)$row['progress_percent']);
        $this->setPrivateProperty($enrollment, 'enrolledAt', new \DateTimeImmutable($row['enrolled_at']));
        
        if ($row['completed_at']) {
            $this->setPrivateProperty($enrollment, 'completedAt', new \DateTimeImmutable($row['completed_at']));
        }
        
        if ($row['last_activity_at']) {
            $this->setPrivateProperty($enrollment, 'lastActivityAt', new \DateTimeImmutable($row['last_activity_at']));
        }
        
        return $enrollment;
    }
    
    private function setPrivateProperty(object $object, string $property, mixed $value): void
    {
        $reflection = new \ReflectionClass($object);
        $property = $reflection->getProperty($property);
        $property->setAccessible(true);
        $property->setValue($object, $value);
    }
} 