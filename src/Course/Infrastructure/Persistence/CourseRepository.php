<?php

declare(strict_types=1);

namespace App\Course\Infrastructure\Persistence;

use App\Course\Domain\Entities\Course;
use App\Course\Domain\Repository\CourseRepositoryInterface;
use App\Course\Domain\ValueObjects\CourseId;
use App\Course\Domain\ValueObjects\CourseCode;
use App\Course\Domain\ValueObjects\Duration;
use App\Course\Domain\ValueObjects\Price;
use Doctrine\DBAL\Connection;

class CourseRepository implements CourseRepositoryInterface
{
    public function __construct(
        private Connection $connection
    ) {
    }
    
    public function save(Course $course): void
    {
        $exists = $this->exists($course->id());
        
        $data = [
            'id' => $course->id()->value(),
            'code' => $course->code()->value(),
            'title' => $course->title(),
            'description' => $course->description(),
            'duration_minutes' => $course->duration()->inMinutes(),
            'price_amount' => $course->price()->amount(),
            'price_currency' => $course->price()->currency(),
            'status' => $course->status(),
            'created_at' => $course->createdAt()->format('Y-m-d H:i:s'),
            'published_at' => $course->publishedAt()?->format('Y-m-d H:i:s'),
            'archived_at' => null, // Will be set when needed
        ];
        
        if ($exists) {
            // Update existing course
            $this->connection->update('courses', $data, ['id' => $course->id()->value()]);
        } else {
            // Insert new course
            $this->connection->insert('courses', $data);
        }
        
        // Handle domain events if needed
        $events = $course->pullDomainEvents();
        // Events would be published to message bus here
    }
    
    public function findById(CourseId $id): ?Course
    {
        $sql = "SELECT * FROM courses WHERE id = :id";
        $row = $this->connection->fetchAssociative($sql, ['id' => $id->value()]);
        
        if ($row === false) {
            return null;
        }
        
        return $this->hydrateCourse($row);
    }
    
    public function findByCode(CourseCode $code): ?Course
    {
        $sql = "SELECT * FROM courses WHERE code = :code";
        $row = $this->connection->fetchAssociative($sql, ['code' => $code->value()]);
        
        if ($row === false) {
            return null;
        }
        
        return $this->hydrateCourse($row);
    }
    
    public function findAll(): array
    {
        $sql = "SELECT * FROM courses ORDER BY created_at DESC";
        $rows = $this->connection->fetchAllAssociative($sql);
        
        return array_map(fn($row) => $this->hydrateCourse($row), $rows);
    }
    
    public function findPublished(): array
    {
        $sql = "SELECT * FROM courses WHERE status = 'published' ORDER BY published_at DESC";
        $rows = $this->connection->fetchAllAssociative($sql);
        
        return array_map(fn($row) => $this->hydrateCourse($row), $rows);
    }
    
    public function findByStatus(string $status): array
    {
        $sql = "SELECT * FROM courses WHERE status = :status ORDER BY created_at DESC";
        $rows = $this->connection->fetchAllAssociative($sql, ['status' => $status]);
        
        return array_map(fn($row) => $this->hydrateCourse($row), $rows);
    }
    
    public function exists(CourseId $id): bool
    {
        $sql = "SELECT COUNT(*) FROM courses WHERE id = :id";
        $count = $this->connection->fetchOne($sql, ['id' => $id->value()]);
        
        return $count > 0;
    }
    
    public function delete(Course $course): void
    {
        $this->connection->delete('courses', ['id' => $course->id()->value()]);
    }
    
    private function hydrateCourse(array $row): Course
    {
        // We need to reconstruct the course from database data
        // This is a simplified version - in production we'd use a proper hydrator
        $reflection = new \ReflectionClass(Course::class);
        $course = $reflection->newInstanceWithoutConstructor();
        
        // Set properties via reflection
        $this->setPrivateProperty($course, 'id', new CourseId($row['id']));
        $this->setPrivateProperty($course, 'code', new CourseCode($row['code']));
        $this->setPrivateProperty($course, 'title', $row['title']);
        $this->setPrivateProperty($course, 'description', $row['description']);
        $this->setPrivateProperty($course, 'duration', new Duration((int)$row['duration_minutes']));
        $this->setPrivateProperty($course, 'price', new Price((float)$row['price_amount'], $row['price_currency']));
        $this->setPrivateProperty($course, 'status', $row['status']);
        $this->setPrivateProperty($course, 'createdAt', new \DateTimeImmutable($row['created_at']));
        
        if ($row['published_at']) {
            $this->setPrivateProperty($course, 'publishedAt', new \DateTimeImmutable($row['published_at']));
        }
        
        if ($row['archived_at']) {
            $this->setPrivateProperty($course, 'archivedAt', new \DateTimeImmutable($row['archived_at']));
        }
        
        return $course;
    }
    
    private function setPrivateProperty(object $object, string $property, mixed $value): void
    {
        $reflection = new \ReflectionClass($object);
        $property = $reflection->getProperty($property);
        $property->setAccessible(true);
        $property->setValue($object, $value);
    }
} 