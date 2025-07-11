#!/bin/bash
xcodebuild -scheme LMS \
    -destination 'platform=iOS Simulator,name=iPhone 16' \
    -configuration Debug \
    -derivedDataPath ./DerivedData \
    clean build \
    CODE_SIGNING_REQUIRED=NO \
    CODE_SIGN_IDENTITY="" \
    EXCLUDED_SOURCE_FILE_NAMES="Info.plist" 2>&1 | tail -50
