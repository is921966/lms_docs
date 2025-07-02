<?php

declare(strict_types=1);

namespace Program\Application\DTO;

use Program\Domain\Program;

final class ProgramDTO implements \JsonSerializable
{
    public function __construct(
        public readonly string $id,
        public readonly string $code,
        public readonly string $title,
        public readonly string $description,
        public readonly string $status,
        public readonly array $completionCriteria,
        public readonly array $metadata = [],
        public readonly int $trackCount = 0,
        public readonly int $enrollmentCount = 0
    ) {}
    
    public static function fromEntity(Program $program, int $trackCount = 0, int $enrollmentCount = 0): self
    {
        return new self(
            id: $program->getId()->getValue(),
            code: $program->getCode()->getValue(),
            title: $program->getTitle(),
            description: $program->getDescription(),
            status: $program->getStatus()->getValue(),
            completionCriteria: $program->getCompletionCriteria()->jsonSerialize(),
            metadata: $program->getMetadata(),
            trackCount: $trackCount,
            enrollmentCount: $enrollmentCount
        );
    }
    
    public static function fromArray(array $data): self
    {
        return new self(
            id: $data['id'],
            code: $data['code'],
            title: $data['title'],
            description: $data['description'],
            status: $data['status'],
            completionCriteria: $data['completionCriteria'],
            metadata: $data['metadata'] ?? [],
            trackCount: $data['trackCount'] ?? 0,
            enrollmentCount: $data['enrollmentCount'] ?? 0
        );
    }
    
    public function toArray(): array
    {
        return [
            'id' => $this->id,
            'code' => $this->code,
            'title' => $this->title,
            'description' => $this->description,
            'status' => $this->status,
            'completionCriteria' => $this->completionCriteria,
            'metadata' => $this->metadata,
            'trackCount' => $this->trackCount,
            'enrollmentCount' => $this->enrollmentCount
        ];
    }
    
    public function jsonSerialize(): array
    {
        return $this->toArray();
    }
} 