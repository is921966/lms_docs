<?php

declare(strict_types=1);

namespace App\Learning\Domain\ValueObjects;

enum CourseType: string implements \JsonSerializable
{
    case ONLINE = 'ONLINE';
    case OFFLINE = 'OFFLINE';
    case BLENDED = 'BLENDED';
    
    public function getLabel(): string
    {
        return match($this) {
            self::ONLINE => 'Online',
            self::OFFLINE => 'Offline',
            self::BLENDED => 'Blended',
        };
    }
    
    public static function values(): array
    {
        return array_map(fn($case) => $case->value, self::cases());
    }
    
    public function jsonSerialize(): string
    {
        return $this->value;
    }
} 