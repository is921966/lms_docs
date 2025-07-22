<?php

namespace App\OrgStructure\Application\DTO;

final class CreateEmployeeDTO
{
    public function __construct(
        public readonly string $tabNumber,
        public readonly string $name,
        public readonly string $position,
        public readonly string $departmentId,
        public readonly ?string $email = null,
        public readonly ?string $phone = null,
        public readonly ?string $userId = null
    ) {
    }
} 