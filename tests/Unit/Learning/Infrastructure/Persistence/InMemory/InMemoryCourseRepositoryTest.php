<?php

declare(strict_types=1);

namespace Tests\Unit\Learning\Infrastructure\Persistence\InMemory;

use Learning\Domain\Course;
use Learning\Domain\ValueObjects\CourseId;
use Learning\Domain\ValueObjects\CourseCode;
use Learning\Domain\ValueObjects\Duration;
use Learning\Domain\ValueObjects\CourseStatus;
use Learning\Infrastructure\Persistence\InMemory\InMemoryCourseRepository;
use PHPUnit\Framework\TestCase;

class InMemoryCourseRepositoryTest extends TestCase
{
    private InMemoryCourseRepository $repository;
    
    protected function setUp(): void
    {
        $this->repository = new InMemoryCourseRepository();
    }
    
    public function testSaveAndFindById(): void
    {
        // Arrange
        $course = $this->createCourse();
        
        // Act
        $this->repository->save($course);
        $found = $this->repository->findById($course->getId());
        
        // Assert
        $this->assertNotNull($found);
        $this->assertEquals((string)$course->getId(), (string)$found->getId());
        $this->assertEquals($course->getTitle(), $found->getTitle());
    }
    
    public function testFindByIdReturnsNullWhenNotFound(): void
    {
        // Arrange
        $id = CourseId::generate();
        
        // Act
        $found = $this->repository->findById($id);
        
        // Assert
        $this->assertNull($found);
    }
    
    public function testFindByCourseCode(): void
    {
        // Arrange
        $course = $this->createCourse();
        
        // Act
        $this->repository->save($course);
        $found = $this->repository->findByCourseCode($course->getCode());
        
        // Assert
        $this->assertNotNull($found);
        $this->assertEquals((string)$course->getCode(), (string)$found->getCode());
    }
    
    public function testFindAll(): void
    {
        // Arrange
        $course1 = $this->createCourse('PHP-101');
        $course2 = $this->createCourse('JAVA-201');
        $course3 = $this->createCourse('PYTHON-301');
        
        // Act
        $this->repository->save($course1);
        $this->repository->save($course2);
        $this->repository->save($course3);
        
        $all = $this->repository->findAll();
        
        // Assert
        $this->assertCount(3, $all);
        $codes = array_map(fn($c) => (string)$c->getCode(), $all);
        $this->assertContains('PHP-101', $codes);
        $this->assertContains('JAVA-201', $codes);
        $this->assertContains('PYTHON-301', $codes);
    }
    
    public function testFindBy(): void
    {
        // Arrange
        $course1 = $this->createCourse('PHP-101', 'beginner');
        $course2 = $this->createCourse('PHP-201', 'intermediate');
        $course3 = $this->createCourse('JAVA-101', 'beginner');
        
        $this->repository->save($course1);
        $this->repository->save($course2);
        $this->repository->save($course3);
        
        // Act - Find by metadata level
        $beginnerCourses = $this->repository->findBy(['metadata.level' => 'beginner']);
        
        // Assert
        $this->assertCount(2, $beginnerCourses);
        $codes = array_map(fn($c) => (string)$c->getCode(), $beginnerCourses);
        $this->assertContains('PHP-101', $codes);
        $this->assertContains('JAVA-101', $codes);
    }
    
    public function testFindByWithLimit(): void
    {
        // Arrange
        for ($i = 1; $i <= 5; $i++) {
            $course = $this->createCourse("COURSE-$i");
            $this->repository->save($course);
        }
        
        // Act
        $limited = $this->repository->findBy([], 2);
        
        // Assert
        $this->assertCount(2, $limited);
    }
    
    public function testFindByWithOffset(): void
    {
        // Arrange
        for ($i = 1; $i <= 5; $i++) {
            $course = $this->createCourse("COURSE-$i");
            $this->repository->save($course);
        }
        
        // Act
        $offset = $this->repository->findBy([], null, 3);
        
        // Assert
        $this->assertCount(2, $offset); // Should return courses 4 and 5
    }
    
    public function testDelete(): void
    {
        // Arrange
        $course = $this->createCourse();
        $this->repository->save($course);
        
        // Act
        $this->repository->delete($course);
        $found = $this->repository->findById($course->getId());
        
        // Assert
        $this->assertNull($found);
    }
    
    public function testUpdateExistingCourse(): void
    {
        // Arrange
        $course = $this->createCourse();
        $this->repository->save($course);
        
        // Act - Modify and save again
        $course->updateDetails('Updated Title', $course->getDescription());
        $this->repository->save($course);
        
        // Assert
        $found = $this->repository->findById($course->getId());
        $this->assertNotNull($found);
        $this->assertEquals('Updated Title', $found->getTitle());
        
        // Ensure we don't have duplicates
        $all = $this->repository->findAll();
        $this->assertCount(1, $all);
    }
    
    private function createCourse(string $code = 'PHP-101', string $level = 'beginner'): Course
    {
        $course = Course::create(
            CourseId::generate(),
            CourseCode::fromString($code),
            'Test Course',
            'Test Description',
            Duration::fromHours(10)
        );
        
        $course->addMetadata('level', $level);
        $course->addMetadata('instructorId', 'instructor-123');
        
        return $course;
    }
} 