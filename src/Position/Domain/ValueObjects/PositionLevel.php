<?php

declare(strict_types=1);

namespace App\Position\Domain\ValueObjects;

final class PositionLevel
{
    private const JUNIOR = 1;
    private const MIDDLE = 2;
    private const SENIOR = 3;
    private const LEAD = 4;
    private const PRINCIPAL = 5;
    
    private const NAMES = [
        self::JUNIOR => 'Junior',
        self::MIDDLE => 'Middle',
        self::SENIOR => 'Senior',
        self::LEAD => 'Lead',
        self::PRINCIPAL => 'Principal'
    ];
    
    private int $value;
    
    private function __construct(int $value)
    {
        if (!isset(self::NAMES[$value])) {
            throw new \InvalidArgumentException('Invalid position level');
        }
        
        $this->value = $value;
    }
    
    public static function junior(): self
    {
        return new self(self::JUNIOR);
    }
    
    public static function middle(): self
    {
        return new self(self::MIDDLE);
    }
    
    public static function senior(): self
    {
        return new self(self::SENIOR);
    }
    
    public static function lead(): self
    {
        return new self(self::LEAD);
    }
    
    public static function principal(): self
    {
        return new self(self::PRINCIPAL);
    }
    
    public static function fromString(string $name): self
    {
        $name = ucfirst(strtolower($name));
        $value = array_search($name, self::NAMES, true);
        
        if ($value === false) {
            throw new \InvalidArgumentException("Invalid position level: $name");
        }
        
        return new self($value);
    }
    
    public static function fromValue(int $value): self
    {
        return new self($value);
    }
    
    public function getValue(): int
    {
        return $this->value;
    }
    
    public function getName(): string
    {
        return self::NAMES[$this->value];
    }
    
    public function equals(PositionLevel $other): bool
    {
        return $this->value === $other->value;
    }
    
    public function isHigherThan(PositionLevel $other): bool
    {
        return $this->value > $other->value;
    }
    
    public function isLowerThan(PositionLevel $other): bool
    {
        return $this->value < $other->value;
    }
    
    public function __toString(): string
    {
        return $this->getName();
    }
} 