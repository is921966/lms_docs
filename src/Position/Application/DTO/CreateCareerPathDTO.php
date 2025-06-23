<?php

declare(strict_types=1);

namespace App\Position\Application\DTO;

final class CreateCareerPathDTO
{
    public function __construct(
        public readonly string $fromPositionId,
        public readonly string $toPositionId,
        public readonly array $requirements,
        public readonly int $estimatedDuration
    ) {
    }
} 