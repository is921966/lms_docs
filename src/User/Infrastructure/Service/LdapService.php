<?php

declare(strict_types=1);

namespace App\User\Infrastructure\Service;

use App\User\Domain\Service\LdapServiceInterface;
use App\User\Domain\User;
use App\User\Domain\ValueObjects\Email;
use App\User\Domain\Repository\UserRepositoryInterface;
use App\User\Domain\Repository\RoleRepositoryInterface;
use App\User\Infrastructure\Service\Ldap\LdapConnectionService;
use App\User\Infrastructure\Service\Ldap\LdapDataMapper;
use App\User\Infrastructure\Service\Ldap\LdapGroupService;
use Psr\Log\LoggerInterface;

/**
 * Refactored LDAP service implementation
 */
class LdapService implements LdapServiceInterface
{
    private LdapConnectionService $connectionService;
    private LdapDataMapper $dataMapper;
    private LdapGroupService $groupService;
    
    public function __construct(
        private array $config,
        private UserRepositoryInterface $userRepository,
        private RoleRepositoryInterface $roleRepository,
        private LoggerInterface $logger
    ) {
        $this->connectionService = new LdapConnectionService($config, $logger);
        $this->dataMapper = new LdapDataMapper($config['attribute_map'] ?? [], $logger);
        $this->groupService = new LdapGroupService($this->connectionService, $config, $logger);
    }
    
    /**
     * Authenticate user against LDAP
     */
    public function authenticate(string $username, string $password): ?array
    {
        $this->logger->info('Authenticating user via LDAP', ['username' => $username]);
        
        try {
            // Try to bind with user credentials
            if (!$this->connectionService->bind($username, $password)) {
                $this->logger->warning('LDAP authentication failed', ['username' => $username]);
                return null;
            }
            
            // Get user data
            $userData = $this->getUserData($username);
            
            if (!$userData) {
                $this->logger->warning('User not found in LDAP after successful bind', ['username' => $username]);
                return null;
            }
            
            $this->logger->info('LDAP authentication successful', ['username' => $username]);
            
            return $userData;
            
        } catch (\Exception $e) {
            $this->logger->error('LDAP authentication error', [
                'username' => $username,
                'error' => $e->getMessage()
            ]);
            return null;
        }
    }
    
    /**
     * Import user from LDAP
     */
    public function importUser(string $username): ?User
    {
        $this->logger->info('Importing user from LDAP', ['username' => $username]);
        
        try {
            // Bind with service account
            $this->bindAsServiceAccount();
            
            // Get user data
            $userData = $this->getUserData($username);
            
            if (!$userData) {
                $this->logger->warning('User not found in LDAP', ['username' => $username]);
                return null;
            }
            
            // Create user from LDAP data
            $user = User::createFromLdap($userData);
            
            // Assign roles based on LDAP groups
            $this->assignRolesFromGroups($user, $username);
            
            // Save user
            $this->userRepository->save($user);
            
            $this->logger->info('User imported from LDAP successfully', [
                'userId' => $user->getId()->getValue(),
                'username' => $username
            ]);
            
            return $user;
            
        } catch (\Exception $e) {
            $this->logger->error('Failed to import user from LDAP', [
                'username' => $username,
                'error' => $e->getMessage()
            ]);
            return null;
        }
    }
    
    /**
     * Sync user data from LDAP
     */
    public function syncUser(User $user): void
    {
        $this->logger->info('Syncing user from LDAP', ['userId' => $user->getId()->getValue()]);
        
        try {
            // Bind with service account
            $this->bindAsServiceAccount();
            
            // Get username
            $username = $user->getAdUsername();
            if (!$username) {
                $this->logger->warning('User has no AD username', ['userId' => $user->getId()->getValue()]);
                return;
            }
            
            // Get user data
            $userData = $this->getUserData($username);
            
            if (!$userData) {
                $this->logger->warning('User not found in LDAP', [
                    'userId' => $user->getId()->getValue(),
                    'username' => $username
                ]);
                return;
            }
            
            // Update user from LDAP data
            $this->dataMapper->updateUserFromLdap($user, $userData);
            
            // Update roles based on LDAP groups
            $this->assignRolesFromGroups($user, $username);
            
            // Save user
            $this->userRepository->save($user);
            
            $this->logger->info('User synced from LDAP successfully', [
                'userId' => $user->getId()->getValue()
            ]);
            
        } catch (\Exception $e) {
            $this->logger->error('Failed to sync user from LDAP', [
                'userId' => $user->getId()->getValue(),
                'error' => $e->getMessage()
            ]);
        }
    }
    
