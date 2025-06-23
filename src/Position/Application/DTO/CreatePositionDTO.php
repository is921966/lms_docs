<?php

declare(strict_types=1);

namespace App\Position\Application\DTO;

final class CreatePositionDTO
{
    public function __construct(
        public readonly string $code,
        public readonly string $title,
        public readonly string $department,
        public readonly int $level,
        public readonly string $description,
        public readonly ?string $parentId = null
    ) {
    }
} 