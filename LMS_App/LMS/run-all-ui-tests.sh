#!/bin/bash

echo "🚀🚀🚀 Starting Full MVP UI Test Suite 🚀🚀🚀"
echo "==============================================="
echo "Total tests to run: 94"
echo "Estimated time: 5-10 minutes"
echo "==============================================="

# Navigate to the correct directory if the script is not run from there
if [ ! -d "LMS.xcodeproj" ]; then
    echo "Error: LMS.xcodeproj not found. Please run this script from the LMS_App/LMS/ directory."
    exit 1
fi

# Clean previous build artifacts
echo "🧹 Cleaning build folder..."
xcodebuild clean -quiet

# Run all UI tests in the LMSUITests target
echo "🧪 Executing all 94 UI tests..."

start_time=$(date +%s)

xcodebuild test \
    -scheme LMS \
    -destination 'platform=iOS Simulator,name=iPhone 16 Pro' \
    -only-testing:LMSUITests \
    -resultBundlePath "TestResults.xcresult"

# Check the exit code of the test command
exit_code=$?

end_time=$(date +%s)
duration=$((end_time - start_time))

echo "==============================================="
if [ $exit_code -eq 0 ]; then
    echo "✅✅✅ SUCCESS ✅✅✅"
    echo "All UI tests passed successfully!"
else
    echo "❌❌❌ FAILURE ❌❌❌"
    echo "Some UI tests failed. Check the output above or the TestResults.xcresult bundle."
fi
echo "==============================================="
echo "Total execution time: $(($duration / 60)) minutes and $(($duration % 60)) seconds."
echo "==============================================="

exit $exit_code 