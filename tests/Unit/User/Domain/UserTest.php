<?php

namespace Tests\Unit\User\Domain;

use Tests\TestCase;
use App\User\Domain\User;
use App\User\Domain\Role;
use App\User\Domain\ValueObjects\Email;
use App\User\Domain\ValueObjects\Password;
use App\User\Domain\ValueObjects\UserId;
use App\User\Domain\Events\UserCreated;
use App\User\Domain\Events\UserUpdated;
use App\User\Domain\Events\UserLoggedIn;

class UserTest extends TestCase
{
    /**
     * @test
     */
    public function it_creates_user_with_required_fields(): void
    {
        $email = new Email('user@example.com');
        $password = Password::fromPlainText('SecurePassword123!');
        
        $user = User::create(
            $email,
            'John',
            'Doe',
            $password
        );
        
        $this->assertInstanceOf(User::class, $user);
        $this->assertEquals('user@example.com', $user->getEmail()->getValue());
        $this->assertEquals('John', $user->getFirstName());
        $this->assertEquals('Doe', $user->getLastName());
        $this->assertEquals('John Doe', $user->getFullName());
        $this->assertEquals(User::STATUS_ACTIVE, $user->getStatus());
        
        // Check for UserCreated event
        $events = $user->pullDomainEvents();
        $this->assertCount(1, $events);
        $this->assertInstanceOf(UserCreated::class, $events[0]);
    }
    
    /**
     * @test
     */
    public function it_creates_user_from_ldap(): void
    {
        $ldapData = [
            'mail' => 'john.doe@company.com',
            'givenName' => 'John',
            'sn' => 'Doe',
            'sAMAccountName' => 'john.doe',
            'department' => 'IT',
            'title' => 'Developer',
            'displayName' => 'John Doe'
        ];
        
        $user = User::createFromLdap($ldapData);
        
        $this->assertEquals('john.doe', $user->getAdUsername());
        $this->assertEquals('IT', $user->getDepartment());
        $this->assertTrue($user->isLdapUser());
        $this->assertNotNull($user->getLdapSyncedAt());
        $this->assertEquals(User::STATUS_ACTIVE, $user->getStatus());
    }
    
    /**
     * @test
     */
    public function it_manages_user_roles(): void
    {
        $user = $this->createUser();
        $adminRole = Role::create('admin', 'Administrator');
        $managerRole = Role::create('manager', 'Manager');
        
        // Add roles
        $user->addRole($adminRole);
        $user->addRole($managerRole);
        
        $this->assertTrue($user->hasRole('admin'));
        $this->assertTrue($user->hasRole('manager'));
        $this->assertFalse($user->hasRole('employee'));
        $this->assertCount(2, $user->getRoles());
        
        // Remove role
        $user->removeRole($adminRole);
        
        $this->assertFalse($user->hasRole('admin'));
        $this->assertTrue($user->hasRole('manager'));
        $this->assertCount(1, $user->getRoles());
        
        // Sync roles
        $newRoles = [Role::create('employee', 'Employee')];
        $user->syncRoles($newRoles);
        
        $this->assertFalse($user->hasRole('manager'));
        $this->assertTrue($user->hasRole('employee'));
        $this->assertCount(1, $user->getRoles());
    }
    
    /**
     * @test
     */
    public function it_manages_user_status(): void
    {
        $user = $this->createUser();
        
        // Deactivate
        $user->deactivate();
        $this->assertEquals(User::STATUS_INACTIVE, $user->getStatus());
        $this->assertFalse($user->isActive());
        
        // Activate
        $user->activate();
        $this->assertEquals(User::STATUS_ACTIVE, $user->getStatus());
        $this->assertTrue($user->isActive());
        
        // Suspend
        $user->suspend('Policy violation', new \DateTime('+30 days'));
        $this->assertEquals(User::STATUS_SUSPENDED, $user->getStatus());
        $this->assertTrue($user->isSuspended());
        $this->assertEquals('Policy violation', $user->getSuspensionReason());
        $this->assertNotNull($user->getSuspendedUntil());
    }
    
    /**
     * @test
     */
    public function it_handles_soft_delete(): void
    {
        $user = $this->createUser();
        
        $user->delete();
        
        $this->assertTrue($user->isDeleted());
        $this->assertNotNull($user->getDeletedAt());
        
        $user->restore();
        
        $this->assertFalse($user->isDeleted());
        $this->assertNull($user->getDeletedAt());
    }
    
