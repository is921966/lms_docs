<?php

declare(strict_types=1);

namespace App\User\Infrastructure\Service\Ldap;

use Psr\Log\LoggerInterface;

/**
 * Service for managing LDAP connections
 */
class LdapConnectionService
{
    private $connection = null;
    
    public function __construct(
        private array $config,
        private LoggerInterface $logger
    ) {
    }
    
    /**
     * Get LDAP connection
     */
    public function getConnection()
    {
        if ($this->connection === null) {
            $this->connect();
        }
        
        return $this->connection;
    }
    
    /**
     * Connect to LDAP server
     */
    private function connect(): void
    {
        $this->logger->info('Connecting to LDAP server', ['host' => $this->config['host']]);
        
        $this->connection = ldap_connect($this->config['host'], $this->config['port']);
        
        if (!$this->connection) {
            throw new \RuntimeException('Failed to connect to LDAP server');
        }
        
        // Set LDAP options
        ldap_set_option($this->connection, LDAP_OPT_PROTOCOL_VERSION, 3);
        ldap_set_option($this->connection, LDAP_OPT_REFERRALS, 0);
        
        if ($this->config['use_tls']) {
            if (!ldap_start_tls($this->connection)) {
                throw new \RuntimeException('Failed to start TLS');
            }
        }
        
        $this->logger->info('Connected to LDAP server successfully');
    }
    
    /**
     * Bind to LDAP with credentials
     */
    public function bind(string $username, string $password): bool
    {
        $connection = $this->getConnection();
        $bindDn = $this->constructBindDn($username);
        
        $this->logger->debug('Attempting LDAP bind', ['bind_dn' => $bindDn]);
        
        $result = @ldap_bind($connection, $bindDn, $password);
        
        if (!$result) {
            $this->logger->warning('LDAP bind failed', [
                'bind_dn' => $bindDn,
                'error' => ldap_error($connection)
            ]);
        }
        
        return $result;
    }
    
    /**
     * Search LDAP
     */
    public function search(string $baseDn, string $filter, array $attributes = []): array
    {
        $connection = $this->getConnection();
        
        $this->logger->debug('Searching LDAP', [
            'base_dn' => $baseDn,
            'filter' => $filter,
            'attributes' => $attributes
        ]);
        
        $result = ldap_search($connection, $baseDn, $filter, $attributes);
        
        if (!$result) {
            $this->logger->error('LDAP search failed', [
                'error' => ldap_error($connection)
            ]);
            return [];
        }
        
        $entries = ldap_get_entries($connection, $result);
        
        if ($entries === false) {
            return [];
        }
        
        // Remove count element
        unset($entries['count']);
        
        return $entries;
    }
    
    /**
     * Construct bind DN from username
     */
    private function constructBindDn(string $username): string
    {
        if (strpos($username, '@') !== false) {
            return $username;
        }
        
        if (!empty($this->config['bind_dn_template'])) {
            return str_replace('{username}', $username, $this->config['bind_dn_template']);
        }
        
        return $username . '@' . $this->config['domain'];
    }
    
    /**
     * Close LDAP connection
     */
    public function close(): void
    {
        if ($this->connection) {
            ldap_close($this->connection);
            $this->connection = null;
        }
    }
    
    /**
     * Destructor
     */
    public function __destruct()
    {
        $this->close();
    }
} 