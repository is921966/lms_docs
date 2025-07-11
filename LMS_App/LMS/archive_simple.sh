#!/bin/bash

echo "🚀 Simple Archive Process"
echo "======================="

# Clean first
xcodebuild clean -scheme LMS -quiet

# Archive with minimal options
xcodebuild archive \
    -scheme LMS \
    -archivePath build/LMS.xcarchive \
    -destination "generic/platform=iOS" \
    CODE_SIGN_STYLE=Automatic \
    DEVELOPMENT_TEAM=N85286S93X \
    -allowProvisioningUpdates \
    GCC_PREPROCESSOR_DEFINITIONS='$GCC_PREPROCESSOR_DEFINITIONS DEBUG=1' \
    SWIFT_ACTIVE_COMPILATION_CONDITIONS='DEBUG' \
    -quiet

if [ -d "build/LMS.xcarchive" ]; then
    echo "✅ Archive created successfully!"
    echo "📱 Location: $(pwd)/build/LMS.xcarchive"
    echo ""
    echo "Next steps:"
    echo "1. Open Xcode"
    echo "2. Window → Organizer"
    echo "3. Or open directly: open build/LMS.xcarchive"
else
    echo "❌ Archive failed"
fi
