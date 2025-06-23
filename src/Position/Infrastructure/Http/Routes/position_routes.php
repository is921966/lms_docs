<?php

declare(strict_types=1);

use App\Position\Infrastructure\Http\PositionController;
use App\Position\Infrastructure\Http\ProfileController;
use App\Position\Infrastructure\Http\CareerPathController;
use Symfony\Component\Routing\Route;
use Symfony\Component\Routing\RouteCollection;

$routes = new RouteCollection();

// Position routes
$routes->add('position_list', new Route(
    '/api/v1/positions',
    ['_controller' => [PositionController::class, 'getActivePositions']],
    methods: ['GET']
));

$routes->add('position_create', new Route(
    '/api/v1/positions',
    ['_controller' => [PositionController::class, 'createPosition']],
    methods: ['POST']
));

$routes->add('position_get', new Route(
    '/api/v1/positions/{id}',
    ['_controller' => [PositionController::class, 'getPosition']],
    requirements: ['id' => '[\w-]+'],
    methods: ['GET']
));

$routes->add('position_update', new Route(
    '/api/v1/positions/{id}',
    ['_controller' => [PositionController::class, 'updatePosition']],
    requirements: ['id' => '[\w-]+'],
    methods: ['PUT']
));

$routes->add('position_archive', new Route(
    '/api/v1/positions/{id}/archive',
    ['_controller' => [PositionController::class, 'archivePosition']],
    requirements: ['id' => '[\w-]+'],
    methods: ['POST']
));

$routes->add('position_by_department', new Route(
    '/api/v1/positions/department/{department}',
    ['_controller' => [PositionController::class, 'getPositionsByDepartment']],
    requirements: ['department' => '[\w-]+'],
    methods: ['GET']
));

// Profile routes
$routes->add('profile_get', new Route(
    '/api/v1/positions/{positionId}/profile',
    ['_controller' => [ProfileController::class, 'getProfile']],
    requirements: ['positionId' => '[\w-]+'],
    methods: ['GET']
));

$routes->add('profile_create', new Route(
    '/api/v1/profiles',
    ['_controller' => [ProfileController::class, 'createProfile']],
    methods: ['POST']
));

$routes->add('profile_update', new Route(
    '/api/v1/positions/{positionId}/profile',
    ['_controller' => [ProfileController::class, 'updateProfile']],
    requirements: ['positionId' => '[\w-]+'],
    methods: ['PUT']
));

$routes->add('profile_add_competency', new Route(
    '/api/v1/positions/{positionId}/profile/competencies',
    ['_controller' => [ProfileController::class, 'addCompetencyRequirement']],
    requirements: ['positionId' => '[\w-]+'],
    methods: ['POST']
));

$routes->add('profile_remove_competency', new Route(
    '/api/v1/positions/{positionId}/profile/competencies/{competencyId}',
    ['_controller' => [ProfileController::class, 'removeCompetencyRequirement']],
    requirements: ['positionId' => '[\w-]+', 'competencyId' => '[\w-]+'],
    methods: ['DELETE']
));

$routes->add('profiles_by_competency', new Route(
    '/api/v1/profiles/competency/{competencyId}',
    ['_controller' => [ProfileController::class, 'getProfilesByCompetency']],
    requirements: ['competencyId' => '[\w-]+'],
    methods: ['GET']
));

// Career Path routes
$routes->add('career_path_create', new Route(
    '/api/v1/career-paths',
    ['_controller' => [CareerPathController::class, 'createCareerPath']],
    methods: ['POST']
));

$routes->add('career_path_get', new Route(
    '/api/v1/career-paths/{fromPositionId}/{toPositionId}',
    ['_controller' => [CareerPathController::class, 'getCareerPath']],
    requirements: ['fromPositionId' => '[\w-]+', 'toPositionId' => '[\w-]+'],
    methods: ['GET']
));

$routes->add('career_path_add_milestone', new Route(
    '/api/v1/career-paths/{careerPathId}/milestones',
    ['_controller' => [CareerPathController::class, 'addMilestone']],
    requirements: ['careerPathId' => '[\w-]+'],
    methods: ['POST']
));

$routes->add('career_path_progress', new Route(
    '/api/v1/career-paths/{fromPositionId}/{toPositionId}/progress',
    ['_controller' => [CareerPathController::class, 'getCareerProgress']],
    requirements: ['fromPositionId' => '[\w-]+', 'toPositionId' => '[\w-]+'],
    methods: ['GET']
));

$routes->add('career_paths_active', new Route(
    '/api/v1/career-paths/active',
    ['_controller' => [CareerPathController::class, 'getActiveCareerPaths']],
    methods: ['GET']
));

$routes->add('career_path_deactivate', new Route(
    '/api/v1/career-paths/{careerPathId}/deactivate',
    ['_controller' => [CareerPathController::class, 'deactivateCareerPath']],
    requirements: ['careerPathId' => '[\w-]+'],
    methods: ['POST']
));

$routes->add('career_paths_from_position', new Route(
    '/api/v1/positions/{positionId}/career-paths',
    ['_controller' => [CareerPathController::class, 'getCareerPathsFromPosition']],
    requirements: ['positionId' => '[\w-]+'],
    methods: ['GET']
));

return $routes; 