#!/bin/bash

# Script to set unique build number based on timestamp
# This ensures no conflicts with App Store Connect

INFO_PLIST="LMS/App/Info.plist"

if [ ! -f "$INFO_PLIST" ]; then
    echo "❌ Error: Info.plist not found at $INFO_PLIST"
    exit 1
fi

# Generate unique build number based on timestamp
# Format: YYYYMMDDHHMMSS (e.g., 20250711171500)
NEW_BUILD=$(date +%Y%m%d%H%M%S)

# For shorter numbers, use days since epoch
# NEW_BUILD=$(( $(date +%s) / 86400 ))

echo "🔢 Setting build number to: $NEW_BUILD"

# Update Info.plist
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $NEW_BUILD" "$INFO_PLIST"

# Update project settings
sed -i '' "s/CURRENT_PROJECT_VERSION = [0-9]*;/CURRENT_PROJECT_VERSION = $NEW_BUILD;/g" LMS.xcodeproj/project.pbxproj

echo "✅ Build number set to $NEW_BUILD"
echo "📝 This guarantees uniqueness for App Store Connect" 