<?php

declare(strict_types=1);

namespace Tests\Unit\Learning\Domain\ValueObjects;

use Learning\Domain\ValueObjects\ModuleId;
use PHPUnit\Framework\TestCase;
use Ramsey\Uuid\Uuid;

class ModuleIdTest extends TestCase
{
    public function testCanBeCreatedFromValidUuid(): void
    {
        $uuid = Uuid::uuid4()->toString();
        $moduleId = ModuleId::fromString($uuid);
        
        $this->assertInstanceOf(ModuleId::class, $moduleId);
        $this->assertEquals($uuid, $moduleId->toString());
    }
    
    public function testCanGenerateNewId(): void
    {
        $moduleId = ModuleId::generate();
        
        $this->assertInstanceOf(ModuleId::class, $moduleId);
        $this->assertTrue(Uuid::isValid($moduleId->toString()));
    }
    
    public function testThrowsExceptionForInvalidUuid(): void
    {
        $this->expectException(\InvalidArgumentException::class);
        $this->expectExceptionMessage('Invalid ModuleId format');
        
        ModuleId::fromString('invalid-uuid');
    }
    
    public function testCanBeCompared(): void
    {
        $uuid = Uuid::uuid4()->toString();
        $moduleId1 = ModuleId::fromString($uuid);
        $moduleId2 = ModuleId::fromString($uuid);
        $moduleId3 = ModuleId::generate();
        
        $this->assertTrue($moduleId1->equals($moduleId2));
        $this->assertFalse($moduleId1->equals($moduleId3));
    }
} 