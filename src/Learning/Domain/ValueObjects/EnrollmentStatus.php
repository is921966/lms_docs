<?php

declare(strict_types=1);

namespace App\Learning\Domain\ValueObjects;

enum EnrollmentStatus: string
{
    case PENDING = 'pending';
    case ACTIVE = 'active';
    case COMPLETED = 'completed';
    case CANCELLED = 'cancelled';
    case EXPIRED = 'expired';
    
    public function label(): string
    {
        return match ($this) {
            self::PENDING => 'Ожидает подтверждения',
            self::ACTIVE => 'Активна',
            self::COMPLETED => 'Завершена',
            self::CANCELLED => 'Отменена',
            self::EXPIRED => 'Истекла',
        };
    }
    
    public function isActive(): bool
    {
        return $this === self::ACTIVE;
    }
    
    public function isFinal(): bool
    {
        return in_array($this, [self::COMPLETED, self::CANCELLED, self::EXPIRED], true);
    }
    
    public function allowedTransitions(): array
    {
        return match ($this) {
            self::PENDING => [self::ACTIVE, self::CANCELLED],
            self::ACTIVE => [self::COMPLETED, self::CANCELLED, self::EXPIRED],
            self::COMPLETED, self::CANCELLED, self::EXPIRED => [],
        };
    }
    
    public function canTransitionTo(self $newStatus): bool
    {
        return in_array($newStatus, $this->allowedTransitions(), true);
    }
} 