<?php

declare(strict_types=1);

namespace App\User\Infrastructure\Repository;

use App\Common\Exceptions\NotFoundException;
use App\User\Domain\Repository\UserRepositoryInterface;
use App\User\Domain\User;
use App\User\Domain\ValueObjects\Email;
use App\User\Domain\ValueObjects\UserId;
use Doctrine\ORM\EntityManagerInterface;
use Doctrine\ORM\EntityRepository;

/**
 * Doctrine implementation of UserRepository
 */
class DoctrineUserRepository implements UserRepositoryInterface
{
    private EntityRepository $repository;
    
    public function __construct(
        private EntityManagerInterface $entityManager
    ) {
        $this->repository = $entityManager->getRepository(User::class);
    }
    
    /**
     * Save user
     */
    public function save(User $user): void
    {
        $this->entityManager->persist($user);
        $this->entityManager->flush();
    }
    
    /**
     * Get user by ID
     */
    public function getById(UserId $userId): User
    {
        $user = $this->repository->find($userId->getValue());
        
        if (!$user) {
            throw new NotFoundException('User not found');
        }
        
        return $user;
    }
    
    /**
     * Find user by email
     */
    public function findByEmail(Email $email): ?User
    {
        return $this->repository->findOneBy(['email.value' => $email->getValue()]);
    }
    
    /**
     * Check if email exists
     */
    public function emailExists(Email $email, ?UserId $excludeUserId = null): bool
    {
        $qb = $this->repository->createQueryBuilder('u')
            ->select('COUNT(u.id)')
            ->where('u.email.value = :email')
            ->setParameter('email', $email->getValue());
        
        if ($excludeUserId) {
            $qb->andWhere('u.id != :excludeId')
                ->setParameter('excludeId', $excludeUserId->getValue());
        }
        
        return $qb->getQuery()->getSingleScalarResult() > 0;
    }
    
    /**
     * Find user by AD username
     */
    public function findByAdUsername(string $username): ?User
    {
        return $this->repository->findOneBy(['adUsername' => $username]);
    }
    
    /**
     * Search users
     */
    public function search(array $criteria): array
    {
        $qb = $this->repository->createQueryBuilder('u');
        
        // Apply filters
        if (!empty($criteria['search'])) {
            $search = '%' . $criteria['search'] . '%';
            $qb->andWhere('u.firstName LIKE :search OR u.lastName LIKE :search OR u.email.value LIKE :search')
                ->setParameter('search', $search);
        }
        
        if (!empty($criteria['status'])) {
            $qb->andWhere('u.status = :status')
                ->setParameter('status', $criteria['status']);
        }
        
        if (empty($criteria['includeDeleted'])) {
            $qb->andWhere('u.deletedAt IS NULL');
        }
        
        // Sorting
        $orderBy = $criteria['orderBy'] ?? 'lastName';
        $orderDir = $criteria['orderDir'] ?? 'ASC';
        $qb->orderBy('u.' . $orderBy, $orderDir);
        
        // Pagination
        $page = $criteria['page'] ?? 1;
        $perPage = $criteria['perPage'] ?? 20;
        $qb->setFirstResult(($page - 1) * $perPage)
            ->setMaxResults($perPage);
        
        return $qb->getQuery()->getResult();
    }
    
    /**
     * Get user statistics
     */
    public function getStatistics(): array
    {
        $qb = $this->repository->createQueryBuilder('u');
        
        $stats = [
            'total' => $qb->select('COUNT(u.id)')->getQuery()->getSingleScalarResult(),
            'active' => $qb->select('COUNT(u.id)')
                ->where('u.status = :status')
                ->setParameter('status', 'active')
                ->getQuery()->getSingleScalarResult(),
            'inactive' => $qb->select('COUNT(u.id)')
                ->where('u.status = :status')
                ->setParameter('status', 'inactive')
                ->getQuery()->getSingleScalarResult(),
            'suspended' => $qb->select('COUNT(u.id)')
                ->where('u.status = :status')
                ->setParameter('status', 'suspended')
                ->getQuery()->getSingleScalarResult(),
            'deleted' => $qb->select('COUNT(u.id)')
                ->where('u.deletedAt IS NOT NULL')
                ->getQuery()->getSingleScalarResult(),
        ];
        
        return $stats;
    }
    
    /**
     * Find user by ID
     */
    public function findById(UserId $userId): ?User
    {
        return $this->repository->find($userId->getValue());
    }
    
    /**
     * Find users by manager
     */
    public function findByManager(UserId $managerId): array
    {
        return $this->repository->findBy(['managerId' => $managerId->getValue()]);
    }
    
    /**
     * Find users by department
     */
    public function findByDepartment(string $department): array
    {
        return $this->repository->findBy(['department' => $department]);
    }
    
    /**
     * Find users by position
     */
    public function findByPosition(int $positionId): array
    {
        return $this->repository->findBy(['positionId' => $positionId]);
    }
    
    /**
     * Find users by role
     */
    public function findByRole(string $roleName): array
    {
        return $this->repository->createQueryBuilder('u')
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
        return $this->repository->findBy(['status' => 'active']);
    }
    
    /**
     * Find users for LDAP sync
     */
    public function findForLdapSync(\DateTimeInterface $lastSyncBefore): array
    {
        return $this->repository->createQueryBuilder('u')
            ->where('u.adUsername IS NOT NULL')
            ->andWhere('u.lastSyncedAt IS NULL OR u.lastSyncedAt < :lastSyncBefore')
            ->setParameter('lastSyncBefore', $lastSyncBefore)
            ->getQuery()
            ->getResult();
    }
    
    /**
     * Count users by criteria
     */
    public function countByCriteria(array $criteria): int
    {
        $qb = $this->repository->createQueryBuilder('u')
            ->select('COUNT(u.id)');
        
        // Apply same filters as search
        if (!empty($criteria['search'])) {
            $search = '%' . $criteria['search'] . '%';
            $qb->andWhere('u.firstName LIKE :search OR u.lastName LIKE :search OR u.email.value LIKE :search')
                ->setParameter('search', $search);
        }
        
        if (!empty($criteria['status'])) {
            $qb->andWhere('u.status = :status')
                ->setParameter('status', $criteria['status']);
        }
        
        if (empty($criteria['includeDeleted'])) {
            $qb->andWhere('u.deletedAt IS NULL');
        }
        
        return (int) $qb->getQuery()->getSingleScalarResult();
    }
    
    /**
     * Remove user
     */
    public function remove(User $user): void
    {
        $this->entityManager->remove($user);
        $this->entityManager->flush();
    }
} 