#!/bin/bash

# Quick test runner for Cmi5 optimization tests

echo "🚀 Running Cmi5 Optimization Tests..."
echo "=================================="

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test categories
INTEGRATION_TESTS="Cmi5IntegrationTests"
PERFORMANCE_TESTS="Cmi5PerformanceTests"
UI_TESTS="Cmi5UITests"

# Function to run tests with timeout
run_test_suite() {
    local test_suite=$1
    local timeout=${2:-120} # Default 2 minutes
    
    echo -e "\n${YELLOW}Running $test_suite...${NC}"
    
    # Run with timeout
    if timeout $timeout xcodebuild test \
        -scheme LMS \
        -destination 'platform=iOS Simulator,name=iPhone 16' \
        -only-testing:LMSTests/$test_suite \
        -parallel-testing-enabled YES \
        -quiet | grep -E "(Test Suite|passed|failed|error:)" ; then
        echo -e "${GREEN}✅ $test_suite completed${NC}"
        return 0
    else
        echo -e "${RED}❌ $test_suite failed or timed out${NC}"
        return 1
    fi
}

# Run specific test if provided as argument
if [ -n "$1" ]; then
    case "$1" in
        "integration")
            run_test_suite $INTEGRATION_TESTS 180
            ;;
        "performance")
            run_test_suite $PERFORMANCE_TESTS 300
            ;;
        "ui")
            run_test_suite $UI_TESTS 240
            ;;
        *)
            echo "Usage: $0 [integration|performance|ui|all]"
            exit 1
            ;;
    esac
else
    # Run all optimization tests
    echo "Running all optimization test suites..."
    
    # Track results
    FAILED_SUITES=()
    
    # Run each suite
    if ! run_test_suite $INTEGRATION_TESTS 180; then
        FAILED_SUITES+=($INTEGRATION_TESTS)
    fi
    
    if ! run_test_suite $PERFORMANCE_TESTS 300; then
        FAILED_SUITES+=($PERFORMANCE_TESTS)
    fi
    
    if ! run_test_suite $UI_TESTS 240; then
        FAILED_SUITES+=($UI_TESTS)
    fi
    
    # Summary
    echo -e "\n${YELLOW}==============================${NC}"
    echo "Optimization Test Summary:"
    
    if [ ${#FAILED_SUITES[@]} -eq 0 ]; then
        echo -e "${GREEN}✅ All optimization tests passed!${NC}"
        exit 0
    else
        echo -e "${RED}❌ Failed test suites:${NC}"
        for suite in "${FAILED_SUITES[@]}"; do
            echo "   - $suite"
        done
        exit 1
    fi
fi 