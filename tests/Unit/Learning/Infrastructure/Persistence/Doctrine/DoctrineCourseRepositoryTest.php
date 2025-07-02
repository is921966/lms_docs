<?php

declare(strict_types=1);

namespace Tests\Unit\Learning\Infrastructure\Persistence\Doctrine;

use Doctrine\ORM\EntityManagerInterface;
use Doctrine\ORM\EntityRepository;
use Doctrine\ORM\Query;
use Doctrine\ORM\QueryBuilder;
use Doctrine\ORM\AbstractQuery;
use Doctrine\Persistence\ObjectRepository;
use Learning\Domain\Course;
use Learning\Domain\ValueObjects\CourseId;
use Learning\Domain\ValueObjects\CourseCode;
use Learning\Domain\ValueObjects\Duration;
use Learning\Domain\ValueObjects\CourseStatus;
use Learning\Infrastructure\Persistence\Doctrine\DoctrineCourseRepository;
use PHPUnit\Framework\TestCase;

class DoctrineCourseRepositoryTest extends TestCase
{
    private EntityManagerInterface $entityManager;
    private EntityRepository $doctrineRepository;
    private DoctrineCourseRepository $repository;
    
    protected function setUp(): void
    {
        $this->entityManager = $this->createMock(EntityManagerInterface::class);
        $this->doctrineRepository = $this->createMock(EntityRepository::class);
        
        $this->entityManager->expects($this->any())
            ->method('getRepository')
            ->with(Course::class)
            ->willReturn($this->doctrineRepository);
        
        $this->repository = new DoctrineCourseRepository($this->entityManager);
    }
    
    public function testSaveWithTransaction(): void
    {
        // Arrange
        $course = $this->createCourse();
        
        $this->entityManager->expects($this->once())
            ->method('beginTransaction');
        
        $this->entityManager->expects($this->once())
            ->method('persist')
            ->with($course);
        
        $this->entityManager->expects($this->once())
            ->method('flush');
        
        $this->entityManager->expects($this->once())
            ->method('commit');
        
        // Act
        $this->repository->save($course);
    }
    
    public function testSaveRollbackOnException(): void
    {
        // Arrange
        $course = $this->createCourse();
        
        $this->entityManager->expects($this->once())
            ->method('beginTransaction');
        
        $this->entityManager->expects($this->once())
            ->method('flush')
            ->willThrowException(new \Exception('Database error'));
        
        $this->entityManager->expects($this->once())
            ->method('rollback');
        
        // Act & Assert
        $this->expectException(\Exception::class);
        $this->repository->save($course);
    }
    
    public function testFindByIdWithLazyLoading(): void
    {
        // Arrange
        $courseId = CourseId::fromString('course-123');
        $course = $this->createCourse();
        
        $this->doctrineRepository->expects($this->once())
            ->method('find')
            ->with($courseId)
            ->willReturn($course);
        
        // Act
        $result = $this->repository->findById($courseId);
        
        // Assert
        $this->assertSame($course, $result);
    }
    
    public function testFindByCourseCode(): void
    {
        // Arrange
        $courseCode = CourseCode::fromString('PHP-101');
        $course = $this->createCourse();
        
        $this->doctrineRepository->expects($this->once())
            ->method('findOneBy')
            ->with(['code' => $courseCode])
            ->willReturn($course);
        
        // Act
        $result = $this->repository->findByCourseCode($courseCode);
        
        // Assert
        $this->assertSame($course, $result);
    }
    
    public function testFindAllWithPagination(): void
    {
        // Arrange
        $courses = [$this->createCourse(), $this->createCourse('JAVA-201')];
        $limit = 10;
        $offset = 20;
        
        $queryBuilder = $this->createMock(QueryBuilder::class);
        $query = $this->createMock(AbstractQuery::class);
        
        $this->doctrineRepository->expects($this->once())
            ->method('createQueryBuilder')
            ->with('c')
            ->willReturn($queryBuilder);
        
        $queryBuilder->expects($this->once())
            ->method('setMaxResults')
            ->with($limit)
            ->willReturnSelf();
        
        $queryBuilder->expects($this->once())
            ->method('setFirstResult')
            ->with($offset)
            ->willReturnSelf();
        
        $queryBuilder->expects($this->once())
            ->method('getQuery')
            ->willReturn($query);
        
        $query->expects($this->once())
            ->method('getResult')
            ->willReturn($courses);
        
        // Act
        $result = $this->repository->findAll($limit, $offset);
        
        // Assert
        $this->assertSame($courses, $result);
    }
    
