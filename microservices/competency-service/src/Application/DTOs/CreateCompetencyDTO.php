<?php

namespace CompetencyService\Application\DTOs;

final class CreateCompetencyDTO
{
    public function __construct(
        public readonly string $code,
        public readonly string $name,
        public readonly string $description,
        public readonly string $category,
        public readonly array $levels = []
    ) {}
} 