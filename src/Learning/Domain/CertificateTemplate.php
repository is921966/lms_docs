<?php

declare(strict_types=1);

namespace App\Learning\Domain;

use App\Learning\Domain\ValueObjects\CertificateId;

class CertificateTemplate
{
    private CertificateId $id;
    private string $name;
    private string $description;
    private string $templatePath;
    private array $variables = [];
    private array $styles = [];
    private array $settings = [];
    private bool $isActive = true;
    private bool $isDefault = false;
    private \DateTimeImmutable $createdAt;
    private \DateTimeImmutable $updatedAt;
    
    private function __construct(
        CertificateId $id,
        string $name,
        string $description,
        string $templatePath,
        array $variables
    ) {
        $this->id = $id;
        $this->name = $name;
        $this->description = $description;
        $this->templatePath = $templatePath;
        $this->variables = array_unique($variables);
        $this->createdAt = new \DateTimeImmutable();
        $this->updatedAt = new \DateTimeImmutable();
    }
    
    public static function create(
        string $name,
        string $description,
        string $templatePath,
        array $variables
    ): self {
        return new self(
            CertificateId::generate(),
            $name,
            $description,
            $templatePath,
            $variables
        );
    }
    
    public function updateBasicInfo(string $name, string $description, string $templatePath): void
    {
        $this->name = $name;
        $this->description = $description;
        $this->templatePath = $templatePath;
        $this->updatedAt = new \DateTimeImmutable();
    }
    
    public function addVariable(string $variable): void
    {
        if (!in_array($variable, $this->variables, true)) {
            $this->variables[] = $variable;
            $this->updatedAt = new \DateTimeImmutable();
        }
    }
    
    public function removeVariable(string $variable): void
    {
        $this->variables = array_values(
            array_filter(
                $this->variables,
                fn(string $v) => $v !== $variable
            )
        );
        $this->updatedAt = new \DateTimeImmutable();
    }
    
    public function setStyles(array $styles): void
    {
        $this->styles = $styles;
        $this->updatedAt = new \DateTimeImmutable();
    }
    
    public function setSettings(array $settings): void
    {
        $this->settings = $settings;
        $this->updatedAt = new \DateTimeImmutable();
    }
    
    public function activate(): void
    {
        $this->isActive = true;
        $this->updatedAt = new \DateTimeImmutable();
    }
    
    public function deactivate(): void
    {
        $this->isActive = false;
        $this->updatedAt = new \DateTimeImmutable();
    }
    
    public function setAsDefault(): void
    {
        $this->isDefault = true;
        $this->updatedAt = new \DateTimeImmutable();
    }
    
    public function unsetDefault(): void
    {
        $this->isDefault = false;
        $this->updatedAt = new \DateTimeImmutable();
    }
    
    public function validateVariables(array $data): bool
    {
        foreach ($this->variables as $variable) {
            if (!array_key_exists($variable, $data)) {
                return false;
            }
        }
        
        return true;
    }
    
    // Getters
    public function getId(): CertificateId
    {
        return $this->id;
    }
    
    public function getName(): string
    {
        return $this->name;
    }
    
    public function getDescription(): string
    {
        return $this->description;
    }
    
    public function getTemplatePath(): string
    {
        return $this->templatePath;
    }
    
    public function getVariables(): array
    {
        return $this->variables;
    }
    
    public function getStyles(): array
    {
        return $this->styles;
    }
    
    public function getSettings(): array
    {
        return $this->settings;
    }
    
    public function isActive(): bool
    {
        return $this->isActive;
    }
    
    public function isDefault(): bool
    {
        return $this->isDefault;
    }
    
    public function getCreatedAt(): \DateTimeImmutable
    {
        return $this->createdAt;
    }
    
    public function getUpdatedAt(): \DateTimeImmutable
    {
        return $this->updatedAt;
    }
} 