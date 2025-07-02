<?php

declare(strict_types=1);

namespace Tests\Unit\Program\Application\DTO;

use Program\Application\DTO\ProgramEnrollmentDTO;
use Program\Domain\ProgramEnrollment;
use Program\Domain\ValueObjects\ProgramId;
use User\Domain\ValueObjects\UserId;
use PHPUnit\Framework\TestCase;

class ProgramEnrollmentDTOTest extends TestCase
{
    public function testCanBeCreatedFromEntity(): void
    {
        // Arrange
        $enrollment = ProgramEnrollment::create(
            UserId::generate(),
            ProgramId::generate()
        );
        $enrollment->start();
        $enrollment->updateProgress(75);
        
        // Act
        $dto = ProgramEnrollmentDTO::fromEntity($enrollment);
        
        // Assert
        $this->assertInstanceOf(ProgramEnrollmentDTO::class, $dto);
        $this->assertEquals($enrollment->getUserId()->getValue(), $dto->userId);
        $this->assertEquals($enrollment->getProgramId()->getValue(), $dto->programId);
        $this->assertEquals($enrollment->getStatus(), $dto->status);
        $this->assertEquals($enrollment->getProgress(), $dto->progress);
        $this->assertEquals($enrollment->getEnrolledAt()->format('Y-m-d H:i:s'), $dto->enrolledAt);
        $this->assertNotNull($dto->startedAt);
        $this->assertNull($dto->completedAt);
    }
    
    public function testCanBeCreatedFromArray(): void
    {
        // Arrange
        $data = [
            'userId' => 'u123e4567-e89b-12d3-a456-426614174000',
            'programId' => 'p987e6543-e21b-12d3-a456-426614174000',
            'status' => 'in_progress',
            'progress' => 50,
            'enrolledAt' => '2025-07-01 10:00:00',
            'startedAt' => '2025-07-01 10:30:00',
            'completedAt' => null
        ];
        
        // Act
        $dto = ProgramEnrollmentDTO::fromArray($data);
        
        // Assert
        $this->assertEquals($data['userId'], $dto->userId);
        $this->assertEquals($data['programId'], $dto->programId);
        $this->assertEquals($data['status'], $dto->status);
        $this->assertEquals($data['progress'], $dto->progress);
        $this->assertEquals($data['enrolledAt'], $dto->enrolledAt);
        $this->assertEquals($data['startedAt'], $dto->startedAt);
        $this->assertNull($dto->completedAt);
    }
    
    public function testCanHandleCompletedEnrollment(): void
    {
        // Arrange
        $enrollment = ProgramEnrollment::create(
            UserId::generate(),
            ProgramId::generate()
        );
        $enrollment->start();
        $enrollment->complete();
        
        // Act
        $dto = ProgramEnrollmentDTO::fromEntity($enrollment);
        
        // Assert
        $this->assertEquals('completed', $dto->status);
        $this->assertEquals(100, $dto->progress);
        $this->assertNotNull($dto->completedAt);
    }
    
    public function testCanBeConvertedToArray(): void
    {
        // Arrange
        $enrollment = $this->createEnrollment();
        $dto = ProgramEnrollmentDTO::fromEntity($enrollment);
        
        // Act
        $array = $dto->toArray();
        
        // Assert
        $this->assertIsArray($array);
        $this->assertArrayHasKey('userId', $array);
        $this->assertArrayHasKey('programId', $array);
        $this->assertArrayHasKey('status', $array);
        $this->assertArrayHasKey('progress', $array);
        $this->assertArrayHasKey('enrolledAt', $array);
        $this->assertArrayHasKey('startedAt', $array);
        $this->assertArrayHasKey('completedAt', $array);
    }
    
    public function testCanBeJsonSerialized(): void
    {
        // Arrange
        $enrollment = $this->createEnrollment();
        $dto = ProgramEnrollmentDTO::fromEntity($enrollment);
        
        // Act
        $json = json_encode($dto);
        $decoded = json_decode($json, true);
        
        // Assert
        $this->assertIsString($json);
        $this->assertEquals($dto->userId, $decoded['userId']);
        $this->assertEquals($dto->programId, $decoded['programId']);
        $this->assertEquals($dto->status, $decoded['status']);
    }
    
    private function createEnrollment(): ProgramEnrollment
    {
        return ProgramEnrollment::create(
            UserId::generate(),
            ProgramId::generate()
        );
    }
} 