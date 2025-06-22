<?php

declare(strict_types=1);

namespace App\User\Infrastructure\Repository;

use App\Common\Exceptions\NotFoundException;
use App\User\Domain\Repository\RoleRepositoryInterface;
use App\User\Domain\Role;
use Doctrine\ORM\EntityManagerInterface;
use Doctrine\ORM\EntityRepository;

/**
 * Doctrine implementation of RoleRepository
 */
class DoctrineRoleRepository implements RoleRepositoryInterface
{
    private EntityRepository $repository;
    
    public function __construct(
        private EntityManagerInterface $entityManager
    ) {
        $this->repository = $entityManager->getRepository(Role::class);
    }
    
    /**
     * Save role
     */
    public function save(Role $role): void
    {
        $this->entityManager->persist($role);
        $this->entityManager->flush();
    }
    
    /**
     * Get role by name
     */
    public function getByName(string $name): Role
    {
        $role = $this->repository->findOneBy(['name' => $name]);
        
        if (!$role) {
            throw new NotFoundException("Role '{$name}' not found");
        }
        
        return $role;
    }
    
    /**
     * Find role by name
     */
    public function findByName(string $name): ?Role
    {
        return $this->repository->findOneBy(['name' => $name]);
    }
    
    /**
     * Find roles by names
     */
    public function findByNames(array $names): array
    {
        return $this->repository->createQueryBuilder('r')
            ->where('r.name IN (:names)')
            ->setParameter('names', $names)
            ->getQuery()
            ->getResult();
    }
    
    /**
     * Get all roles
     */
    public function getAll(): array
    {
        return $this->repository->findBy([], ['name' => 'ASC']);
    }
    
    /**
     * Get default role
     */
    public function getDefaultRole(): ?Role
    {
        return $this->repository->findOneBy(['isDefault' => true]);
    }
    
    /**
     * Check if role exists
     */
    public function exists(string $name): bool
    {
        return $this->repository->count(['name' => $name]) > 0;
    }
} 