<?php

declare(strict_types=1);

namespace Tests\Unit\Learning\Infrastructure\Repository;

use App\Learning\Infrastructure\Repository\InMemoryEnrollmentRepository;
use App\Learning\Domain\Enrollment;
use App\Learning\Domain\ValueObjects\EnrollmentId;
use App\Learning\Domain\ValueObjects\CourseId;
use App\User\Domain\ValueObjects\UserId;
use PHPUnit\Framework\TestCase;

class InMemoryEnrollmentRepositoryTest extends TestCase
{
    private InMemoryEnrollmentRepository $repository;
    
    protected function setUp(): void
    {
        $this->repository = new InMemoryEnrollmentRepository();
    }
    
    public function testCanSaveAndFindEnrollment(): void
    {
        $enrollment = $this->createEnrollment();
        
        $this->repository->save($enrollment);
        
        $found = $this->repository->findById($enrollment->getId());
        
        $this->assertNotNull($found);
        $this->assertEquals($enrollment->getId()->toString(), $found->getId()->toString());
    }
    
    public function testCanFindByUserAndCourse(): void
    {
        $userId = UserId::generate();
        $courseId = CourseId::generate();
        $enrollment = Enrollment::create($userId, $courseId, $userId);
        
        $this->repository->save($enrollment);
        
        $found = $this->repository->findByUserAndCourse($userId, $courseId);
        
        $this->assertNotNull($found);
        $this->assertEquals($enrollment->getId()->toString(), $found->getId()->toString());
    }
    
    public function testCanFindByUser(): void
    {
        $userId = UserId::generate();
        $enrollment1 = Enrollment::create($userId, CourseId::generate(), $userId);
        $enrollment2 = Enrollment::create($userId, CourseId::generate(), $userId);
        
        $this->repository->save($enrollment1);
        $this->repository->save($enrollment2);
        
        $enrollments = $this->repository->findByUser($userId);
        
        $this->assertCount(2, $enrollments);
    }
    
    public function testCanFindByCourse(): void
    {
        $courseId = CourseId::generate();
        $enrollment1 = Enrollment::create(UserId::generate(), $courseId, UserId::generate());
        $enrollment2 = Enrollment::create(UserId::generate(), $courseId, UserId::generate());
        
        $this->repository->save($enrollment1);
        $this->repository->save($enrollment2);
        
        $enrollments = $this->repository->findByCourse($courseId);
        
        $this->assertCount(2, $enrollments);
    }
    
    private function createEnrollment(): Enrollment
    {
        return Enrollment::create(
            UserId::generate(),
            CourseId::generate(),
            UserId::generate()
        );
    }
} 