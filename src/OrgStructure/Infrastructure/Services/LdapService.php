<?php

namespace App\OrgStructure\Infrastructure\Services;

use App\OrgStructure\Domain\ValueObjects\TabNumber;
use App\OrgStructure\Infrastructure\DTO\LdapUserData;

class LdapService
{
    private $ldapConnection;
    private bool $isConnected = false;
    
    public function __construct($ldapConnection = null)
    {
        $this->ldapConnection = $ldapConnection;
        $this->isConnected = $ldapConnection !== null;
    }
    
    public function findUserByTabNumber(TabNumber $tabNumber): ?LdapUserData
    {
        if (!$this->isConnected) {
            return null;
        }
        
        $filter = "(employeeNumber={$tabNumber->toString()})";
        $searchResult = $this->ldapConnection->search(
            "OU=Users,DC=example,DC=com",
            $filter,
            ['cn', 'mail', 'telephonenumber', 'department', 'title', 'manager', 'distinguishedname']
        );
        
        if (!$searchResult) {
            return null;
        }
        
        $entries = $this->ldapConnection->get_entries($searchResult);
        
        if (!$entries || $entries['count'] === 0) {
            return null;
        }
        
        return $this->mapToUserData($entries[0], $tabNumber->toString());
    }
    
    public function syncEmployeeData(TabNumber $tabNumber): bool
    {
        $userData = $this->findUserByTabNumber($tabNumber);
        return $userData !== null;
    }
    
    /**
     * @return LdapUserData[]
     */
    public function getAllEmployees(): array
    {
        if (!$this->isConnected) {
            return [];
        }
        
        $filter = "(objectClass=user)";
        $searchResult = $this->ldapConnection->search(
            "OU=Users,DC=example,DC=com",
            $filter,
            ['employeenumber', 'cn', 'mail', 'telephonenumber', 'department', 'title', 'manager', 'distinguishedname']
        );
        
        if (!$searchResult) {
            return [];
        }
        
        $entries = $this->ldapConnection->get_entries($searchResult);
        
        if (!$entries || $entries['count'] === 0) {
            return [];
        }
        
        $users = [];
        for ($i = 0; $i < $entries['count']; $i++) {
            if (isset($entries[$i]['employeenumber'][0])) {
                $users[] = $this->mapToUserData($entries[$i], $entries[$i]['employeenumber'][0]);
            }
        }
        
        return $users;
    }
    
    public function isConnected(): bool
    {
        return $this->isConnected;
    }
    
    private function mapToUserData(array $entry, string $tabNumber): LdapUserData
    {
        return new LdapUserData(
            $tabNumber,
            $entry['cn'][0] ?? '',
            $entry['mail'][0] ?? '',
            $entry['telephonenumber'][0] ?? null,
            $entry['department'][0] ?? null,
            $entry['title'][0] ?? null,
            $entry['manager'][0] ?? null,
            $entry['distinguishedname'][0] ?? null
        );
    }
} 