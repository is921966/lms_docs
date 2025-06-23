<?php

declare(strict_types=1);

namespace App\Position\Application\DTO;

final class UpdateProfileDTO
{
    public function __construct(
        public readonly array $responsibilities,
        public readonly array $requirements
    ) {
    }
} 