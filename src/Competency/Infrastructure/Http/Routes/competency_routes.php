<?php

declare(strict_types=1);

use App\Competency\Infrastructure\Http\CompetencyController;
use App\Competency\Infrastructure\Http\AssessmentController;
use Symfony\Component\Routing\Loader\Configurator\RoutingConfigurator;

return function (RoutingConfigurator $routes) {
    // Competency routes
    $routes->add('competency_create', '/api/v1/competencies')
        ->controller([CompetencyController::class, 'create'])
        ->methods(['POST']);
        
    $routes->add('competency_list', '/api/v1/competencies')
        ->controller([CompetencyController::class, 'list'])
        ->methods(['GET']);
        
    $routes->add('competency_get', '/api/v1/competencies/{id}')
        ->controller([CompetencyController::class, 'get'])
        ->methods(['GET'])
        ->requirements(['id' => '[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}']);
        
    $routes->add('competency_update', '/api/v1/competencies/{id}')
        ->controller([CompetencyController::class, 'update'])
        ->methods(['PUT', 'PATCH'])
        ->requirements(['id' => '[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}']);
        
    $routes->add('competency_delete', '/api/v1/competencies/{id}')
        ->controller([CompetencyController::class, 'delete'])
        ->methods(['DELETE'])
        ->requirements(['id' => '[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}']);
        
    // Assessment routes
    $routes->add('assessment_create', '/api/v1/assessments')
        ->controller([AssessmentController::class, 'create'])
        ->methods(['POST']);
        
    $routes->add('assessment_user_list', '/api/v1/users/{userId}/assessments')
        ->controller([AssessmentController::class, 'getUserAssessments'])
        ->methods(['GET'])
        ->requirements(['userId' => '[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}']);
        
    $routes->add('assessment_update', '/api/v1/assessments/{id}')
        ->controller([AssessmentController::class, 'update'])
        ->methods(['PUT', 'PATCH'])
        ->requirements(['id' => '[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}']);
        
    $routes->add('assessment_confirm', '/api/v1/assessments/{id}/confirm')
        ->controller([AssessmentController::class, 'confirm'])
        ->methods(['POST'])
        ->requirements(['id' => '[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}']);
        
    $routes->add('assessment_history', '/api/v1/users/{userId}/competencies/{competencyId}/assessments')
        ->controller([AssessmentController::class, 'getHistory'])
        ->methods(['GET'])
        ->requirements([
            'userId' => '[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}',
            'competencyId' => '[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}'
        ]);
}; 