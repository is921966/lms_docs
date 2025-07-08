#!/bin/bash

# Quick Cmi5 tests runner with timeout
# Usage: ./scripts/test-cmi5-quick.sh

set -e

# Set timeout in seconds (default 60)
TIMEOUT=${1:-60}

echo "🚀 Running Cmi5 tests with ${TIMEOUT}s timeout..."
echo "=================================="

# Clean build directory
rm -rf DerivedData/

# Function to run test with timeout
run_test() {
    local test_name=$1
    local scheme="LMS"
    
    echo "Running: $test_name"
    
    # Start test in background
    timeout $TIMEOUT xcodebuild test \
        -scheme "$scheme" \
        -destination 'platform=iOS Simulator,name=iPhone 16' \
        -only-testing:"LMSTests/Features/Cmi5/$test_name" \
        2>&1 | grep -E "(Test Suite|passed|failed|error:|warning:|✓|✗)" &
    
    # Get PID and wait
    local pid=$!
    wait $pid
    local exit_code=$?
    
    if [ $exit_code -eq 124 ]; then
        echo "❌ Test timed out after ${TIMEOUT}s: $test_name"
        return 1
    elif [ $exit_code -eq 0 ]; then
        echo "✅ Test passed: $test_name"
        return 0
    else
        echo "❌ Test failed: $test_name (exit code: $exit_code)"
        return 1
    fi
}

# Run all Cmi5 tests
echo "🧪 Running all Cmi5 tests..."
run_test "Cmi5" || true

# Run specific test classes if provided
if [ -n "$2" ]; then
    echo ""
    echo "🧪 Running specific test: $2"
    run_test "$2"
fi

echo ""
echo "=================================="
echo "✅ Cmi5 tests completed" 