<?php

declare(strict_types=1);

namespace Tests\Unit\Position\Domain\Repository;

use App\Position\Domain\Repository\PositionRepositoryInterface;
use App\Position\Domain\Repository\PositionProfileRepositoryInterface;
use App\Position\Domain\Repository\CareerPathRepositoryInterface;
use App\Position\Domain\Position;
use App\Position\Domain\PositionProfile;
use App\Position\Domain\CareerPath;
use App\Position\Domain\ValueObjects\PositionId;
use PHPUnit\Framework\TestCase;

class PositionRepositoryInterfaceTest extends TestCase
{
    public function testPositionRepositoryInterfaceExists(): void
    {
        $this->assertTrue(interface_exists(PositionRepositoryInterface::class));
        
        $reflection = new \ReflectionClass(PositionRepositoryInterface::class);
        
        // Check required methods
        $this->assertTrue($reflection->hasMethod('save'));
        $this->assertTrue($reflection->hasMethod('findById'));
        $this->assertTrue($reflection->hasMethod('findByCode'));
        $this->assertTrue($reflection->hasMethod('findByDepartment'));
        $this->assertTrue($reflection->hasMethod('findActive'));
        $this->assertTrue($reflection->hasMethod('delete'));
    }
    
    public function testPositionProfileRepositoryInterfaceExists(): void
    {
        $this->assertTrue(interface_exists(PositionProfileRepositoryInterface::class));
        
        $reflection = new \ReflectionClass(PositionProfileRepositoryInterface::class);
        
        // Check required methods
        $this->assertTrue($reflection->hasMethod('save'));
        $this->assertTrue($reflection->hasMethod('findByPositionId'));
        $this->assertTrue($reflection->hasMethod('findByCompetencyId'));
        $this->assertTrue($reflection->hasMethod('delete'));
    }
    
    public function testCareerPathRepositoryInterfaceExists(): void
    {
        $this->assertTrue(interface_exists(CareerPathRepositoryInterface::class));
        
        $reflection = new \ReflectionClass(CareerPathRepositoryInterface::class);
        
        // Check required methods
        $this->assertTrue($reflection->hasMethod('save'));
        $this->assertTrue($reflection->hasMethod('findById'));
        $this->assertTrue($reflection->hasMethod('findByFromPosition'));
        $this->assertTrue($reflection->hasMethod('findByToPosition'));
        $this->assertTrue($reflection->hasMethod('findPath'));
        $this->assertTrue($reflection->hasMethod('findActive'));
        $this->assertTrue($reflection->hasMethod('delete'));
    }
} 