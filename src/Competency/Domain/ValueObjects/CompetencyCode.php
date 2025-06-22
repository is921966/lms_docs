<?php

declare(strict_types=1);

namespace App\Competency\Domain\ValueObjects;

/**
 * Represents a unique competency code
 */
final class CompetencyCode
{
    private const MAX_LENGTH = 50;
    private const VALID_PATTERN = '/^[A-Z0-9\-_.]+$/';
    
    private readonly string $value;
    
    public function __construct(string $value)
    {
        $normalizedValue = strtoupper(trim($value));
        
        if (empty($normalizedValue)) {
            throw new \InvalidArgumentException('Competency code cannot be empty');
        }
        
        if (strlen($normalizedValue) > self::MAX_LENGTH) {
            throw new \InvalidArgumentException(
                sprintf('Competency code cannot exceed %d characters', self::MAX_LENGTH)
            );
        }
        
        if (!preg_match(self::VALID_PATTERN, $normalizedValue)) {
            throw new \InvalidArgumentException('Competency code contains invalid characters');
        }
        
        $this->value = $normalizedValue;
    }
    
    public static function fromString(string $code): self
    {
        return new self($code);
    }
    
    public function getValue(): string
    {
        return $this->value;
    }
    
    public function equals(self $other): bool
    {
        return $this->value === $other->value;
    }
    
    public function getPrefix(): ?string
    {
        $parts = $this->getParts();
        return $parts[0] ?? null;
    }
    
    public function getCategory(): ?string
    {
        $parts = $this->getParts();
        return $parts[1] ?? null;
    }
    
    public function getSequence(): ?string
    {
        $parts = $this->getParts();
        return $parts[2] ?? null;
    }
    
    public function nextSequence(): self
    {
        $parts = $this->getParts();
        
        if (count($parts) < 3) {
            throw new \LogicException('Cannot generate next sequence for code without sequence number');
        }
        
        $sequence = $parts[2];
        
        if (!is_numeric($sequence)) {
            throw new \LogicException('Cannot generate next sequence for non-numeric sequence');
        }
        
        $nextNumber = (int) $sequence + 1;
        $paddedNumber = str_pad((string) $nextNumber, strlen($sequence), '0', STR_PAD_LEFT);
        
        $parts[2] = $paddedNumber;
        $newCode = implode('-', $parts);
        
        return new self($newCode);
    }
    
    /**
     * @return string[]
     */
    private function getParts(): array
    {
        // Try different separators
        foreach (['-', '_', '.'] as $separator) {
            if (str_contains($this->value, $separator)) {
                return explode($separator, $this->value);
            }
        }
        
        return [$this->value];
    }
    
    public function __toString(): string
    {
        return $this->value;
    }
} 