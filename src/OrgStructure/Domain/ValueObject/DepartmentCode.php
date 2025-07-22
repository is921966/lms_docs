<?php

namespace App\OrgStructure\Domain\ValueObject;

use App\OrgStructure\Domain\Exception\InvalidDepartmentCodeException;

final class DepartmentCode
{
    private string $value;
    private const PATTERN = '/^АП(\.\d+)*$/u';
    
    public function __construct(string $value)
    {
        $value = trim($value);
        
        if (!$this->isValid($value)) {
            throw new InvalidDepartmentCodeException(
                sprintf('Invalid department code format: "%s"', $value)
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
    
    public function getLevel(): int
    {
        return substr_count($this->value, '.');
    }
    
    public function isRoot(): bool
    {
        return $this->getLevel() === 0;
    }
    
    public function getParentCode(): ?self
    {
        if ($this->isRoot()) {
            return null;
        }
        
        $segments = $this->getSegments();
        array_pop($segments);
        
        return new self(implode('.', $segments));
    }
    
    public function getSegments(): array
    {
        return explode('.', $this->value);
    }
    
    public function isChildOf(self $other): bool
    {
        // Check if this code starts with the other code followed by a dot
        $otherValue = $other->getValue();
        
        return str_starts_with($this->value, $otherValue . '.') 
            && strlen($this->value) > strlen($otherValue);
    }
    
    public function createChildCode(int $number): self
    {
        return new self($this->value . '.' . $number);
    }
    
    public function equals(self $other): bool
    {
        return $this->value === $other->value;
    }
} 