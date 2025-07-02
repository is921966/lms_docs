<?php

declare(strict_types=1);

namespace Tests\Unit\Learning\Domain\ValueObjects;

use Learning\Domain\ValueObjects\ProgressId;
use PHPUnit\Framework\TestCase;

class ProgressIdTest extends TestCase
{
    public function testCanBeCreatedFromString(): void
    {
        $uuid = 'a1b2c3d4-e5f6-4789-0123-456789abcdef';
        $progressId = ProgressId::fromString($uuid);
        
        $this->assertInstanceOf(ProgressId::class, $progressId);
        $this->assertEquals($uuid, $progressId->getValue());
    }
    
    public function testCanBeGenerated(): void
    {
        $progressId = ProgressId::generate();
        
        $this->assertInstanceOf(ProgressId::class, $progressId);
        $this->assertMatchesRegularExpression(
            '/^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i',
            $progressId->getValue()
        );
    }
    
    public function testEquality(): void
    {
        $uuid = 'a1b2c3d4-e5f6-4789-0123-456789abcdef';
        $progressId1 = ProgressId::fromString($uuid);
        $progressId2 = ProgressId::fromString($uuid);
        $progressId3 = ProgressId::generate();
        
        $this->assertTrue($progressId1->equals($progressId2));
        $this->assertFalse($progressId1->equals($progressId3));
    }
} 