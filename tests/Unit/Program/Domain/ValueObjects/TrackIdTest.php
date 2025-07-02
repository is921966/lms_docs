<?php

declare(strict_types=1);

namespace Tests\Unit\Program\Domain\ValueObjects;

use Program\Domain\ValueObjects\TrackId;
use PHPUnit\Framework\TestCase;

class TrackIdTest extends TestCase
{
    public function testCanBeCreatedFromValidString(): void
    {
        // Arrange
        $uuid = 'a1b2c3d4-e5f6-7890-abcd-ef1234567890';
        
        // Act
        $trackId = TrackId::fromString($uuid);
        
        // Assert
        $this->assertInstanceOf(TrackId::class, $trackId);
        $this->assertEquals($uuid, $trackId->getValue());
    }
    
    public function testCanGenerateNewId(): void
    {
        // Act
        $trackId = TrackId::generate();
        
        // Assert
        $this->assertInstanceOf(TrackId::class, $trackId);
        $this->assertMatchesRegularExpression(
            '/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i',
            $trackId->getValue()
        );
    }
    
    public function testThrowsExceptionForInvalidUuid(): void
    {
        // Arrange
        $invalidUuid = 'not-a-valid-uuid';
        
        // Assert
        $this->expectException(\InvalidArgumentException::class);
        $this->expectExceptionMessage('Invalid TrackId format');
        
        // Act
        TrackId::fromString($invalidUuid);
    }
    
    public function testCanBeCompared(): void
    {
        // Arrange
        $uuid = 'a1b2c3d4-e5f6-7890-abcd-ef1234567890';
        $trackId1 = TrackId::fromString($uuid);
        $trackId2 = TrackId::fromString($uuid);
        $trackId3 = TrackId::generate();
        
        // Act & Assert
        $this->assertTrue($trackId1->equals($trackId2));
        $this->assertFalse($trackId1->equals($trackId3));
    }
    
    public function testCanBeConvertedToString(): void
    {
        // Arrange
        $uuid = 'a1b2c3d4-e5f6-7890-abcd-ef1234567890';
        $trackId = TrackId::fromString($uuid);
        
        // Act & Assert
        $this->assertEquals($uuid, (string)$trackId);
        $this->assertEquals($uuid, $trackId->toString());
    }
    
    public function testIsJsonSerializable(): void
    {
        // Arrange
        $uuid = 'a1b2c3d4-e5f6-7890-abcd-ef1234567890';
        $trackId = TrackId::fromString($uuid);
        
        // Act
        $json = json_encode(['trackId' => $trackId]);
        
        // Assert
        $this->assertEquals('{"trackId":"' . $uuid . '"}', $json);
    }
} 