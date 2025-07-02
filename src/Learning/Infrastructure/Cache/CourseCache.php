<?php

declare(strict_types=1);

namespace Learning\Infrastructure\Cache;

use Learning\Domain\Course;
use Learning\Domain\ValueObjects\CourseId;
use Learning\Domain\Services\CourseCacheInterface;
use Psr\Cache\CacheItemPoolInterface;
use Psr\Cache\CacheItemInterface;
use Exception;

final class CourseCache implements CourseCacheInterface
{
    private const DEFAULT_TTL = 3600; // 1 hour
    private const CIRCUIT_BREAKER_THRESHOLD = 3;
    private const CIRCUIT_BREAKER_TIMEOUT = 300; // 5 minutes
    
    private int $failureCount = 0;
    private ?int $circuitOpenedAt = null;
    
    public function __construct(
        private readonly CacheItemPoolInterface $cachePool,
        private readonly CacheKeyGenerator $keyGenerator
    ) {
    }
    
    public function getCourse(CourseId $courseId): ?Course
    {
        if ($this->isCircuitOpen()) {
            return null;
        }
        
        try {
            $key = $this->keyGenerator->generateCourseKey($courseId);
            $item = $this->cachePool->getItem($key);
            
            if ($item->isHit()) {
                $this->resetCircuitBreaker();
                return $item->get();
            }
            
            return null;
        } catch (Exception $e) {
            $this->recordFailure();
            
            if ($this->failureCount < self::CIRCUIT_BREAKER_THRESHOLD) {
                throw $e;
            }
            
            return null;
        }
    }
    
    public function setCourse(Course $course): bool
    {
        try {
            $key = $this->keyGenerator->generateCourseKey($course->getId());
            $item = $this->cachePool->getItem($key);
            
            $item->set($course);
            $item->expiresAfter(self::DEFAULT_TTL);
            
            return $this->cachePool->save($item);
        } catch (Exception $e) {
            return false;
        }
    }
    
    public function invalidateCourse(CourseId $courseId): bool
    {
        try {
            $key = $this->keyGenerator->generateCourseKey($courseId);
            return $this->cachePool->deleteItem($key);
        } catch (Exception $e) {
            return false;
        }
    }
    
    public function invalidateByTag(string $tag): bool
    {
        try {
            // Assuming PSR-6 cache pool with tagging support
            if (method_exists($this->cachePool, 'invalidateTags')) {
                return $this->cachePool->invalidateTags([$tag]);
            }
            
            return false;
        } catch (Exception $e) {
            return false;
        }
    }
    
    /**
     * @param Course[] $courses
     */
    public function warmCache(array $courses): int
    {
        $count = 0;
        
        foreach ($courses as $course) {
            if ($this->setCourse($course)) {
                $count++;
            }
        }
        
        return $count;
    }
    
    public function getStatistics(): array
    {
        if (method_exists($this->cachePool, 'getStats')) {
            return $this->cachePool->getStats();
        }
        
        return [
            'hits' => 0,
            'misses' => 0,
            'hit_rate' => 0.0,
            'size' => 0,
            'items' => 0
        ];
    }
    
    public function clear(): bool
    {
        try {
            return $this->cachePool->clear();
        } catch (Exception $e) {
            return false;
        }
    }
    
    /**
     * @param CourseId[] $courseIds
     * @return Course[]
     */
    public function getMultiple(array $courseIds): array
    {
        if ($this->isCircuitOpen()) {
            return [];
        }
        
        try {
            $keys = array_map(
                fn($id) => $this->keyGenerator->generateCourseKey($id),
                $courseIds
            );
            
            $items = $this->cachePool->getItems($keys);
            $courses = [];
            
            foreach ($items as $item) {
                if ($item->isHit()) {
                    $course = $item->get();
                    if ($course instanceof Course) {
                        $courses[] = $course;
                    }
                }
            }
            
            $this->resetCircuitBreaker();
            return $courses;
        } catch (Exception $e) {
            $this->recordFailure();
            return [];
        }
    }
    
    private function isCircuitOpen(): bool
    {
        if ($this->circuitOpenedAt === null) {
            return false;
        }
        
        // Check if circuit breaker timeout has passed
        if (time() - $this->circuitOpenedAt > self::CIRCUIT_BREAKER_TIMEOUT) {
            $this->resetCircuitBreaker();
            return false;
        }
        
        return true;
    }
    
    private function recordFailure(): void
    {
        $this->failureCount++;
        
        if ($this->failureCount >= self::CIRCUIT_BREAKER_THRESHOLD) {
            $this->circuitOpenedAt = time();
        }
    }
    
    private function resetCircuitBreaker(): void
    {
        $this->failureCount = 0;
        $this->circuitOpenedAt = null;
    }
} 