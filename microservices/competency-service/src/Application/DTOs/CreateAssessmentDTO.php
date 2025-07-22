<?php

namespace CompetencyService\Application\DTOs;

final class CreateAssessmentDTO
{
    public function __construct(
        public readonly string $competencyId,
        public readonly string $userId,
        public readonly string $assessorId
    ) {}
} 