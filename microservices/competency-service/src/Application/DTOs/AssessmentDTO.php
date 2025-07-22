<?php

namespace CompetencyService\Application\DTOs;

use CompetencyService\Domain\Entities\Assessment;

final class AssessmentDTO
{
    public function __construct(
        public readonly string $id,
        public readonly string $competencyId,
        public readonly string $userId,
        public readonly string $assessorId,
        public readonly string $status,
        public readonly ?array $score,
        public readonly ?string $cancellationReason,
        public readonly string $createdAt,
        public readonly ?string $completedAt
    ) {}
    
    public static function fromEntity(Assessment $assessment): self
    {
        $data = $assessment->toArray();
        
        return new self(
            id: $data['id'],
            competencyId: $data['competency_id'],
            userId: $data['user_id'],
            assessorId: $data['assessor_id'],
            status: $data['status'],
            score: $data['score'],
            cancellationReason: $data['cancellation_reason'],
            createdAt: $data['created_at'],
            completedAt: $data['completed_at']
        );
    }
} 