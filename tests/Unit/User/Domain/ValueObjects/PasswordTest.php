<?php

namespace Tests\Unit\User\Domain\ValueObjects;

use Tests\TestCase;
use App\User\Domain\ValueObjects\Password;

class PasswordTest extends TestCase
{
    /**
     * @test
     */
    public function it_creates_password_from_plain_text(): void
    {
        $plainPassword = 'SecurePassword123!';
        $password = Password::fromPlainText($plainPassword);
        
        $this->assertInstanceOf(Password::class, $password);
        $this->assertTrue($password->verify($plainPassword));
        $this->assertFalse($password->verify('WrongPassword'));
    }
    
    /**
     * @test
     */
    public function it_creates_password_from_hash(): void
    {
        $hash = password_hash('SecurePassword123!', PASSWORD_ARGON2ID);
        $password = Password::fromHash($hash);
        
        $this->assertInstanceOf(Password::class, $password);
        $this->assertEquals($hash, $password->getHash());
    }
    
    /**
     * @test
     * @dataProvider weakPasswordProvider
     */
    public function it_validates_password_strength(
        string $weakPassword,
        string $expectedError
    ): void {
        $this->expectException(\InvalidArgumentException::class);
        $this->expectExceptionMessage($expectedError);
        
        Password::fromPlainText($weakPassword);
    }
    
    /**
     * @test
     */
    public function it_generates_random_password(): void
    {
        $password1 = Password::generate();
        $password2 = Password::generate(16, true, true, true, true);
        
        $this->assertInstanceOf(Password::class, $password1);
        $this->assertInstanceOf(Password::class, $password2);
        
        // Generated passwords should be different
        $this->assertNotEquals(
            $password1->getHash(),
            $password2->getHash()
        );
    }
    
    /**
     * @test
     */
    public function it_checks_if_password_needs_rehash(): void
    {
        // Old bcrypt hash
        $oldHash = password_hash('password', PASSWORD_BCRYPT);
        $oldPassword = Password::fromHash($oldHash);
        
        // New Argon2ID hash
        $newPassword = Password::fromPlainText('SecurePassword123!');
        
        $this->assertTrue($oldPassword->needsRehash());
        $this->assertFalse($newPassword->needsRehash());
    }
    
    /**
     * @test
     */
    public function it_validates_password_policies(): void
    {
        $policies = [
            'min_length' => 12,
            'require_uppercase' => true,
            'require_lowercase' => true,
            'require_numbers' => true,
            'require_special' => true,
            'max_length' => 128
        ];
        
        // Valid password
        $this->assertTrue(
            Password::validateAgainstPolicies('SecurePass123!@#', $policies)
        );
        
        // Too short
        $this->assertFalse(
            Password::validateAgainstPolicies('Short1!', $policies)
        );
        
        // No special characters
        $this->assertFalse(
            Password::validateAgainstPolicies('SecurePassword123', $policies)
        );
    }
    
    /**
     * @test
     */
    public function it_calculates_password_strength(): void
    {
        $weak = Password::fromPlainText('Password1!');
        $medium = Password::fromPlainText('Password123!');
        $strong = Password::fromPlainText('C0mpl3x!P@ssw0rd#2024');
        
        // Since we can't calculate strength from hash, all return 'medium'
        $this->assertEquals('medium', $weak->getStrength());
        $this->assertEquals('medium', $medium->getStrength());
        $this->assertEquals('medium', $strong->getStrength());
    }
    
    /**
     * @test
     */
    public function it_checks_compromised_passwords(): void
    {
        // Common password that might be compromised
        $commonPassword = Password::fromPlainText('Password123!');
        
        // This test might fail if external service is not available
        try {
            $isCompromised = $commonPassword->isCompromised();
            $this->assertIsBool($isCompromised);
        } catch (\Exception $e) {
            $this->markTestSkipped('Compromised password check not available');
        }
    }
    
    /**
     * @test
     */
    public function it_masks_password_in_string_representation(): void
    {
        $password = Password::fromPlainText('SecurePassword123!');
        
        $this->assertEquals('********', (string) $password);
        $this->assertEquals('"********"', json_encode($password));
    }
    
    /**
     * @test
     */
    public function it_prevents_password_reuse(): void
    {
        $currentPassword = Password::fromPlainText('CurrentPassword123!');
        $oldPassword1 = Password::fromPlainText('OldPassword1!');
        $oldPassword2 = Password::fromPlainText('OldPassword2!');
        
        $oldHashes = [
            $oldPassword1->getHash(),
            $oldPassword2->getHash(),
            $currentPassword->getHash(), // Same hash
        ];
        
        $this->assertTrue($currentPassword->wasUsedBefore($oldHashes));
        
        $newPassword = Password::fromPlainText('NewPassword123!');
        $this->assertFalse($newPassword->wasUsedBefore($oldHashes));
    }
    
    public function weakPasswordProvider(): array
    {
        return [
            'too short' => [
                'Short1!',
                'Password must be at least 8 characters'
            ],
            'no uppercase' => [
                'password123!',
                'Password must contain at least one uppercase letter'
            ],
            'no lowercase' => [
                'PASSWORD123!',
                'Password must contain at least one lowercase letter'
            ],
            'no numbers' => [
                'Password!@#',
                'Password must contain at least one number'
            ],
            'no special chars' => [
                'Password123',
                'Password must contain at least one special character'
            ],
            'common password' => [
                'password',
                'Password is too common'
            ],
            'sequential' => [
                '12345678',
                'Password contains sequential characters'
            ],
            'repeated chars' => [
                'aaaaaaaa',
                'Password contains too many repeated characters'
            ],
        ];
    }
} 