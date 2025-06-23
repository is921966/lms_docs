<?php

declare(strict_types=1);

namespace Tests\Unit\Learning\Domain\ValueObjects;

use App\Learning\Domain\ValueObjects\CertificateId;
use PHPUnit\Framework\TestCase;

class CertificateIdTest extends TestCase
{
    public function testCanBeCreatedFromString(): void
    {
        $uuid = 'c1d2e3f4-a5b6-4789-0123-456789abcdef';
        $certificateId = CertificateId::fromString($uuid);
        
        $this->assertInstanceOf(CertificateId::class, $certificateId);
        $this->assertEquals($uuid, $certificateId->toString());
    }
    
    public function testCanBeGenerated(): void
    {
        $certificateId = CertificateId::generate();
        
        $this->assertInstanceOf(CertificateId::class, $certificateId);
        $this->assertMatchesRegularExpression(
            '/^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i',
            $certificateId->toString()
        );
    }
    
    public function testEquality(): void
    {
        $uuid = 'c1d2e3f4-a5b6-4789-0123-456789abcdef';
        $certificateId1 = CertificateId::fromString($uuid);
        $certificateId2 = CertificateId::fromString($uuid);
        $certificateId3 = CertificateId::generate();
        
        $this->assertTrue($certificateId1->equals($certificateId2));
        $this->assertFalse($certificateId1->equals($certificateId3));
    }
} 