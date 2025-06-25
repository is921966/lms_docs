#!/bin/bash

# Build and upload to TestFlight

echo "🚀 Building LMS for TestFlight..."
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

# Update build number
echo "📝 Updating build number to $BUILD_NUMBER..."
xcrun agvtool new-version -all $BUILD_NUMBER

# Archive the app
echo "📦 Creating archive..."
xcodebuild archive \
    -project "$PROJECT" \
    -scheme "$SCHEME" \
    -configuration "$CONFIGURATION" \
    -archivePath "$ARCHIVE_PATH" \
    -destination "generic/platform=iOS" \
    -allowProvisioningUpdates \
    DEVELOPMENT_TEAM=N85286S93X \
    CODE_SIGN_STYLE=Automatic

if [ $? -ne 0 ]; then
    echo "❌ Archive failed"
    exit 1
fi

echo "✅ Archive created successfully"

# Create ExportOptions.plist
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
    <key>provisioningProfiles</key>
    <dict>
        <key>ru.tsum.lms.igor</key>
        <string>Automatic</string>
    </dict>
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

# Upload to App Store Connect
echo "🚀 Uploading to TestFlight..."
xcrun altool --upload-app \
    -f "$EXPORT_PATH/LMS.ipa" \
    -t ios \
    --apiKey "$APP_STORE_CONNECT_API_KEY_ID" \
    --apiIssuer "$APP_STORE_CONNECT_API_KEY_ISSUER_ID" \
    --verbose

if [ $? -ne 0 ]; then
    echo "❌ Upload failed"
    echo ""
    echo "Please check:"
    echo "1. API keys are set in environment variables"
    echo "2. AuthKey_${APP_STORE_CONNECT_API_KEY_ID}.p8 exists in ~/.private_keys/ or ./private_keys/"
    exit 1
fi

echo ""
echo "✅ Successfully uploaded to TestFlight!"
echo ""
echo "📱 Next steps:"
echo "1. Go to App Store Connect"
echo "2. Navigate to TestFlight section"
echo "3. Submit build for review if needed"
echo "4. Invite testers"
echo ""
echo "Build number: $BUILD_NUMBER" 