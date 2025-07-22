<?php

declare(strict_types=1);

namespace Tests\Integration\Course\Infrastructure\Persistence;

use App\Course\Domain\Entities\Course;
use App\Course\Domain\ValueObjects\CourseId;
use App\Course\Domain\ValueObjects\CourseCode;
use App\Course\Domain\ValueObjects\Duration;
use App\Course\Domain\ValueObjects\Price;
use App\Course\Infrastructure\Persistence\CourseRepository;
use Doctrine\DBAL\Connection;
use Tests\Integration\IntegrationTestCase;

class CourseRepositoryTest extends IntegrationTestCase
{
    private CourseRepository $repository;
    private Connection $connection;
    
    protected function setUp(): void
    {
        parent::setUp();
        $this->connection = $this->getConnection();
        $this->repository = new CourseRepository($this->connection);
        
        // Clean up before each test
        $this->connection->executeStatement('TRUNCATE TABLE courses CASCADE');
    }
    
    public function testCanSaveAndFindCourse(): void
    {
        // Given
        $course = $this->createValidCourse();
        
        // When
        $this->repository->save($course);
        
        // Then
        $foundCourse = $this->repository->findById($course->id());
        
        $this->assertNotNull($foundCourse);
        $this->assertEquals($course->id()->value(), $foundCourse->id()->value());
        $this->assertEquals($course->code()->value(), $foundCourse->code()->value());
        $this->assertEquals($course->title(), $foundCourse->title());
        $this->assertEquals($course->description(), $foundCourse->description());
        $this->assertEquals($course->duration()->inMinutes(), $foundCourse->duration()->inMinutes());
        $this->assertEquals($course->price()->amount(), $foundCourse->price()->amount());
        $this->assertEquals($course->status(), $foundCourse->status());
    }
    
    public function testCanUpdateCourse(): void
    {
        // Given
        $course = $this->createValidCourse();
        $this->repository->save($course);
        
        // When
        $course->updateDetails('Updated Title', 'Updated Description', new Price(199.99, 'USD'));
        $this->repository->save($course);
        
        // Then
        $updatedCourse = $this->repository->findById($course->id());
        $this->assertEquals('Updated Title', $updatedCourse->title());
        $this->assertEquals('Updated Description', $updatedCourse->description());
        $this->assertEquals(199.99, $updatedCourse->price()->amount());
    }
    
    public function testCanFindByCode(): void
    {
        // Given
        $course = $this->createValidCourse();
        $this->repository->save($course);
        
        // When
        $foundCourse = $this->repository->findByCode($course->code());
        
        // Then
        $this->assertNotNull($foundCourse);
        $this->assertEquals($course->id()->value(), $foundCourse->id()->value());
    }
    
    public function testCanFindAllCourses(): void
    {
        // Given
        $course1 = $this->createValidCourse();
        $course2 = new Course(
            CourseId::generate(),
            new CourseCode('CS102'),
            'Advanced Computer Science',
            'Advanced topics',
            new Duration(600),
            new Price(149.99, 'USD')
        );
        
        $this->repository->save($course1);
        $this->repository->save($course2);
        
        // When
        $courses = $this->repository->findAll();
        
        // Then
        $this->assertCount(2, $courses);
    }
    
    public function testCanFindPublishedCourses(): void
    {
        // Given
        $draftCourse = $this->createValidCourse();
        $publishedCourse = new Course(
            CourseId::generate(),
            new CourseCode('CS102'),
            'Published Course',
            'Description',
            new Duration(300),
            new Price(79.99, 'USD')
        );
        $publishedCourse->publish();
        
        $this->repository->save($draftCourse);
        $this->repository->save($publishedCourse);
        
        // When
        $publishedCourses = $this->repository->findPublished();
        
        // Then
        $this->assertCount(1, $publishedCourses);
        $this->assertEquals('published', $publishedCourses[0]->status());
    }
    
    public function testCanDeleteCourse(): void
    {
        // Given
        $course = $this->createValidCourse();
        $this->repository->save($course);
        
        // When
        $this->repository->delete($course);
        
        // Then
        $foundCourse = $this->repository->findById($course->id());
        $this->assertNull($foundCourse);
    }
    
    public function testExistsReturnsTrueForExistingCourse(): void
    {
        // Given
        $course = $this->createValidCourse();
        $this->repository->save($course);
        
        // When & Then
        $this->assertTrue($this->repository->exists($course->id()));
    }
    
    public function testExistsReturnsFalseForNonExistentCourse(): void
    {
        // Given
        $nonExistentId = CourseId::generate();
        
        // When & Then
        $this->assertFalse($this->repository->exists($nonExistentId));
    }
    
    private function createValidCourse(): Course
    {
        return new Course(
            CourseId::generate(),
            new CourseCode('CS101'),
            'Introduction to Computer Science',
            'Basic course covering fundamentals of CS',
            new Duration(480),
            new Price(99.99, 'USD')
        );
    }
} 