<?php

declare(strict_types=1);

namespace Learning\Http\Responses;

use Learning\Application\DTO\CourseDTO;
use JsonSerializable;

final class CourseResponse implements JsonSerializable
{
    private function __construct(
        private readonly string $id,
        private readonly string $courseCode,
        private readonly string $title,
        private readonly string $description,
        private readonly int $durationHours,
        private readonly string $instructorId,
        private readonly string $status,
        private readonly array $metadata,
        private readonly ?string $createdAt,
        private readonly ?string $updatedAt
    ) {
    }

    public static function fromDto(CourseDTO $dto): self
    {
        return new self(
            id: $dto->id,
            courseCode: $dto->courseCode,
            title: $dto->title,
            description: $dto->description,
            durationHours: $dto->durationHours,
            instructorId: $dto->instructorId,
            status: $dto->status,
            metadata: $dto->metadata,
            createdAt: $dto->createdAt,
            updatedAt: $dto->updatedAt
        );
    }

    /**
     * @param CourseDTO[] $dtos
     * @return self[]
     */
    public static function fromCollection(array $dtos): array
    {
        return array_map(
            fn(CourseDTO $dto) => self::fromDto($dto),
            $dtos
        );
    }

    public function getId(): string
    {
        return $this->id;
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

    public function getStatus(): string
    {
        return $this->status;
    }

    public function getMetadata(): array
    {
        return $this->metadata;
    }

    public function getCreatedAt(): ?string
    {
        return $this->createdAt;
    }

    public function getUpdatedAt(): ?string
    {
        return $this->updatedAt;
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