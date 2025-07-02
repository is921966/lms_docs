<?php

declare(strict_types=1);

namespace Tests\Unit\Program\Domain\ValueObjects;

use Program\Domain\ValueObjects\ProgramId;
use PHPUnit\Framework\TestCase;

class ProgramIdTest extends TestCase
{
    public function testCanBeCreatedFromValidString(): void
    {
        // Arrange
        $uuid = 'f47ac10b-58cc-4372-a567-0e02b2c3d479';
        
        // Act
        $programId = ProgramId::fromString($uuid);
        
        // Assert
        $this->assertInstanceOf(ProgramId::class, $programId);
        $this->assertEquals($uuid, $programId->getValue());
    }
    
    public function testCanGenerateNewId(): void
    {
        // Act
        $programId = ProgramId::generate();
        
        // Assert
        $this->assertInstanceOf(ProgramId::class, $programId);
        $this->assertMatchesRegularExpression(
            '/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i',
            $programId->getValue()
        );
    }
    
    public function testThrowsExceptionForInvalidUuid(): void
    {
        // Arrange
        $invalidUuid = 'invalid-uuid';
        
        // Assert
        $this->expectException(\InvalidArgumentException::class);
        $this->expectExceptionMessage('Invalid ProgramId format');
        
        // Act
        ProgramId::fromString($invalidUuid);
    }
    
    public function testCanBeCompared(): void
    {
        // Arrange
        $uuid = 'f47ac10b-58cc-4372-a567-0e02b2c3d479';
        $programId1 = ProgramId::fromString($uuid);
        $programId2 = ProgramId::fromString($uuid);
        $programId3 = ProgramId::generate();
        
        // Act & Assert
        $this->assertTrue($programId1->equals($programId2));
        $this->assertFalse($programId1->equals($programId3));
    }
    
    public function testCanBeConvertedToString(): void
    {
        // Arrange
        $uuid = 'f47ac10b-58cc-4372-a567-0e02b2c3d479';
        $programId = ProgramId::fromString($uuid);
        
        // Act & Assert
        $this->assertEquals($uuid, (string)$programId);
        $this->assertEquals($uuid, $programId->toString());
    }
    
    public function testIsJsonSerializable(): void
    {
        // Arrange
        $uuid = 'f47ac10b-58cc-4372-a567-0e02b2c3d479';
        $programId = ProgramId::fromString($uuid);
        
        // Act
        $json = json_encode(['id' => $programId]);
        
        // Assert
        $this->assertEquals('{"id":"' . $uuid . '"}', $json);
    }
} 