<?php

namespace CompetencyService\Application\DTOs;

final class UpdateCompetencyDTO
{
    public function __construct(
        public readonly string $id,
        public readonly string $name,
        public readonly string $description
    ) {}
} 