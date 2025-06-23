<?php

declare(strict_types=1);

namespace App\Position\Application\DTO;

final class UpdatePositionDTO
{
    public function __construct(
        public readonly string $title,
        public readonly string $description,
        public readonly int $level
    ) {
    }
} 