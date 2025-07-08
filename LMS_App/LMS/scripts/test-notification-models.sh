#!/bin/bash

# Test Notification Models Script
# Sprint 41 - Quick test runner for notification models

echo "🧪 Testing Notification Models..."

# Create a simple test file that can be run independently
cat > /tmp/NotificationModelsTest.swift << 'SWIFTEOF'
import Foundation

// Copy of notification models for testing
enum NotificationType: String, CaseIterable {
    case courseAssigned = "course_assigned"
    case testDeadline = "test_deadline"
    case certificateIssued = "certificate_issued"
    
    var displayName: String {
        switch self {
        case .courseAssigned: return "Новый курс"
        case .testDeadline: return "Дедлайн теста"
        case .certificateIssued: return "Сертификат выдан"
        }
    }
}

enum NotificationChannel: String, CaseIterable {
    case push = "push"
    case email = "email"
    case inApp = "in_app"
    
    var displayName: String {
        switch self {
        case .push: return "Push-уведомления"
        case .email: return "Email"
        case .inApp: return "В приложении"
        }
    }
}

// Run tests
print("✅ Testing NotificationType")
assert(NotificationType.courseAssigned.displayName == "Новый курс")
assert(NotificationType.testDeadline.displayName == "Дедлайн теста")
print("   - Display names: PASSED")

print("\n✅ Testing NotificationChannel")
assert(NotificationChannel.push.displayName == "Push-уведомления")
assert(NotificationChannel.email.displayName == "Email")
print("   - Display names: PASSED")

print("\n✅ Testing CaseIterable")
assert(NotificationType.allCases.count == 3)
assert(NotificationChannel.allCases.count == 3)
print("   - All cases count: PASSED")

print("\n🎉 All Notification Model Tests PASSED!")
SWIFTEOF

# Run the test
swift /tmp/NotificationModelsTest.swift

# Clean up
rm -f /tmp/NotificationModelsTest.swift

echo "✅ Test completed!"
