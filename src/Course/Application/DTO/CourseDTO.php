<?php

declare(strict_types=1);

namespace App\Course\Application\DTO;

final class CourseDTO
{
    public function __construct(
        public readonly string $id,
        public readonly string $code,
        public readonly string $title,
        public readonly string $description,
        public readonly int $durationMinutes,
        public readonly float $durationHours,
        public readonly string $durationFormatted,
        public readonly float $priceAmount,
        public readonly string $priceCurrency,
        public readonly string $priceFormatted,
        public readonly string $status,
        public readonly string $createdAt,
        public readonly ?string $publishedAt = null,
        public readonly int $enrollmentCount = 0,
        public readonly int $completionCount = 0
    ) {
    }
    
    public static function fromArray(array $data): self
    {
        return new self(
            id: $data['id'],
            code: $data['code'],
            title: $data['title'],
            description: $data['description'],
            durationMinutes: $data['duration_minutes'],
            durationHours: $data['duration_hours'],
            durationFormatted: $data['duration_formatted'],
            priceAmount: $data['price_amount'],
            priceCurrency: $data['price_currency'],
            priceFormatted: $data['price_formatted'],
            status: $data['status'],
            createdAt: $data['created_at'],
            publishedAt: $data['published_at'] ?? null,
            enrollmentCount: $data['enrollment_count'] ?? 0,
            completionCount: $data['completion_count'] ?? 0
        );
    }
    
    public function toArray(): array
    {
        return [
            'id' => $this->id,
            'code' => $this->code,
            'title' => $this->title,
            'description' => $this->description,
            'duration_minutes' => $this->durationMinutes,
            'duration_hours' => $this->durationHours,
            'duration_formatted' => $this->durationFormatted,
            'price_amount' => $this->priceAmount,
            'price_currency' => $this->priceCurrency,
            'price_formatted' => $this->priceFormatted,
            'status' => $this->status,
            'created_at' => $this->createdAt,
            'published_at' => $this->publishedAt,
            'enrollment_count' => $this->enrollmentCount,
            'completion_count' => $this->completionCount,
        ];
    }
} 