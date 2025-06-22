#!/usr/bin/env php
<?php

echo "=== LMS Test Runner ===\n\n";

// Check if vendor directory exists
if (!file_exists(__DIR__ . '/vendor/autoload.php')) {
    echo "❌ ERROR: vendor/autoload.php not found. Run 'composer install' first.\n";
    exit(1);
}

// Load autoloader
require __DIR__ . '/vendor/autoload.php';

// Check if required classes exist
$requiredClasses = [
    'Tests\\TestCase' => 'tests/TestCase.php',
    'App\\User\\Domain\\User' => 'src/User/Domain/User.php',
    'App\\User\\Domain\\ValueObjects\\Email' => 'src/User/Domain/ValueObjects/Email.php',
    'Ramsey\\Uuid\\Uuid' => 'vendor/ramsey/uuid (composer package)',
];

echo "Checking required classes:\n";
foreach ($requiredClasses as $class => $location) {
    if (class_exists($class) || interface_exists($class)) {
        echo "✅ $class found\n";
    } else {
        echo "❌ $class NOT found (expected in: $location)\n";
    }
}

echo "\nChecking test files:\n";
$testFiles = [
    'tests/TestCase.php',
    'tests/Unit/User/Domain/UserTest.php',
    'tests/Unit/User/Domain/ValueObjects/EmailTest.php',
    'tests/IntegrationTestCase.php',
    'tests/FeatureTestCase.php',
];

foreach ($testFiles as $file) {
    if (file_exists($file)) {
        echo "✅ $file exists\n";
    } else {
        echo "❌ $file NOT found\n";
    }
}

// Try to instantiate a simple test
echo "\nTrying to instantiate a test class:\n";
try {
    if (class_exists('Tests\\TestCase')) {
        echo "✅ Tests\\TestCase can be loaded\n";
        
        // Try to load a specific test
        if (class_exists('Tests\\Unit\\User\\Domain\\ValueObjects\\EmailTest')) {
            echo "✅ EmailTest can be loaded\n";
        } else {
            echo "❌ EmailTest cannot be loaded\n";
        }
    }
} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
}

echo "\nPHPUnit installation check:\n";
if (file_exists(__DIR__ . '/vendor/bin/phpunit')) {
    echo "✅ PHPUnit is installed\n";
    echo "\nTo run tests, use: ./vendor/bin/phpunit\n";
} else {
    echo "❌ PHPUnit is NOT installed\n";
}

echo "\n=== End of checks ===\n"; 