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
    
    public static function fromArray(array $data): self
    {
        return new self(
            id: $data['id'] ?? '',
            courseCode: $data['course_code'] ?? $data['courseCode'] ?? '',
            title: $data['title'] ?? '',
            description: $data['description'] ?? '',
            durationHours: (int)($data['duration_hours'] ?? $data['durationHours'] ?? 0),
            instructorId: $data['instructor_id'] ?? $data['instructorId'] ?? '',
            status: $data['status'] ?? 'draft',
            metadata: $data['metadata'] ?? [],
            createdAt: $data['created_at'] ?? $data['createdAt'] ?? null,
            updatedAt: $data['updated_at'] ?? $data['updatedAt'] ?? null
        );
    }
    
    public static function fromEntity(\Learning\Domain\Course $course): self
    {
        return new self(
            id: $course->getId()->getValue(),
            courseCode: $course->getCode()->getValue(),
            title: $course->getTitle(),
            description: $course->getDescription(),
            durationHours: $course->getDuration()->getHours(),
            instructorId: '', // Will be set by service layer
            status: $course->getStatus()->getValue(),
            metadata: $course->getMetadata(),
            createdAt: $course->getCreatedAt()->format('Y-m-d H:i:s'),
            updatedAt: $course->getUpdatedAt() ? $course->getUpdatedAt()->format('Y-m-d H:i:s') : null
        );
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
