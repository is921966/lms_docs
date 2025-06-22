<?php

namespace Tests;

use PHPUnit\Framework\TestCase;

class SimpleTest extends TestCase
{
    public function testBasicAssertion(): void
    {
        $this->assertTrue(true);
    }
    
    public function testBasicMath(): void
    {
        $this->assertEquals(4, 2 + 2);
    }
    
    public function testString(): void
    {
        $string = 'Hello, World!';
        $this->assertStringContainsString('World', $string);
    }
} 