#!/bin/bash

echo "🧪 Running Feed Module Tests Only..."

# Compile first without running tests
echo "📦 Building project..."
xcodebuild build-for-testing \
    -project LMS.xcodeproj \
    -scheme LMS \
    -destination 'platform=iOS Simulator,name=iPhone 16 Pro,OS=18.5' \
    -quiet

# Run specific Feed tests
echo "🏃 Running Feed tests..."
xcodebuild test-without-building \
    -project LMS.xcodeproj \
    -scheme LMS \
    -destination 'platform=iOS Simulator,name=iPhone 16 Pro,OS=18.5' \
    -only-testing:LMSTests/FeedPostTests \
    -only-testing:LMSTests/FeedServiceTests \
    -only-testing:LMSTests/FeedViewTests \
    -only-testing:LMSTests/FeedIntegrationTests \
    -resultBundlePath TestResults/feed_tests.xcresult \
    2>&1 | xcpretty -r junit -o TestResults/feed_junit.xml

# Check results
if [ $? -eq 0 ]; then
    echo "✅ Feed tests passed!"
    # Generate coverage report
    xcrun xccov view --report TestResults/feed_tests.xcresult > TestResults/feed_coverage.txt
    echo "📊 Coverage report saved to TestResults/feed_coverage.txt"
else
    echo "❌ Feed tests failed!"
    exit 1
fi 