<?php

declare(strict_types=1);

namespace App\Course\Infrastructure\Cmi5;

class Cmi5AssignableUnit
{
    public function __construct(
        private string $id,
        private string $title,
        private string $description,
        private string $url,
        private string $moveOn = 'passed',
        private float $masteryScore = 0.8
    ) {
    }
    
    public function id(): string
    {
        return $this->id;
    }
    
    public function title(): string
    {
        return $this->title;
    }
    
    public function description(): string
    {
        return $this->description;
    }
    
    public function url(): string
    {
        return $this->url;
    }
    
    public function moveOn(): string
    {
        return $this->moveOn;
    }
    
    public function masteryScore(): float
    {
        return $this->masteryScore;
    }
    
    public function toArray(): array
    {
        return [
            'id' => $this->id,
            'title' => $this->title,
            'description' => $this->description,
            'url' => $this->url,
            'moveOn' => $this->moveOn,
            'masteryScore' => $this->masteryScore
        ];
    }
} 