    /**
     * Sync all users from LDAP
     */
    public function syncAllUsers(): array
    {
        $this->logger->info('Starting LDAP sync for all users');
        
        $results = [
            'synced' => 0,
            'failed' => 0,
            'errors' => []
        ];
        
        try {
            // Bind with service account
            $this->bindAsServiceAccount();
            
            // Get all users from LDAP
            $filter = $this->config['user_filter'] ?? '(&(objectClass=user)(objectCategory=person))';
            $baseDn = $this->config['base_dn'];
            
            $entries = $this->connectionService->search($baseDn, $filter);
            
            foreach ($entries as $entry) {
                try {
                    $userData = $this->dataMapper->mapLdapEntry($entry);
                    
                    if (empty($userData['username'])) {
                        continue;
                    }
                    
                    // Find existing user
                    $user = $this->userRepository->findByAdUsername($userData['username']);
                    
                    if (!$user && !empty($userData['email'])) {
                        $user = $this->userRepository->findByEmail(new Email($userData['email']));
                    }
                    
                    if ($user) {
                        // Update existing user
                        $this->dataMapper->updateUserFromLdap($user, $entry);
                        $this->assignRolesFromGroups($user, $userData['username']);
                        $this->userRepository->save($user);
                    } else {
                        // Import new user
                        $user = User::createFromLdap($userData);
                        $this->assignRolesFromGroups($user, $userData['username']);
                        $this->userRepository->save($user);
                    }
                    
                    $results['synced']++;
                    
                } catch (\Exception $e) {
                    $results['failed']++;
                    $results['errors'][] = $e->getMessage();
                    
                    $this->logger->error('Failed to sync user', [
                        'error' => $e->getMessage()
                    ]);
                }
            }
            
            $this->logger->info('LDAP sync completed', $results);
            
        } catch (\Exception $e) {
            $this->logger->error('LDAP sync failed', [
                'error' => $e->getMessage()
            ]);
            
            $results['errors'][] = $e->getMessage();
        }
        
        return $results;
    }
    
    /**
     * Get user data from LDAP
     */
    private function getUserData(string $username): ?array
    {
        $filter = sprintf($this->config['user_filter_template'], $username);
        $baseDn = $this->config['base_dn'];
        
        $entries = $this->connectionService->search($baseDn, $filter);
        
        if (empty($entries)) {
            return null;
        }
        
        return $this->dataMapper->mapLdapEntry($entries[0]);
    }
    
    /**
     * Bind to LDAP as service account
     */
    private function bindAsServiceAccount(): void
    {
        if (!empty($this->config['bind_dn']) && !empty($this->config['bind_password'])) {
            if (!$this->connectionService->bind($this->config['bind_dn'], $this->config['bind_password'])) {
                throw new \RuntimeException('Failed to bind as service account');
            }
        }
    }
    
    /**
     * Assign roles to user based on LDAP groups
     */
    private function assignRolesFromGroups(User $user, string $username): void
    {
        $groups = $this->groupService->getUserGroups($username);
        $roleNames = $this->groupService->mapGroupsToRoles($groups);
        
        // Clear existing roles
        foreach ($user->getRoles() as $role) {
            $user->removeRole($role);
        }
        
        // Assign new roles
        foreach ($roleNames as $roleName) {
            $role = $this->roleRepository->findByName($roleName);
            if ($role) {
                $user->addRole($role);
            }
        }
    }
} 