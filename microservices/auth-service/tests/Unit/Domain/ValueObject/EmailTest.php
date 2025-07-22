<?php

namespace App\Tests\Unit\Domain\ValueObject;

use App\Domain\ValueObject\Email;
use PHPUnit\Framework\TestCase;

class EmailTest extends TestCase
{
    public function testValidEmailCreation(): void
    {
        $email = new Email('test@example.com');
        
        $this->assertEquals('test@example.com', $email->getValue());
        $this->assertEquals('example.com', $email->getDomain());
        $this->assertEquals('test', $email->getLocalPart());
    }
    
    public function testEmailNormalization(): void
    {
        $email = new Email('  TEST@EXAMPLE.COM  ');
        
        $this->assertEquals('test@example.com', $email->getValue());
    }
    
    public function testInvalidEmailThrowsException(): void
    {
        $this->expectException(\InvalidArgumentException::class);
        $this->expectExceptionMessage('Invalid email address: notanemail');
        
        new Email('notanemail');
    }
    
    public function testEmptyEmailThrowsException(): void
    {
        $this->expectException(\InvalidArgumentException::class);
        
        new Email('');
    }
    
    public function testEmailEquality(): void
    {
        $email1 = new Email('test@example.com');
        $email2 = new Email('test@example.com');
        $email3 = new Email('other@example.com');
        
        $this->assertTrue($email1->equals($email2));
        $this->assertFalse($email1->equals($email3));
    }
    
    public function testEmailToString(): void
    {
        $email = new Email('test@example.com');
        
        $this->assertEquals('test@example.com', (string) $email);
    }
} 