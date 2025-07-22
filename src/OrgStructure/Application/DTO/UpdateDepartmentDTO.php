<?php

namespace App\OrgStructure\Application\DTO;

final class UpdateDepartmentDTO
{
    public function __construct(
        public readonly ?string $name = null,
        public readonly ?string $parentId = null
    ) {
    }
} 