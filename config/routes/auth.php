<?php

use Symfony\Component\Routing\Loader\Configurator\RoutingConfigurator;
use Auth\Http\Controllers\AuthController;

return function (RoutingConfigurator $routes) {
    $routes->add('auth_login', '/api/auth/login')
        ->controller([AuthController::class, 'login'])
        ->methods(['POST']);

    $routes->add('auth_refresh', '/api/auth/refresh')
        ->controller([AuthController::class, 'refresh'])
        ->methods(['POST']);

    $routes->add('auth_logout', '/api/auth/logout')
        ->controller([AuthController::class, 'logout'])
        ->methods(['POST']);

    $routes->add('auth_me', '/api/auth/me')
        ->controller([AuthController::class, 'me'])
        ->methods(['GET']);
}; 