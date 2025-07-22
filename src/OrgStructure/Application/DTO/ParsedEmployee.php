<?php

namespace App\OrgStructure\Application\DTO;

final class ParsedEmployee
{
    public function __construct(
        public readonly string $tabNumber,
        public readonly string $name,
        public readonly string $position,
        public readonly string $departmentCode,
        public readonly ?string $email = null,
        public readonly ?string $phone = null,
        public readonly int $rowNumber = 0
    ) {
    }
} 