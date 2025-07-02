<?php

declare(strict_types=1);

namespace Learning\Domain\ValueObjects;

final class CertificateNumber
{
    private const PATTERN = '/^CERT-(\d{4})-(\d{5})$/';
    private string $value;
    
    public function __construct(string $value)
    {
        if (!$this->isValid($value)) {
            throw new \InvalidArgumentException('Invalid certificate number format');
        }
        
        $this->value = $value;
    }
    
    public static function generate(int $year, int $sequence): self
    {
        if ($year < 2000 || $year > 9999) {
            throw new \InvalidArgumentException('Year must be between 2000 and 9999');
        }
        
        if ($sequence < 1 || $sequence > 99999) {
            throw new \InvalidArgumentException('Sequence must be between 1 and 99999');
        }
        
        $number = sprintf('CERT-%04d-%05d', $year, $sequence);
        
        return new self($number);
    }
    
    public function getValue(): string
    {
        return $this->value;
    }
    
    public function getYear(): int
    {
        preg_match(self::PATTERN, $this->value, $matches);
        return (int) $matches[1];
    }
    
    public function getSequence(): int
    {
        preg_match(self::PATTERN, $this->value, $matches);
        return (int) $matches[2];
    }
    
    public function equals(self $other): bool
    {
        return $this->value === $other->value;
    }
    
    public function __toString(): string
    {
        return $this->value;
    }
    
    private function isValid(string $value): bool
    {
        return preg_match(self::PATTERN, $value) === 1;
    }
} 