<?php

declare(strict_types=1);

namespace App\Common\Base;

use App\Common\Interfaces\RepositoryInterface;
use Doctrine\ORM\EntityManagerInterface;
use Doctrine\ORM\EntityRepository;
use Doctrine\ORM\QueryBuilder;
use App\Common\Exceptions\NotFoundException;

/**
 * Base repository implementation with Doctrine ORM
 * 
 * @template T of object
 * @implements RepositoryInterface<T>
 */
abstract class BaseRepository implements RepositoryInterface
{
    protected EntityManagerInterface $entityManager;
    protected EntityRepository $repository;
    
    /**
     * @var class-string<T>
     */
    protected string $entityClass;
    
    public function __construct(EntityManagerInterface $entityManager)
    {
        $this->entityManager = $entityManager;
        $this->repository = $entityManager->getRepository($this->entityClass);
    }
    
    /**
     * {@inheritdoc}
     */
    public function find(int|string $id): ?object
    {
        return $this->repository->find($id);
    }
    
    /**
     * {@inheritdoc}
     */
    public function findAll(
        int $limit = 100,
        int $offset = 0,
        array $criteria = [],
        array $orderBy = []
    ): array {
        return $this->repository->findBy($criteria, $orderBy, $limit, $offset);
    }
    
    /**
     * {@inheritdoc}
     */
    public function save(object $entity): object
    {
        $this->entityManager->persist($entity);
        $this->entityManager->flush();
        
        return $entity;
    }
    
    /**
     * {@inheritdoc}
     */
    public function update(object $entity): object
    {
        $this->entityManager->flush();
        
        return $entity;
    }
    
    /**
     * {@inheritdoc}
     */
    public function delete(object $entity): void
    {
        $this->entityManager->remove($entity);
        $this->entityManager->flush();
    }
    
    /**
     * {@inheritdoc}
     */
    public function count(array $criteria = []): int
    {
        return $this->repository->count($criteria);
    }
    
    /**
     * Create query builder for complex queries
     * 
     * @param string $alias
     * @return QueryBuilder
     */
    protected function createQueryBuilder(string $alias): QueryBuilder
    {
        return $this->repository->createQueryBuilder($alias);
    }
    
    /**
     * Find one entity by criteria or throw exception
     * 
     * @param array<string, mixed> $criteria
     * @return T
     * @throws NotFoundException
     */
    protected function findOneByOrFail(array $criteria): object
    {
        $entity = $this->repository->findOneBy($criteria);
        
        if ($entity === null) {
            throw new NotFoundException(
                sprintf('%s not found', $this->entityClass)
            );
        }
        
        return $entity;
    }
} 