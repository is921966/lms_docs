<?php

declare(strict_types=1);

namespace Competency\Application\DTO;

use Competency\Domain\CompetencyAssessment;

final class AssessmentDTO
{
    public function __construct(
        public readonly string $id,
        public readonly string $userId,
        public readonly string $competencyId,
        public readonly string $assessorId,
        public readonly string $level,
        public readonly int $score,
        public readonly ?string $comment,
        public readonly bool $isSelfAssessment,
        public readonly bool $isConfirmed,
        public readonly string $assessedAt,
        public readonly ?string $confirmedAt,
        public readonly ?string $confirmedBy
    ) {
    }
    
    public static function fromArray(array $data): self
    {
        return new self(
            id: $data['id'],
            userId: $data['user_id'],
            competencyId: $data['competency_id'],
            assessorId: $data['assessor_id'],
            level: $data['level'],
            score: $data['score'],
            comment: $data['comment'] ?? null,
            isSelfAssessment: $data['is_self_assessment'] ?? false,
            isConfirmed: $data['is_confirmed'] ?? false,
            assessedAt: $data['assessed_at'],
            confirmedAt: $data['confirmed_at'] ?? null,
            confirmedBy: $data['confirmed_by'] ?? null
        );
    }
    
    public static function fromEntity(CompetencyAssessment $assessment): self
    {
        return new self(
            id: $assessment->getId(),
            userId: $assessment->getUserId()->getValue(),
            competencyId: $assessment->getCompetencyId()->getValue(),
            assessorId: $assessment->getAssessorId()->getValue(),
            level: strtolower($assessment->getLevel()->getName()),
            score: $assessment->getScore()->getRoundedPercentage(),
            comment: $assessment->getComment(),
            isSelfAssessment: $assessment->isSelfAssessment(),
            isConfirmed: $assessment->isConfirmed(),
            assessedAt: $assessment->getAssessedAt()->format('Y-m-d H:i:s'),
            confirmedAt: $assessment->getConfirmedAt()?->format('Y-m-d H:i:s'),
            confirmedBy: $assessment->getConfirmedBy()?->getValue()
        );
    }
    
    public function toArray(): array
    {
        return [
            'id' => $this->id,
            'user_id' => $this->userId,
            'competency_id' => $this->competencyId,
            'assessor_id' => $this->assessorId,
            'level' => $this->level,
            'score' => $this->score,
            'comment' => $this->comment,
            'is_self_assessment' => $this->isSelfAssessment,
            'is_confirmed' => $this->isConfirmed,
            'assessed_at' => $this->assessedAt,
            'confirmed_at' => $this->confirmedAt,
            'confirmed_by' => $this->confirmedBy
        ];
    }
} 