#!/bin/bash

echo "🚀 Alternative TestFlight Build Process"
echo "====================================="

# Clean everything first
echo "🧹 Deep cleaning..."
rm -rf ~/Library/Developer/Xcode/DerivedData/LMS-*
rm -rf DerivedData
rm -rf build

# Use previous working commit 
echo "📦 Using last known working commit..."
git stash
git checkout 2eaa210e # Last successful build commit

# Build archive
echo "🏗️ Building archive..."
xcodebuild archive \
    -scheme LMS \
    -archivePath build/LMS.xcarchive \
    -destination "generic/platform=iOS" \
    CODE_SIGN_STYLE=Automatic \
    DEVELOPMENT_TEAM=N85286S93X \
    -allowProvisioningUpdates

if [ $? -eq 0 ]; then
    echo "✅ Archive created successfully!"
    echo ""
    echo "📱 Next steps:"
    echo "1. Open Xcode"
    echo "2. Window → Organizer"
    echo "3. Select the archive"
    echo "4. Click 'Distribute App'"
    echo "5. Choose 'App Store Connect'"
    echo "6. Follow the wizard to upload"
else
    echo "❌ Archive failed"
    echo ""
    echo "Alternative: Use manual process in Xcode:"
    echo "1. Open LMS.xcodeproj"
    echo "2. Select 'Any iOS Device' as destination"
    echo "3. Product → Archive"
    echo "4. Follow the upload wizard"
fi 