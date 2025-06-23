<?php

declare(strict_types=1);

namespace App\Learning\Application\DTO;

use App\Learning\Domain\Course;
use App\Learning\Domain\ValueObjects\CourseCode;
use App\Learning\Domain\ValueObjects\CourseType;

final class CourseDTO
{
    public function __construct(
        public readonly ?string $id,
        public readonly string $code,
        public readonly string $title,
        public readonly string $description,
        public readonly string $type,
        public readonly string $status,
        public readonly int $durationHours,
        public readonly ?int $maxStudents,
        public readonly ?float $price,
        public readonly array $tags,
        public readonly array $prerequisites,
        public readonly ?string $imageUrl = null,
        public readonly ?string $createdAt = null,
        public readonly ?string $updatedAt = null
    ) {}
    
    public static function fromArray(array $data): self
    {
        return new self(
            id: $data['id'] ?? null,
            code: $data['code'],
            title: $data['title'],
            description: $data['description'],
            type: $data['type'],
            status: $data['status'] ?? 'draft',
            durationHours: $data['durationHours'],
            maxStudents: $data['maxStudents'] ?? null,
            price: $data['price'] ?? null,
            tags: $data['tags'] ?? [],
            prerequisites: $data['prerequisites'] ?? [],
            imageUrl: $data['imageUrl'] ?? null,
            createdAt: $data['createdAt'] ?? null,
            updatedAt: $data['updatedAt'] ?? null
        );
    }
    
    public static function fromEntity(Course $course): self
    {
        return new self(
            id: $course->getId()->toString(),
            code: $course->getCode()->toString(),
            title: $course->getTitle(),
            description: $course->getDescription(),
            type: strtolower($course->getType()->value),
            status: $course->getStatus()->value,
            durationHours: $course->getDurationHours(),
            maxStudents: null, // Not in domain yet
            price: null, // Not in domain yet
            tags: $course->getTags(),
            prerequisites: array_map(
                fn($prerequisite) => $prerequisite->toString(),
                $course->getPrerequisites()
            ),
            imageUrl: $course->getImageUrl(),
            createdAt: $course->getCreatedAt()->format('c'),
            updatedAt: $course->getUpdatedAt()->format('c')
        );
    }
    
    public function toArray(): array
    {
        return [
            'id' => $this->id,
            'code' => $this->code,
            'title' => $this->title,
            'description' => $this->description,
            'type' => $this->type,
            'status' => $this->status,
            'durationHours' => $this->durationHours,
            'maxStudents' => $this->maxStudents,
            'price' => $this->price,
            'tags' => $this->tags,
            'prerequisites' => $this->prerequisites,
            'imageUrl' => $this->imageUrl,
            'createdAt' => $this->createdAt,
            'updatedAt' => $this->updatedAt,
        ];
    }
    
    public function toNewEntity(): Course
    {
        if ($this->id !== null) {
            throw new \InvalidArgumentException('Cannot create new entity from DTO with ID');
        }
        
        return Course::create(
            code: CourseCode::fromString($this->code),
            title: $this->title,
            description: $this->description,
            type: CourseType::from(strtoupper($this->type)),
            durationHours: $this->durationHours
        );
    }
} 