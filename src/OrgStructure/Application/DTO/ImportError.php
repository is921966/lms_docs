<?php

declare(strict_types=1);

namespace App\OrgStructure\Application\DTO;

final class ImportError
{
    public function __construct(
        private readonly string $type,
        private readonly string $message,
        private readonly int $row = 0,
        private readonly array $data = []
    ) {}

    public function getType(): string
    {
        return $this->type;
    }

    public function getMessage(): string
    {
        return $this->message;
    }

    public function getRow(): int
    {
        return $this->row;
    }

    public function getData(): array
    {
        return $this->data;
    }

    public function getRowNumber(): int
    {
        return $this->row;
    }

    public function getContext(): array
    {
        return $this->data;
    }

    public function toArray(): array
    {
        return [
            'message' => $this->message,
            'row_number' => $this->rowNumber,
            'context' => $this->context
        ];
    }
} 