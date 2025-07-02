<?php

declare(strict_types=1);

namespace User\Infrastructure\Repository;

use App\Common\Base\BaseRepository;
use App\Common\Exceptions\NotFoundException;
use App\User\Domain\Role;
use App\User\Domain\Repository\RoleRepositoryInterface;
use Doctrine\ORM\EntityManagerInterface;

/**
 * Role repository implementation
 */
class RoleRepository extends BaseRepository implements RoleRepositoryInterface
{
    public function __construct(EntityManagerInterface $entityManager)
    {
        parent::__construct($entityManager, Role::class);
    }
    
    /**
     * Find role by name
     */
    public function findByName(string $name): ?Role
    {
        return $this->findOneBy(['name' => $name]);
    }
    
    /**
     * Get role by name (throws exception if not found)
     */
    public function getByName(string $name): Role
    {
        $role = $this->findByName($name);
        
        if (!$role) {
            throw NotFoundException::forEntity('Role', $name);
        }
        
        return $role;
    }
    
    /**
     * Find roles by names
     */
    public function findByNames(array $names): array
    {
        if (empty($names)) {
            return [];
        }
        
        return $this->createQueryBuilder('r')
            ->where('r.name IN (:names)')
            ->setParameter('names', $names)
            ->getQuery()
            ->getResult();
    }
    
    /**
     * Find active roles
     */
    public function findActive(): array
    {
        return $this->findBy(['isActive' => true], ['priority' => 'DESC', 'name' => 'ASC']);
    }
    
    /**
     * Find system roles
     */
    public function findSystemRoles(): array
    {
        return $this->findBy(['isSystem' => true], ['priority' => 'DESC']);
    }
    
    /**
     * Find custom roles
     */
    public function findCustomRoles(): array
    {
        return $this->findBy(['isSystem' => false], ['priority' => 'DESC', 'name' => 'ASC']);
    }
    
    /**
     * Find roles with specific permission
     */
    public function findByPermission(string $permissionId): array
    {
        return $this->createQueryBuilder('r')
            ->join('r.permissions', 'p')
            ->where('p.id = :permissionId')
            ->andWhere('r.isActive = :active')
            ->setParameter('permissionId', $permissionId)
            ->setParameter('active', true)
            ->orderBy('r.priority', 'DESC')
            ->getQuery()
            ->getResult();
    }
    
    /**
     * Check if role name exists
     */
    public function nameExists(string $name, ?int $excludeId = null): bool
    {
        $qb = $this->createQueryBuilder('r')
            ->select('COUNT(r.id)')
            ->where('LOWER(r.name) = LOWER(:name)')
            ->setParameter('name', $name);
        
        if ($excludeId) {
            $qb->andWhere('r.id != :excludeId')
                ->setParameter('excludeId', $excludeId);
        }
        
        return (int) $qb->getQuery()->getSingleScalarResult() > 0;
    }
    
    /**
     * Get highest priority
     */
    public function getHighestPriority(): int
    {
        $result = $this->createQueryBuilder('r')
            ->select('MAX(r.priority)')
            ->getQuery()
            ->getSingleScalarResult();
        
        return (int) ($result ?? 0);
    }
    
    /**
     * Get default role
     */
    public function getDefaultRole(): ?Role
    {
        return $this->findByName(Role::ROLE_EMPLOYEE);
    }
    
    /**
     * Save role
     */
    public function save(Role $role): void
    {
        parent::save($role);
    }
    
    /**
     * Remove role
     */
    public function remove(Role $role): void
    {
        if ($role->isSystem()) {
            throw new \RuntimeException('Cannot remove system role');
        }
        
        $this->getEntityManager()->remove($role);
        $this->getEntityManager()->flush();
    }
} 