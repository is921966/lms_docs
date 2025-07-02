<?php

declare(strict_types=1);

namespace User\Infrastructure\Service\Ldap;

use Psr\Log\LoggerInterface;

/**
 * Service for managing LDAP groups
 */
class LdapGroupService
{
    public function __construct(
        private LdapConnectionService $connectionService,
        private array $config,
        private LoggerInterface $logger
    ) {
    }
    
    /**
     * Get user groups from LDAP
     */
    public function getUserGroups(string $username): array
    {
        $this->logger->info('Getting user groups from LDAP', ['username' => $username]);
        
        $filter = sprintf($this->config['group_member_filter'], $username);
        $baseDn = $this->config['group_base_dn'];
        
        $entries = $this->connectionService->search($baseDn, $filter, ['cn', 'description']);
        
        $groups = [];
        foreach ($entries as $entry) {
            if (isset($entry['cn'][0])) {
                $groups[] = [
                    'name' => $entry['cn'][0],
                    'description' => $entry['description'][0] ?? ''
                ];
            }
        }
        
        $this->logger->info('Found user groups', [
            'username' => $username,
            'groups' => array_column($groups, 'name')
        ]);
        
        return $groups;
    }
    
    /**
     * Check if user is member of group
     */
    public function isMemberOf(string $username, string $groupName): bool
    {
        $groups = $this->getUserGroups($username);
        
        foreach ($groups as $group) {
            if (strcasecmp($group['name'], $groupName) === 0) {
                return true;
            }
        }
        
        return false;
    }
    
    /**
     * Get all groups
     */
    public function getAllGroups(): array
    {
        $this->logger->info('Getting all groups from LDAP');
        
        $filter = $this->config['group_filter'] ?? '(objectClass=group)';
        $baseDn = $this->config['group_base_dn'];
        
        $entries = $this->connectionService->search($baseDn, $filter, ['cn', 'description']);
        
        $groups = [];
        foreach ($entries as $entry) {
            if (isset($entry['cn'][0])) {
                $groups[] = [
                    'name' => $entry['cn'][0],
                    'description' => $entry['description'][0] ?? ''
                ];
            }
        }
        
        $this->logger->info('Found groups', ['count' => count($groups)]);
        
        return $groups;
    }
    
    /**
     * Map LDAP groups to application roles
     */
    public function mapGroupsToRoles(array $groups): array
    {
        $roles = [];
        
        if (empty($this->config['group_role_mapping'])) {
            return $roles;
        }
        
        foreach ($groups as $group) {
            $groupName = $group['name'] ?? $group;
            
            if (isset($this->config['group_role_mapping'][$groupName])) {
                $role = $this->config['group_role_mapping'][$groupName];
                if (!in_array($role, $roles)) {
                    $roles[] = $role;
                }
            }
        }
        
        $this->logger->debug('Mapped groups to roles', [
            'groups' => array_map(fn($g) => is_array($g) ? $g['name'] : $g, $groups),
            'roles' => $roles
        ]);
        
        return $roles;
    }
} 