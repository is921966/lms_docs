#!/bin/bash

echo "🚀 Manual TestFlight Build Script"
echo "================================"

# Configuration
SCHEME="LMS"
CONFIGURATION="Release"
BUNDLE_ID="ru.tsum.lms.igor"
TEAM_ID="N85286S93X"

# Clean
echo "🧹 Cleaning..."
rm -rf build/
xcodebuild clean -scheme $SCHEME -quiet

# Archive
echo "📦 Creating archive..."
xcodebuild archive \
    -scheme $SCHEME \
    -configuration $CONFIGURATION \
    -archivePath build/LMS.xcarchive \
    -destination "generic/platform=iOS" \
    -allowProvisioningUpdates \
    CODE_SIGN_STYLE=Automatic \
    DEVELOPMENT_TEAM=$TEAM_ID \
    PRODUCT_BUNDLE_IDENTIFIER=$BUNDLE_ID \
    -quiet || { echo "❌ Archive failed"; exit 1; }

echo "✅ Archive created successfully"

# Create ExportOptions.plist
echo "📝 Creating ExportOptions.plist..."
cat > build/ExportOptions.plist << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>destination</key>
    <string>export</string>
    <key>method</key>
    <string>app-store</string>
    <key>teamID</key>
    <string>$TEAM_ID</string>
    <key>uploadSymbols</key>
    <true/>
    <key>compileBitcode</key>
    <false/>
    <key>signingStyle</key>
    <string>automatic</string>
</dict>
</plist>
EOF

# Export IPA
echo "📲 Exporting IPA..."
xcodebuild -exportArchive \
    -archivePath build/LMS.xcarchive \
    -exportPath build \
    -exportOptionsPlist build/ExportOptions.plist \
    -allowProvisioningUpdates \
    -quiet || { echo "❌ Export failed"; exit 1; }

echo "✅ IPA exported successfully"

# Check results
if [ -f "build/LMS.ipa" ]; then
    echo "✅ Build successful!"
    echo ""
    echo "📱 IPA Location: $(pwd)/build/LMS.ipa"
    echo "📦 Archive Location: $(pwd)/build/LMS.xcarchive"
    echo ""
    echo "🚀 Next steps:"
    echo "1. Open Xcode"
    echo "2. Window → Organizer"
    echo "3. Select the archive"
    echo "4. Click 'Distribute App'"
    echo "5. Follow the upload wizard"
    echo ""
    echo "Or use command line:"
    echo "xcrun altool --upload-app --file build/LMS.ipa --type ios --apiKey <KEY_ID> --apiIssuer <ISSUER_ID>"
else
    echo "❌ Build failed - IPA not found"
    exit 1
fi 