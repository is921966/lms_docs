#!/bin/bash

# Script to increment build number in Info.plist
# Usage: ./increment-build-number.sh

INFO_PLIST="LMS/App/Info.plist"

if [ ! -f "$INFO_PLIST" ]; then
    echo "❌ Error: Info.plist not found at $INFO_PLIST"
    exit 1
fi

# Get current build number
CURRENT_BUILD=$(/usr/libexec/PlistBuddy -c "Print :CFBundleVersion" "$INFO_PLIST")
echo "📊 Current build number: $CURRENT_BUILD"

# Increment build number
NEW_BUILD=$((CURRENT_BUILD + 1))
echo "🔢 New build number: $NEW_BUILD"

# Update Info.plist
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $NEW_BUILD" "$INFO_PLIST"

# Also update project settings
sed -i '' "s/CURRENT_PROJECT_VERSION = $CURRENT_BUILD;/CURRENT_PROJECT_VERSION = $NEW_BUILD;/g" LMS.xcodeproj/project.pbxproj

echo "✅ Build number updated to $NEW_BUILD"
echo ""
echo "📝 Next steps:"
echo "1. Create archive in Xcode"
echo "2. Upload to App Store Connect"
echo "3. The build number should now be consistent" 