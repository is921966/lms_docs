<?php

declare(strict_types=1);

namespace App\Position\Application\DTO;

final class CreateProfileDTO
{
    public function __construct(
        public readonly string $positionId,
        public readonly array $responsibilities,
        public readonly array $requirements
    ) {
    }
} 