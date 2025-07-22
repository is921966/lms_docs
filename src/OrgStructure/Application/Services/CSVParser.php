<?php
declare(strict_types=1);

namespace App\OrgStructure\Application\Services;

use App\OrgStructure\Application\Exceptions\InvalidCSVException;

/**
 * Service for parsing CSV files with support for different encodings and delimiters
 */
class CSVParser
{
    public function parse(string $content, string $delimiter = ','): array
    {
        // Check if content is just newlines
        if (preg_match('/^\s*$/', $content)) {
            if (strpos($content, "\n") !== false) {
                throw new InvalidCSVException('CSV must have headers');
            }
            throw new InvalidCSVException('CSV content is empty');
        }

        // Split into lines (don't filter yet to detect empty headers)
        $lines = explode("\n", $content);
        
        if (count($lines) < 1 || empty(trim($lines[0]))) {
            throw new InvalidCSVException('CSV must have headers');
        }
        
        // Now filter empty lines
        $lines = array_values(array_filter($lines, fn($line) => !empty(trim($line))));

        // Parse headers
        $headers = str_getcsv($lines[0], $delimiter);
        if (empty($headers) || count(array_filter($headers)) === 0) {
            throw new InvalidCSVException('CSV must have headers');
        }

        // Parse data rows
        $data = [];
        for ($i = 1; $i < count($lines); $i++) {
            $row = str_getcsv($lines[$i], $delimiter);
            
            // Create associative array with headers as keys
            $rowData = [];
            foreach ($headers as $index => $header) {
                $rowData[trim($header)] = isset($row[$index]) ? trim($row[$index]) : '';
            }
            
            $data[] = $rowData;
        }

        return $data;
    }

    public function detectDelimiter(string $content): string
    {
        $delimiters = [',', ';', "\t"];
        $maxCount = 0;
        $detectedDelimiter = ',';

        foreach ($delimiters as $delimiter) {
            $count = substr_count($content, $delimiter);
            if ($count > $maxCount) {
                $maxCount = $count;
                $detectedDelimiter = $delimiter;
            }
        }

        return $detectedDelimiter;
    }

    public function validateHeaders(string $content, array $requiredHeaders): bool
    {
        try {
            $data = $this->parse($content);
            if (empty($data)) {
                return false;
            }

            $headers = array_keys($data[0]);
            foreach ($requiredHeaders as $required) {
                if (!in_array($required, $headers)) {
                    return false;
                }
            }

            return true;
        } catch (InvalidCSVException $e) {
            return false;
        }
    }

    public function parseFile(string $filePath): array
    {
        if (!file_exists($filePath)) {
            throw new InvalidCSVException("File not found: $filePath");
        }

        $content = file_get_contents($filePath);
        if ($content === false) {
            throw new InvalidCSVException("Cannot read file: $filePath");
        }

        // Detect and convert encoding if needed
        $encoding = mb_detect_encoding($content, ['UTF-8', 'Windows-1251', 'ISO-8859-1'], true);
        if ($encoding !== 'UTF-8') {
            $content = mb_convert_encoding($content, 'UTF-8', $encoding);
        }

        // Detect delimiter
        $delimiter = $this->detectDelimiter($content);

        return $this->parse($content, $delimiter);
    }
} 