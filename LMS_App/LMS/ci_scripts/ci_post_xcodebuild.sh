#!/bin/sh

# Xcode Cloud Post-Build Script
# This script runs after Xcode Cloud completes the build

set -e  # Exit on error

echo "📊 Post-build script started..."
echo "🎯 Action: $CI_XCODEBUILD_ACTION"
echo "📱 Product: $CI_PRODUCT"
echo "📁 Archive Path: $CI_ARCHIVE_PATH"

# Check if build succeeded
if [ "$CI_XCODEBUILD_EXIT_CODE" != "0" ]; then
    echo "❌ Build failed with exit code: $CI_XCODEBUILD_EXIT_CODE"
    exit 0  # Don't fail the workflow
fi

# For archive builds, collect metrics
if [ "$CI_XCODEBUILD_ACTION" = "archive" ]; then
    echo "📏 Collecting build metrics..."
    
    # Get app size
    if [ -d "$CI_ARCHIVE_PATH" ]; then
        APP_SIZE=$(du -sh "$CI_ARCHIVE_PATH" | cut -f1)
        echo "📱 Archive size: $APP_SIZE"
        
        # Get IPA size if available
        IPA_PATH="$CI_ARCHIVE_PATH/Products/Applications/LMS.app"
        if [ -d "$IPA_PATH" ]; then
            IPA_SIZE=$(du -sh "$IPA_PATH" | cut -f1)
            echo "📦 App size: $IPA_SIZE"
        fi
    fi
    
    # Generate build report
    echo "📝 Generating build report..."
    cat > "$CI_DERIVED_DATA_PATH/build_report.txt" << EOF
Build Report - Xcode Cloud
========================
Date: $(date)
Build Number: $CI_BUILD_NUMBER
Branch: $CI_BRANCH
Commit: $CI_COMMIT
Archive Size: $APP_SIZE
App Size: $IPA_SIZE
Duration: $CI_XCODEBUILD_DURATION seconds
EOF

    # Upload dSYMs to crash reporting service (if configured)
    DSYM_PATH="$CI_ARCHIVE_PATH/dSYMs"
    if [ -d "$DSYM_PATH" ]; then
        echo "🔍 Found dSYMs at: $DSYM_PATH"
        # Example: Upload to Crashlytics/Sentry
        # ./upload_dsyms.sh "$DSYM_PATH"
    fi
fi

# For test action, process results
if [ "$CI_XCODEBUILD_ACTION" = "test" ]; then
    echo "🧪 Processing test results..."
    
    # Check test results
    if [ -f "$CI_RESULT_BUNDLE_PATH/TestSummaries.plist" ]; then
        # Extract test summary (simplified)
        echo "📊 Test summary available at: $CI_RESULT_BUNDLE_PATH"
        
        # You can use PlistBuddy or other tools to parse results
        # Example: /usr/libexec/PlistBuddy -c "Print :TestableSummaries:0:Tests" "$CI_RESULT_BUNDLE_PATH/TestSummaries.plist"
    fi
fi

# Send notifications (example)
if [ -n "$SLACK_WEBHOOK_URL" ]; then
    echo "📢 Sending Slack notification..."
    
    MESSAGE="Build #$CI_BUILD_NUMBER completed on branch $CI_BRANCH"
    if [ "$CI_XCODEBUILD_ACTION" = "archive" ]; then
        MESSAGE="$MESSAGE - Archive size: $APP_SIZE"
    fi
    
    # curl -X POST -H 'Content-type: application/json' \
    #     --data "{\"text\":\"$MESSAGE\"}" \
    #     "$SLACK_WEBHOOK_URL"
fi

echo "✅ Post-build script completed!" 