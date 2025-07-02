<?php

declare(strict_types=1);

namespace Common\Utils;

/**
 * Date helper utility class
 */
class DateHelper
{
    public const API_FORMAT = 'Y-m-d\TH:i:s\Z';
    public const TIMEZONE = 'Europe/Moscow';
    
    /**
     * Format date for API response
     */
    public static function formatForApi(\DateTimeInterface $date): string
    {
        return $date
            ->setTimezone(new \DateTimeZone('UTC'))
            ->format(self::API_FORMAT);
    }
    
    /**
     * Parse date from API request
     */
    public static function parseFromApi(string $dateString): \DateTimeImmutable
    {
        $date = \DateTimeImmutable::createFromFormat(self::API_FORMAT, $dateString, new \DateTimeZone('UTC'));
        
        if ($date === false) {
            throw new \InvalidArgumentException("Invalid date format: {$dateString}");
        }
        
        return $date->setTimezone(new \DateTimeZone(self::TIMEZONE));
    }
    
    /**
     * Calculate difference in days between two dates
     */
    public static function diffInDays(\DateTimeInterface $from, \DateTimeInterface $to): int
    {
        return (int) $from->diff($to)->format('%r%a');
    }
    
    /**
     * Check if date is a workday (Monday-Friday)
     */
    public static function isWorkday(\DateTimeInterface $date): bool
    {
        $dayOfWeek = (int) $date->format('N');
        return $dayOfWeek >= 1 && $dayOfWeek <= 5;
    }
    
    /**
     * Get start of day
     */
    public static function startOfDay(\DateTimeInterface $date): \DateTimeImmutable
    {
        return \DateTimeImmutable::createFromFormat(
            'Y-m-d H:i:s',
            $date->format('Y-m-d 00:00:00'),
            $date->getTimezone()
        ) ?: new \DateTimeImmutable('today', $date->getTimezone());
    }
    
    /**
     * Get end of day
     */
    public static function endOfDay(\DateTimeInterface $date): \DateTimeImmutable
    {
        return \DateTimeImmutable::createFromFormat(
            'Y-m-d H:i:s',
            $date->format('Y-m-d 23:59:59'),
            $date->getTimezone()
        ) ?: new \DateTimeImmutable('today 23:59:59', $date->getTimezone());
    }
    
    /**
     * Add business days to date
     */
    public static function addBusinessDays(\DateTimeInterface $date, int $days): \DateTimeImmutable
    {
        $result = \DateTimeImmutable::createFromInterface($date);
        $added = 0;
        
        while ($added < $days) {
            $result = $result->modify('+1 day');
            if (self::isWorkday($result)) {
                $added++;
            }
        }
        
        return $result;
    }
} 