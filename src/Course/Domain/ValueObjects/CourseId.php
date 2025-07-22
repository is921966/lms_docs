<?php

declare(strict_types=1);

namespace App\Course\Domain\ValueObjects;

use App\Common\Exceptions\InvalidArgumentException;
use Ramsey\Uuid\Uuid;

final class CourseId
{
    private const PREFIX = 'CRS-';
    private const PATTERN = '/^CRS-[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i';
    
    private string $value;
    
    public function __construct(string $value)
    {
        if (empty($value)) {
            throw new InvalidArgumentException('CourseId cannot be empty');
        }
        
        if (!preg_match(self::PATTERN, $value)) {
            throw new InvalidArgumentException('Invalid CourseId format');
        }
        
        $this->value = $value;
    }
    
    public static function generate(): self
    {
        return new self(self::PREFIX . Uuid::uuid4()->toString());
    }
    
    public function value(): string
    {
        return $this->value;
    }
    
    public function equals(self $other): bool
    {
        return $this->value === $other->value;
    }
    
    public function __toString(): string
    {
        return $this->value;
    }
} 