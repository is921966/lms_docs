<?php

declare(strict_types=1);

namespace Tests\Unit\Domain\ValueObject;

use PHPUnit\Framework\TestCase;
use App\Domain\ValueObject\Password;
use App\Domain\Exception\InvalidPasswordException;

class PasswordTest extends TestCase
{
    public function testValidPasswordCreation(): void
    {
        $password = new Password('SecurePassword123!');
        $this->assertInstanceOf(Password::class, $password);
    }

    public function testPasswordHashing(): void
    {
        $rawPassword = 'SecurePassword123!';
        $password = new Password($rawPassword);
        
        $this->assertTrue($password->verify($rawPassword));
        $this->assertFalse($password->verify('WrongPassword'));
    }

    public function testPasswordTooShort(): void
    {
        $this->expectException(InvalidPasswordException::class);
        $this->expectExceptionMessage('Password must be at least 8 characters long');
        
        new Password('short');
    }

    public function testPasswordTooLong(): void
    {
        $this->expectException(InvalidPasswordException::class);
        $this->expectExceptionMessage('Password must not exceed 255 characters');
        
        new Password(str_repeat('a', 256));
    }

    public function testPasswordEquality(): void
    {
        $password1 = new Password('SecurePassword123!');
        $password2 = new Password('SecurePassword123!');
        $password3 = new Password('DifferentPassword123!');
        
        // Same raw password should result in different hashes
        $this->assertNotEquals($password1->getHash(), $password2->getHash());
        
        // But both should verify the original password
        $this->assertTrue($password1->verify('SecurePassword123!'));
        $this->assertTrue($password2->verify('SecurePassword123!'));
        
        // Different password should not verify
        $this->assertFalse($password3->verify('SecurePassword123!'));
    }

    public function testFromHash(): void
    {
        $originalPassword = new Password('SecurePassword123!');
        $hash = $originalPassword->getHash();
        
        $passwordFromHash = Password::fromHash($hash);
        
        $this->assertEquals($hash, $passwordFromHash->getHash());
        $this->assertTrue($passwordFromHash->verify('SecurePassword123!'));
    }

    public function testEmptyPassword(): void
    {
        $this->expectException(InvalidPasswordException::class);
        $this->expectExceptionMessage('Password cannot be empty');
        
        new Password('');
    }

    public function testPasswordStrength(): void
    {
        // Test weak passwords that should be rejected
        $weakPasswords = [
            'password',     // Too common
            '12345678',     // Only numbers
            'aaaaaaaa',     // Repeated characters
            'Password',     // No numbers/special chars
        ];
        
        foreach ($weakPasswords as $weak) {
            try {
                new Password($weak);
                $this->fail("Weak password '$weak' should have been rejected");
            } catch (InvalidPasswordException $e) {
                $this->assertStringContainsString('Password is too weak', $e->getMessage());
            }
        }
        
        // Test strong passwords that should be accepted
        $strongPasswords = [
            'P@ssw0rd123!',
            'Str0ng&Secure!',
            'MyP@ss2024#',
        ];
        
        foreach ($strongPasswords as $strong) {
            $password = new Password($strong);
            $this->assertInstanceOf(Password::class, $password);
        }
    }
} 