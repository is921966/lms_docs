<?php

declare(strict_types=1);

namespace Tests\Unit\Learning\Application\DTO;

use App\Learning\Application\DTO\EnrollmentDTO;
use App\Learning\Domain\Enrollment;
use App\Learning\Domain\ValueObjects\CourseId;
use App\User\Domain\ValueObjects\UserId;
use PHPUnit\Framework\TestCase;

class EnrollmentDTOTest extends TestCase
{
    public function testCanBeCreatedFromArray(): void
    {
        $data = [
            'id' => 'f47ac10b-58cc-4372-a567-0e02b2c3d479',
            'userId' => 'a1b2c3d4-e5f6-4789-0123-456789abcdef',
            'courseId' => 'c1d2e3f4-a5b6-4789-0123-456789abcdef',
            'enrolledBy' => 'a1b2c3d4-e5f6-4789-0123-456789abcdef',
            'status' => 'active',
            'progressPercentage' => 75.5,
            'completionScore' => null,
            'expiryDate' => '2025-12-31T23:59:59+00:00',
            'activatedAt' => '2024-01-15T10:00:00+00:00',
            'completedAt' => null,
            'cancelledAt' => null,
            'cancellationReason' => null
        ];
        
        $dto = EnrollmentDTO::fromArray($data);
        
        $this->assertEquals($data['id'], $dto->id);
        $this->assertEquals($data['userId'], $dto->userId);
        $this->assertEquals($data['courseId'], $dto->courseId);
        $this->assertEquals($data['enrolledBy'], $dto->enrolledBy);
        $this->assertEquals($data['status'], $dto->status);
        $this->assertEquals($data['progressPercentage'], $dto->progressPercentage);
        $this->assertNull($dto->completionScore);
        $this->assertEquals($data['expiryDate'], $dto->expiryDate);
        $this->assertEquals($data['activatedAt'], $dto->activatedAt);
    }
    
    public function testCanBeCreatedFromDomainEntity(): void
    {
        $enrollment = $this->createTestEnrollment();
        $enrollment->activate();
        $enrollment->updateProgress(50.0);
        
        $dto = EnrollmentDTO::fromEntity($enrollment);
        
        $this->assertEquals($enrollment->getId()->toString(), $dto->id);
        $this->assertEquals($enrollment->getUserId()->getValue(), $dto->userId);
        $this->assertEquals($enrollment->getCourseId()->toString(), $dto->courseId);
        $this->assertEquals($enrollment->getEnrolledBy()->getValue(), $dto->enrolledBy);
        $this->assertEquals('active', $dto->status);
        $this->assertEquals(50.0, $dto->progressPercentage);
        $this->assertNull($dto->completionScore);
        $this->assertNotNull($dto->activatedAt);
    }
    
    public function testCanConvertToArray(): void
    {
        $dto = new EnrollmentDTO(
            id: 'f47ac10b-58cc-4372-a567-0e02b2c3d479',
            userId: 'user-123',
            courseId: 'course-456',
            enrolledBy: 'admin-789',
            status: 'pending',
            progressPercentage: 0.0,
            completionScore: null,
            expiryDate: null,
            activatedAt: null,
            completedAt: null,
            cancelledAt: null,
            expiredAt: null,
            cancellationReason: null,
            createdAt: '2024-01-01T00:00:00+00:00',
            updatedAt: '2024-01-01T00:00:00+00:00'
        );
        
        $array = $dto->toArray();
        
        $this->assertIsArray($array);
        $this->assertEquals($dto->id, $array['id']);
        $this->assertEquals($dto->userId, $array['userId']);
        $this->assertEquals($dto->courseId, $array['courseId']);
        $this->assertEquals($dto->status, $array['status']);
        $this->assertEquals($dto->progressPercentage, $array['progressPercentage']);
    }
    
    public function testCanCreateNewEntity(): void
    {
        $dto = new EnrollmentDTO(
            id: null,
            userId: 'a1b2c3d4-e5f6-4789-0123-456789abcdef',
            courseId: 'c1d2e3f4-a5b6-4789-0123-456789abcdef',
            enrolledBy: 'a1b2c3d4-e5f6-4789-0123-456789abcdef',
            status: 'pending',
            progressPercentage: 0.0,
            completionScore: null,
            expiryDate: null,
            activatedAt: null,
            completedAt: null,
            cancelledAt: null,
            expiredAt: null,
            cancellationReason: null,
            createdAt: null,
            updatedAt: null
        );
        
        $enrollment = $dto->toNewEntity();
        
        $this->assertInstanceOf(Enrollment::class, $enrollment);
        $this->assertEquals($dto->userId, $enrollment->getUserId()->getValue());
        $this->assertEquals($dto->courseId, $enrollment->getCourseId()->toString());
        $this->assertEquals('pending', $enrollment->getStatus()->value);
    }
    
    private function createTestEnrollment(): Enrollment
    {
        return Enrollment::create(
            userId: UserId::generate(),
            courseId: CourseId::generate(),
            enrolledBy: UserId::generate()
        );
    }
} 