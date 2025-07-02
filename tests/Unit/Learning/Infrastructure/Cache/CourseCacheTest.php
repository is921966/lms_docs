<?php

declare(strict_types=1);

namespace Tests\Unit\Learning\Infrastructure\Cache;

use Learning\Domain\Course;
use Learning\Domain\ValueObjects\CourseId;
use Learning\Domain\ValueObjects\CourseCode;
use Learning\Domain\ValueObjects\Duration;
use Learning\Infrastructure\Cache\CourseCache;
use Learning\Infrastructure\Cache\CacheKeyGenerator;
use PHPUnit\Framework\TestCase;
use Psr\Cache\CacheItemInterface;
use Psr\Cache\CacheItemPoolInterface;

class CourseCacheTest extends TestCase
{
    private CacheItemPoolInterface $cachePool;
    private CacheKeyGenerator $keyGenerator;
    private CourseCache $cache;
    
    protected function setUp(): void
    {
        $this->cachePool = $this->getMockBuilder(CacheItemPoolInterface::class)
            ->addMethods(['invalidateTags', 'getStats'])
            ->getMockForAbstractClass();
        $this->keyGenerator = new CacheKeyGenerator();
        $this->cache = new CourseCache($this->cachePool, $this->keyGenerator);
    }
    
    public function testGetCourseFromCache(): void
    {
        // Arrange
        $courseId = CourseId::fromString('course-123');
        $course = $this->createCourse();
        $key = $this->keyGenerator->generateCourseKey($courseId);
        
        $cacheItem = $this->createMock(CacheItemInterface::class);
        $cacheItem->expects($this->once())
            ->method('isHit')
            ->willReturn(true);
        $cacheItem->expects($this->once())
            ->method('get')
            ->willReturn($course);
        
        $this->cachePool->expects($this->once())
            ->method('getItem')
            ->with($key)
            ->willReturn($cacheItem);
        
        // Act
        $result = $this->cache->getCourse($courseId);
        
        // Assert
        $this->assertSame($course, $result);
    }
    
    public function testGetCourseFromCacheMiss(): void
    {
        // Arrange
        $courseId = CourseId::fromString('course-123');
        $key = $this->keyGenerator->generateCourseKey($courseId);
        
        $cacheItem = $this->createMock(CacheItemInterface::class);
        $cacheItem->expects($this->once())
            ->method('isHit')
            ->willReturn(false);
        
        $this->cachePool->expects($this->once())
            ->method('getItem')
            ->with($key)
            ->willReturn($cacheItem);
        
        // Act
        $result = $this->cache->getCourse($courseId);
        
        // Assert
        $this->assertNull($result);
    }
    
    public function testSetCourseInCache(): void
    {
        // Arrange
        $course = $this->createCourse();
        $courseId = $course->getId();
        $key = $this->keyGenerator->generateCourseKey($courseId);
        
        $cacheItem = $this->createMock(CacheItemInterface::class);
        $cacheItem->expects($this->once())
            ->method('set')
            ->with($course)
            ->willReturnSelf();
        $cacheItem->expects($this->once())
            ->method('expiresAfter')
            ->with(3600)
            ->willReturnSelf();
        
        $this->cachePool->expects($this->once())
            ->method('getItem')
            ->with($key)
            ->willReturn($cacheItem);
        
        $this->cachePool->expects($this->once())
            ->method('save')
            ->with($cacheItem)
            ->willReturn(true);
        
        // Act
        $result = $this->cache->setCourse($course);
        
        // Assert
        $this->assertTrue($result);
    }
    
    public function testInvalidateCourse(): void
    {
        // Arrange
        $courseId = CourseId::fromString('course-123');
        $key = $this->keyGenerator->generateCourseKey($courseId);
        
        $this->cachePool->expects($this->once())
            ->method('deleteItem')
            ->with($key)
            ->willReturn(true);
        
        // Act
        $result = $this->cache->invalidateCourse($courseId);
        
        // Assert
        $this->assertTrue($result);
    }
    
    public function testInvalidateByTag(): void
    {
        // Arrange
        $tag = 'published-courses';
        
        $this->cachePool->expects($this->once())
            ->method('invalidateTags')
            ->with([$tag])
            ->willReturn(true);
        
        // Act
        $result = $this->cache->invalidateByTag($tag);
        
        // Assert
        $this->assertTrue($result);
    }
    
    public function testWarmCache(): void
    {
        // Arrange
        $courses = [
            $this->createCourse('PHP-101'),
            $this->createCourse('JAVA-201')
        ];
        
        $this->cachePool->expects($this->exactly(2))
            ->method('getItem')
            ->willReturn($this->createMock(CacheItemInterface::class));
        
        $this->cachePool->expects($this->exactly(2))
            ->method('save')
            ->willReturn(true);
        
        // Act
        $count = $this->cache->warmCache($courses);
        
        // Assert
        $this->assertEquals(2, $count);
    }
    
    public function testGetCacheStatistics(): void
    {
        // Arrange
        $expectedStats = [
            'hits' => 150,
            'misses' => 25,
            'hit_rate' => 0.857,
            'size' => 1024,
            'items' => 50
        ];
        
        $this->cachePool->expects($this->once())
            ->method('getStats')
            ->willReturn($expectedStats);
        
        // Act
        $stats = $this->cache->getStatistics();
        
        // Assert
        $this->assertEquals($expectedStats, $stats);
    }
    
    public function testClearAllCache(): void
    {
        // Arrange
        $this->cachePool->expects($this->once())
            ->method('clear')
            ->willReturn(true);
        
        // Act
        $result = $this->cache->clear();
        
        // Assert
        $this->assertTrue($result);
    }
    
    public function testGetMultipleCourses(): void
    {
        // Arrange
        $courseIds = [
            CourseId::fromString('course-123'),
            CourseId::fromString('course-456')
        ];
        $courses = [
            'course-123' => $this->createCourse('PHP-101'),
            'course-456' => $this->createCourse('JAVA-201')
        ];
        
        $keys = array_map(
            fn($id) => $this->keyGenerator->generateCourseKey($id),
            $courseIds
        );
        
        $cacheItems = [];
        foreach ($keys as $i => $key) {
            $item = $this->createMock(CacheItemInterface::class);
            $item->expects($this->once())
                ->method('isHit')
                ->willReturn(true);
            $item->expects($this->once())
                ->method('get')
                ->willReturn($courses[array_keys($courses)[$i]]);
            $cacheItems[$key] = $item;
        }
        
        $this->cachePool->expects($this->once())
            ->method('getItems')
            ->with($keys)
            ->willReturn($cacheItems);
        
        // Act
        $result = $this->cache->getMultiple($courseIds);
        
        // Assert
        $this->assertCount(2, $result);
    }
    
    public function testCircuitBreakerPattern(): void
    {
        $this->markTestSkipped('Circuit breaker test needs refactoring');
    }
    
    private function createCourse(string $code = 'PHP-101'): Course
    {
        return Course::create(
            CourseId::generate(),
            CourseCode::fromString($code),
            'Test Course',
            'Test Description',
            Duration::fromHours(10)
        );
    }
} 