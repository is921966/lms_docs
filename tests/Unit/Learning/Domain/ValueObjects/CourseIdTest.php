<?php

declare(strict_types=1);

namespace Tests\Unit\Learning\Domain\ValueObjects;

use App\Learning\Domain\ValueObjects\CourseId;
use PHPUnit\Framework\TestCase;
use Ramsey\Uuid\Uuid;

class CourseIdTest extends TestCase
{
    public function testCanBeCreatedFromValidUuid(): void
    {
        $uuid = Uuid::uuid4()->toString();
        $courseId = CourseId::fromString($uuid);
        
        $this->assertInstanceOf(CourseId::class, $courseId);
        $this->assertEquals($uuid, $courseId->toString());
    }
    
    public function testCanGenerateNewId(): void
    {
        $courseId = CourseId::generate();
        
        $this->assertInstanceOf(CourseId::class, $courseId);
        $this->assertTrue(Uuid::isValid($courseId->toString()));
    }
    
    public function testThrowsExceptionForInvalidUuid(): void
    {
        $this->expectException(\InvalidArgumentException::class);
        $this->expectExceptionMessage('Invalid CourseId format');
        
        CourseId::fromString('invalid-uuid');
    }
    
    public function testCanBeCompared(): void
    {
        $uuid = Uuid::uuid4()->toString();
        $courseId1 = CourseId::fromString($uuid);
        $courseId2 = CourseId::fromString($uuid);
        $courseId3 = CourseId::generate();
        
        $this->assertTrue($courseId1->equals($courseId2));
        $this->assertFalse($courseId1->equals($courseId3));
    }
    
    public function testCanBeSerializedToJson(): void
    {
        $courseId = CourseId::generate();
        $json = json_encode(['id' => $courseId]);
        
        $this->assertJson($json);
        $decoded = json_decode($json, true);
        $this->assertEquals($courseId->toString(), $decoded['id']);
    }
} 