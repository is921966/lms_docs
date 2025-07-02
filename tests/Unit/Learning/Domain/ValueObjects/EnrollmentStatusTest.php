<?php

declare(strict_types=1);

namespace Tests\Unit\Learning\Domain\ValueObjects;

use Learning\Domain\ValueObjects\EnrollmentStatus;
use PHPUnit\Framework\TestCase;

class EnrollmentStatusTest extends TestCase
{
    public function testCanBeCreatedWithValidStatuses(): void
    {
        $pending = EnrollmentStatus::PENDING;
        $active = EnrollmentStatus::ACTIVE;
        $completed = EnrollmentStatus::COMPLETED;
        $cancelled = EnrollmentStatus::CANCELLED;
        $expired = EnrollmentStatus::EXPIRED;
        
        $this->assertEquals('pending', $pending->value);
        $this->assertEquals('active', $active->value);
        $this->assertEquals('completed', $completed->value);
        $this->assertEquals('cancelled', $cancelled->value);
        $this->assertEquals('expired', $expired->value);
    }
    
    public function testCanGetLabel(): void
    {
        $this->assertEquals('Ожидает подтверждения', EnrollmentStatus::PENDING->label());
        $this->assertEquals('Активна', EnrollmentStatus::ACTIVE->label());
        $this->assertEquals('Завершена', EnrollmentStatus::COMPLETED->label());
        $this->assertEquals('Отменена', EnrollmentStatus::CANCELLED->label());
        $this->assertEquals('Истекла', EnrollmentStatus::EXPIRED->label());
    }
    
    public function testCanCheckIfActive(): void
    {
        $this->assertFalse(EnrollmentStatus::PENDING->isActive());
        $this->assertTrue(EnrollmentStatus::ACTIVE->isActive());
        $this->assertFalse(EnrollmentStatus::COMPLETED->isActive());
        $this->assertFalse(EnrollmentStatus::CANCELLED->isActive());
        $this->assertFalse(EnrollmentStatus::EXPIRED->isActive());
    }
    
    public function testCanCheckIfFinal(): void
    {
        $this->assertFalse(EnrollmentStatus::PENDING->isFinal());
        $this->assertFalse(EnrollmentStatus::ACTIVE->isFinal());
        $this->assertTrue(EnrollmentStatus::COMPLETED->isFinal());
        $this->assertTrue(EnrollmentStatus::CANCELLED->isFinal());
        $this->assertTrue(EnrollmentStatus::EXPIRED->isFinal());
    }
    
    public function testCanCheckAllowedTransitions(): void
    {
        // From PENDING
        $pendingTransitions = EnrollmentStatus::PENDING->allowedTransitions();
        $this->assertContains(EnrollmentStatus::ACTIVE, $pendingTransitions);
        $this->assertContains(EnrollmentStatus::CANCELLED, $pendingTransitions);
        $this->assertNotContains(EnrollmentStatus::COMPLETED, $pendingTransitions);
        
        // From ACTIVE
        $activeTransitions = EnrollmentStatus::ACTIVE->allowedTransitions();
        $this->assertContains(EnrollmentStatus::COMPLETED, $activeTransitions);
        $this->assertContains(EnrollmentStatus::CANCELLED, $activeTransitions);
        $this->assertContains(EnrollmentStatus::EXPIRED, $activeTransitions);
        $this->assertNotContains(EnrollmentStatus::PENDING, $activeTransitions);
        
        // From final states
        $this->assertEmpty(EnrollmentStatus::COMPLETED->allowedTransitions());
        $this->assertEmpty(EnrollmentStatus::CANCELLED->allowedTransitions());
        $this->assertEmpty(EnrollmentStatus::EXPIRED->allowedTransitions());
    }
    
    public function testCanTransitionTo(): void
    {
        // Valid transitions
        $this->assertTrue(EnrollmentStatus::PENDING->canTransitionTo(EnrollmentStatus::ACTIVE));
        $this->assertTrue(EnrollmentStatus::ACTIVE->canTransitionTo(EnrollmentStatus::COMPLETED));
        
        // Invalid transitions
        $this->assertFalse(EnrollmentStatus::PENDING->canTransitionTo(EnrollmentStatus::COMPLETED));
        $this->assertFalse(EnrollmentStatus::COMPLETED->canTransitionTo(EnrollmentStatus::ACTIVE));
    }
    
    public function testCanGetAllStatuses(): void
    {
        $statuses = EnrollmentStatus::cases();
        
        $this->assertCount(5, $statuses);
        $this->assertContainsOnlyInstancesOf(EnrollmentStatus::class, $statuses);
    }
} 