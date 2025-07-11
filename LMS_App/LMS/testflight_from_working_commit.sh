#!/bin/bash

echo "🚀 TestFlight Build from Last Working Commit"
echo "==========================================="

# Save current work
echo "💾 Saving current work..."
git stash push -m "Temporary stash for TestFlight build"

# Checkout last known working commit
echo "📝 Switching to last working commit..."
git checkout 2eaa210e

# Clean everything
echo "🧹 Cleaning..."
rm -rf ~/Library/Developer/Xcode/DerivedData/LMS-*
rm -rf build/

# Archive
echo "📦 Building archive..."
xcodebuild archive \
    -scheme LMS \
    -archivePath build/LMS.xcarchive \
    -destination "generic/platform=iOS" \
    CODE_SIGN_STYLE=Automatic \
    DEVELOPMENT_TEAM=N85286S93X \
    -allowProvisioningUpdates \
    -quiet | tail -20

if [ -d "build/LMS.xcarchive" ]; then
    echo ""
    echo "✅ Archive created successfully!"
    
    # Export for App Store
    echo "📤 Exporting for App Store..."
    
    cat > ExportOptions.plist << 'EOF'
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
    <key>uploadBitcode</key>
    <false/>
    <key>compileBitcode</key>
    <false/>
    <key>generateAppStoreInformation</key>
    <true/>
</dict>
</plist>
EOF

    xcodebuild -exportArchive \
        -archivePath build/LMS.xcarchive \
        -exportPath build/export \
        -exportOptionsPlist ExportOptions.plist \
        -quiet
    
    if [ -f "build/export/LMS.ipa" ]; then
        echo "✅ IPA exported successfully!"
        echo ""
        echo "🚀 Ready for TestFlight upload!"
        echo "📍 IPA location: $(pwd)/build/export/LMS.ipa"
        echo ""
        echo "Upload options:"
        echo "1. Open archive in Xcode: open build/LMS.xcarchive"
        echo "2. Use Transporter app: open build/export/LMS.ipa"
        echo "3. Use altool (requires app-specific password)"
    else
        echo "❌ Export failed"
    fi
else
    echo "❌ Archive failed"
fi

echo ""
echo "🔄 Returning to original branch..."
git checkout -
git stash pop

echo ""
echo "✅ Done!" 