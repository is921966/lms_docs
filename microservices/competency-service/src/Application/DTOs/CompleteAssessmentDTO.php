<?php

namespace CompetencyService\Application\DTOs;

final class CompleteAssessmentDTO
{
    public function __construct(
        public readonly string $assessmentId,
        public readonly int $level,
        public readonly string $feedback,
        public readonly string $recommendations
    ) {}
} 