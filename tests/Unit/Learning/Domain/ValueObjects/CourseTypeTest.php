<?php

declare(strict_types=1);

namespace Tests\Unit\Learning\Domain\ValueObjects;

use Learning\Domain\ValueObjects\CourseType;
use PHPUnit\Framework\TestCase;

class CourseTypeTest extends TestCase
{
    public function testCanBeCreatedFromValidType(): void
    {
        $online = CourseType::ONLINE;
        $offline = CourseType::OFFLINE;
        $blended = CourseType::BLENDED;
        
        $this->assertEquals('ONLINE', $online->value);
        $this->assertEquals('OFFLINE', $offline->value);
        $this->assertEquals('BLENDED', $blended->value);
    }
    
    public function testCanGetAllValues(): void
    {
        $values = CourseType::values();
        
        $this->assertCount(3, $values);
        $this->assertContains('ONLINE', $values);
        $this->assertContains('OFFLINE', $values);
        $this->assertContains('BLENDED', $values);
    }
    
    public function testCanBeCreatedFromString(): void
    {
        $online = CourseType::from('ONLINE');
        $offline = CourseType::from('OFFLINE');
        $blended = CourseType::from('BLENDED');
        
        $this->assertEquals(CourseType::ONLINE, $online);
        $this->assertEquals(CourseType::OFFLINE, $offline);
        $this->assertEquals(CourseType::BLENDED, $blended);
    }
    
    public function testCanTryFromString(): void
    {
        $online = CourseType::tryFrom('ONLINE');
        $invalid = CourseType::tryFrom('INVALID');
        
        $this->assertEquals(CourseType::ONLINE, $online);
        $this->assertNull($invalid);
    }
    
    public function testCanGetLabel(): void
    {
        $this->assertEquals('Online', CourseType::ONLINE->getLabel());
        $this->assertEquals('Offline', CourseType::OFFLINE->getLabel());
        $this->assertEquals('Blended', CourseType::BLENDED->getLabel());
    }
    
    public function testCanBeSerializedToJson(): void
    {
        $type = CourseType::ONLINE;
        $json = json_encode(['type' => $type]);
        
        $this->assertJson($json);
        $decoded = json_decode($json, true);
        $this->assertEquals('ONLINE', $decoded['type']);
    }
} 