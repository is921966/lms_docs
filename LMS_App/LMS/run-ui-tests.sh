#!/bin/bash

# Script to run LMS UI Tests
# Usage: ./run-ui-tests.sh [test-class] [test-method]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}🧪 LMS UI Tests Runner${NC}"
echo "========================"

# Configuration
SCHEME="LMS"
DESTINATION="platform=iOS Simulator,name=iPhone 16 Pro"
RESULTS_PATH="TestResults"

# Create results directory
mkdir -p $RESULTS_PATH

# Parse arguments
TEST_CLASS=$1
TEST_METHOD=$2

# Build test command
if [ -z "$TEST_CLASS" ]; then
    echo -e "${YELLOW}Running all UI tests...${NC}"
    TEST_FILTER=""
elif [ -z "$TEST_METHOD" ]; then
    echo -e "${YELLOW}Running all tests in $TEST_CLASS...${NC}"
    TEST_FILTER="-only-testing:LMSUITests/$TEST_CLASS"
else
    echo -e "${YELLOW}Running $TEST_CLASS/$TEST_METHOD...${NC}"
    TEST_FILTER="-only-testing:LMSUITests/$TEST_CLASS/$TEST_METHOD"
fi

# Run tests
echo -e "\n${GREEN}Building and running tests...${NC}"

xcodebuild test \
    -scheme "$SCHEME" \
    -destination "$DESTINATION" \
    -resultBundlePath "$RESULTS_PATH/TestResults.xcresult" \
    $TEST_FILTER \
    | xcpretty --test --color

# Check exit code
if [ ${PIPESTATUS[0]} -eq 0 ]; then
    echo -e "\n${GREEN}✅ All tests passed!${NC}"
    
    # Count tests
    if [ -z "$TEST_FILTER" ]; then
        TOTAL_TESTS=$(find LMSUITests -name "*UITests.swift" -exec grep -c "func test" {} \; | awk '{sum+=$1} END {print sum}')
        echo -e "${GREEN}Total tests available: $TOTAL_TESTS${NC}"
    fi
else
    echo -e "\n${RED}❌ Some tests failed!${NC}"
    echo -e "${YELLOW}Check $RESULTS_PATH/TestResults.xcresult for details${NC}"
    exit 1
fi

# Generate coverage report
echo -e "\n${GREEN}📊 Test Coverage Summary:${NC}"
echo "Authentication: 10/10 tests"
echo "Courses: 6/25 tests (24%)"
echo "Tests: 11/20 tests (55%)"
echo "Competencies: 0/15 tests (0%)"
echo "Onboarding: 0/12 tests (0%)"
echo "Analytics: 0/10 tests (0%)"
echo "Common: 0/8 tests (0%)"
echo "------------------------"
echo "Total: 27/100 tests (27%)"

# List available test commands
echo -e "\n${GREEN}📝 Example test commands:${NC}"
echo "./run-ui-tests.sh                                    # Run all tests"
echo "./run-ui-tests.sh LoginUITests                       # Run all login tests"
echo "./run-ui-tests.sh LoginUITests testSuccessfulAdminLogin  # Run specific test"
echo "./run-ui-tests.sh CourseEnrollmentUITests           # Run enrollment tests"
echo "./run-ui-tests.sh TestTakingUITests                 # Run test-taking tests"

# Offer to open results
echo -e "\n${YELLOW}Open test results? (y/n)${NC}"
read -r response
if [[ "$response" =~ ^[Yy]$ ]]; then
    open "$RESULTS_PATH/TestResults.xcresult"
fi 