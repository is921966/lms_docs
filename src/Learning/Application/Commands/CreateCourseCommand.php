<?php

declare(strict_types=1);

namespace Learning\Application\Commands;

use InvalidArgumentException;
use DateTimeImmutable;

final class CreateCourseCommand
{
    private string $commandId;
    private string $courseCode;
    private string $title;
    private string $description;
    private int $durationHours;
    private string $instructorId;
    private array $metadata;
    private DateTimeImmutable $createdAt;
    
    public function __construct(
        string $courseCode,
        string $title,
        string $description,
        int $durationHours,
        string $instructorId,
        array $metadata = []
    ) {
        // Validation
        if (empty($courseCode)) {
            throw new InvalidArgumentException('Course code cannot be empty');
        }
        
        if (empty($title)) {
            throw new InvalidArgumentException('Title cannot be empty');
        }
        
        if ($durationHours <= 0) {
            throw new InvalidArgumentException('Duration must be positive');
        }
        
        if (empty($instructorId)) {
            throw new InvalidArgumentException('Instructor ID cannot be empty');
        }
        
        $this->commandId = uniqid('cmd_', true);
        $this->courseCode = $courseCode;
        $this->title = $title;
        $this->description = $description;
        $this->durationHours = $durationHours;
        $this->instructorId = $instructorId;
        $this->metadata = $metadata;
        $this->createdAt = new DateTimeImmutable();
    }
    
    public function getCommandId(): string
    {
        return $this->commandId;
    }
    
    public function getCourseCode(): string
    {
        return $this->courseCode;
    }
    
    public function getTitle(): string
    {
        return $this->title;
    }
    
    public function getDescription(): string
    {
        return $this->description;
    }
    
    public function getDurationHours(): int
    {
        return $this->durationHours;
    }
    
    public function getInstructorId(): string
    {
        return $this->instructorId;
    }
    
    public function getMetadata(): array
    {
        return $this->metadata;
    }
    
    public function getCreatedAt(): DateTimeImmutable
    {
        return $this->createdAt;
    }
    
    public function toArray(): array
    {
        return [
            'command_id' => $this->commandId,
            'course_code' => $this->courseCode,
            'title' => $this->title,
            'description' => $this->description,
            'duration_hours' => $this->durationHours,
            'instructor_id' => $this->instructorId,
            'metadata' => $this->metadata,
            'created_at' => $this->createdAt->format('Y-m-d H:i:s')
        ];
    }
} 