<?php

declare(strict_types=1);

namespace Tests\Unit\Program\Application\DTO;

use Program\Application\DTO\TrackDTO;
use Program\Domain\Track;
use Program\Domain\ValueObjects\TrackId;
use Program\Domain\ValueObjects\ProgramId;
use Program\Domain\ValueObjects\TrackOrder;
use Learning\Domain\ValueObjects\CourseId;
use PHPUnit\Framework\TestCase;

class TrackDTOTest extends TestCase
{
    public function testCanBeCreatedFromEntity(): void
    {
        // Arrange
        $track = Track::create(
            TrackId::generate(),
            ProgramId::generate(),
            'Foundation Track',
            'Basic knowledge and skills',
            TrackOrder::first()
        );
        $track->setRequired(true);
        $track->addCourse(CourseId::generate());
        $track->addCourse(CourseId::generate());
        
        // Act
        $dto = TrackDTO::fromEntity($track);
        
        // Assert
        $this->assertInstanceOf(TrackDTO::class, $dto);
        $this->assertEquals($track->getId()->getValue(), $dto->id);
        $this->assertEquals($track->getProgramId()->getValue(), $dto->programId);
        $this->assertEquals($track->getTitle(), $dto->title);
        $this->assertEquals($track->getDescription(), $dto->description);
        $this->assertEquals($track->getOrder()->getValue(), $dto->order);
        $this->assertEquals($track->isRequired(), $dto->isRequired);
        $this->assertCount(2, $dto->courseIds);
    }
    
    public function testCanBeCreatedFromArray(): void
    {
        // Arrange
        $data = [
            'id' => 'a1b2c3d4-e5f6-7890-abcd-ef1234567890',
            'programId' => 'f47ac10b-58cc-4372-a567-0e02b2c3d479',
            'title' => 'Advanced Track',
            'description' => 'Advanced topics and practices',
            'order' => 2,
            'isRequired' => false,
            'courseIds' => [
                'c1d2e3f4-5678-90ab-cdef-1234567890ab',
                'd2e3f4g5-6789-0abc-def1-234567890abc'
            ],
            'courseCount' => 2
        ];
        
        // Act
        $dto = TrackDTO::fromArray($data);
        
        // Assert
        $this->assertEquals($data['id'], $dto->id);
        $this->assertEquals($data['programId'], $dto->programId);
        $this->assertEquals($data['title'], $dto->title);
        $this->assertEquals($data['description'], $dto->description);
        $this->assertEquals($data['order'], $dto->order);
        $this->assertEquals($data['isRequired'], $dto->isRequired);
        $this->assertEquals($data['courseIds'], $dto->courseIds);
        $this->assertEquals($data['courseCount'], $dto->courseCount);
    }
    
    public function testCanBeConvertedToArray(): void
    {
        // Arrange
        $track = $this->createTrack();
        $dto = TrackDTO::fromEntity($track);
        
        // Act
        $array = $dto->toArray();
        
        // Assert
        $this->assertIsArray($array);
        $this->assertArrayHasKey('id', $array);
        $this->assertArrayHasKey('programId', $array);
        $this->assertArrayHasKey('title', $array);
        $this->assertArrayHasKey('description', $array);
        $this->assertArrayHasKey('order', $array);
        $this->assertArrayHasKey('isRequired', $array);
        $this->assertArrayHasKey('courseIds', $array);
        $this->assertArrayHasKey('courseCount', $array);
    }
    
    public function testCanBeJsonSerialized(): void
    {
        // Arrange
        $track = $this->createTrack();
        $dto = TrackDTO::fromEntity($track);
        
        // Act
        $json = json_encode($dto);
        $decoded = json_decode($json, true);
        
        // Assert
        $this->assertIsString($json);
        $this->assertEquals($dto->id, $decoded['id']);
        $this->assertEquals($dto->title, $decoded['title']);
        $this->assertEquals($dto->order, $decoded['order']);
    }
    
    private function createTrack(): Track
    {
        return Track::create(
            TrackId::generate(),
            ProgramId::generate(),
            'Test Track',
            'Test Description',
            TrackOrder::first()
        );
    }
} 