<?php

namespace Competency\Application\DTO;

use Competency\Domain\Competency;

class CompetencyDTO
{
    public string $id;
    public string $name;
    public string $description;
    public string $categoryId;
    public string $categoryName;
    public bool $isActive;
    public array $skillLevels;
    public array $requiredForPositions;

    public function __construct(
        string $id,
        string $name,
        string $description,
        string $categoryId,
        string $categoryName,
        bool $isActive,
        array $skillLevels = [],
        array $requiredForPositions = []
    ) {
        $this->id = $id;
        $this->name = $name;
        $this->description = $description;
        $this->categoryId = $categoryId;
        $this->categoryName = $categoryName;
        $this->isActive = $isActive;
        $this->skillLevels = $skillLevels;
        $this->requiredForPositions = $requiredForPositions;
    }

    public static function fromEntity(Competency $competency): self
    {
        $skillLevels = [];
        foreach ($competency->getLevels() as $level) {
            $skillLevels[] = [
                'level' => $level->getValue(),
                'name' => $level->getName(),
                'description' => $level->getDescription()
            ];
        }

        return new self(
            $competency->getId()->getValue(),
            $competency->getName(),
            $competency->getDescription(),
            $competency->getCategory()->getValue(),
            $competency->getCategory()->getDisplayName(),
            $competency->isActive(),
            $skillLevels,
            [] // getRequiredForPositions doesn't exist yet
        );
    }

    public static function fromArray(array $data): self
    {
        return new self(
            $data['id'],
            $data['name'],
            $data['description'],
            $data['categoryId'],
            $data['categoryName'],
            $data['isActive'],
            $data['skillLevels'] ?? [],
            $data['requiredForPositions'] ?? []
        );
    }

    public function toArray(): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'description' => $this->description,
            'categoryId' => $this->categoryId,
            'categoryName' => $this->categoryName,
            'isActive' => $this->isActive,
            'skillLevels' => $this->skillLevels,
            'requiredForPositions' => $this->requiredForPositions
        ];
    }
} 