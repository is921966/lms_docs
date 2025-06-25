#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

echo "🧪 Running UI Tests..."

# Clean build folder
echo "🧹 Cleaning build folder..."
xcodebuild clean -scheme LMS -destination "platform=iOS Simulator,name=iPhone 16" > /dev/null 2>&1

# Build for testing
echo "🔨 Building app for testing..."
if ! xcodebuild build-for-testing \
    -scheme LMS \
    -destination "platform=iOS Simulator,name=iPhone 16" \
    -derivedDataPath build/DerivedData \
    2>&1 | grep -E "(error:|warning:|BUILD)"
then
    echo -e "${GREEN}✅ Build successful${NC}"
else
    echo -e "${RED}❌ Build failed${NC}"
    exit 1
fi

# Run UI tests
echo "🚀 Running UI tests..."
if xcodebuild test-without-building \
    -scheme LMS \
    -destination "platform=iOS Simulator,name=iPhone 16" \
    -derivedDataPath build/DerivedData \
    -only-testing:LMSUITests \
    2>&1 | tee test-results.log | grep -E "(Test Case|passed|failed|error:)"
then
    echo -e "${GREEN}✅ All UI tests passed!${NC}"
    
    # Show summary
    PASSED=$(grep -c "passed" test-results.log)
    echo -e "${GREEN}Summary: $PASSED tests passed${NC}"
    
    # Clean up
    rm test-results.log
    exit 0
else
    echo -e "${RED}❌ UI tests failed!${NC}"
    
    # Show failed tests
    echo -e "${YELLOW}Failed tests:${NC}"
    grep "failed" test-results.log
    
    # Clean up
    rm test-results.log
    exit 1
fi 