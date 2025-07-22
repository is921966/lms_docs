<?php
declare(strict_types=1);

namespace App\OrgStructure\Domain\ValueObjects;

use App\OrgStructure\Domain\Exceptions\InvalidEmployeeDataException;

class EmployeeId
{
    private string $value;
    
    private function __construct(string $value)
    {
        if (empty($value)) {
            throw new InvalidEmployeeDataException('Employee ID cannot be empty');
        }
        
        $this->value = $value;
    }
    
    public static function generate(): self
    {
        return new self(self::generateUuid());
    }
    
    public static function fromString(string $value): self
    {
        if (!self::isValidUuid($value)) {
            throw new InvalidEmployeeDataException('Invalid UUID format for Employee ID');
        }
        
        return new self($value);
    }
    
    public function toString(): string
    {
        return $this->value;
    }
    
    public function equals(EmployeeId $other): bool
    {
        return $this->value === $other->value;
    }
    
    private static function generateUuid(): string
    {
        $data = random_bytes(16);
        
        $data[6] = chr(ord($data[6]) & 0x0f | 0x40);
        $data[8] = chr(ord($data[8]) & 0x3f | 0x80);
        
        return vsprintf('%s%s-%s-%s-%s-%s%s%s', str_split(bin2hex($data), 4));
    }
    
    private static function isValidUuid(string $uuid): bool
    {
        $pattern = '/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i';
        return preg_match($pattern, $uuid) === 1;
    }
} 