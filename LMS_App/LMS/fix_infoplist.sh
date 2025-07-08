#!/bin/bash

echo "🔧 Fixing Info.plist duplication issue..."

cd "$(dirname "$0")"

# Backup the project file
cp LMS.xcodeproj/project.pbxproj LMS.xcodeproj/project.pbxproj.backup

# Replace GENERATE_INFOPLIST_FILE = YES with NO and add INFOPLIST_FILE path
sed -i '' 's/GENERATE_INFOPLIST_FILE = YES;/GENERATE_INFOPLIST_FILE = NO;\
				INFOPLIST_FILE = LMS\/App\/Info.plist;/g' LMS.xcodeproj/project.pbxproj

echo "✅ Updated project settings:"
echo "  - GENERATE_INFOPLIST_FILE = NO"
echo "  - INFOPLIST_FILE = LMS/App/Info.plist"

# Update version to 2.0.0 (remove -emergency)
sed -i '' 's/2.0.0-emergency/2.0.0/g' LMS/App/Info.plist

echo "✅ Updated version to 2.0.0"

# Clean DerivedData
echo "🧹 Cleaning DerivedData..."
rm -rf ~/Library/Developer/Xcode/DerivedData/LMS-*

echo "✅ Info.plist issue fixed!"
echo ""
echo "Next steps:"
echo "1. Test build locally: xcodebuild -scheme LMS -configuration Debug build"
echo "2. Commit changes"
echo "3. Push to trigger CI/CD" 