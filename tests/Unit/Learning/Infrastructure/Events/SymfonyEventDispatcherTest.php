<?php

declare(strict_types=1);

namespace Tests\Unit\Learning\Infrastructure\Events;

use Learning\Domain\Events\CourseCreated;
use Common\Interfaces\DomainEventInterface;
use Learning\Domain\ValueObjects\CourseId;
use Learning\Domain\ValueObjects\CourseCode;
use Learning\Domain\ValueObjects\CourseStatus;
use Learning\Infrastructure\Events\SymfonyEventDispatcher;
use PHPUnit\Framework\TestCase;
use Symfony\Component\EventDispatcher\EventDispatcher;
use Symfony\Component\EventDispatcher\EventSubscriberInterface;

class SymfonyEventDispatcherTest extends TestCase
{
    private EventDispatcher $symfonyDispatcher;
    private SymfonyEventDispatcher $dispatcher;
    
    protected function setUp(): void
    {
        $this->symfonyDispatcher = new EventDispatcher();
        $this->dispatcher = new SymfonyEventDispatcher($this->symfonyDispatcher);
    }
    
    public function testDispatchEvent(): void
    {
        // Arrange
        $eventReceived = null;
        $listener = function(DomainEventInterface $event) use (&$eventReceived) {
            $eventReceived = $event;
        };
        
        $this->symfonyDispatcher->addListener(
            CourseCreated::class,
            $listener
        );
        
        $event = CourseCreated::create(
            CourseId::fromString('course-123'),
            CourseCode::fromString('PHP-101'),
            'PHP Basics',
            'Learn PHP from scratch',
            CourseStatus::draft()
        );
        
        // Act
        $this->dispatcher->dispatch($event);
        
        // Assert
        $this->assertNotNull($eventReceived);
        $this->assertInstanceOf(CourseCreated::class, $eventReceived);
        $this->assertEquals('course-123', $eventReceived->getCourseId()->getValue());
    }
    
    public function testDispatchMultipleListeners(): void
    {
        // Arrange
        $callCount = 0;
        $listener1 = function() use (&$callCount) {
            $callCount++;
        };
        $listener2 = function() use (&$callCount) {
            $callCount++;
        };
        
        $this->symfonyDispatcher->addListener(CourseCreated::class, $listener1);
        $this->symfonyDispatcher->addListener(CourseCreated::class, $listener2);
        
        $event = CourseCreated::create(
            CourseId::fromString('course-123'),
            CourseCode::fromString('PHP-101'),
            'PHP Basics',
            'Learn PHP from scratch',
            CourseStatus::draft()
        );
        
        // Act
        $this->dispatcher->dispatch($event);
        
        // Assert
        $this->assertEquals(2, $callCount);
    }
    
    public function testAddSubscriber(): void
    {
        // Arrange
        $subscriber = new TestEventSubscriber();
        $this->dispatcher->addSubscriber($subscriber);
        
        $event = CourseCreated::create(
            CourseId::fromString('course-123'),
            CourseCode::fromString('PHP-101'),
            'PHP Basics',
            'Learn PHP from scratch',
            CourseStatus::draft()
        );
        
        // Act
        $this->dispatcher->dispatch($event);
        
        // Assert
        $this->assertTrue($subscriber->wasHandled());
    }
    
    public function testEventPropagation(): void
    {
        // Arrange
        $events = [];
        
        // High priority listener
        $this->symfonyDispatcher->addListener(
            CourseCreated::class,
            function($event) use (&$events) {
                $events[] = 'high';
            },
            100
        );
        
        // Low priority listener
        $this->symfonyDispatcher->addListener(
            CourseCreated::class,
            function($event) use (&$events) {
                $events[] = 'low';
            },
            -100
        );
        
        $event = CourseCreated::create(
            CourseId::fromString('course-123'),
            CourseCode::fromString('PHP-101'),
            'PHP Basics',
            'Learn PHP from scratch',
            CourseStatus::draft()
        );
        
        // Act
        $this->dispatcher->dispatch($event);
        
        // Assert
        $this->assertEquals(['high', 'low'], $events);
    }
}

class TestEventSubscriber implements EventSubscriberInterface
{
    private bool $handled = false;
    
    public static function getSubscribedEvents(): array
    {
        return [
            CourseCreated::class => 'onCourseCreated',
        ];
    }
    
    public function onCourseCreated(CourseCreated $event): void
    {
        $this->handled = true;
    }
    
    public function wasHandled(): bool
    {
        return $this->handled;
    }
} 