    public function testFindPublished(): void
    {
        // Arrange
        $courses = [$this->createCourse()];
        
        $queryBuilder = $this->createMock(QueryBuilder::class);
        $query = $this->createMock(AbstractQuery::class);
        
        $this->doctrineRepository->expects($this->once())
            ->method('createQueryBuilder')
            ->with('c')
            ->willReturn($queryBuilder);
        
        $queryBuilder->expects($this->once())
            ->method('where')
            ->with('c.status = :status')
            ->willReturnSelf();
        
        $queryBuilder->expects($this->once())
            ->method('setParameter')
            ->with('status', CourseStatus::published())
            ->willReturnSelf();
        
        $queryBuilder->expects($this->once())
            ->method('orderBy')
            ->with('c.publishedAt', 'DESC')
            ->willReturnSelf();
        
        $queryBuilder->expects($this->once())
            ->method('getQuery')
            ->willReturn($query);
        
        $query->expects($this->once())
            ->method('getResult')
            ->willReturn($courses);
        
        // Act
        $result = $this->repository->findPublished();
        
        // Assert
        $this->assertSame($courses, $result);
    }
    
    public function testFindByInstructor(): void
    {
        // Arrange
        $instructorId = 'instructor-123';
        $courses = [$this->createCourse()];
        
        $queryBuilder = $this->createMock(QueryBuilder::class);
        $query = $this->createMock(AbstractQuery::class);
        
        $this->doctrineRepository->expects($this->once())
            ->method('createQueryBuilder')
            ->with('c')
            ->willReturn($queryBuilder);
        
        $queryBuilder->expects($this->once())
            ->method('where')
            ->with('JSON_EXTRACT(c.metadata, \'$.instructorId\') = :instructorId')
            ->willReturnSelf();
        
        $queryBuilder->expects($this->once())
            ->method('setParameter')
            ->with('instructorId', $instructorId)
            ->willReturnSelf();
        
        $queryBuilder->expects($this->once())
            ->method('getQuery')
            ->willReturn($query);
        
        $query->expects($this->once())
            ->method('getResult')
            ->willReturn($courses);
        
        // Act
        $result = $this->repository->findByInstructor($instructorId);
        
        // Assert
        $this->assertSame($courses, $result);
    }
    
    public function testCountByStatus(): void
    {
        // Arrange
        $status = CourseStatus::published();
        $count = 42;
        
        $queryBuilder = $this->createMock(QueryBuilder::class);
        $query = $this->createMock(AbstractQuery::class);
        
        $this->doctrineRepository->expects($this->once())
            ->method('createQueryBuilder')
            ->with('c')
            ->willReturn($queryBuilder);
        
        $queryBuilder->expects($this->once())
            ->method('select')
            ->with('COUNT(c.id)')
            ->willReturnSelf();
        
        $queryBuilder->expects($this->once())
            ->method('where')
            ->with('c.status = :status')
            ->willReturnSelf();
        
        $queryBuilder->expects($this->once())
            ->method('setParameter')
            ->with('status', $status)
            ->willReturnSelf();
        
        $queryBuilder->expects($this->once())
            ->method('getQuery')
            ->willReturn($query);
        
        $query->expects($this->once())
            ->method('getSingleScalarResult')
            ->willReturn($count);
        
        // Act
        $result = $this->repository->countByStatus($status);
        
        // Assert
        $this->assertEquals($count, $result);
    }
    
    public function testDeleteWithSoftDelete(): void
    {
        // Arrange
        $course = $this->createCourse();
        
        $this->entityManager->expects($this->once())
            ->method('remove')
            ->with($course);
        
        $this->entityManager->expects($this->once())
            ->method('flush');
        
        // Act
        $this->repository->delete($course);
    }
    
    public function testFindWithOptimisticLock(): void
    {
        // Arrange
        $courseId = CourseId::fromString('course-123');
        $course = $this->createCourse();
        $version = 5;
        
        $this->entityManager->expects($this->once())
            ->method('find')
            ->with(
                Course::class,
                $courseId,
                \Doctrine\DBAL\LockMode::OPTIMISTIC,
                $version
            )
            ->willReturn($course);
        
        // Act
        $result = $this->repository->findByIdWithLock($courseId, $version);
        
        // Assert
        $this->assertSame($course, $result);
    }
    
    private function createCourse(string $code = 'PHP-101'): Course
    {
        $course = Course::create(
            CourseId::generate(),
            CourseCode::fromString($code),
            'Test Course',
            'Test Description',
            Duration::fromHours(10)
        );
        
        $course->addMetadata('instructorId', 'instructor-123');
        
        return $course;
    }
} 