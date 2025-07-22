#!/bin/bash

# TestFlight Release Script
set -e

VERSION="2.4.0"
BUILD_NUMBER="210"
SCHEME="LMS"
CONFIGURATION="Release"

echo "🚀 Starting TestFlight Release v${VERSION} (${BUILD_NUMBER})"
echo "============================================"

# Step 1: Update version and build number
echo ""
echo "📝 Updating version numbers..."
cd LMS
agvtool new-marketing-version ${VERSION}
agvtool new-version -all ${BUILD_NUMBER}

# Step 2: Run tests
echo ""
echo "🧪 Running tests..."
xcodebuild test \
  -scheme ${SCHEME} \
  -destination 'platform=iOS Simulator,name=iPhone 14' \
  -configuration ${CONFIGURATION} \
  CODE_SIGN_IDENTITY="" \
  CODE_SIGNING_REQUIRED=NO

# Step 3: Archive
echo ""
echo "📦 Creating archive..."
xcodebuild archive \
  -scheme ${SCHEME} \
  -configuration ${CONFIGURATION} \
  -archivePath "../build/${SCHEME}-${VERSION}.xcarchive" \
  -destination 'generic/platform=iOS' \
  DEVELOPMENT_TEAM="YOUR_TEAM_ID" \
  CODE_SIGN_STYLE="Automatic"

# Step 4: Export IPA
echo ""
echo "📱 Exporting IPA..."
xcodebuild -exportArchive \
  -archivePath "../build/${SCHEME}-${VERSION}.xcarchive" \
  -exportPath "../build" \
  -exportOptionsPlist "../ExportOptions.plist"

# Step 5: Upload to TestFlight
echo ""
echo "☁️ Uploading to TestFlight..."
xcrun altool --upload-app \
  -f "../build/${SCHEME}.ipa" \
  -t ios \
  -u "developer@tsum.ru" \
  -p "@keychain:AC_PASSWORD" \
  --verbose

# Step 6: Tag release
echo ""
echo "🏷️ Creating git tag..."
git add .
git commit -m "Release v${VERSION} (${BUILD_NUMBER})"
git tag -a "v${VERSION}" -m "TestFlight Release v${VERSION}"
git push origin main --tags

echo ""
echo "✅ TestFlight release completed!"
echo ""
echo "Next steps:"
echo "1. Go to App Store Connect"
echo "2. Add release notes from docs/releases/TESTFLIGHT_RELEASE_v${VERSION}.md"
echo "3. Submit for TestFlight review"
echo "4. Notify beta testers"
echo ""
echo "Release notes location:"
echo "docs/releases/TESTFLIGHT_RELEASE_v${VERSION}.md" 