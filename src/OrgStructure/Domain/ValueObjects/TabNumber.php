<?php
declare(strict_types=1);

namespace App\OrgStructure\Domain\ValueObjects;

use App\OrgStructure\Domain\Exceptions\InvalidTabNumberException;

final class TabNumber
{
    private string $value;

    public function __construct(string $value)
    {
        $trimmedValue = trim($value);
        
        if (empty($trimmedValue)) {
            throw new InvalidTabNumberException('Tab number cannot be empty');
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
    
    public function equals(TabNumber $other): bool
    {
        return $this->value === $other->value;
    }
    
    public function __toString(): string
    {
        return $this->value;
    }
} 