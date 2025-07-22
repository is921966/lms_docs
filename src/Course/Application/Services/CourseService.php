<?php

declare(strict_types=1);

namespace App\Course\Application\Services;

use App\Common\Exceptions\InvalidArgumentException;
use App\Course\Application\DTO\CourseDTO;
use App\Course\Domain\Entities\Course;
use App\Course\Domain\Repository\CourseRepositoryInterface;
use App\Course\Domain\Repository\EnrollmentRepositoryInterface;
use App\Course\Domain\ValueObjects\CourseId;
use App\Course\Domain\ValueObjects\CourseCode;
use App\Course\Domain\ValueObjects\Duration;
use App\Course\Domain\ValueObjects\Price;

class CourseService
{
    public function __construct(
        private CourseRepositoryInterface $courseRepository,
        private EnrollmentRepositoryInterface $enrollmentRepository
    ) {
    }
    
    public function createCourse(
        string $code,
        string $title,
        string $description,
        int $durationMinutes,
        float $priceAmount,
        string $priceCurrency = 'USD'
    ): CourseDTO {
        $courseCode = new CourseCode($code);
        
        // Check if course with this code already exists
        if ($this->courseRepository->findByCode($courseCode) !== null) {
            throw new InvalidArgumentException("Course with code $code already exists");
        }
        
        $course = new Course(
            CourseId::generate(),
            $courseCode,
            $title,
            $description,
            new Duration($durationMinutes),
            new Price($priceAmount, $priceCurrency)
        );
        
        $this->courseRepository->save($course);
        
        return $this->mapToDTO($course);
    }
    
    public function getCourseById(string $courseIdString): CourseDTO
    {
        $courseId = new CourseId($courseIdString);
        $course = $this->courseRepository->findById($courseId);
        
        if ($course === null) {
            throw new InvalidArgumentException('Course not found');
        }
        
        $enrollmentCount = $this->enrollmentRepository->countByCourse($courseId);
        $completionCount = $this->enrollmentRepository->countCompletedByCourse($courseId);
        
        return $this->mapToDTO($course, $enrollmentCount, $completionCount);
    }
    
    public function publishCourse(string $courseIdString): void
    {
        $courseId = new CourseId($courseIdString);
        $course = $this->courseRepository->findById($courseId);
        
        if ($course === null) {
            throw new InvalidArgumentException('Course not found');
        }
        
        $course->publish();
        
        $this->courseRepository->save($course);
    }
    
    public function archiveCourse(string $courseIdString): void
    {
        $courseId = new CourseId($courseIdString);
        $course = $this->courseRepository->findById($courseId);
        
        if ($course === null) {
            throw new InvalidArgumentException('Course not found');
        }
        
        $course->archive();
        
        $this->courseRepository->save($course);
    }
    
    /**
     * @return CourseDTO[]
     */
    public function getAllCourses(): array
    {
        $courses = $this->courseRepository->findAll();
        
        return array_map(
            fn(Course $course) => $this->mapToDTO($course),
            $courses
        );
    }
    
    /**
     * @return CourseDTO[]
     */
    public function getPublishedCourses(): array
    {
        $courses = $this->courseRepository->findPublished();
        
        return array_map(
            fn(Course $course) => $this->mapToDTO($course),
            $courses
        );
    }
    
    private function mapToDTO(Course $course, int $enrollmentCount = 0, int $completionCount = 0): CourseDTO
    {
        return new CourseDTO(
            id: $course->id()->value(),
            code: $course->code()->value(),
            title: $course->title(),
            description: $course->description(),
            durationMinutes: $course->duration()->inMinutes(),
            durationHours: $course->duration()->inHours(),
            durationFormatted: (string)$course->duration(),
            priceAmount: $course->price()->amount(),
            priceCurrency: $course->price()->currency(),
            priceFormatted: (string)$course->price(),
            status: $course->status(),
            createdAt: $course->createdAt()->format('Y-m-d H:i:s'),
            publishedAt: $course->publishedAt()?->format('Y-m-d H:i:s'),
            enrollmentCount: $enrollmentCount,
            completionCount: $completionCount
        );
    }
} 