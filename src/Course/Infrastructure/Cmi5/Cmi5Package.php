<?php

declare(strict_types=1);

namespace App\Course\Infrastructure\Cmi5;

use App\Course\Domain\ValueObjects\CourseId;

class Cmi5Package
{
    public function __construct(
        private CourseId $courseId,
        private Cmi5CourseStructure $manifest,
        private string $extractPath
    ) {
    }
    
    public function courseId(): CourseId
    {
        return $this->courseId;
    }
    
    public function manifest(): Cmi5CourseStructure
    {
        return $this->manifest;
    }
    
    public function extractPath(): string
    {
        return $this->extractPath;
    }
    
    public function getAUs(): array
    {
        return $this->manifest->getAssignableUnits();
    }
    
    public function getFileContent(string $relativePath): ?string
    {
        $fullPath = $this->extractPath . '/' . ltrim($relativePath, '/');
        
        if (!file_exists($fullPath)) {
            return null;
        }
        
        return file_get_contents($fullPath);
    }
    
    public function cleanup(): void
    {
        if (is_dir($this->extractPath)) {
            $this->recursiveDelete($this->extractPath);
        }
    }
    
    private function recursiveDelete(string $dir): void
    {
        if (!is_dir($dir)) {
            return;
        }
        
        $files = array_diff(scandir($dir), ['.', '..']);
        
        foreach ($files as $file) {
            $path = $dir . '/' . $file;
            
            if (is_dir($path)) {
                $this->recursiveDelete($path);
            } else {
                unlink($path);
            }
        }
        
        rmdir($dir);
    }
    
    public function __destruct()
    {
        // Auto-cleanup when package is destroyed
        $this->cleanup();
    }
} 