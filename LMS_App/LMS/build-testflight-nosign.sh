#!/bin/bash

# Build TestFlight archive without signing
# Sign manually in Xcode Organizer

echo "🚀 Building LMS archive (without signing)..."
echo ""

# Set variables
PROJECT="LMS.xcodeproj"
SCHEME="LMS"
CONFIGURATION="Release"
ARCHIVE_PATH="build/LMS-unsigned.xcarchive"
BUILD_NUMBER=$(date +%Y%m%d%H%M)

# Clean build folder
echo "🧹 Cleaning build folder..."
rm -rf build
mkdir -p build

# Archive without signing
echo "📦 Creating unsigned archive..."
echo "This may take a few minutes..."
xcodebuild archive \
    -project "$PROJECT" \
    -scheme "$SCHEME" \
    -configuration "$CONFIGURATION" \
    -archivePath "$ARCHIVE_PATH" \
    -destination "generic/platform=iOS" \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGN_IDENTITY="" \
    CODE_SIGNING_ALLOWED=NO \
    MARKETING_VERSION=2.0.1 \
    CURRENT_PROJECT_VERSION=$BUILD_NUMBER

if [ $? -ne 0 ]; then
    echo "❌ Archive failed"
    exit 1
fi

echo "✅ Archive created successfully (unsigned)"
echo ""
echo "📝 Next steps:"
echo ""
echo "1. Open Xcode"
echo "2. Go to Xcode → Settings → Accounts"
echo "3. Add your Apple ID account (igor.shirokov@mac.com)"
echo "4. Go to Window → Organizer"
echo "5. Find the archive we just created"
echo "6. Click 'Distribute App'"
echo "7. Select 'App Store Connect'"
echo "8. Xcode will re-sign the app with a valid certificate"
echo "9. Upload to TestFlight"
echo ""
echo "Archive location: $(pwd)/$ARCHIVE_PATH"
echo ""
echo "Opening Xcode Organizer..."
open -a Xcode
osascript -e 'tell application "Xcode" to activate'
osascript -e 'tell application "System Events" to keystroke "O" using {command down, shift down}' 2>/dev/null || true 