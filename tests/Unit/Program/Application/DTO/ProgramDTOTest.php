<?php

declare(strict_types=1);

namespace Tests\Unit\Program\Application\DTO;

use Program\Application\DTO\ProgramDTO;
use Program\Domain\Program;
use Program\Domain\ValueObjects\ProgramId;
use Program\Domain\ValueObjects\ProgramCode;
use PHPUnit\Framework\TestCase;

class ProgramDTOTest extends TestCase
{
    public function testCanBeCreatedFromEntity(): void
    {
        // Arrange
        $program = Program::create(
            ProgramId::generate(),
            ProgramCode::fromString('LEAD-101'),
            'Leadership Program',
            'A comprehensive leadership development program'
        );
        
        // Act
        $dto = ProgramDTO::fromEntity($program);
        
        // Assert
        $this->assertInstanceOf(ProgramDTO::class, $dto);
        $this->assertEquals($program->getId()->getValue(), $dto->id);
        $this->assertEquals($program->getCode()->getValue(), $dto->code);
        $this->assertEquals($program->getTitle(), $dto->title);
        $this->assertEquals($program->getDescription(), $dto->description);
        $this->assertEquals($program->getStatus()->getValue(), $dto->status);
        $this->assertEquals($program->getCompletionCriteria()->jsonSerialize(), $dto->completionCriteria);
    }
    
    public function testCanBeCreatedFromArray(): void
    {
        // Arrange
        $data = [
            'id' => 'f47ac10b-58cc-4372-a567-0e02b2c3d479',
            'code' => 'TECH-201',
            'title' => 'Technical Leadership',
            'description' => 'Advanced technical leadership program',
            'status' => 'draft',
            'completionCriteria' => [
                'percentage' => 80,
                'requireAll' => false
            ],
            'metadata' => ['level' => 'advanced'],
            'trackCount' => 3,
            'enrollmentCount' => 25
        ];
        
        // Act
        $dto = ProgramDTO::fromArray($data);
        
        // Assert
        $this->assertEquals($data['id'], $dto->id);
        $this->assertEquals($data['code'], $dto->code);
        $this->assertEquals($data['title'], $dto->title);
        $this->assertEquals($data['description'], $dto->description);
        $this->assertEquals($data['status'], $dto->status);
        $this->assertEquals($data['completionCriteria'], $dto->completionCriteria);
        $this->assertEquals($data['metadata'], $dto->metadata);
        $this->assertEquals($data['trackCount'], $dto->trackCount);
        $this->assertEquals($data['enrollmentCount'], $dto->enrollmentCount);
    }
    
    public function testCanBeConvertedToArray(): void
    {
        // Arrange
        $program = $this->createProgram();
        $dto = ProgramDTO::fromEntity($program);
        
        // Act
        $array = $dto->toArray();
        
        // Assert
        $this->assertIsArray($array);
        $this->assertArrayHasKey('id', $array);
        $this->assertArrayHasKey('code', $array);
        $this->assertArrayHasKey('title', $array);
        $this->assertArrayHasKey('description', $array);
        $this->assertArrayHasKey('status', $array);
        $this->assertArrayHasKey('completionCriteria', $array);
        $this->assertArrayHasKey('metadata', $array);
        $this->assertArrayHasKey('trackCount', $array);
        $this->assertArrayHasKey('enrollmentCount', $array);
    }
    
    public function testCanBeJsonSerialized(): void
    {
        // Arrange
        $program = $this->createProgram();
        $dto = ProgramDTO::fromEntity($program);
        
        // Act
        $json = json_encode($dto);
        $decoded = json_decode($json, true);
        
        // Assert
        $this->assertIsString($json);
        $this->assertEquals($dto->id, $decoded['id']);
        $this->assertEquals($dto->code, $decoded['code']);
        $this->assertEquals($dto->title, $decoded['title']);
    }
    
    private function createProgram(): Program
    {
        return Program::create(
            ProgramId::generate(),
            ProgramCode::fromString('TEST-001'),
            'Test Program',
            'Test Description'
        );
    }
} 