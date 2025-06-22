<?php

namespace Tests;

use PHPUnit\Framework\TestCase as BaseTestCase;
use Faker\Factory as Faker;
use Faker\Generator;

abstract class TestCase extends BaseTestCase
{
    protected Generator $faker;
    
    protected function setUp(): void
    {
        parent::setUp();
        $this->faker = Faker::create('ru_RU');
    }
    
    /**
     * Assert that an exception is thrown with specific message
     */
    protected function assertExceptionThrown(
        string $exceptionClass,
        string $expectedMessage,
        callable $callback
    ): void {
        $this->expectException($exceptionClass);
        $this->expectExceptionMessage($expectedMessage);
        $callback();
    }
    
    /**
     * Create a mock object with methods
     */
    protected function createMockWithMethods(
        string $className,
        array $methods = []
    ): object {
        $mock = $this->getMockBuilder($className)
            ->disableOriginalConstructor()
            ->onlyMethods(array_keys($methods))
            ->getMock();
            
        foreach ($methods as $method => $return) {
            if (is_callable($return)) {
                $mock->expects($this->any())
                    ->method($method)
                    ->willReturnCallback($return);
            } else {
                $mock->expects($this->any())
                    ->method($method)
                    ->willReturn($return);
            }
        }
        
        return $mock;
    }
    
    /**
     * Get private property value
     */
    protected function getPrivateProperty(object $object, string $property): mixed
    {
        $reflection = new \ReflectionClass($object);
        $property = $reflection->getProperty($property);
        $property->setAccessible(true);
        
        return $property->getValue($object);
    }
    
    /**
     * Set private property value
     */
    protected function setPrivateProperty(
        object $object,
        string $property,
        mixed $value
    ): void {
        $reflection = new \ReflectionClass($object);
        $property = $reflection->getProperty($property);
        $property->setAccessible(true);
        $property->setValue($object, $value);
    }
    
    /**
     * Call private method
     */
    protected function callPrivateMethod(
        object $object,
        string $method,
        array $args = []
    ): mixed {
        $reflection = new \ReflectionClass($object);
        $method = $reflection->getMethod($method);
        $method->setAccessible(true);
        
        return $method->invokeArgs($object, $args);
    }
} 