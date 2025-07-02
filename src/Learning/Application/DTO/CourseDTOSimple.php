<?php

declare(strict_types=1);

namespace Learning\Application\DTO;

use JsonSerializable;

final class CourseDTO implements JsonSerializable
{
    public function __construct(
        public readonly string $id,
        public readonly string $courseCode,
        public readonly string $title,
        public readonly string $description,
        public readonly int $durationHours,
        public readonly string $instructorId,
        public readonly string $status,
        public readonly array $metadata = [],
        public readonly ?string $createdAt = null,
        public readonly ?string $updatedAt = null
    ) {
    }
    
    public function toArray(): array
    {
        return [
            'id' => $this->id,
            'course_code' => $this->courseCode,
            'title' => $this->title,
            'description' => $this->description,
            'duration_hours' => $this->durationHours,
            'instructor_id' => $this->instructorId,
            'status' => $this->status,
            'metadata' => $this->metadata,
            'created_at' => $this->createdAt,
            'updated_at' => $this->updatedAt
        ];
    }
    
    public function jsonSerialize(): array
    {
        return $this->toArray();
    }
} 