<?php

use Symfony\Component\Routing\Loader\Configurator\RoutingConfigurator;

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
}; 