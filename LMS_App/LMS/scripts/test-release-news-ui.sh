#!/bin/bash

echo "🧪 Testing Release News UI Integration"
echo "======================================"

# Clean build folder
echo "🧹 Cleaning build folder..."
rm -rf ~/Library/Developer/Xcode/DerivedData/LMS-*/Build/Products/Debug-iphonesimulator/

# Run specific UI test
echo "🚀 Running ReleaseNewsUITests..."
xcodebuild test \
    -scheme LMS \
    -destination "platform=iOS Simulator,name=iPhone 16" \
    -only-testing:LMSUITests/ReleaseNewsUITests/testReleaseAlertAppearsOnNewVersion \
    -resultBundlePath "TestResults/ReleaseNewsUITest_$(date +%Y%m%d_%H%M%S).xcresult" \
    2>&1 | grep -E "(Test Suite|Test Case|passed|failed|error|Executed)" | tail -20

echo ""
echo "✅ Test completed!" 