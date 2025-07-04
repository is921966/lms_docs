#!/bin/bash

# Run Unit Tests with Coverage Report
# Usage: ./scripts/run-tests-with-coverage.sh

set -euo pipefail

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "🧪 Running LMS Unit Tests with Coverage..."

# Clean previous results
rm -rf TestResults
mkdir -p TestResults

# Build and test
echo "📦 Building for testing..."
xcodebuild build-for-testing \
    -scheme LMS-UnitTests \
    -destination 'platform=iOS Simulator,name=iPhone 16 Pro Max' \
    -quiet

echo "🏃 Running tests..."
xcodebuild test-without-building \
    -scheme LMS-UnitTests \
    -destination 'platform=iOS Simulator,name=iPhone 16 Pro Max' \
    -enableCodeCoverage YES \
    -resultBundlePath TestResults/unit-tests.xcresult \
    -quiet | tee TestResults/test-output.log

# Extract test results
echo "📊 Analyzing results..."

# Count passed/failed tests
PASSED=$(grep -c "passed on" TestResults/test-output.log || echo "0")
FAILED=$(grep -c "failed on" TestResults/test-output.log || echo "0")
TOTAL=$((PASSED + FAILED))

# Calculate percentage
if [ $TOTAL -gt 0 ]; then
    PERCENTAGE=$(echo "scale=2; $PASSED * 100 / $TOTAL" | bc)
else
    PERCENTAGE=0
fi

# Generate coverage report
echo "📈 Generating coverage report..."
xcrun xccov view --report --json TestResults/unit-tests.xcresult > TestResults/coverage.json

# Extract coverage percentage
COVERAGE=$(cat TestResults/coverage.json | jq '.lineCoverage' | awk '{printf "%.2f", $1 * 100}')

# Display results
echo ""
echo "========================================="
echo "📊 TEST RESULTS"
echo "========================================="
echo -e "✅ Passed:    ${GREEN}$PASSED${NC}"
echo -e "❌ Failed:    ${RED}$FAILED${NC}"
echo "📋 Total:     $TOTAL"
echo -e "📊 Pass Rate: ${PERCENTAGE}%"
echo ""
echo "========================================="
echo "📈 CODE COVERAGE"
echo "========================================="
echo -e "📊 Coverage:  ${GREEN}${COVERAGE}%${NC}"

# Check thresholds
if [ $FAILED -gt 0 ]; then
    echo ""
    echo -e "${RED}❌ Tests failed!${NC}"
    echo "Failed tests:"
    grep "failed on" TestResults/test-output.log | grep -o "Test case '[^']*'" | sed "s/Test case '/  - /"
    exit 1
fi

if (( $(echo "$COVERAGE < 80" | bc -l) )); then
    echo ""
    echo -e "${YELLOW}⚠️  Code coverage is below 80%${NC}"
fi

echo ""
echo -e "${GREEN}✅ All tests passed!${NC}"

# Generate HTML coverage report
echo ""
echo "📄 Generating HTML coverage report..."
xcrun xccov view --report TestResults/unit-tests.xcresult --output-directory TestResults/coverage-html

echo "✨ Coverage report available at: TestResults/coverage-html/index.html" 