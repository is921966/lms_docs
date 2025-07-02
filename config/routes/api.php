<?php

use Symfony\Component\Routing\Loader\Configurator\RoutingConfigurator;
use User\Http\Controllers\UserController;

return function (RoutingConfigurator $routes) {
    // API v1 routes
    $routes->import('../../src/*/Http/Routes/*_routes.php', 'glob')
        ->prefix('/api/v1')
        ->namePrefix('api.v1.')
        ->host('{subdomain}.{domain}')
        ->defaults([
            'subdomain' => 'api',
            'domain' => '%app.domain%',
        ])
        ->requirements([
            'subdomain' => 'api|api-staging',
            'domain' => '%app.domain%',
        ]);
    
    // Health check endpoints
    $routes->add('health', '/health')
        ->controller('App\Common\Http\Controllers\HealthController::check')
        ->methods(['GET']);
    
    $routes->add('health.detailed', '/health/detailed')
        ->controller('App\Common\Http\Controllers\HealthController::detailed')
        ->methods(['GET']);
    
    // Authentication endpoints
    $routes->add('auth.login', '/api/v1/auth/login')
        ->controller('App\User\Http\Controllers\AuthController::login')
        ->methods(['POST']);
    
    $routes->add('auth.logout', '/api/v1/auth/logout')
        ->controller('App\User\Http\Controllers\AuthController::logout')
        ->methods(['POST']);
    
    $routes->add('auth.refresh', '/api/v1/auth/refresh')
        ->controller('App\User\Http\Controllers\AuthController::refresh')
        ->methods(['POST']);
    
    $routes->add('auth.me', '/api/v1/auth/me')
        ->controller('App\User\Http\Controllers\AuthController::me')
        ->methods(['GET']);
    
    // LDAP sync endpoint (admin only)
    $routes->add('auth.ldap.sync', '/api/v1/auth/ldap/sync')
        ->controller('App\User\Http\Controllers\LdapController::sync')
        ->methods(['POST'])
        ->defaults(['_auth' => true, '_roles' => ['ROLE_ADMIN']]);
    
    // API documentation
    $routes->add('api.docs', '/api/docs')
        ->controller('App\Common\Http\Controllers\ApiDocController::index')
        ->methods(['GET']);
    
    $routes->add('api.openapi', '/api/openapi.json')
        ->controller('App\Common\Http\Controllers\ApiDocController::openapi')
        ->methods(['GET']);

    // User routes
    $routes->add('users.index', '/api/users')
        ->controller([UserController::class, 'index'])
        ->methods(['GET']);
        
    $routes->add('users.store', '/api/users')
        ->controller([UserController::class, 'store'])
        ->methods(['POST']);
        
    $routes->add('users.show', '/api/users/{id}')
        ->controller([UserController::class, 'show'])
        ->methods(['GET'])
        ->requirements(['id' => '[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}']);
        
    $routes->add('users.update', '/api/users/{id}')
        ->controller([UserController::class, 'update'])
        ->methods(['PUT', 'PATCH'])
        ->requirements(['id' => '[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}']);
        
    $routes->add('users.destroy', '/api/users/{id}')
        ->controller([UserController::class, 'destroy'])
        ->methods(['DELETE'])
        ->requirements(['id' => '[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}']);
}; 