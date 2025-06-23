<?php

declare(strict_types=1);

namespace Tests\Unit\Learning\Domain\ValueObjects;

use App\Learning\Domain\ValueObjects\EnrollmentId;
use PHPUnit\Framework\TestCase;

class EnrollmentIdTest extends TestCase
{
    public function testCanBeCreatedFromString(): void
    {
        $uuid = 'f47ac10b-58cc-4372-a567-0e02b2c3d479';
        $enrollmentId = EnrollmentId::fromString($uuid);
        
        $this->assertInstanceOf(EnrollmentId::class, $enrollmentId);
        $this->assertEquals($uuid, $enrollmentId->toString());
    }
    
    public function testCanBeGenerated(): void
    {
        $enrollmentId = EnrollmentId::generate();
        
        $this->assertInstanceOf(EnrollmentId::class, $enrollmentId);
        $this->assertMatchesRegularExpression(
            '/^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i',
            $enrollmentId->toString()
        );
    }
    
    public function testEquality(): void
    {
        $uuid = 'f47ac10b-58cc-4372-a567-0e02b2c3d479';
        $enrollmentId1 = EnrollmentId::fromString($uuid);
        $enrollmentId2 = EnrollmentId::fromString($uuid);
        $enrollmentId3 = EnrollmentId::generate();
        
        $this->assertTrue($enrollmentId1->equals($enrollmentId2));
        $this->assertFalse($enrollmentId1->equals($enrollmentId3));
    }
    
    public function testThrowsExceptionForInvalidUuid(): void
    {
        $this->expectException(\InvalidArgumentException::class);
        $this->expectExceptionMessage('Invalid UUID format');
        
        EnrollmentId::fromString('invalid-uuid');
    }
} 