    /**
     * @test
     */
    public function it_verifies_password(): void
    {
        $plainPassword = 'SecurePassword123!';
        $user = $this->createUser($plainPassword);
        
        $this->assertTrue($user->verifyPassword($plainPassword));
        $this->assertFalse($user->verifyPassword('WrongPassword'));
    }
    
    /**
     * @test
     */
    public function it_changes_password(): void
    {
        $user = $this->createUser('OldPassword123!');
        $newPassword = Password::fromPlainText('NewPassword123!');
        
        $user->changePassword($newPassword);
        
        $this->assertTrue($user->verifyPassword('NewPassword123!'));
        $this->assertFalse($user->verifyPassword('OldPassword123!'));
    }
    
    /**
     * @test
     */
    public function it_updates_profile(): void
    {
        $user = $this->createUser();
        
        // Clear initial events
        $user->pullDomainEvents();
        
        $user->updateProfile(
            'Jane',
            'Smith',
            'Marie',
            '+7 (999) 123-45-67',
            'HR'
        );
        
        $this->assertEquals('Jane', $user->getFirstName());
        $this->assertEquals('Smith', $user->getLastName());
        $this->assertEquals('Marie', $user->getMiddleName());
        $this->assertEquals('+7 (999) 123-45-67', $user->getPhone());
        $this->assertEquals('HR', $user->getDepartment());
        
        $events = $user->pullDomainEvents();
        $this->assertCount(1, $events);
        $this->assertInstanceOf(UserUpdated::class, $events[0]);
    }
    
    /**
     * @test
     */
    public function it_handles_login(): void
    {
        $user = $this->createUser();
        
        // Clear initial events (UserCreated)
        $user->pullDomainEvents();
        
        $user->recordLogin('192.168.1.1', 'Mozilla/5.0');
        
        $this->assertNotNull($user->getLastLoginAt());
        $this->assertEquals('192.168.1.1', $user->getLastLoginIp());
        $this->assertEquals('Mozilla/5.0', $user->getLastUserAgent());
        $this->assertEquals(1, $user->getLoginCount());
        
        $events = $user->pullDomainEvents();
        $this->assertCount(1, $events);
        $this->assertInstanceOf(UserLoggedIn::class, $events[0]);
    }
    
    /**
     * @test
     */
    public function it_manages_two_factor_auth(): void
    {
        $user = $this->createUser();
        
        $this->assertFalse($user->hasTwoFactorEnabled());
        
        $secret = 'JBSWY3DPEHPK3PXP';
        $user->enableTwoFactor($secret);
        
        $this->assertTrue($user->hasTwoFactorEnabled());
        $this->assertEquals($secret, $user->getTwoFactorSecret());
        
        $user->disableTwoFactor();
        
        $this->assertFalse($user->hasTwoFactorEnabled());
        $this->assertNull($user->getTwoFactorSecret());
    }
    
    /**
     * @test
     */
    public function it_prevents_duplicate_role_assignment(): void
    {
        $user = $this->createUser();
        $role = Role::create('test_admin', 'Test Administrator');
        
        $user->addRole($role);
        $user->addRole($role); // Should not add duplicate
        
        $this->assertCount(1, $user->getRoles());
    }
    
    /**
     * @test
     */
    public function it_validates_email_change(): void
    {
        $user = $this->createUser();
        $newEmail = new Email('newemail@example.com');
        
        $user->changeEmail($newEmail);
        
        $this->assertEquals('newemail@example.com', $user->getEmail()->getValue());
        $this->assertFalse($user->isEmailVerified());
    }
    
    /**
     * @test
     */
    public function it_syncs_with_ldap_data(): void
    {
        $user = $this->createUser();
        
        $ldapData = [
            'givenName' => 'Updated',
            'sn' => 'Name',
            'department' => 'New Department',
            'title' => 'Senior Developer',
            'displayName' => 'Updated Name'
        ];
        
        $user->syncWithLdap($ldapData);
        
        $this->assertEquals('Updated', $user->getFirstName());
        $this->assertEquals('Name', $user->getLastName());
        $this->assertEquals('New Department', $user->getDepartment());
        $this->assertNotNull($user->getLdapSyncedAt());
    }
    
    private function createUser(string $password = 'Password123!'): User
    {
        return User::create(
            new Email('test@example.com'),
            'Test',
            'User',
            Password::fromPlainText($password)
        );
    }
} 