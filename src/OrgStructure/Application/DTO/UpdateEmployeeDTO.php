<?php

namespace App\OrgStructure\Application\DTO;

final class UpdateEmployeeDTO
{
    public function __construct(
        public readonly ?string $name = null,
        public readonly ?string $position = null,
        public readonly ?string $departmentId = null,
        public readonly ?string $email = null,
        public readonly ?string $phone = null
    ) {
    }
} 