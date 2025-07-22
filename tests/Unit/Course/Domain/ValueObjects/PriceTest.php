<?php

declare(strict_types=1);

namespace Tests\Unit\Course\Domain\ValueObjects;

use PHPUnit\Framework\TestCase;
use App\Course\Domain\ValueObjects\Price;
use App\Common\Exceptions\InvalidArgumentException;

class PriceTest extends TestCase
{
    public function testCanCreateValidPrice(): void
    {
        // Given
        $amount = 99.99;
        $currency = 'USD';
        
        // When
        $price = new Price($amount, $currency);
        
        // Then
        $this->assertEquals(99.99, $price->amount());
        $this->assertEquals('USD', $price->currency());
        $this->assertEquals('$99.99', (string)$price);
    }
    
    public function testCanCreateFreePrice(): void
    {
        // When
        $price = Price::free();
        
        // Then
        $this->assertEquals(0.0, $price->amount());
        $this->assertEquals('USD', $price->currency());
        $this->assertTrue($price->isFree());
        $this->assertEquals('Free', (string)$price);
    }
    
    public function testThrowsExceptionForNegativeAmount(): void
    {
        // Then
        $this->expectException(InvalidArgumentException::class);
        $this->expectExceptionMessage('Price amount cannot be negative');
        
        // When
        new Price(-1.0, 'USD');
    }
    
    public function testThrowsExceptionForInvalidCurrency(): void
    {
        // Then
        $this->expectException(InvalidArgumentException::class);
        $this->expectExceptionMessage('Invalid currency code');
        
        // When
        new Price(100.0, 'INVALID');
    }
    
    public function testCurrencyFormatting(): void
    {
        // Given
        $testCases = [
            ['USD', 100.00, '$100.00'],
            ['EUR', 100.00, '€100.00'],
            ['GBP', 100.00, '£100.00'],
            ['RUB', 100.00, '₽100.00'],
            ['JPY', 100, '¥100']
        ];
        
        foreach ($testCases as [$currency, $amount, $expected]) {
            // When
            $price = new Price($amount, $currency);
            
            // Then
            $this->assertEquals($expected, (string)$price);
        }
    }
    
    public function testEquality(): void
    {
        // Given
        $price1 = new Price(99.99, 'USD');
        $price2 = new Price(99.99, 'USD');
        $price3 = new Price(99.99, 'EUR');
        $price4 = new Price(100.00, 'USD');
        
        // Then
        $this->assertTrue($price1->equals($price2));
        $this->assertFalse($price1->equals($price3)); // Different currency
        $this->assertFalse($price1->equals($price4)); // Different amount
    }
    
    public function testArithmetic(): void
    {
        // Given
        $price1 = new Price(100.00, 'USD');
        $price2 = new Price(50.00, 'USD');
        
        // When
        $sum = $price1->add($price2);
        $difference = $price1->subtract($price2);
        $multiplied = $price1->multiply(1.5);
        
        // Then
        $this->assertEquals(150.00, $sum->amount());
        $this->assertEquals(50.00, $difference->amount());
        $this->assertEquals(150.00, $multiplied->amount());
    }
    
    public function testCannotAddDifferentCurrencies(): void
    {
        // Given
        $price1 = new Price(100.00, 'USD');
        $price2 = new Price(100.00, 'EUR');
        
        // Then
        $this->expectException(InvalidArgumentException::class);
        $this->expectExceptionMessage('Cannot add prices with different currencies');
        
        // When
        $price1->add($price2);
    }
} 