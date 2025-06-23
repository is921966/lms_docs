<?php

declare(strict_types=1);

namespace App\Position\Application\DTO;

final class CompetencyRequirementDTO
{
    public function __construct(
        public readonly string $competencyId,
        public readonly int $minimumLevel,
        public readonly bool $isRequired = true
    ) {
    }
} 