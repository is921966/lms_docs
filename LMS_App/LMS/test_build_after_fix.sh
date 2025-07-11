#!/bin/bash

echo "🧪 Testing build after Xcode fix..."

# Clean first
rm -rf ~/Library/Developer/Xcode/DerivedData/LMS-*

# Test build
echo "📦 Building..."
xcodebuild -scheme LMS \
    -destination 'platform=iOS Simulator,name=iPhone 16' \
    -configuration Debug \
    build \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGN_IDENTITY="" 2>&1 | grep -E "(BUILD SUCCEEDED|BUILD FAILED|error:|warning:)"

# Check result
if [ ${PIPESTATUS[0]} -eq 0 ]; then
    echo ""
    echo "✅ BUILD SUCCEEDED! Info.plist issue is fixed!"
    echo ""
    echo "Next steps:"
    echo "1. Commit the changes: git add -A && git commit -m 'Fix Info.plist duplication issue'"
    echo "2. Push to trigger CI/CD: git push origin feature/cmi5-support"
    echo "3. Or build for TestFlight: chmod +x manual_testflight_build.sh && ./manual_testflight_build.sh"
else
    echo ""
    echo "❌ Build still failing. Check the error messages above."
fi 