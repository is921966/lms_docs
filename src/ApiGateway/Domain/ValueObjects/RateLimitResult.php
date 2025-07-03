<?php

declare(strict_types=1);

namespace ApiGateway\Domain\ValueObjects;

final class RateLimitResult
{
    private bool $allowed;
    private int $limit;
    private int $remaining;
    private \DateTimeImmutable $resetsAt;
    private ?string $reason;
    
    public function __construct(
        bool $allowed,
        int $limit,
        int $remaining,
        \DateTimeImmutable $resetsAt,
        ?string $reason = null
    ) {
        if ($limit < 0) {
            throw new \InvalidArgumentException('Limit cannot be negative');
        }
        
        if ($remaining < 0) {
            throw new \InvalidArgumentException('Remaining cannot be negative');
        }
        
        if ($remaining > $limit) {
            throw new \InvalidArgumentException('Remaining cannot exceed limit');
        }
        
        $this->allowed = $allowed;
        $this->limit = $limit;
        $this->remaining = $remaining;
        $this->resetsAt = $resetsAt;
        $this->reason = $reason;
    }
    
    public static function allow(int $limit, int $remaining, \DateTimeImmutable $resetsAt): self
    {
        return new self(true, $limit, $remaining, $resetsAt);
    }
    
    public static function deny(int $limit, \DateTimeImmutable $resetsAt, string $reason = 'Rate limit exceeded'): self
    {
        return new self(false, $limit, 0, $resetsAt, $reason);
    }
    
    public function isAllowed(): bool
    {
        return $this->allowed;
    }
    
    public function isDenied(): bool
    {
        return !$this->allowed;
    }
    
    public function getLimit(): int
    {
        return $this->limit;
    }
    
    public function getRemaining(): int
    {
        return $this->remaining;
    }
    
    public function getResetsAt(): \DateTimeImmutable
    {
        return $this->resetsAt;
    }
    
    public function getResetsIn(): int
    {
        $now = new \DateTimeImmutable();
        $diff = $this->resetsAt->getTimestamp() - $now->getTimestamp();
        return max(0, $diff);
    }
    
    public function getReason(): ?string
    {
        return $this->reason;
    }
    
    public function toArray(): array
    {
        return [
            'allowed' => $this->allowed,
            'limit' => $this->limit,
            'remaining' => $this->remaining,
            'resets_at' => $this->resetsAt->format(\DateTimeInterface::ATOM),
            'resets_in' => $this->getResetsIn(),
            'reason' => $this->reason,
        ];
    }
    
    public function toHeaders(): array
    {
        return [
            'X-RateLimit-Limit' => (string) $this->limit,
            'X-RateLimit-Remaining' => (string) $this->remaining,
            'X-RateLimit-Reset' => (string) $this->resetsAt->getTimestamp(),
        ];
    }
} 