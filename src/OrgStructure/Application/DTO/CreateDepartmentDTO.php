<?php

namespace App\OrgStructure\Application\DTO;

final class CreateDepartmentDTO
{
    public function __construct(
        public readonly string $name,
        public readonly string $code,
        public readonly ?string $parentId = null
    ) {
    }
} 