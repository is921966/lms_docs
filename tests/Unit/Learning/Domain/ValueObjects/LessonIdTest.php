<?php

declare(strict_types=1);

namespace Tests\Unit\Learning\Domain\ValueObjects;

use App\Learning\Domain\ValueObjects\LessonId;
use PHPUnit\Framework\TestCase;
use Ramsey\Uuid\Uuid;

class LessonIdTest extends TestCase
{
    public function testCanBeCreatedFromValidUuid(): void
    {
        $uuid = Uuid::uuid4()->toString();
        $lessonId = LessonId::fromString($uuid);
        
        $this->assertInstanceOf(LessonId::class, $lessonId);
        $this->assertEquals($uuid, $lessonId->toString());
    }
    
    public function testCanGenerateNewId(): void
    {
        $lessonId = LessonId::generate();
        
        $this->assertInstanceOf(LessonId::class, $lessonId);
        $this->assertTrue(Uuid::isValid($lessonId->toString()));
    }
    
    public function testThrowsExceptionForInvalidUuid(): void
    {
        $this->expectException(\InvalidArgumentException::class);
        $this->expectExceptionMessage('Invalid LessonId format');
        
        LessonId::fromString('invalid-uuid');
    }
    
    public function testCanBeCompared(): void
    {
        $uuid = Uuid::uuid4()->toString();
        $lessonId1 = LessonId::fromString($uuid);
        $lessonId2 = LessonId::fromString($uuid);
        $lessonId3 = LessonId::generate();
        
        $this->assertTrue($lessonId1->equals($lessonId2));
        $this->assertFalse($lessonId1->equals($lessonId3));
    }
} 