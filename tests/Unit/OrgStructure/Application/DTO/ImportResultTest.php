<?php

declare(strict_types=1);

namespace Tests\Unit\OrgStructure\Application\DTO;

use App\OrgStructure\Application\DTO\ImportError;
use App\OrgStructure\Application\DTO\ImportResult;
use PHPUnit\Framework\TestCase;

final class ImportResultTest extends TestCase
{
    public function testCreateSuccessfulResult(): void
    {
        $result = ImportResult::success(10);

        $this->assertTrue($result->isSuccess());
        $this->assertFalse($result->isPartialSuccess());
        $this->assertEquals(10, $result->getImportedCount());
        $this->assertEquals(0, $result->getFailedCount());
        $this->assertEmpty($result->getErrors());
    }

    public function testCreateFailedResult(): void
    {
        $error = new ImportError('CSV parse error', 0, ['line' => 1]);
        $result = ImportResult::failure([$error]);

        $this->assertFalse($result->isSuccess());
        $this->assertFalse($result->isPartialSuccess());
        $this->assertEquals(0, $result->getImportedCount());
        $this->assertEquals(0, $result->getFailedCount());
        $this->assertCount(1, $result->getErrors());
        $this->assertEquals('CSV parse error', $result->getErrors()[0]->getMessage());
    }

    public function testCreatePartialSuccessResult(): void
    {
        $error1 = new ImportError('Invalid department', 3, ['code' => 'INVALID']);
        $error2 = new ImportError('Missing position', 5, ['position' => 'null']);
        
        $result = ImportResult::partialSuccess(8, 2, [$error1, $error2]);

        $this->assertFalse($result->isSuccess());
        $this->assertTrue($result->isPartialSuccess());
        $this->assertEquals(8, $result->getImportedCount());
        $this->assertEquals(2, $result->getFailedCount());
        $this->assertCount(2, $result->getErrors());
    }

    public function testAddError(): void
    {
        $result = ImportResult::success(5);
        $error = new ImportError('Validation failed', 6);

        $result->addError($error);
        $result->incrementFailed();

        $this->assertFalse($result->isSuccess());
        $this->assertTrue($result->isPartialSuccess());
        $this->assertEquals(5, $result->getImportedCount());
        $this->assertEquals(1, $result->getFailedCount());
        $this->assertCount(1, $result->getErrors());
    }

    public function testIncrementCounters(): void
    {
        $result = ImportResult::success(0);

        $result->incrementImported();
        $result->incrementImported();
        $result->incrementImported();

        $this->assertEquals(3, $result->getImportedCount());
        $this->assertEquals(0, $result->getFailedCount());
        $this->assertTrue($result->isSuccess());
    }

    public function testSetDetails(): void
    {
        $result = ImportResult::success(10);
        
        $details = [
            'departments' => 3,
            'positions' => 2,
            'employees' => 5,
            'processing_time' => 1.23
        ];

        $result->setDetails($details);

        $this->assertEquals($details, $result->getDetails());
        $this->assertEquals(3, $result->getDetails()['departments']);
    }

    public function testMergeResults(): void
    {
        $result1 = ImportResult::success(5);
        $result1->setDetails(['departments' => 5]);

        $error = new ImportError('Employee error', 10);
        $result2 = ImportResult::partialSuccess(3, 1, [$error]);
        $result2->setDetails(['employees' => 3]);

        $merged = $result1->merge($result2);

        $this->assertTrue($merged->isPartialSuccess());
        $this->assertEquals(8, $merged->getImportedCount());
        $this->assertEquals(1, $merged->getFailedCount());
        $this->assertCount(1, $merged->getErrors());
        $this->assertEquals(5, $merged->getDetails()['departments']);
        $this->assertEquals(3, $merged->getDetails()['employees']);
    }

    public function testImportErrorProperties(): void
    {
        $context = [
            'tab_number' => '00001',
            'full_name' => 'Test User',
            'line' => 5
        ];

        $error = new ImportError('Invalid email format', 5, $context);

        $this->assertEquals('Invalid email format', $error->getMessage());
        $this->assertEquals(5, $error->getRowNumber());
        $this->assertEquals($context, $error->getContext());
        $this->assertEquals('00001', $error->getContext()['tab_number']);
    }

    public function testGetSuccessRate(): void
    {
        $result = ImportResult::partialSuccess(8, 2, []);

        $this->assertEquals(80.0, $result->getSuccessRate());
    }

    public function testGetSuccessRateWithNoData(): void
    {
        $result = ImportResult::success(0);

        $this->assertEquals(100.0, $result->getSuccessRate());
    }

    public function testToArray(): void
    {
        $error = new ImportError('Test error', 1);
        $result = ImportResult::partialSuccess(5, 1, [$error]);
        $result->setDetails(['test' => true]);

        $array = $result->toArray();

        $this->assertArrayHasKey('success', $array);
        $this->assertArrayHasKey('partial_success', $array);
        $this->assertArrayHasKey('imported_count', $array);
        $this->assertArrayHasKey('failed_count', $array);
        $this->assertArrayHasKey('success_rate', $array);
        $this->assertArrayHasKey('errors', $array);
        $this->assertArrayHasKey('details', $array);

        $this->assertFalse($array['success']);
        $this->assertTrue($array['partial_success']);
        $this->assertEquals(5, $array['imported_count']);
        $this->assertEquals(1, $array['failed_count']);
        $this->assertCount(1, $array['errors']);
    }
} 