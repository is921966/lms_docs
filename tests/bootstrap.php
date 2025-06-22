<?php

// Load composer autoloader
require dirname(__DIR__) . '/vendor/autoload.php';

// Load environment variables
// TODO: Restore Dotenv loading after installing the package
// if (file_exists(dirname(__DIR__) . '/.env.test')) {
//     $dotenv = Dotenv\Dotenv::createImmutable(dirname(__DIR__), '.env.test');
//     $dotenv->load();
// } elseif (file_exists(dirname(__DIR__) . '/.env')) {
//     $dotenv = Dotenv\Dotenv::createImmutable(dirname(__DIR__));
//     $dotenv->load();
// }

// Set error reporting
error_reporting(E_ALL);
ini_set('display_errors', '1');

// Set timezone
date_default_timezone_set('UTC'); 