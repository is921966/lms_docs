<?php

declare(strict_types=1);

namespace User\Infrastructure\Repository;

use App\Common\Base\BaseRepository;
use App\Common\Exceptions\NotFoundException;
use App\User\Domain\User;
use App\User\Domain\Repository\UserRepositoryInterface;
use App\User\Domain\ValueObjects\Email;
use App\User\Domain\ValueObjects\UserId;
use Doctrine\ORM\EntityManagerInterface;
use Doctrine\ORM\QueryBuilder;

/**
 * User repository implementation
 */
class UserRepository extends BaseRepository implements UserRepositoryInterface
{
    public function __construct(EntityManagerInterface $entityManager)
    {
        parent::__construct($entityManager, User::class);
    }
    
    /**
     * Find user by ID
     */
    public function findById(UserId $id): ?User
    {
        return $this->find($id->getValue());
    }
    
    /**
     * Get user by ID (throws exception if not found)
     */
    public function getById(UserId $id): User
    {
        $user = $this->findById($id);
        
        if (!$user) {
            throw NotFoundException::forEntity('User', $id->getValue());
        }
        
        return $user;
    }
    
    /**
     * Find user by email
     */
    public function findByEmail(Email $email): ?User
    {
        return $this->findOneBy(['email.value' => $email->getValue()]);
    }
    
    /**
     * Find user by AD username
     */
    public function findByAdUsername(string $username): ?User
    {
        return $this->findOneBy(['adUsername' => $username]);
    }
    
    /**
     * Check if email exists
     */
    public function emailExists(Email $email, ?UserId $excludeUserId = null): bool
    {
        $qb = $this->createQueryBuilder('u')
            ->select('COUNT(u.id)')
            ->where('u.email.value = :email')
            ->setParameter('email', $email->getValue());
        
        if ($excludeUserId) {
            $qb->andWhere('u.id != :userId')
                ->setParameter('userId', $excludeUserId->getValue());
        }
        
        return (int) $qb->getQuery()->getSingleScalarResult() > 0;
    }
    
    /**
     * Find users by manager
     */
    public function findByManager(UserId $managerId): array
    {
        return $this->findBy(['managerId' => $managerId->getValue()]);
    }
    
    /**
     * Find users by department
     */
    public function findByDepartment(string $department): array
    {
        return $this->findBy(['department' => $department]);
    }
    
    /**
     * Find users by position
     */
    public function findByPosition(int $positionId): array
    {
        return $this->findBy(['positionId' => $positionId]);
    }
    
    /**
     * Find users with specific role
     */
    public function findByRole(string $roleName): array
    {
        return $this->createQueryBuilder('u')
            ->join('u.roles', 'r')
            ->where('r.name = :roleName')
            ->setParameter('roleName', $roleName)
            ->getQuery()
            ->getResult();
    }
    
    /**
     * Find active users
     */
    public function findActive(): array
    {
        return $this->findBy([
            'status' => User::STATUS_ACTIVE,
            'deletedAt' => null,
        ]);
    }
    
    /**
     * Find users for LDAP sync
     */
    public function findForLdapSync(\DateTimeInterface $lastSyncBefore): array
    {
        return $this->createQueryBuilder('u')
            ->where('u.adUsername IS NOT NULL')
            ->andWhere('u.status = :status')
            ->andWhere('u.ldapSyncedAt IS NULL OR u.ldapSyncedAt < :syncBefore')
            ->setParameter('status', User::STATUS_ACTIVE)
            ->setParameter('syncBefore', $lastSyncBefore)
            ->setMaxResults(100)
            ->getQuery()
            ->getResult();
    }
    
