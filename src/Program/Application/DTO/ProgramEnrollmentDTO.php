<?php

declare(strict_types=1);

namespace Program\Application\DTO;

use Program\Domain\ProgramEnrollment;

final class ProgramEnrollmentDTO implements \JsonSerializable
{
    public function __construct(
        public readonly string $userId,
        public readonly string $programId,
        public readonly string $status,
        public readonly int $progress,
        public readonly string $enrolledAt,
        public readonly ?string $startedAt = null,
        public readonly ?string $completedAt = null
    ) {}
    
    public static function fromEntity(ProgramEnrollment $enrollment): self
    {
        return new self(
            userId: $enrollment->getUserId()->getValue(),
            programId: $enrollment->getProgramId()->getValue(),
            status: $enrollment->getStatus(),
            progress: $enrollment->getProgress(),
            enrolledAt: $enrollment->getEnrolledAt()->format('Y-m-d H:i:s'),
            startedAt: $enrollment->getStartedAt()?->format('Y-m-d H:i:s'),
            completedAt: $enrollment->getCompletedAt()?->format('Y-m-d H:i:s')
        );
    }
    
    public static function fromArray(array $data): self
    {
        return new self(
            userId: $data['userId'],
            programId: $data['programId'],
            status: $data['status'],
            progress: $data['progress'],
            enrolledAt: $data['enrolledAt'],
            startedAt: $data['startedAt'] ?? null,
            completedAt: $data['completedAt'] ?? null
        );
    }
    
    public function toArray(): array
    {
        return [
            'userId' => $this->userId,
            'programId' => $this->programId,
            'status' => $this->status,
            'progress' => $this->progress,
            'enrolledAt' => $this->enrolledAt,
            'startedAt' => $this->startedAt,
            'completedAt' => $this->completedAt
        ];
    }
    
    public function jsonSerialize(): array
    {
        return $this->toArray();
    }
} 