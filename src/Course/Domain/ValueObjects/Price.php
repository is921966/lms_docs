<?php

declare(strict_types=1);

namespace App\Course\Domain\ValueObjects;

use App\Common\Exceptions\InvalidArgumentException;

final class Price
{
    private const VALID_CURRENCIES = ['USD', 'EUR', 'GBP', 'RUB', 'JPY'];
    private const CURRENCY_SYMBOLS = [
        'USD' => '$',
        'EUR' => '€',
        'GBP' => '£',
        'RUB' => '₽',
        'JPY' => '¥'
    ];
    
    private float $amount;
    private string $currency;
    
    public function __construct(float $amount, string $currency = 'USD')
    {
        if ($amount < 0) {
            throw new InvalidArgumentException('Price amount cannot be negative');
        }
        
        if (!in_array($currency, self::VALID_CURRENCIES, true)) {
            throw new InvalidArgumentException('Invalid currency code');
        }
        
        $this->amount = round($amount, 2);
        $this->currency = $currency;
    }
    
    public static function free(string $currency = 'USD'): self
    {
        return new self(0, $currency);
    }
    
    public function amount(): float
    {
        return $this->amount;
    }
    
    public function currency(): string
    {
        return $this->currency;
    }
    
    public function isFree(): bool
    {
        return $this->amount === 0.0;
    }
    
    public function add(self $other): self
    {
        if ($this->currency !== $other->currency) {
            throw new InvalidArgumentException('Cannot add prices with different currencies');
        }
        
        return new self($this->amount + $other->amount, $this->currency);
    }
    
    public function subtract(self $other): self
    {
        if ($this->currency !== $other->currency) {
            throw new InvalidArgumentException('Cannot subtract prices with different currencies');
        }
        
        return new self($this->amount - $other->amount, $this->currency);
    }
    
    public function multiply(float $factor): self
    {
        return new self($this->amount * $factor, $this->currency);
    }
    
    public function equals(self $other): bool
    {
        return $this->amount === $other->amount && $this->currency === $other->currency;
    }
    
    public function __toString(): string
    {
        if ($this->isFree()) {
            return 'Free';
        }
        
        $symbol = self::CURRENCY_SYMBOLS[$this->currency] ?? $this->currency;
        
        if ($this->currency === 'JPY') {
            return $symbol . number_format($this->amount, 0);
        }
        
        return $symbol . number_format($this->amount, 2, '.', '');
    }
} 