#!/bin/bash

echo "🔧 Final Info.plist fix..."

cd "$(dirname "$0")"

# 1. Clean everything first
echo "🧹 Deep cleaning..."
rm -rf ~/Library/Developer/Xcode/DerivedData/LMS-*
rm -rf build/
rm -rf DerivedData/

# 2. Backup project file
echo "💾 Backing up project file..."
cp LMS.xcodeproj/project.pbxproj LMS.xcodeproj/project.pbxproj.backup

# 3. Remove GENERATE_INFOPLIST_FILE and set INFOPLIST_FILE correctly
echo "📝 Fixing project settings..."

# Remove all GENERATE_INFOPLIST_FILE settings
sed -i '' '/GENERATE_INFOPLIST_FILE = YES;/d' LMS.xcodeproj/project.pbxproj

# Ensure INFOPLIST_FILE is set correctly
if ! grep -q "INFOPLIST_FILE = LMS/App/Info.plist;" LMS.xcodeproj/project.pbxproj; then
    # Add INFOPLIST_FILE after PRODUCT_NAME in each build configuration
    sed -i '' '/PRODUCT_NAME = LMS;/a\
				INFOPLIST_FILE = LMS/App/Info.plist;' LMS.xcodeproj/project.pbxproj
fi

# 4. Remove Info.plist from Copy Bundle Resources if it exists
echo "📝 Removing Info.plist from resources..."
python3 << 'EOF'
import re

with open('LMS.xcodeproj/project.pbxproj', 'r') as f:
    content = f.read()

# Find and remove Info.plist from resources
pattern = r'\s*[A-Z0-9]+ /\* Info\.plist in Resources \*/,?\s*\n'
content = re.sub(pattern, '', content)

with open('LMS.xcodeproj/project.pbxproj', 'w') as f:
    f.write(content)

print("✅ Removed Info.plist from resources")
EOF

# 5. Test with a simple build
echo "🧪 Testing build..."
xcodebuild -scheme LMS \
    -destination 'platform=iOS Simulator,name=iPhone 16' \
    -configuration Debug \
    build \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGN_IDENTITY="" \
    -quiet 2>&1 | grep -E "(BUILD SUCCEEDED|BUILD FAILED|error:)" | tail -10

echo ""
echo "✅ Info.plist fix completed!"
echo ""
echo "📱 Next: Try archiving again:"
echo "  xcodebuild archive -scheme LMS -archivePath build/LMS.xcarchive" 