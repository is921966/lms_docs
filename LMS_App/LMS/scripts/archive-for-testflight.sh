#!/bin/bash
set -e

echo "🚀 Creating TestFlight Archive..."
echo "================================"

VERSION="1.43.0"
BUILD=$(date +%s)

# Update version
/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $VERSION" LMS/Info.plist
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $BUILD" LMS/Info.plist

# Create archive
xcodebuild archive \
    -scheme LMS \
    -archivePath ~/Desktop/LMS_v${VERSION}.xcarchive \
    -destination 'generic/platform=iOS' \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGN_IDENTITY=""

echo "✅ Archive created at: ~/Desktop/LMS_v${VERSION}.xcarchive"
echo "📱 Version: $VERSION (Build $BUILD)"
echo ""
echo "Next steps:"
echo "1. Open Xcode Organizer (Window > Organizer)"
echo "2. Select the archive"
echo "3. Click 'Distribute App'"
echo "4. Follow TestFlight upload wizard"
