<?php

declare(strict_types=1);

namespace App\Course\Infrastructure\Cmi5;

use App\Course\Domain\ValueObjects\CourseId;
use ZipArchive;

class Cmi5Service
{
    private const CMI5_MANIFEST = 'cmi5.xml';
    
    public function importPackage(string $zipPath, CourseId $courseId): Cmi5Package
    {
        if (!file_exists($zipPath)) {
            throw new \InvalidArgumentException("CMI5 package not found: $zipPath");
        }
        
        $zip = new ZipArchive();
        if ($zip->open($zipPath) !== true) {
            throw new \RuntimeException("Failed to open CMI5 package: $zipPath");
        }
        
        // Extract manifest
        $manifestContent = $zip->getFromName(self::CMI5_MANIFEST);
        if ($manifestContent === false) {
            $zip->close();
            throw new \InvalidArgumentException("CMI5 manifest not found in package");
        }
        
        $structure = $this->parseManifest($manifestContent);
        
        // Extract all files to temporary directory
        $tempDir = sys_get_temp_dir() . '/cmi5_' . uniqid();
        $zip->extractTo($tempDir);
        $zip->close();
        
        return new Cmi5Package($courseId, $structure, $tempDir);
    }
    
    public function parseManifest(string $xmlContent): Cmi5CourseStructure
    {
        $xml = simplexml_load_string($xmlContent);
        if ($xml === false) {
            throw new \InvalidArgumentException("Invalid CMI5 manifest XML");
        }
        
        // Register namespace
        $xml->registerXPathNamespace('cmi5', 'https://w3id.org/xapi/profiles/cmi5/v1/CourseStructure.xsd');
        
        // Extract course info
        $course = $xml->course ?? $xml->xpath('//cmi5:course')[0] ?? null;
        if (!$course) {
            throw new \InvalidArgumentException("Course element not found in manifest");
        }
        
        $courseId = (string)$course['id'];
        $title = $this->extractLangString($course->title);
        $description = $this->extractLangString($course->description);
        
        // Extract assignable units
        $aus = [];
        foreach ($xml->au ?? [] as $au) {
            $aus[] = new Cmi5AssignableUnit(
                (string)$au['id'],
                $this->extractLangString($au->title),
                $this->extractLangString($au->description),
                (string)$au->url,
                (string)($au['moveOn'] ?? 'passed'),
                (float)($au['masteryScore'] ?? 0.8)
            );
        }
        
        return new Cmi5CourseStructure($courseId, $title, $description, $aus);
    }
    
    public function validatePackage(string $zipPath): bool
    {
        try {
            $zip = new ZipArchive();
            if ($zip->open($zipPath) !== true) {
                return false;
            }
            
            // Check for manifest
            if ($zip->getFromName(self::CMI5_MANIFEST) === false) {
                $zip->close();
                return false;
            }
            
            $zip->close();
            return true;
        } catch (\Exception $e) {
            return false;
        }
    }
    
    public function extractMetadata(string $zipPath): array
    {
        $package = $this->importPackage($zipPath, CourseId::generate());
        $structure = $package->manifest();
        
        return [
            'title' => $structure->title(),
            'description' => $structure->description(),
            'version' => '1.0', // Would be extracted from manifest if available
            'duration' => $this->calculateDuration($structure),
            'assignableUnitsCount' => count($structure->getAssignableUnits())
        ];
    }
    
    public function convertToCourseData(Cmi5CourseStructure $structure, CourseId $courseId): array
    {
        $modules = [];
        
        foreach ($structure->getAssignableUnits() as $index => $au) {
            $modules[] = [
                'title' => $au->title(),
                'description' => $au->description(),
                'order' => $index + 1,
                'lessons' => [
                    [
                        'title' => $au->title(),
                        'description' => $au->description(),
                        'content' => $au->url(),
                        'type' => 'cmi5',
                        'duration' => 30, // Default duration
                        'order' => 1
                    ]
                ]
            ];
        }
        
        return [
            'id' => $courseId->value(),
            'title' => $structure->title(),
            'description' => $structure->description(),
            'modules' => $modules
        ];
    }
    
    private function extractLangString($element): string
    {
        if (!$element) {
            return '';
        }
        
        // Try to get English version first
        foreach ($element->langstring ?? [] as $langstring) {
            if ((string)$langstring['lang'] === 'en') {
                return (string)$langstring;
            }
        }
        
        // Return first available if no English
        return (string)($element->langstring[0] ?? $element);
    }
    
    private function calculateDuration(Cmi5CourseStructure $structure): int
    {
        // Simple calculation: 30 minutes per AU
        return count($structure->getAssignableUnits()) * 30;
    }
} 