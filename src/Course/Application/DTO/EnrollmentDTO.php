<?php

declare(strict_types=1);

namespace App\Course\Application\DTO;

final class EnrollmentDTO
{
    public function __construct(
        public readonly string $id,
        public readonly string $courseId,
        public readonly string $courseTitle,
        public readonly string $courseCode,
        public readonly string $userId,
        public readonly string $status,
        public readonly int $progressPercent,
        public readonly string $enrolledAt,
        public readonly ?string $completedAt = null,
        public readonly ?string $lastActivityAt = null
    ) {
    }
    
    public static function fromArray(array $data): self
    {
        return new self(
            id: $data['id'],
            courseId: $data['course_id'],
            courseTitle: $data['course_title'],
            courseCode: $data['course_code'],
            userId: $data['user_id'],
            status: $data['status'],
            progressPercent: $data['progress_percent'],
            enrolledAt: $data['enrolled_at'],
            completedAt: $data['completed_at'] ?? null,
            lastActivityAt: $data['last_activity_at'] ?? null
        );
    }
    
    public function toArray(): array
    {
        return [
            'id' => $this->id,
            'course_id' => $this->courseId,
            'course_title' => $this->courseTitle,
            'course_code' => $this->courseCode,
            'user_id' => $this->userId,
            'status' => $this->status,
            'progress_percent' => $this->progressPercent,
            'enrolled_at' => $this->enrolledAt,
            'completed_at' => $this->completedAt,
            'last_activity_at' => $this->lastActivityAt,
        ];
    }
} 