<?php

declare(strict_types=1);

namespace App\Position\Application\DTO;

final class UpdateCareerPathDTO
{
    public function __construct(
        public readonly array $requirements,
        public readonly int $estimatedDuration
    ) {
    }
} 