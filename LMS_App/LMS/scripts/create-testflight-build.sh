#!/bin/bash

# TestFlight Build Creation Script
# Usage: ./create-testflight-build.sh <version> <build_number>

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Arguments
VERSION=${1:-"2.2.0"}
BUILD_NUMBER=${2:-"213"}

echo -e "${GREEN}🚀 Creating TestFlight Build${NC}"
echo -e "Version: ${VERSION}"
echo -e "Build: ${BUILD_NUMBER}"
echo ""

# Update version and build number
echo -e "${YELLOW}📝 Updating version info...${NC}"
agvtool new-marketing-version ${VERSION}
agvtool new-version -all ${BUILD_NUMBER}

# Clean project
echo -e "${YELLOW}🧹 Cleaning project...${NC}"
xcodebuild clean -scheme LMS

# Create archive
echo -e "${YELLOW}📦 Creating archive...${NC}"
xcodebuild archive \
  -scheme LMS \
  -destination "generic/platform=iOS" \
  -archivePath ./build/LMS_v${VERSION}_b${BUILD_NUMBER}.xcarchive \
  CODE_SIGNING_REQUIRED=YES

# Check if archive was created
if [ ! -d "./build/LMS_v${VERSION}_b${BUILD_NUMBER}.xcarchive" ]; then
    echo -e "${RED}❌ Archive creation failed!${NC}"
    exit 1
fi

echo -e "${GREEN}✅ Archive created successfully!${NC}"

# Export IPA
echo -e "${YELLOW}📤 Exporting IPA...${NC}"
xcodebuild -exportArchive \
  -archivePath ./build/LMS_v${VERSION}_b${BUILD_NUMBER}.xcarchive \
  -exportPath ./build \
  -exportOptionsPlist ExportOptions.plist

# Check if IPA was created
if [ ! -f "./build/LMS.ipa" ]; then
    echo -e "${RED}❌ IPA export failed!${NC}"
    exit 1
fi

echo -e "${GREEN}✅ IPA exported successfully!${NC}"

# Create build info file
echo -e "${YELLOW}📄 Creating build info...${NC}"
cat > ./build/BUILD_INFO.txt << EOF
TestFlight Build Information
===========================
Version: ${VERSION}
Build: ${BUILD_NUMBER}
Date: $(date)
Archive: LMS_v${VERSION}_b${BUILD_NUMBER}.xcarchive
IPA: LMS.ipa

Next Steps:
1. Upload to App Store Connect using Xcode Organizer or Transporter
2. Wait for processing (usually 5-15 minutes)
3. Submit for TestFlight review if needed
4. Distribute to testers

Release Notes: See TESTFLIGHT_RELEASE_v${VERSION}_build${BUILD_NUMBER}.md
EOF

echo -e "${GREEN}✅ Build process completed!${NC}"
echo ""
echo -e "${YELLOW}📱 Next steps:${NC}"
echo "1. Open Xcode Organizer: open ./build/LMS_v${VERSION}_b${BUILD_NUMBER}.xcarchive"
echo "2. Click 'Distribute App'"
echo "3. Select 'App Store Connect'"
echo "4. Follow the upload wizard"
echo ""
echo -e "${GREEN}🎉 Build ${VERSION} (${BUILD_NUMBER}) is ready for TestFlight!${NC}" 