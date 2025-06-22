#!/bin/bash

# Quick test runner using pre-built PHP image
# No building required!

echo "🚀 Quick Test Runner for LMS"
echo "==========================="

# Check if vendor directory exists
if [ ! -d "vendor" ]; then
    echo "📦 Installing dependencies..."
    docker run --rm -v $(pwd):/app -w /app composer:2.6 install --ignore-platform-reqs
fi

# Run tests
if [ $# -eq 0 ]; then
    echo "🧪 Running all tests..."
    docker run --rm -v $(pwd):/app -w /app php:8.2-cli php vendor/bin/phpunit
else
    echo "🧪 Running specific test: $1"
    docker run --rm -v $(pwd):/app -w /app php:8.2-cli php vendor/bin/phpunit "$1"
fi 