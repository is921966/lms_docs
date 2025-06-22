<?php

use Symfony\Component\Routing\Loader\Configurator\RoutingConfigurator;

return function (RoutingConfigurator $routes) {
    // Redirect root to admin panel
    $routes->add('root', '/')
        ->controller('App\Common\Http\Controllers\HomeController::index')
        ->methods(['GET']);
    
    // Admin panel (SPA)
    $routes->add('admin', '/admin{path}')
        ->controller('App\Common\Http\Controllers\AdminController::index')
        ->methods(['GET'])
        ->requirements(['path' => '.*'])
        ->defaults(['path' => '', '_auth' => true]);
    
    // Student portal (SPA)
    $routes->add('portal', '/portal{path}')
        ->controller('App\Common\Http\Controllers\PortalController::index')
        ->methods(['GET'])
        ->requirements(['path' => '.*'])
        ->defaults(['path' => '', '_auth' => true]);
    
    // Public pages
    $routes->add('login', '/login')
        ->controller('App\User\Http\Controllers\LoginController::show')
        ->methods(['GET']);
    
    $routes->add('logout', '/logout')
        ->controller('App\User\Http\Controllers\LoginController::logout')
        ->methods(['GET', 'POST']);
    
    // Password reset
    $routes->add('password.request', '/password/reset')
        ->controller('App\User\Http\Controllers\PasswordController::request')
        ->methods(['GET']);
    
    $routes->add('password.email', '/password/email')
        ->controller('App\User\Http\Controllers\PasswordController::email')
        ->methods(['POST']);
    
    $routes->add('password.reset', '/password/reset/{token}')
        ->controller('App\User\Http\Controllers\PasswordController::reset')
        ->methods(['GET'])
        ->requirements(['token' => '[a-zA-Z0-9]+']);
    
    $routes->add('password.update', '/password/update')
        ->controller('App\User\Http\Controllers\PasswordController::update')
        ->methods(['POST']);
    
    // File downloads (authenticated)
    $routes->add('download.file', '/download/{type}/{id}/{filename}')
        ->controller('App\Common\Http\Controllers\DownloadController::file')
        ->methods(['GET'])
        ->requirements([
            'type' => 'course|test|certificate',
            'id' => '\d+',
            'filename' => '.+',
        ])
        ->defaults(['_auth' => true]);
    
    // Certificate verification (public)
    $routes->add('certificate.verify', '/certificate/verify/{code}')
        ->controller('App\Learning\Http\Controllers\CertificateController::verify')
        ->methods(['GET'])
        ->requirements(['code' => '[A-Z0-9]{8,16}']);
    
    // Error pages
    $routes->add('error.403', '/error/403')
        ->controller('App\Common\Http\Controllers\ErrorController::forbidden')
        ->methods(['GET']);
    
    $routes->add('error.404', '/error/404')
        ->controller('App\Common\Http\Controllers\ErrorController::notFound')
        ->methods(['GET']);
    
    $routes->add('error.500', '/error/500')
        ->controller('App\Common\Http\Controllers\ErrorController::serverError')
        ->methods(['GET']);
    
    // Maintenance mode
    $routes->add('maintenance', '/maintenance')
        ->controller('App\Common\Http\Controllers\MaintenanceController::index')
        ->methods(['GET']);
}; 