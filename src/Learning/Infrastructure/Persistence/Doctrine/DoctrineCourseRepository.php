<?php

declare(strict_types=1);

namespace Learning\Infrastructure\Persistence\Doctrine;

use Doctrine\ORM\EntityManagerInterface;
use Doctrine\ORM\EntityRepository;
use Doctrine\ORM\QueryBuilder;
use Doctrine\DBAL\LockMode;
use Learning\Domain\Course;
use Learning\Domain\Repositories\CourseRepositoryInterface;
use Learning\Domain\ValueObjects\CourseId;
use Learning\Domain\ValueObjects\CourseCode;
use Learning\Domain\ValueObjects\CourseStatus;
use Exception;

final class DoctrineCourseRepository implements CourseRepositoryInterface
{
    private EntityRepository $repository;
    
    public function __construct(
        private readonly EntityManagerInterface $entityManager
    ) {
        $this->repository = $this->entityManager->getRepository(Course::class);
    }
    
    public function save(Course $course): void
    {
        $this->entityManager->beginTransaction();
        
        try {
            $this->entityManager->persist($course);
            $this->entityManager->flush();
            $this->entityManager->commit();
        } catch (Exception $e) {
            $this->entityManager->rollback();
            throw $e;
        }
    }
    
    public function findById(CourseId $id): ?Course
    {
        return $this->repository->find($id);
    }
    
    public function findByCourseCode(CourseCode $code): ?Course
    {
        return $this->repository->findOneBy(['code' => $code]);
    }
    
    public function delete(Course $course): void
    {
        $this->entityManager->remove($course);
        $this->entityManager->flush();
    }
    
    /**
     * @return Course[]
     */
    public function findAll(int $limit = null, int $offset = null): array
    {
        $qb = $this->repository->createQueryBuilder('c');
        
        if ($limit !== null) {
            $qb->setMaxResults($limit);
        }
        
        if ($offset !== null) {
            $qb->setFirstResult($offset);
        }
        
        return $qb->getQuery()->getResult();
    }
    
    /**
     * @param array $criteria
     * @return Course[]
     */
    public function findBy(array $criteria, int $limit = null, int $offset = null): array
    {
        return $this->repository->findBy($criteria, null, $limit, $offset);
    }
    
    /**
     * @return Course[]
     */
    public function findPublished(): array
    {
        return $this->repository->createQueryBuilder('c')
            ->where('c.status = :status')
            ->setParameter('status', CourseStatus::published())
            ->orderBy('c.publishedAt', 'DESC')
            ->getQuery()
            ->getResult();
    }
    
    /**
     * @return Course[]
     */
    public function findByInstructor(string $instructorId): array
    {
        return $this->repository->createQueryBuilder('c')
            ->where('JSON_EXTRACT(c.metadata, \'$.instructorId\') = :instructorId')
            ->setParameter('instructorId', $instructorId)
            ->getQuery()
            ->getResult();
    }
    
    public function countByStatus(CourseStatus $status): int
    {
        return (int) $this->repository->createQueryBuilder('c')
            ->select('COUNT(c.id)')
            ->where('c.status = :status')
            ->setParameter('status', $status)
            ->getQuery()
            ->getSingleScalarResult();
    }
    
    public function findByIdWithLock(CourseId $id, int $expectedVersion): ?Course
    {
        return $this->entityManager->find(
            Course::class,
            $id,
            LockMode::OPTIMISTIC,
            $expectedVersion
        );
    }
    
    /**
     * @return Course[]
     */
    public function findDraftCoursesOlderThan(\DateTimeImmutable $date): array
    {
        return $this->repository->createQueryBuilder('c')
            ->where('c.status = :status')
            ->andWhere('c.createdAt < :date')
            ->setParameter('status', CourseStatus::draft())
            ->setParameter('date', $date)
            ->getQuery()
            ->getResult();
    }
    
    /**
     * @return Course[]
     */
    public function findByCategory(string $category): array
    {
        return $this->repository->createQueryBuilder('c')
            ->where('JSON_EXTRACT(c.metadata, \'$.category\') = :category')
            ->setParameter('category', $category)
            ->getQuery()
            ->getResult();
    }
    
    /**
     * @param string[] $courseIds
     * @return Course[]
     */
    public function findByIds(array $courseIds): array
    {
        if (empty($courseIds)) {
            return [];
        }
        
        return $this->repository->createQueryBuilder('c')
            ->where('c.id IN (:ids)')
            ->setParameter('ids', $courseIds)
            ->getQuery()
            ->getResult();
    }
} 