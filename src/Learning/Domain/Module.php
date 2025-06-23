<?php

declare(strict_types=1);

namespace App\Learning\Domain;

use App\Learning\Domain\ValueObjects\ModuleId;
use App\Learning\Domain\ValueObjects\CourseId;
use App\Learning\Domain\ValueObjects\LessonId;

class Module
{
    private ModuleId $id;
    private CourseId $courseId;
    private string $title;
    private string $description;
    private int $orderIndex;
    private int $durationMinutes;
    private bool $isRequired;
    private array $lessons = [];
    private \DateTimeImmutable $createdAt;
    private \DateTimeImmutable $updatedAt;
    
    private function __construct(
        ModuleId $id,
        CourseId $courseId,
        string $title,
        string $description,
        int $orderIndex,
        int $durationMinutes,
        bool $isRequired
    ) {
        $this->id = $id;
        $this->courseId = $courseId;
        $this->title = $title;
        $this->description = $description;
        $this->setOrderIndex($orderIndex);
        $this->durationMinutes = $durationMinutes;
        $this->isRequired = $isRequired;
        $this->createdAt = new \DateTimeImmutable();
        $this->updatedAt = new \DateTimeImmutable();
    }
    
    public static function create(
        CourseId $courseId,
        string $title,
        string $description,
        int $orderIndex,
        int $durationMinutes,
        bool $isRequired
    ): self {
        return new self(
            ModuleId::generate(),
            $courseId,
            $title,
            $description,
            $orderIndex,
            $durationMinutes,
            $isRequired
        );
    }
    
    public function updateBasicInfo(string $title, string $description, int $durationMinutes): void
    {
        $this->title = $title;
        $this->description = $description;
        $this->durationMinutes = $durationMinutes;
        $this->updatedAt = new \DateTimeImmutable();
    }
    
    public function setRequired(bool $isRequired): void
    {
        $this->isRequired = $isRequired;
        $this->updatedAt = new \DateTimeImmutable();
    }
    
    public function setOrderIndex(int $orderIndex): void
    {
        if ($orderIndex < 1) {
            throw new \InvalidArgumentException('Order index must be positive');
        }
        
        $this->orderIndex = $orderIndex;
        $this->updatedAt = new \DateTimeImmutable();
    }
    
    public function addLesson(Lesson $lesson): void
    {
        if ($this->hasLesson($lesson->getId())) {
            return;
        }
        
        $this->lessons[] = $lesson;
        $this->updatedAt = new \DateTimeImmutable();
    }
    
    public function removeLesson(LessonId $lessonId): void
    {
        $this->lessons = array_values(
            array_filter(
                $this->lessons,
                fn(Lesson $lesson) => !$lesson->getId()->equals($lessonId)
            )
        );
        $this->updatedAt = new \DateTimeImmutable();
    }
    
    public function hasLesson(LessonId $lessonId): bool
    {
        foreach ($this->lessons as $lesson) {
            if ($lesson->getId()->equals($lessonId)) {
                return true;
            }
        }
        return false;
    }
    
    public function reorderLessons(array $lessonIds): void
    {
        $orderedLessons = [];
        $orderIndex = 1;
        
        foreach ($lessonIds as $lessonId) {
            foreach ($this->lessons as $lesson) {
                if ($lesson->getId()->equals($lessonId)) {
                    $lesson->setOrderIndex($orderIndex++);
                    $orderedLessons[] = $lesson;
                    break;
                }
            }
        }
        
        $this->lessons = $orderedLessons;
        $this->updatedAt = new \DateTimeImmutable();
    }
    
    public function calculateTotalDuration(): int
    {
        return array_reduce(
            $this->lessons,
            fn(int $total, Lesson $lesson) => $total + $lesson->getDurationMinutes(),
            0
        );
    }
    
    // Getters
    public function getId(): ModuleId
    {
        return $this->id;
    }
    
    public function getCourseId(): CourseId
    {
        return $this->courseId;
    }
    
    public function getTitle(): string
    {
        return $this->title;
    }
    
    public function getDescription(): string
    {
        return $this->description;
    }
    
    public function getOrderIndex(): int
    {
        return $this->orderIndex;
    }
    
    public function getDurationMinutes(): int
    {
        return $this->durationMinutes;
    }
    
    public function isRequired(): bool
    {
        return $this->isRequired;
    }
    
    public function getLessons(): array
    {
        return $this->lessons;
    }
    
    public function getCreatedAt(): \DateTimeImmutable
    {
        return $this->createdAt;
    }
    
    public function getUpdatedAt(): \DateTimeImmutable
    {
        return $this->updatedAt;
    }
} 