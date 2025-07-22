<?php
declare(strict_types=1);

namespace App\OrgStructure\Domain\ValueObjects;

use App\OrgStructure\Domain\Exceptions\InvalidDepartmentCodeException;

final class DepartmentCode
{
    private string $value;

    public function __construct(string $value)
    {
        $trimmedValue = trim($value);
        
        if (empty($trimmedValue)) {
            throw new InvalidDepartmentCodeException('Department code cannot be empty');
        }

        $this->value = $trimmedValue;
    }

        public function getValue(): string
    {
        return $this->value;
    }
    
    public function toString(): string
    {
        return $this->value;
    }
    
    public function equals(DepartmentCode $other): bool
    {
        return $this->value === $other->value;
    }
    
    public function __toString(): string
    {
        return $this->value;
    }
} 