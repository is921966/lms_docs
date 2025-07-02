<?php

declare(strict_types=1);

namespace User\Infrastructure\Http;

use App\Common\Http\BaseController;
use App\User\Domain\Service\LdapServiceInterface;
use Psr\Http\Message\ResponseInterface;
use Psr\Http\Message\ServerRequestInterface;

/**
 * LDAP management controller
 */
class LdapController extends BaseController
{
    public function __construct(
        private LdapServiceInterface $ldapService
    ) {
    }
    
    /**
     * Test LDAP connection
     */
    public function testConnection(ServerRequestInterface $request, ResponseInterface $response): ResponseInterface
    {
        $this->requirePermission($request, 'ldap.manage');
        
        try {
            $connected = $this->ldapService->testConnection();
            
            if ($connected) {
                return $this->success($response, [
                    'connected' => true,
                    'message' => 'LDAP connection successful'
                ]);
            } else {
                return $this->error($response, 'LDAP connection failed', [], 503);
            }
        } catch (\Exception $e) {
            return $this->error($response, 'LDAP connection error: ' . $e->getMessage(), [], 503);
        }
    }
    
    /**
     * Get LDAP server information
     */
    public function serverInfo(ServerRequestInterface $request, ResponseInterface $response): ResponseInterface
    {
        $this->requirePermission($request, 'ldap.manage');
        
        try {
            $info = $this->ldapService->getServerInfo();
            return $this->success($response, $info);
        } catch (\Exception $e) {
            return $this->error($response, 'Failed to get server info: ' . $e->getMessage(), [], 500);
        }
    }
    
    /**
     * Search users in LDAP
     */
    public function searchUsers(ServerRequestInterface $request, ResponseInterface $response): ResponseInterface
    {
        $this->requirePermission($request, 'ldap.search');
        
        $queryParams = $this->getQueryParams($request);
        $query = $queryParams['q'] ?? '';
        
        if (empty($query)) {
            return $this->error($response, 'Search query is required', [], 422);
        }
        
        try {
            $filter = sprintf('(|(cn=*%s*)(mail=*%s*)(sAMAccountName=*%s*))', 
                ldap_escape($query, '', LDAP_ESCAPE_FILTER),
                ldap_escape($query, '', LDAP_ESCAPE_FILTER),
                ldap_escape($query, '', LDAP_ESCAPE_FILTER)
            );
            
            $users = $this->ldapService->searchUsers($filter);
            
            // Transform LDAP data for response
            $results = array_map(fn($user) => $this->ldapService->mapLdapAttributes($user), $users);
            
            return $this->success($response, $results);
        } catch (\Exception $e) {
            return $this->error($response, 'LDAP search failed: ' . $e->getMessage(), [], 500);
        }
    }
    
    /**
     * Import single user from LDAP
     */
    public function importUser(ServerRequestInterface $request, ResponseInterface $response): ResponseInterface
    {
        $this->requirePermission($request, 'ldap.import');
        
        $data = $this->getValidatedData($request);
        
        if (empty($data['username'])) {
            return $this->error($response, 'Username is required', [], 422);
        }
        
        try {
            $user = $this->ldapService->importUser($data['username']);
            
            if ($user) {
                return $this->success($response, [
                    'id' => $user->getId()->getValue(),
                    'email' => $user->getEmail()->getValue(),
                    'name' => $user->getFullName()
                ], 'User imported successfully');
            } else {
                return $this->error($response, 'User not found in LDAP or import failed', [], 404);
            }
        } catch (\Exception $e) {
            return $this->error($response, 'Import failed: ' . $e->getMessage(), [], 500);
        }
    }
    
    /**
     * Import users from LDAP group
     */
    public function importGroup(ServerRequestInterface $request, ResponseInterface $response): ResponseInterface
    {
        $this->requirePermission($request, 'ldap.import');
        
        $data = $this->getValidatedData($request);
        
        if (empty($data['group_dn'])) {
            return $this->error($response, 'Group DN is required', [], 422);
        }
        
        try {
            $results = $this->ldapService->importUsersFromGroup($data['group_dn']);
            return $this->success($response, $results, 'Group import completed');
        } catch (\Exception $e) {
            return $this->error($response, 'Group import failed: ' . $e->getMessage(), [], 500);
        }
    }
    
    /**
     * Sync all users from LDAP
     */
    public function syncAll(ServerRequestInterface $request, ResponseInterface $response): ResponseInterface
    {
        $this->requirePermission($request, 'ldap.sync');
        
        try {
            // This could be a long-running operation
            set_time_limit(300); // 5 minutes
            
            $results = $this->ldapService->syncAllUsers();
            return $this->success($response, $results, 'LDAP sync completed');
        } catch (\Exception $e) {
            return $this->error($response, 'Sync failed: ' . $e->getMessage(), [], 500);
        }
    }
    
    /**
     * Get organizational units
     */
    public function organizationalUnits(ServerRequestInterface $request, ResponseInterface $response): ResponseInterface
    {
        $this->requirePermission($request, 'ldap.search');
        
        try {
            $ous = $this->ldapService->getOrganizationalUnits();
            return $this->success($response, $ous);
        } catch (\Exception $e) {
            return $this->error($response, 'Failed to get organizational units: ' . $e->getMessage(), [], 500);
        }
    }
    
    /**
     * Get departments from LDAP
     */
    public function departments(ServerRequestInterface $request, ResponseInterface $response): ResponseInterface
    {
        $this->requirePermission($request, 'ldap.search');
        
        try {
            $departments = $this->ldapService->getDepartments();
            return $this->success($response, $departments);
        } catch (\Exception $e) {
            return $this->error($response, 'Failed to get departments: ' . $e->getMessage(), [], 500);
        }
    }
    
    /**
     * Get user groups from LDAP
     */
    public function userGroups(ServerRequestInterface $request, ResponseInterface $response): ResponseInterface
    {
        $this->requirePermission($request, 'ldap.search');
        
        $username = $this->getRouteParam($request, 'username');
        
        if (!$username) {
            return $this->error($response, 'Username is required', [], 400);
        }
        
        try {
            $groups = $this->ldapService->getUserGroups($username);
            return $this->success($response, $groups);
        } catch (\Exception $e) {
            return $this->error($response, 'Failed to get user groups: ' . $e->getMessage(), [], 500);
        }
    }
} 