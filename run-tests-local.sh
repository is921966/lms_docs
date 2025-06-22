#!/bin/bash

# Local test runner script
# This script runs tests locally without Docker

echo "🚀 Local Test Runner for LMS Project"
echo "===================================="

# Check if PHP is installed
if ! command -v php &> /dev/null; then
    echo "❌ PHP is not installed. Please install PHP 8.2+ first."
    echo ""
    echo "On macOS with Homebrew:"
    echo "  brew install php@8.2"
    echo ""
    echo "On Ubuntu/Debian:"
    echo "  sudo apt update && sudo apt install php8.2-cli php8.2-mbstring php8.2-xml"
    echo ""
    exit 1
fi

# Check PHP version
PHP_VERSION=$(php -r "echo PHP_VERSION;")
echo "✅ PHP version: $PHP_VERSION"

# Check if vendor directory exists
if [ ! -d "vendor" ]; then
    echo "📦 Installing dependencies..."
    if command -v composer &> /dev/null; then
        composer install --ignore-platform-reqs
    else
        echo "❌ Composer is not installed. Please install Composer first."
        echo "Visit: https://getcomposer.org/download/"
        exit 1
    fi
fi

# Run tests
if [ $# -eq 0 ]; then
    echo "🧪 Running all tests..."
    php vendor/bin/phpunit
else
    echo "🧪 Running specific test: $1"
    php vendor/bin/phpunit "$1"
fi 