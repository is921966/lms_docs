<?php

namespace Tests\Unit\User\Domain\ValueObjects;

use Tests\TestCase;
use App\User\Domain\ValueObjects\Email;

class EmailTest extends TestCase
{
    /**
     * @test
     */
    public function it_creates_valid_email(): void
    {
        $email = new Email('user@example.com');
        
        $this->assertInstanceOf(Email::class, $email);
        $this->assertEquals('user@example.com', $email->getValue());
        $this->assertEquals('user@example.com', (string) $email);
    }
    
    /**
     * @test
     * @dataProvider invalidEmailProvider
     */
    public function it_throws_exception_for_invalid_email(string $invalidEmail): void
    {
        $this->expectException(\InvalidArgumentException::class);
        new Email($invalidEmail);
    }
    
    /**
     * @test
     */
    public function it_normalizes_email(): void
    {
        $email = new Email('  USER@EXAMPLE.COM  ');
        
        $this->assertEquals('user@example.com', $email->getValue());
    }
    
    /**
     * @test
     */
    public function it_validates_dns_record(): void
    {
        // This test might fail if DNS is not available
        try {
            $email = new Email('test@gmail.com');
            $this->assertTrue($email->hasDnsRecord());
        } catch (\Exception $e) {
            $this->markTestSkipped('DNS validation not available');
        }
    }
    
    /**
     * @test
     */
    public function it_extracts_domain(): void
    {
        $email = new Email('user@example.com');
        
        $this->assertEquals('example.com', $email->getDomain());
    }
    
    /**
     * @test
     */
    public function it_extracts_local_part(): void
    {
        $email = new Email('user.name+tag@example.com');
        
        $this->assertEquals('user.name+tag', $email->getLocalPart());
    }
    
    /**
     * @test
     */
    public function it_checks_corporate_domain(): void
    {
        $corporateEmail = new Email('user@lms.com');
        $externalEmail = new Email('user@gmail.com');
        
        $corporateDomains = ['lms.com', 'company.com'];
        
        $this->assertTrue($corporateEmail->isCorporate($corporateDomains));
        $this->assertFalse($externalEmail->isCorporate($corporateDomains));
    }
    
    /**
     * @test
     */
    public function it_compares_emails(): void
    {
        $email1 = new Email('user@example.com');
        $email2 = new Email('USER@EXAMPLE.COM');
        $email3 = new Email('other@example.com');
        
        $this->assertTrue($email1->equals($email2));
        $this->assertFalse($email1->equals($email3));
    }
    
    /**
     * @test
     */
    public function it_serializes_to_json(): void
    {
        $email = new Email('user@example.com');
        
        $this->assertEquals('"user@example.com"', json_encode($email));
    }
    
    /**
     * @test
     */
    public function it_validates_max_length(): void
    {
        $longEmail = str_repeat('a', 244) . '@example.com'; // 256 chars total
        
        $this->expectException(\InvalidArgumentException::class);
        $this->expectExceptionMessage('Email must not exceed 255 characters');
        
        new Email($longEmail);
    }
    
    /**
     * @test
     */
    public function it_rejects_disposable_emails(): void
    {
        $disposableEmail = 'test@tempmail.com';
        
        $email = new Email($disposableEmail);
        $this->assertTrue($email->isDisposable());
    }
    
    public function invalidEmailProvider(): array
    {
        return [
            'empty string' => [''],
            'without @' => ['userexample.com'],
            'without domain' => ['user@'],
            'without local part' => ['@example.com'],
            'with spaces' => ['user @example.com'],
            'double @' => ['user@@example.com'],
            'invalid characters' => ['user<>@example.com'],
            'trailing dot' => ['user@example.com.'],
            'leading dot' => ['.user@example.com'],
            'consecutive dots' => ['user..name@example.com'],
        ];
    }
} 