<?php

namespace User\Infrastructure\Persistence\MySQL;

use User\Domain\User;
use User\Domain\UserRepository;
use User\Domain\ValueObjects\UserId;
use User\Domain\ValueObjects\Email;
use User\Domain\ValueObjects\Password;
use PDO;

class MySQLUserRepository implements UserRepository
{
    private PDO $pdo;

    public function __construct(PDO $pdo)
    {
        $this->pdo = $pdo;
    }

    public function findByEmail(string $email): ?User
    {
        $stmt = $this->pdo->prepare('SELECT * FROM users WHERE email = :email LIMIT 1');
        $stmt->execute(['email' => $email]);
        
        $row = $stmt->fetch(PDO::FETCH_ASSOC);
        if (!$row) {
            return null;
        }
        
        return $this->hydrate($row);
    }

    public function findById(UserId $id): ?User
    {
        $stmt = $this->pdo->prepare('SELECT * FROM users WHERE id = :id LIMIT 1');
        $stmt->execute(['id' => (string) $id]);
        
        $row = $stmt->fetch(PDO::FETCH_ASSOC);
        if (!$row) {
            return null;
        }
        
        return $this->hydrate($row);
    }

    public function findAll(): array
    {
        $stmt = $this->pdo->query('SELECT * FROM users ORDER BY created_at DESC');
        $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        return array_map([$this, 'hydrate'], $rows);
    }

    public function save(User $user): void
    {
        $data = $this->extract($user);
        
        // Проверить, существует ли пользователь
        $exists = $this->findById($user->getId()) !== null;
        
        if ($exists) {
            $this->update($user->getId(), $data);
        } else {
            $this->insert($data);
        }
    }

    public function nextId(): int
    {
        // Не используется, так как используем UUID
        return 0;
    }

    private function insert(array $data): void
    {
        $columns = array_keys($data);
        $placeholders = array_map(fn($col) => ':' . $col, $columns);
        
        $sql = sprintf(
            'INSERT INTO users (%s) VALUES (%s)',
            implode(', ', $columns),
            implode(', ', $placeholders)
        );
        
        $stmt = $this->pdo->prepare($sql);
        $stmt->execute($data);
    }

    private function update(UserId $id, array $data): void
    {
        unset($data['id']); // ID не обновляется
        unset($data['created_at']); // created_at не обновляется
        
        $sets = array_map(fn($col) => $col . ' = :' . $col, array_keys($data));
        
        $sql = sprintf(
            'UPDATE users SET %s WHERE id = :id',
            implode(', ', $sets)
        );
        
        $data['id'] = (string) $id;
        
        $stmt = $this->pdo->prepare($sql);
        $stmt->execute($data);
    }

    private function hydrate(array $row): User
    {
        // Использовать reflection для создания User с приватным конструктором
        $reflection = new \ReflectionClass(User::class);
        $user = $reflection->newInstanceWithoutConstructor();
        
        // Заполнить свойства через reflection
        $this->setProperty($user, 'id', UserId::fromString($row['id']));
        $this->setProperty($user, 'email', new Email($row['email']));
        $this->setProperty($user, 'firstName', $row['first_name']);
        $this->setProperty($user, 'lastName', $row['last_name']);
        $this->setProperty($user, 'middleName', $row['middle_name']);
        $this->setProperty($user, 'phone', $row['phone']);
        $this->setProperty($user, 'department', $row['department']);
        $this->setProperty($user, 'displayName', $row['display_name']);
        $this->setProperty($user, 'positionTitle', $row['position_title']);
        $this->setProperty($user, 'positionId', $row['position_id']);
        $this->setProperty($user, 'status', $row['status']);
        $this->setProperty($user, 'isAdmin', (bool) $row['is_admin']);
        
        if ($row['password']) {
            $this->setProperty($user, 'password', Password::fromHash($row['password']));
        }
        
        if ($row['manager_id']) {
            $this->setProperty($user, 'managerId', UserId::fromString($row['manager_id']));
        }
        
        $this->setProperty($user, 'adUsername', $row['ad_username']);
        $this->setProperty($user, 'suspensionReason', $row['suspension_reason']);
        $this->setProperty($user, 'loginCount', (int) $row['login_count']);
        $this->setProperty($user, 'twoFactorEnabled', (bool) $row['two_factor_enabled']);
        $this->setProperty($user, 'twoFactorSecret', $row['two_factor_secret']);
        $this->setProperty($user, 'lastLoginIp', $row['last_login_ip']);
        $this->setProperty($user, 'lastUserAgent', $row['last_user_agent']);
        
        // Timestamps
        $this->setProperty($user, 'createdAt', new \DateTimeImmutable($row['created_at']));
        $this->setProperty($user, 'updatedAt', new \DateTimeImmutable($row['updated_at']));
        
        if ($row['deleted_at']) {
            $this->setProperty($user, 'deletedAt', new \DateTimeImmutable($row['deleted_at']));
        }
        
        if ($row['suspended_until']) {
            $this->setProperty($user, 'suspendedUntil', new \DateTimeImmutable($row['suspended_until']));
        }
        
        if ($row['email_verified_at']) {
            $this->setProperty($user, 'emailVerifiedAt', new \DateTimeImmutable($row['email_verified_at']));
        }
        
        if ($row['password_changed_at']) {
            $this->setProperty($user, 'passwordChangedAt', new \DateTimeImmutable($row['password_changed_at']));
        }
        
        if ($row['last_login_at']) {
            $this->setProperty($user, 'lastLoginAt', new \DateTimeImmutable($row['last_login_at']));
        }
        
        if ($row['ldap_synced_at']) {
            $this->setProperty($user, 'ldapSyncedAt', new \DateTimeImmutable($row['ldap_synced_at']));
        }
        
        // Metadata
        if ($row['metadata']) {
            $metadata = json_decode($row['metadata'], true) ?? [];
            $this->setProperty($user, 'metadata', $metadata);
        }
        
        // Collections
        $this->setProperty($user, 'roles', new \Doctrine\Common\Collections\ArrayCollection());
        $this->setProperty($user, 'permissions', []);
        $this->setProperty($user, 'domainEvents', []);
        
        return $user;
    }

