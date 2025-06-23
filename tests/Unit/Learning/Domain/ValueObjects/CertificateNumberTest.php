<?php

declare(strict_types=1);

namespace Tests\Unit\Learning\Domain\ValueObjects;

use App\Learning\Domain\ValueObjects\CertificateNumber;
use PHPUnit\Framework\TestCase;

class CertificateNumberTest extends TestCase
{
    public function testCanBeCreatedWithValidFormat(): void
    {
        $number = 'CERT-2024-00001';
        $certificateNumber = new CertificateNumber($number);
        
        $this->assertEquals($number, $certificateNumber->getValue());
        $this->assertEquals($number, (string) $certificateNumber);
    }
    
    public function testCanBeGenerated(): void
    {
        $year = 2024;
        $sequence = 123;
        
        $certificateNumber = CertificateNumber::generate($year, $sequence);
        
        $this->assertEquals('CERT-2024-00123', $certificateNumber->getValue());
    }
    
    public function testGenerateWithPadding(): void
    {
        $this->assertEquals('CERT-2024-00001', CertificateNumber::generate(2024, 1)->getValue());
        $this->assertEquals('CERT-2024-00999', CertificateNumber::generate(2024, 999)->getValue());
        $this->assertEquals('CERT-2024-09999', CertificateNumber::generate(2024, 9999)->getValue());
        $this->assertEquals('CERT-2024-99999', CertificateNumber::generate(2024, 99999)->getValue());
    }
    
    public function testCanExtractYear(): void
    {
        $certificateNumber = new CertificateNumber('CERT-2024-00123');
        
        $this->assertEquals(2024, $certificateNumber->getYear());
    }
    
    public function testCanExtractSequence(): void
    {
        $certificateNumber = new CertificateNumber('CERT-2024-00123');
        
        $this->assertEquals(123, $certificateNumber->getSequence());
    }
    
    public function testThrowsExceptionForInvalidFormat(): void
    {
        $this->expectException(\InvalidArgumentException::class);
        $this->expectExceptionMessage('Invalid certificate number format');
        
        new CertificateNumber('INVALID-FORMAT');
    }
    
    public function testThrowsExceptionForInvalidYear(): void
    {
        $this->expectException(\InvalidArgumentException::class);
        $this->expectExceptionMessage('Invalid certificate number format');
        
        new CertificateNumber('CERT-20XX-00001');
    }
    
    public function testThrowsExceptionForInvalidSequence(): void
    {
        $this->expectException(\InvalidArgumentException::class);
        $this->expectExceptionMessage('Invalid certificate number format');
        
        new CertificateNumber('CERT-2024-ABC123');
    }
    
    public function testEquality(): void
    {
        $number1 = new CertificateNumber('CERT-2024-00123');
        $number2 = new CertificateNumber('CERT-2024-00123');
        $number3 = new CertificateNumber('CERT-2024-00124');
        
        $this->assertTrue($number1->equals($number2));
        $this->assertFalse($number1->equals($number3));
    }
} 