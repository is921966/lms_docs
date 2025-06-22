<?php

namespace Tests;

use PHPUnit\Framework\TestCase;
use App\User\Domain\ValueObjects\EmailSimple;

class EmailSimpleTest extends TestCase
{
    public function testValidEmail(): void
    {
        $email = new EmailSimple('test@example.com');
        $this->assertEquals('test@example.com', $email->getValue());
    }
    
    public function testEmailIsLowercased(): void
    {
        $email = new EmailSimple('TEST@EXAMPLE.COM');
        $this->assertEquals('test@example.com', $email->getValue());
    }
    
    public function testEmailIsTrimmed(): void
    {
        $email = new EmailSimple('  test@example.com  ');
        $this->assertEquals('test@example.com', $email->getValue());
    }
    
    public function testEmptyEmailThrowsException(): void
    {
        $this->expectException(\InvalidArgumentException::class);
        $this->expectExceptionMessage('Email cannot be empty');
        new EmailSimple('');
    }
    
    public function testInvalidEmailThrowsException(): void
    {
        $this->expectException(\InvalidArgumentException::class);
        $this->expectExceptionMessage('Invalid email address');
        new EmailSimple('not-an-email');
    }
} 