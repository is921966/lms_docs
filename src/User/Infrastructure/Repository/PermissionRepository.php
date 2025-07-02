<?php

declare(strict_types=1);

namespace User\Infrastructure\Repository;

use App\Common\Base\BaseRepository;
use App\Common\Exceptions\NotFoundException;
use App\User\Domain\Permission;
use App\User\Domain\Repository\PermissionRepositoryInterface;
use Doctrine\ORM\EntityManagerInterface;

/**
 * Permission repository implementation
 */
class PermissionRepository extends BaseRepository implements PermissionRepositoryInterface
{
    public function __construct(EntityManagerInterface $entityManager)
    {
        parent::__construct($entityManager, Permission::class);
    }
    
    /**
     * Find permission by ID
     */
    public function findById(string $id): ?Permission
    {
        return $this->find($id);
    }
    
    /**
     * Get permission by ID (throws exception if not found)
     */
    public function getById(string $id): Permission
    {
        $permission = $this->findById($id);
        
        if (!$permission) {
            throw NotFoundException::forEntity('Permission', $id);
        }
        
        return $permission;
    }
    
    /**
     * Find permissions by IDs
     */
    public function findByIds(array $ids): array
    {
        if (empty($ids)) {
            return [];
        }
        
        return $this->createQueryBuilder('p')
            ->where('p.id IN (:ids)')
            ->setParameter('ids', $ids)
            ->orderBy('p.category', 'ASC')
            ->addOrderBy('p.name', 'ASC')
            ->getQuery()
            ->getResult();
    }
    
    /**
     * Find permissions by category
     */
    public function findByCategory(string $category): array
    {
        return $this->findBy(['category' => $category], ['name' => 'ASC']);
    }
    
    /**
     * Get all permissions grouped by category
     */
    public function getAllGroupedByCategory(): array
    {
        $permissions = $this->findBy([], ['category' => 'ASC', 'name' => 'ASC']);
        
        $grouped = [];
        foreach ($permissions as $permission) {
            $category = $permission->getCategory();
            if (!isset($grouped[$category])) {
                $grouped[$category] = [];
            }
            $grouped[$category][] = $permission;
        }
        
        return $grouped;
    }
    
    /**
     * Find permissions by role
     */
    public function findByRole(int $roleId): array
    {
        return $this->createQueryBuilder('p')
            ->join('p.roles', 'r')
            ->where('r.id = :roleId')
            ->setParameter('roleId', $roleId)
            ->orderBy('p.category', 'ASC')
            ->addOrderBy('p.name', 'ASC')
            ->getQuery()
            ->getResult();
    }
    
    /**
     * Check if permission exists
     */
    public function exists(string $id): bool
    {
        return $this->count(['id' => $id]) > 0;
    }
    
    /**
     * Get all categories
     */
    public function getCategories(): array
    {
        $result = $this->createQueryBuilder('p')
            ->select('DISTINCT p.category')
            ->orderBy('p.category', 'ASC')
            ->getQuery()
            ->getScalarResult();
        
        return array_column($result, 'category');
    }
    
    /**
     * Search permissions
     */
    public function search(string $query): array
    {
        $searchQuery = '%' . $query . '%';
        
        return $this->createQueryBuilder('p')
            ->where('LOWER(p.name) LIKE LOWER(:query)')
            ->orWhere('LOWER(p.description) LIKE LOWER(:query)')
            ->orWhere('LOWER(p.id) LIKE LOWER(:query)')
            ->setParameter('query', $searchQuery)
            ->orderBy('p.category', 'ASC')
            ->addOrderBy('p.name', 'ASC')
            ->getQuery()
            ->getResult();
    }
    
    /**
     * Save permission
     */
    public function save(Permission $permission): void
    {
        $this->getEntityManager()->persist($permission);
        $this->getEntityManager()->flush();
    }
    
    /**
     * Remove permission
     */
    public function remove(Permission $permission): void
    {
        $this->getEntityManager()->remove($permission);
        $this->getEntityManager()->flush();
    }
    
    /**
     * Initialize default permissions
     */
    public function initializeDefaults(): void
    {
        $defaults = Permission::getDefaults();
        
        foreach ($defaults as $id => $data) {
            if (!$this->exists($id)) {
                $permission = new Permission(
                    $id,
                    $data['name'],
                    $data['description'],
                    $data['category']
                );
                $this->save($permission);
            }
        }
    }
} 