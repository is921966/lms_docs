<?php

declare(strict_types=1);

namespace Tests\Unit\Notification\Domain\ValueObjects;

use PHPUnit\Framework\TestCase;
use Notification\Domain\ValueObjects\RecipientId;

class RecipientIdTest extends TestCase
{
    public function testCanBeCreatedFromValidUuid(): void
    {
        $uuid = 'f47ac10b-58cc-4372-a567-0e02b2c3d479';
        $recipientId = RecipientId::fromString($uuid);
        
        $this->assertInstanceOf(RecipientId::class, $recipientId);
        $this->assertEquals($uuid, $recipientId->getValue());
    }
    
    public function testThrowsExceptionForInvalidUuid(): void
    {
        $this->expectException(\InvalidArgumentException::class);
        $this->expectExceptionMessage('Invalid recipient ID format');
        
        RecipientId::fromString('invalid-uuid');
    }
    
    public function testThrowsExceptionForEmptyString(): void
    {
        $this->expectException(\InvalidArgumentException::class);
        $this->expectExceptionMessage('Recipient ID cannot be empty');
        
        RecipientId::fromString('');
    }
    
    public function testCanBeCompared(): void
    {
        $uuid = 'f47ac10b-58cc-4372-a567-0e02b2c3d479';
        $id1 = RecipientId::fromString($uuid);
        $id2 = RecipientId::fromString($uuid);
        $id3 = RecipientId::fromString('a47ac10b-58cc-4372-a567-0e02b2c3d479');
        
        $this->assertTrue($id1->equals($id2));
        $this->assertFalse($id1->equals($id3));
    }
    
    public function testCanBeConvertedToString(): void
    {
        $uuid = 'f47ac10b-58cc-4372-a567-0e02b2c3d479';
        $recipientId = RecipientId::fromString($uuid);
        
        $this->assertEquals($uuid, (string) $recipientId);
    }
} 