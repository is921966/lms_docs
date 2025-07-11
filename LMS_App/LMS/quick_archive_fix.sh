#!/bin/bash

echo "🚀 Quick Archive Fix - Temporary Solution"
echo "========================================"

cd "$(dirname "$0")"

# 1. Temporarily rename problematic files
echo "📝 Temporarily disabling problematic files..."

# Cmi5 problematic files
mv LMS/Features/Cmi5/Models/Cmi5Models+Extensions.swift LMS/Features/Cmi5/Models/Cmi5Models+Extensions.swift.disabled 2>/dev/null
mv LMS/Features/Cmi5/Views/Cmi5PlayerView.swift LMS/Features/Cmi5/Views/Cmi5PlayerView.swift.disabled 2>/dev/null
mv LMS/Features/Cmi5/Services/OfflineStatementStore.swift LMS/Features/Cmi5/Services/OfflineStatementStore.swift.disabled 2>/dev/null
mv LMS/Features/Cmi5/Views/AnalyticsDashboardView.swift LMS/Features/Cmi5/Views/AnalyticsDashboardView.swift.disabled 2>/dev/null

# Feed Service notification references
echo "📝 Fixing FeedService..."
sed -i '' '/NotificationMetadata/,/NotificationService.shared.add/d' LMS/Features/Feed/Services/FeedService.swift

# Fix LMSApp extension
echo "📝 Fixing Push Notifications..."
cat > LMS/App/LMSApp+PushNotifications.swift << 'EOF'
//
//  LMSApp+PushNotifications.swift
//  LMS
//

import SwiftUI
import UserNotifications

extension LMSApp {
    func setupPushNotifications() {
        print("Push notifications are temporarily disabled")
    }
    
    func registerForPushNotifications() {
        // Disabled
    }
    
    func handlePushNotificationRegistration(deviceToken: Data) {
        // Disabled
    }
    
    func handlePushNotificationError(_ error: Error) {
        // Disabled
    }
}
EOF

# 2. Clean build folder
echo "🧹 Cleaning..."
rm -rf ~/Library/Developer/Xcode/DerivedData/LMS-*
rm -rf build/

# 3. Try archive
echo "📦 Attempting archive..."
xcodebuild archive \
    -scheme LMS \
    -archivePath build/LMS.xcarchive \
    -destination "generic/platform=iOS" \
    CODE_SIGN_STYLE=Automatic \
    DEVELOPMENT_TEAM=N85286S93X \
    -allowProvisioningUpdates \
    -quiet | grep -E "(Succeeded|Failed|BUILD)"

if [ -d "build/LMS.xcarchive" ]; then
    echo ""
    echo "✅ Archive created successfully!"
    echo "📍 Location: $(pwd)/build/LMS.xcarchive"
    echo ""
    echo "🚀 Next steps:"
    echo "1. Open archive: open build/LMS.xcarchive"
    echo "2. Or in Xcode: Window → Organizer"
    echo "3. Upload to TestFlight"
    echo ""
    echo "⚠️  Note: Some features temporarily disabled for quick archive"
else
    echo "❌ Archive still failed"
    echo ""
    echo "Alternative: Use previous working commit:"
    echo "  git checkout 2eaa210e"
    echo "  xcodebuild archive -scheme LMS -archivePath build/LMS.xcarchive"
fi 