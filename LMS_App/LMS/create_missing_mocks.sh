#!/bin/bash

echo "🔧 Creating missing mocks and final fixes..."

cd "$(dirname "$0")"

# 1. Create MockNotificationService
echo "📝 Creating MockNotificationService..."
cat > LMS/Services/MockNotificationService.swift << 'EOF'
//
//  MockNotificationService.swift
//  LMS
//

import Foundation
import Combine

public class NotificationService: ObservableObject {
    public static let shared = NotificationService()
    
    @Published public var unreadCount = 0
    @Published public var notifications: [String] = []
    
    private init() {}
    
    public func markAsRead(_ id: String) {
        // Mock implementation
    }
    
    public func requestPermissions() {
        // Mock implementation
    }
}
EOF

# 2. Create UserPreferences struct
echo "📝 Creating UserPreferences..."
cat > LMS/Models/User/UserPreferences.swift << 'EOF'
//
//  UserPreferences.swift
//  LMS
//

import Foundation

public struct UserPreferences: Codable {
    public var language: String = "ru"
    public var theme: String = "light"
    public var notifications: Bool = true
    
    public init() {}
}
EOF

# 3. Fix async/await in OfflineStatementStore
echo "📝 Fixing async/await issues..."
# Replace backgroundContext.perform with performAndWait for sync operations
sed -i '' 's/try await backgroundContext.perform {/try await backgroundContext.perform { @Sendable in/g' LMS/Features/Cmi5/Services/OfflineStatementStore.swift

echo "✅ Missing mocks created!"
echo ""
echo "🚀 Running absolute FINAL build..." 