<?php

declare(strict_types=1);

namespace Notification\Application\Services;

interface TemplateRenderer
{
    /**
     * Render template with provided data
     * 
     * @param string $template Template name/path
     * @param array<string, mixed> $data Template variables
     * @return string Rendered content
     * 
     * @throws \RuntimeException if template not found or rendering fails
     */
    public function render(string $template, array $data): string;
} 