    /**
     * Search users
     */
    public function search(array $criteria): array
    {
        $qb = $this->createQueryBuilder('u');
        
        // Search query
        if (!empty($criteria['query'])) {
            $query = '%' . $criteria['query'] . '%';
            $qb->andWhere(
                $qb->expr()->orX(
                    'LOWER(u.firstName) LIKE LOWER(:query)',
                    'LOWER(u.lastName) LIKE LOWER(:query)',
                    'LOWER(u.email.value) LIKE LOWER(:query)',
                    'LOWER(u.department) LIKE LOWER(:query)'
                )
            )->setParameter('query', $query);
        }
        
        // Status filter
        if (!empty($criteria['status'])) {
            $qb->andWhere('u.status = :status')
                ->setParameter('status', $criteria['status']);
        }
        
        // Department filter
        if (!empty($criteria['department'])) {
            $qb->andWhere('u.department = :department')
                ->setParameter('department', $criteria['department']);
        }
        
        // Position filter
        if (!empty($criteria['position_id'])) {
            $qb->andWhere('u.positionId = :positionId')
                ->setParameter('positionId', $criteria['position_id']);
        }
        
        // Role filter
        if (!empty($criteria['role'])) {
            $qb->join('u.roles', 'r')
                ->andWhere('r.name = :role')
                ->setParameter('role', $criteria['role']);
        }
        
        // Is admin filter
        if (isset($criteria['is_admin'])) {
            $qb->andWhere('u.isAdmin = :isAdmin')
                ->setParameter('isAdmin', $criteria['is_admin']);
        }
        
        // Exclude deleted
        if (!isset($criteria['include_deleted']) || !$criteria['include_deleted']) {
            $qb->andWhere('u.deletedAt IS NULL');
        }
        
        // Sorting
        $sortField = $criteria['sort_by'] ?? 'lastName';
        $sortOrder = $criteria['sort_order'] ?? 'ASC';
        
        $allowedSortFields = [
            'firstName', 'lastName', 'email', 'department', 
            'createdAt', 'lastLoginAt', 'status'
        ];
        
        if (in_array($sortField, $allowedSortFields)) {
            if ($sortField === 'email') {
                $qb->orderBy('u.email.value', $sortOrder);
            } else {
                $qb->orderBy('u.' . $sortField, $sortOrder);
            }
        }
        
        // Pagination
        if (!empty($criteria['limit'])) {
            $qb->setMaxResults($criteria['limit']);
        }
        
        if (!empty($criteria['offset'])) {
            $qb->setFirstResult($criteria['offset']);
        }
        
        return $qb->getQuery()->getResult();
    }
    
    /**
     * Count users by criteria
     */
    public function countByCriteria(array $criteria): int
    {
        $qb = $this->createQueryBuilder('u')
            ->select('COUNT(u.id)');
        
        // Apply same filters as search but without pagination
        if (!empty($criteria['query'])) {
            $query = '%' . $criteria['query'] . '%';
            $qb->andWhere(
                $qb->expr()->orX(
                    'LOWER(u.firstName) LIKE LOWER(:query)',
                    'LOWER(u.lastName) LIKE LOWER(:query)',
                    'LOWER(u.email.value) LIKE LOWER(:query)',
                    'LOWER(u.department) LIKE LOWER(:query)'
                )
            )->setParameter('query', $query);
        }
        
        if (!empty($criteria['status'])) {
            $qb->andWhere('u.status = :status')
                ->setParameter('status', $criteria['status']);
        }
        
        if (!empty($criteria['department'])) {
            $qb->andWhere('u.department = :department')
                ->setParameter('department', $criteria['department']);
        }
        
        if (!empty($criteria['role'])) {
            $qb->join('u.roles', 'r')
                ->andWhere('r.name = :role')
                ->setParameter('role', $criteria['role']);
        }
        
        if (!isset($criteria['include_deleted']) || !$criteria['include_deleted']) {
            $qb->andWhere('u.deletedAt IS NULL');
        }
        
        return (int) $qb->getQuery()->getSingleScalarResult();
    }
    
    /**
     * Get user statistics
     */
    public function getStatistics(): array
    {
        $qb = $this->createQueryBuilder('u');
        
        return [
            'total' => $this->count(['deletedAt' => null]),
            'active' => $this->count(['status' => User::STATUS_ACTIVE, 'deletedAt' => null]),
            'inactive' => $this->count(['status' => User::STATUS_INACTIVE, 'deletedAt' => null]),
            'suspended' => $this->count(['status' => User::STATUS_SUSPENDED, 'deletedAt' => null]),
            'admins' => $this->count(['isAdmin' => true, 'deletedAt' => null]),
            'with_ldap' => $qb->select('COUNT(u.id)')
                ->where('u.adUsername IS NOT NULL')
                ->andWhere('u.deletedAt IS NULL')
                ->getQuery()
                ->getSingleScalarResult(),
        ];
    }
    
    /**
     * Save user
     */
    public function save(User $user): void
    {
        $this->getEntityManager()->persist($user);
        $this->getEntityManager()->flush();
        
        // Dispatch domain events
        $events = $user->pullDomainEvents();
        foreach ($events as $event) {
            // Event dispatcher will be injected and used here
            // $this->eventDispatcher->dispatch($event);
        }
    }
    
    /**
     * Remove user
     */
    public function remove(User $user): void
    {
        $this->getEntityManager()->remove($user);
        $this->getEntityManager()->flush();
    }
} 