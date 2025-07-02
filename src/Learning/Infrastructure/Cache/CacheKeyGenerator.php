<?php

declare(strict_types=1);

namespace Learning\Infrastructure\Cache;

use Learning\Domain\ValueObjects\CourseId;

final class CacheKeyGenerator
{
    private const PREFIX = 'lms';
    private const COURSE_PREFIX = 'course';
    private const ENROLLMENT_PREFIX = 'enrollment';
    private const SEPARATOR = ':';
    
    public function generateCourseKey(CourseId $courseId): string
    {
        return $this->buildKey([
            self::PREFIX,
            self::COURSE_PREFIX,
            (string)$courseId
        ]);
    }
    
    public function generateEnrollmentKey(string $userId, CourseId $courseId): string
    {
        return $this->buildKey([
            self::PREFIX,
            self::ENROLLMENT_PREFIX,
            $userId,
            (string)$courseId
        ]);
    }
    
    public function generateTagKey(string $tag): string
    {
        return $this->buildKey([
            self::PREFIX,
            'tag',
            $tag
        ]);
    }
    
    public function generateListKey(string $type, array $params = []): string
    {
        $parts = [
            self::PREFIX,
            'list',
            $type
        ];
        
        foreach ($params as $key => $value) {
            $parts[] = $key;
            $parts[] = (string)$value;
        }
        
        return $this->buildKey($parts);
    }
    
    private function buildKey(array $parts): string
    {
        return implode(self::SEPARATOR, $parts);
    }
} 