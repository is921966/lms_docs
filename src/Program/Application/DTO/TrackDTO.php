<?php

declare(strict_types=1);

namespace Program\Application\DTO;

use Program\Domain\Track;
use Learning\Domain\ValueObjects\CourseId;

final class TrackDTO implements \JsonSerializable
{
    public function __construct(
        public readonly string $id,
        public readonly string $programId,
        public readonly string $title,
        public readonly string $description,
        public readonly int $order,
        public readonly bool $isRequired,
        public readonly array $courseIds = [],
        public readonly int $courseCount = 0
    ) {}
    
    public static function fromEntity(Track $track): self
    {
        $courseIds = array_map(
            fn(CourseId $courseId) => $courseId->getValue(),
            $track->getCourseIds()
        );
        
        return new self(
            id: $track->getId()->getValue(),
            programId: $track->getProgramId()->getValue(),
            title: $track->getTitle(),
            description: $track->getDescription(),
            order: $track->getOrder()->getValue(),
            isRequired: $track->isRequired(),
            courseIds: $courseIds,
            courseCount: count($courseIds)
        );
    }
    
    public static function fromArray(array $data): self
    {
        return new self(
            id: $data['id'],
            programId: $data['programId'],
            title: $data['title'],
            description: $data['description'],
            order: $data['order'],
            isRequired: $data['isRequired'],
            courseIds: $data['courseIds'] ?? [],
            courseCount: $data['courseCount'] ?? count($data['courseIds'] ?? [])
        );
    }
    
    public function toArray(): array
    {
        return [
            'id' => $this->id,
            'programId' => $this->programId,
            'title' => $this->title,
            'description' => $this->description,
            'order' => $this->order,
            'isRequired' => $this->isRequired,
            'courseIds' => $this->courseIds,
            'courseCount' => $this->courseCount
        ];
    }
    
    public function jsonSerialize(): array
    {
        return $this->toArray();
    }
} 