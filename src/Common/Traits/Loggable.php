<?php

declare(strict_types=1);

namespace Common\Traits;

use Psr\Log\LoggerInterface;
use Psr\Log\LogLevel;

/**
 * Trait for adding logging capabilities
 */
trait Loggable
{
    protected ?LoggerInterface $logger = null;
    
    /**
     * Set logger instance
     */
    public function setLogger(LoggerInterface $logger): void
    {
        $this->logger = $logger;
    }
    
    /**
     * Log debug message
     */
    protected function logDebug(string $message, array $context = []): void
    {
        $this->log(LogLevel::DEBUG, $message, $context);
    }
    
    /**
     * Log info message
     */
    protected function logInfo(string $message, array $context = []): void
    {
        $this->log(LogLevel::INFO, $message, $context);
    }
    
    /**
     * Log warning message
     */
    protected function logWarning(string $message, array $context = []): void
    {
        $this->log(LogLevel::WARNING, $message, $context);
    }
    
    /**
     * Log error message
     */
    protected function logError(string $message, array $context = []): void
    {
        $this->log(LogLevel::ERROR, $message, $context);
    }
    
    /**
     * Log with specific level
     */
    protected function log(string $level, string $message, array $context = []): void
    {
        if ($this->logger !== null) {
            $context['class'] = static::class;
            $this->logger->log($level, $message, $context);
        }
    }
} 