    private function extract(User $user): array
    {
        $data = [
            'id' => (string) $user->getId(),
            'email' => $user->getEmail(),
            'first_name' => $user->getFirstName(),
            'last_name' => $user->getLastName(),
            'middle_name' => $user->getMiddleName(),
            'phone' => $user->getPhone(),
            'department' => $user->getDepartment(),
            'display_name' => $this->getPropertyValue($user, 'displayName'),
            'position_title' => $this->getPropertyValue($user, 'positionTitle'),
            'position_id' => $this->getPropertyValue($user, 'positionId'),
            'manager_id' => $this->getPropertyValue($user, 'managerId') ? (string) $this->getPropertyValue($user, 'managerId') : null,
            'ad_username' => $this->getPropertyValue($user, 'adUsername'),
            'status' => $user->getStatus(),
            'is_admin' => $user->isAdmin() ? 1 : 0,
            'suspension_reason' => $this->getPropertyValue($user, 'suspensionReason'),
            'login_count' => $this->getPropertyValue($user, 'loginCount'),
            'two_factor_enabled' => $this->getPropertyValue($user, 'twoFactorEnabled') ? 1 : 0,
            'two_factor_secret' => $this->getPropertyValue($user, 'twoFactorSecret'),
            'last_login_ip' => $this->getPropertyValue($user, 'lastLoginIp'),
            'last_user_agent' => $this->getPropertyValue($user, 'lastUserAgent'),
            'created_at' => $user->getCreatedAt()->format('Y-m-d H:i:s'),
            'updated_at' => $user->getUpdatedAt()->format('Y-m-d H:i:s')
        ];
        
        // Password
        $password = $user->getPassword();
        $data['password'] = $password ? $password->getHash() : null;
        
        // Optional timestamps
        $deletedAt = $user->getDeletedAt();
        $data['deleted_at'] = $deletedAt ? $deletedAt->format('Y-m-d H:i:s') : null;
        
        $suspendedUntil = $this->getPropertyValue($user, 'suspendedUntil');
        $data['suspended_until'] = $suspendedUntil ? $suspendedUntil->format('Y-m-d H:i:s') : null;
        
        $emailVerifiedAt = $this->getPropertyValue($user, 'emailVerifiedAt');
        $data['email_verified_at'] = $emailVerifiedAt ? $emailVerifiedAt->format('Y-m-d H:i:s') : null;
        
        $passwordChangedAt = $this->getPropertyValue($user, 'passwordChangedAt');
        $data['password_changed_at'] = $passwordChangedAt ? $passwordChangedAt->format('Y-m-d H:i:s') : null;
        
        $lastLoginAt = $user->getLastLoginAt();
        $data['last_login_at'] = $lastLoginAt ? $lastLoginAt->format('Y-m-d H:i:s') : null;
        
        $ldapSyncedAt = $user->getLdapSyncedAt();
        $data['ldap_synced_at'] = $ldapSyncedAt ? $ldapSyncedAt->format('Y-m-d H:i:s') : null;
        
        // Metadata
        $metadata = $this->getPropertyValue($user, 'metadata');
        $data['metadata'] = $metadata ? json_encode($metadata) : null;
        
        return $data;
    }

    private function setProperty($object, string $property, $value): void
    {
        $reflection = new \ReflectionClass($object);
        $prop = $reflection->getProperty($property);
        $prop->setAccessible(true);
        $prop->setValue($object, $value);
    }

    private function getPropertyValue($object, string $property)
    {
        $reflection = new \ReflectionClass($object);
        if (!$reflection->hasProperty($property)) {
            return null;
        }
        $prop = $reflection->getProperty($property);
        $prop->setAccessible(true);
        return $prop->getValue($object);
    }
} 