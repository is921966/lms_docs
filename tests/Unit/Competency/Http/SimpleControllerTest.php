<?php

declare(strict_types=1);

namespace Tests\Unit\Competency\Http;

use Competency\Http\Controllers\CompetencyController;
use Competency\Http\Controllers\CompetencyCategoryController;
use PHPUnit\Framework\TestCase;

class SimpleControllerTest extends TestCase
{
    public function testCompetencyControllerExists(): void
    {
        $this->assertTrue(class_exists(CompetencyController::class));
    }

    public function testCompetencyControllerHasRequiredMethods(): void
    {
        $methods = get_class_methods(CompetencyController::class);
        
        $requiredMethods = [
            'index',
            'show',
            'store',
            'update',
            'destroy',
            'assess'
        ];
        
        foreach ($requiredMethods as $method) {
            $this->assertContains($method, $methods, "Method $method not found in CompetencyController");
        }
    }

    public function testCompetencyCategoryControllerExists(): void
    {
        $this->assertTrue(class_exists(CompetencyCategoryController::class));
    }

    public function testCompetencyCategoryControllerHasRequiredMethods(): void
    {
        $methods = get_class_methods(CompetencyCategoryController::class);
        
        $requiredMethods = [
            'index',
            'show',
            'store',
            'update',
            'destroy'
        ];
        
        foreach ($requiredMethods as $method) {
            $this->assertContains($method, $methods, "Method $method not found in CompetencyCategoryController");
        }
    }
}
