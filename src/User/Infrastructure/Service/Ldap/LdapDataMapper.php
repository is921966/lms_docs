<?php

declare(strict_types=1);

namespace User\Infrastructure\Service\Ldap;

use App\User\Domain\User;
use App\User\Domain\ValueObjects\Email;
use App\User\Domain\ValueObjects\UserId;
use Psr\Log\LoggerInterface;

/**
 * Service for mapping LDAP data to domain models
 */
class LdapDataMapper
{
    public function __construct(
        private array $attributeMap,
        private LoggerInterface $logger
    ) {
    }
    
    /**
     * Map LDAP entry to user data array
     */
    public function mapLdapEntry(array $entry): array
    {
        $this->logger->debug('Mapping LDAP entry to user data');
        
        $userData = [];
        
        foreach ($this->attributeMap as $ldapAttr => $userField) {
            $value = $this->extractAttributeValue($entry, $ldapAttr);
            if ($value !== null) {
                $userData[$userField] = $value;
            }
        }
        
        // Ensure required fields
        if (empty($userData['email'])) {
            $userData['email'] = $this->generateEmailFromUsername($userData);
        }
        
        if (empty($userData['firstName'])) {
            $userData['firstName'] = $userData['displayName'] ?? 'Unknown';
        }
        
        if (empty($userData['lastName'])) {
            $userData['lastName'] = 'User';
        }
        
        $this->logger->debug('Mapped user data', ['userData' => $userData]);
        
        return $userData;
    }
    
    /**
     * Update user from LDAP data
     */
    public function updateUserFromLdap(User $user, array $ldapData): void
    {
        $this->logger->info('Updating user from LDAP', ['userId' => $user->getId()->getValue()]);
        
        $userData = $this->mapLdapEntry($ldapData);
        
        // Update basic info
        if (!empty($userData['firstName'])) {
            $user->updateProfile(
                $userData['firstName'],
                $user->getLastName(),
                $user->getMiddleName()
            );
        }
        
        if (!empty($userData['lastName'])) {
            $user->updateProfile(
                $user->getFirstName(),
                $userData['lastName'],
                $user->getMiddleName()
            );
        }
        
        if (!empty($userData['middleName'])) {
            $user->updateProfile(
                $user->getFirstName(),
                $user->getLastName(),
                $userData['middleName']
            );
        }
        
        // Update contact info
        if (!empty($userData['phone'])) {
            $user->updateContactInfo(
                $user->getEmail(),
                $userData['phone']
            );
        }
        
        // Update work info
        if (!empty($userData['department']) || !empty($userData['positionTitle'])) {
            $user->updateWorkInfo(
                $userData['department'] ?? $user->getDepartment(),
                $userData['positionTitle'] ?? $user->getPositionTitle(),
                $user->getPositionId()
            );
        }
        
        // Update display name
        if (!empty($userData['displayName'])) {
            $user->setDisplayName($userData['displayName']);
        }
        
        // Update manager
        if (!empty($userData['managerId'])) {
            try {
                $managerId = UserId::fromString($userData['managerId']);
                $user->setManagerId($managerId);
            } catch (\Exception $e) {
                $this->logger->warning('Invalid manager ID from LDAP', [
                    'managerId' => $userData['managerId']
                ]);
            }
        }
        
        // Mark as synced
        $user->markLdapSynced();
        
        $this->logger->info('User updated from LDAP successfully');
    }
    
    /**
     * Extract attribute value from LDAP entry
     */
    private function extractAttributeValue(array $entry, string $attribute): ?string
    {
        $attribute = strtolower($attribute);
        
        if (!isset($entry[$attribute])) {
            return null;
        }
        
        if (is_array($entry[$attribute])) {
            // LDAP returns arrays with 'count' and numeric indices
            if (isset($entry[$attribute][0])) {
                return $entry[$attribute][0];
            }
        }
        
        return null;
    }
    
    /**
     * Generate email from username if not provided
     */
    private function generateEmailFromUsername(array $userData): string
    {
        if (!empty($userData['username'])) {
            return $userData['username'] . '@example.com';
        }
        
        return 'unknown@example.com';
    }
} 