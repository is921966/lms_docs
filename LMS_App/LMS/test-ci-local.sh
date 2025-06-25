#!/bin/bash

echo "🧪 Running local CI tests..."

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Run tests
xcodebuild test \
  -project LMS.xcodeproj \
  -scheme LMS \
  -destination 'platform=iOS Simulator,name=iPhone 15,OS=17.5' \
  -configuration Debug \
  CODE_SIGN_IDENTITY="" \
  CODE_SIGNING_REQUIRED=NO \
  | xcpretty --test --color

if [ ${PIPESTATUS[0]} -eq 0 ]; then
    echo -e "${GREEN}✅ Tests passed!${NC}"
else
    echo -e "${RED}❌ Tests failed!${NC}"
    exit 1
fi 