<?php

namespace App\OrgStructure\Domain\ValueObject;

use App\OrgStructure\Domain\Exception\InvalidTabNumberException;

final class TabNumber
{
    private string $value;
    private const PATTERN = '/^АР\d{8}$/u';
    
    public function __construct(string $value)
    {
        $value = trim($value);
        
        if (!$this->isValid($value)) {
            throw new InvalidTabNumberException(
                sprintf('Invalid tab number format: "%s". Expected format: АР + 8 digits', $value)
            );
        }
        
        $this->value = $value;
    }
    
    public function getValue(): string
    {
        return $this->value;
    }
    
    public function __toString(): string
    {
        return $this->value;
    }
    
    private function isValid(string $value): bool
    {
        if (empty($value)) {
            return false;
        }
        
        return preg_match(self::PATTERN, $value) === 1;
    }
    
    public function getNumericPart(): string
    {
        // Use mb_substr for multibyte (UTF-8) characters
        return mb_substr($this->value, 2);
    }
    
    public function equals(self $other): bool
    {
        return $this->value === $other->value;
    }
} 