<?php

declare(strict_types=1);

namespace App\User\Domain\Service;

use App\User\Domain\User;

/**
 * LDAP service interface
 */
interface LdapServiceInterface
{
    /**
     * Authenticate user against LDAP
     */
    public function authenticate(string $username, string $password): ?array;
    
    /**
     * Search user in LDAP
     */
    public function searchUser(string $username): ?array;
    
    /**
     * Search users by filter
     */
    public function searchUsers(string $filter, array $attributes = []): array;
    
    /**
     * Get user groups from LDAP
     */
    public function getUserGroups(string $username): array;
    
    /**
     * Sync user from LDAP
     */
    public function syncUser(User $user): void;
    
    /**
     * Sync all users from LDAP
     */
    public function syncAllUsers(): array;
    
    /**
     * Import user from LDAP
     */
    public function importUser(string $username): ?User;
    
    /**
     * Import users from LDAP group
     */
    public function importUsersFromGroup(string $groupDn): array;
    
    /**
     * Test LDAP connection
     */
    public function testConnection(): bool;
    
    /**
     * Get LDAP server info
     */
    public function getServerInfo(): array;
    
    /**
     * Map LDAP attributes to user data
     */
    public function mapLdapAttributes(array $ldapData): array;
    
    /**
     * Get organizational units
     */
    public function getOrganizationalUnits(): array;
    
    /**
     * Get departments from LDAP
     */
    public function getDepartments(): array;
} 