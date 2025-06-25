#!/bin/bash

# Manual TestFlight build script
# This script builds the app and prepares it for manual upload to TestFlight

echo "🚀 Building LMS for TestFlight (Manual Upload)..."
echo ""

# Set variables
PROJECT="LMS.xcodeproj"
SCHEME="LMS"
CONFIGURATION="Release"
ARCHIVE_PATH="build/LMS.xcarchive"
EXPORT_PATH="build/LMS-TestFlight"
EXPORT_OPTIONS_PLIST="ExportOptions.plist"
BUILD_NUMBER=$(date +%Y%m%d%H%M)

# Clean build folder
echo "🧹 Cleaning build folder..."
rm -rf build
mkdir -p build

# Archive the app
echo "📦 Creating archive..."
echo "This may take a few minutes..."
xcodebuild archive \
    -project "$PROJECT" \
    -scheme "$SCHEME" \
    -configuration "$CONFIGURATION" \
    -archivePath "$ARCHIVE_PATH" \
    -destination "generic/platform=iOS" \
    -allowProvisioningUpdates \
    DEVELOPMENT_TEAM=N85286S93X \
    CODE_SIGN_STYLE=Automatic \
    PRODUCT_BUNDLE_IDENTIFIER=ru.tsum.lms.igor \
    MARKETING_VERSION=2.0.1 \
    CURRENT_PROJECT_VERSION=$BUILD_NUMBER

if [ $? -ne 0 ]; then
    echo "❌ Archive failed"
    echo ""
    echo "Common issues:"
    echo "1. Make sure you're signed in to Xcode with your Apple ID"
    echo "2. Check that automatic signing is enabled in project settings"
    echo "3. Ensure you have a valid development certificate"
    exit 1
fi

echo "✅ Archive created successfully"

# Create ExportOptions.plist for manual signing
echo "📝 Creating ExportOptions.plist..."
cat > "$EXPORT_OPTIONS_PLIST" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>app-store</string>
    <key>teamID</key>
    <string>N85286S93X</string>
    <key>uploadSymbols</key>
    <true/>
    <key>compileBitcode</key>
    <false/>
    <key>stripSwiftSymbols</key>
    <true/>
    <key>signingStyle</key>
    <string>automatic</string>
</dict>
</plist>
EOF

# Export the archive
echo "📤 Exporting archive..."
xcodebuild -exportArchive \
    -archivePath "$ARCHIVE_PATH" \
    -exportPath "$EXPORT_PATH" \
    -exportOptionsPlist "$EXPORT_OPTIONS_PLIST" \
    -allowProvisioningUpdates

if [ $? -ne 0 ]; then
    echo "❌ Export failed"
    exit 1
fi

echo "✅ Export completed successfully"

# Open the export folder
echo "📂 Opening export folder..."
open "$EXPORT_PATH"

echo ""
echo "✅ Build completed!"
echo ""
echo "📱 Manual upload instructions:"
echo ""
echo "Option 1 - Using Xcode:"
echo "1. Open Xcode"
echo "2. Go to Window → Organizer"
echo "3. Click 'Open Archive...' and select: $(pwd)/$ARCHIVE_PATH"
echo "4. Click 'Distribute App'"
echo "5. Select 'App Store Connect' → 'Upload'"
echo "6. Follow the prompts"
echo ""
echo "Option 2 - Using Transporter:"
echo "1. Download Transporter from Mac App Store"
echo "2. Open Transporter and sign in"
echo "3. Drag the .ipa file from: $(pwd)/$EXPORT_PATH/LMS.ipa"
echo "4. Click 'Deliver'"
echo ""
echo "Build details:"
echo "- Version: 2.0.1"
echo "- Build: $BUILD_NUMBER"
echo "- Bundle ID: ru.tsum.lms.igor"
echo ""
echo "After upload, go to App Store Connect to submit for TestFlight review." 