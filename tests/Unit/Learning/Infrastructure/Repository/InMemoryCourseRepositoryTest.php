<?php

declare(strict_types=1);

namespace Tests\Unit\Learning\Infrastructure\Repository;

use App\Learning\Infrastructure\Repository\InMemoryCourseRepository;
use App\Learning\Domain\Course;
use App\Learning\Domain\ValueObjects\CourseId;
use App\Learning\Domain\ValueObjects\CourseCode;
use App\Learning\Domain\ValueObjects\CourseType;
use App\Learning\Domain\ValueObjects\CourseStatus;
use PHPUnit\Framework\TestCase;

class InMemoryCourseRepositoryTest extends TestCase
{
    private InMemoryCourseRepository $repository;
    
    protected function setUp(): void
    {
        $this->repository = new InMemoryCourseRepository();
    }
    
    public function testCanSaveAndFindCourse(): void
    {
        $course = $this->createCourse();
        
        $this->repository->save($course);
        
        $found = $this->repository->findById($course->getId());
        
        $this->assertNotNull($found);
        $this->assertEquals($course->getId()->toString(), $found->getId()->toString());
        $this->assertEquals($course->getCode()->toString(), $found->getCode()->toString());
    }
    
    public function testReturnsNullWhenCourseNotFound(): void
    {
        $id = CourseId::generate();
        
        $found = $this->repository->findById($id);
        
        $this->assertNull($found);
    }
    
    public function testCanFindByCode(): void
    {
        $course = $this->createCourse();
        $this->repository->save($course);
        
        $found = $this->repository->findByCode($course->getCode());
        
        $this->assertNotNull($found);
        $this->assertEquals($course->getId()->toString(), $found->getId()->toString());
    }
    
    public function testCanFindPublished(): void
    {
        $draftCourse = $this->createCourse();
        $publishedCourse = $this->createCourse();
        $publishedCourse->publish();
        
        $this->repository->save($draftCourse);
        $this->repository->save($publishedCourse);
        
        $published = $this->repository->findPublished(10, 0);
        
        $this->assertCount(1, $published);
        $firstPublished = reset($published);
        $this->assertEquals(CourseStatus::PUBLISHED->value, $firstPublished->getStatus()->value);
    }
    
    public function testCanUpdateCourse(): void
    {
        $course = $this->createCourse();
        $this->repository->save($course);
        
        $course->updateBasicInfo('Updated Title', 'Updated Description', 50);
        $this->repository->save($course);
        
        $found = $this->repository->findById($course->getId());
        
        $this->assertEquals('Updated Title', $found->getTitle());
        $this->assertEquals('Updated Description', $found->getDescription());
    }
    
    public function testCanFindAll(): void
    {
        $course1 = $this->createCourse();
        $course2 = $this->createCourse();
        
        $this->repository->save($course1);
        $this->repository->save($course2);
        
        $all = $this->repository->findAll();
        
        $this->assertCount(2, $all);
    }
    
    public function testCanDeleteCourse(): void
    {
        $course = $this->createCourse();
        $this->repository->save($course);
        
        $this->repository->delete($course);
        
        $found = $this->repository->findById($course->getId());
        $this->assertNull($found);
    }
    
    public function testCanSearchCourses(): void
    {
        $course1 = $this->createCourse();
        $course1->updateBasicInfo('PHP Programming', 'Learn PHP basics', 40);
        
        $course2 = $this->createCourse();
        $course2->updateBasicInfo('JavaScript Course', 'Advanced JS', 30);
        
        $this->repository->save($course1);
        $this->repository->save($course2);
        
        $results = $this->repository->search('PHP');
        
        $this->assertCount(1, $results);
        $firstResult = reset($results);
        $this->assertEquals('PHP Programming', $firstResult->getTitle());
    }
    
    public function testCanCheckCodeExists(): void
    {
        $course = $this->createCourse();
        $this->repository->save($course);
        
        $this->assertTrue($this->repository->codeExists($course->getCode()));
        $this->assertFalse($this->repository->codeExists($course->getCode(), $course->getId()));
        $this->assertFalse($this->repository->codeExists(CourseCode::fromString('CRS-999')));
    }
    
    public function testCanGetNextCourseCode(): void
    {
        $course1 = Course::create(
            CourseCode::fromString('CRS-001'),
            'Test Course 1',
            'Description',
            CourseType::ONLINE,
            40
        );
        
        $course2 = Course::create(
            CourseCode::fromString('CRS-003'),
            'Test Course 2',
            'Description',
            CourseType::ONLINE,
            40
        );
        
        $this->repository->save($course1);
        $this->repository->save($course2);
        
        $nextCode = $this->repository->getNextCourseCode();
        
        $this->assertEquals('CRS-004', $nextCode->toString());
    }
    
    private function createCourse(): Course
    {
        static $counter = 0;
        $counter++;
        
        return Course::create(
            CourseCode::fromString('CRS-00' . $counter),
            'Test Course ' . $counter,
            'Test Description',
            CourseType::ONLINE,
            40
        );
    }
} 