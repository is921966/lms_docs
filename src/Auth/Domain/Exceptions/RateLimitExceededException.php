<?php

namespace Auth\Domain\Exceptions;

class RateLimitExceededException extends \Exception
{
    private int $retryAfter;
    private int $limit;
    private int $remaining;

    public function __construct(
        string $message = 'Rate limit exceeded',
        int $retryAfter = 0,
        int $limit = 0,
        int $remaining = 0
    ) {
        parent::__construct($message);
        $this->retryAfter = $retryAfter;
        $this->limit = $limit;
        $this->remaining = $remaining;
    }

    public function getRetryAfter(): int
    {
        return $this->retryAfter;
    }

    public function getLimit(): int
    {
        return $this->limit;
    }

    public function getRemaining(): int
    {
        return $this->remaining;
    }

    public static function withDetails(int $retryAfter, int $limit): self
    {
        return new self(
            sprintf('Rate limit of %d requests exceeded. Retry after %d seconds.', $limit, $retryAfter),
            $retryAfter,
            $limit,
            0
        );
    }
} 