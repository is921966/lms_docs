#!/bin/bash
# SwiftLint script for Xcode Build Phase
# Based on ci-cd-review.mdc requirements

# Exit on any error
set -e

# Colors for output
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Check if SwiftLint is installed
if ! command -v swiftlint &> /dev/null; then
    echo "❌ SwiftLint is not installed. Please install it via:"
    echo "   brew install swiftlint"
    echo "   or"
    echo "   mint install realm/SwiftLint"
    exit 1
fi

# Get SwiftLint version
SWIFTLINT_VERSION=$(swiftlint version)
echo "🔍 SwiftLint version: $SWIFTLINT_VERSION"

# Change to project directory
cd "${SRCROOT}"

# Check if configuration file exists
if [ ! -f ".swiftlint.yml" ]; then
    echo "❌ .swiftlint.yml not found in project root"
    exit 1
fi

# Run SwiftLint based on build configuration
if [ "${CONFIGURATION}" = "Debug" ]; then
    echo "🔍 Running SwiftLint in Debug mode..."
    
    # In Debug mode, only show warnings/errors in Xcode
    swiftlint lint --quiet --reporter xcode
    
elif [ "${CONFIGURATION}" = "Release" ]; then
    echo "🔍 Running SwiftLint in Release mode..."
    
    # In Release mode, fail on errors
    ERROR_COUNT=$(swiftlint lint --quiet --reporter json | grep -o '"severity" : "error"' | wc -l | tr -d ' ')
    
    if [ "$ERROR_COUNT" -gt 0 ]; then
        echo -e "${RED}❌ SwiftLint found $ERROR_COUNT errors. Build failed.${NC}"
        swiftlint lint --quiet --reporter xcode
        exit 1
    else
        echo -e "${GREEN}✅ SwiftLint passed with no errors${NC}"
        swiftlint lint --quiet --reporter xcode
    fi
fi

# Generate HTML report for detailed analysis (optional)
if [ "${GENERATE_SWIFTLINT_REPORT}" = "YES" ]; then
    REPORT_PATH="${BUILD_DIR}/swiftlint-report.html"
    swiftlint lint --reporter html > "$REPORT_PATH"
    echo "📊 SwiftLint report generated: $REPORT_PATH"
fi

echo "✅ SwiftLint check completed" 