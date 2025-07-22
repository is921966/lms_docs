<?php

namespace App\OrgStructure\Application\DTO;

final class ParsedDepartment
{
    public function __construct(
        public readonly string $code,
        public readonly string $name,
        public readonly ?string $parentCode = null,
        public readonly int $rowNumber = 0
    ) {
    }
} 