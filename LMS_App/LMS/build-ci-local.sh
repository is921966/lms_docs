#!/bin/bash

echo "🔨 Building app locally..."

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Clean
echo -e "${YELLOW}Cleaning build folder...${NC}"
rm -rf build

# Build archive
echo -e "${YELLOW}Building archive...${NC}"
xcodebuild archive \
  -project LMS.xcodeproj \
  -scheme LMS \
  -configuration Release \
  -archivePath build/LMS.xcarchive \
  -allowProvisioningUpdates \
  DEVELOPMENT_TEAM=N85286S93X \
  PRODUCT_BUNDLE_IDENTIFIER=ru.tsum.lms.igor \
  | xcpretty

if [ ${PIPESTATUS[0]} -eq 0 ]; then
    echo -e "${GREEN}✅ Archive created successfully!${NC}"
else
    echo -e "${RED}❌ Archive creation failed!${NC}"
    exit 1
fi

# Create export options
echo -e "${YELLOW}Creating export options...${NC}"
cat > ExportOptions.plist <<EOF
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
    <key>uploadBitcode</key>
    <false/>
    <key>signingStyle</key>
    <string>automatic</string>
</dict>
</plist>
EOF

# Export IPA
echo -e "${YELLOW}Exporting IPA...${NC}"
xcodebuild -exportArchive \
  -archivePath build/LMS.xcarchive \
  -exportPath build \
  -exportOptionsPlist ExportOptions.plist \
  -allowProvisioningUpdates \
  | xcpretty

if [ ${PIPESTATUS[0]} -eq 0 ]; then
    echo -e "${GREEN}✅ IPA exported successfully!${NC}"
    echo -e "${GREEN}📦 IPA location: build/LMS.ipa${NC}"
else
    echo -e "${RED}❌ IPA export failed!${NC}"
    exit 1
fi 