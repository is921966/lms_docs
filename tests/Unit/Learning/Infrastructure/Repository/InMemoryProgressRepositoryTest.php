<?php

declare(strict_types=1);

namespace Tests\Unit\Learning\Infrastructure\Repository;

use Learning\Infrastructure\Repository\InMemoryProgressRepository;
use Learning\Domain\Progress;
use Learning\Domain\ValueObjects\ProgressId;
use Learning\Domain\ValueObjects\EnrollmentId;
use Learning\Domain\ValueObjects\LessonId;
use PHPUnit\Framework\TestCase;

class InMemoryProgressRepositoryTest extends TestCase
{
    private InMemoryProgressRepository $repository;
    
    protected function setUp(): void
    {
        $this->repository = new InMemoryProgressRepository();
    }
    
    public function testCanSaveAndFindProgress(): void
    {
        $progress = $this->createProgress();
        
        $this->repository->save($progress);
        
        $found = $this->repository->findById($progress->getId());
        
        $this->assertNotNull($found);
        $this->assertEquals($progress->getId()->getValue(), $found->getId()->getValue());
    }
    
    public function testCanFindByEnrollmentAndLesson(): void
    {
        $enrollmentId = EnrollmentId::generate();
        $lessonId = LessonId::generate();
        $progress = Progress::create($enrollmentId, $lessonId);
        
        $this->repository->save($progress);
        
        $found = $this->repository->findByEnrollmentAndLesson($enrollmentId, $lessonId);
        
        $this->assertNotNull($found);
        $this->assertEquals($progress->getId()->getValue(), $found->getId()->getValue());
    }
    
    public function testCanFindByEnrollment(): void
    {
        $enrollmentId = EnrollmentId::generate();
        $progress1 = Progress::create($enrollmentId, LessonId::generate());
        $progress2 = Progress::create($enrollmentId, LessonId::generate());
        
        $this->repository->save($progress1);
        $this->repository->save($progress2);
        
        $progresses = $this->repository->findByEnrollment($enrollmentId);
        
        $this->assertCount(2, $progresses);
    }
    
    private function createProgress(): Progress
    {
        return Progress::create(
            EnrollmentId::generate(),
            LessonId::generate()
        );
    }
} 