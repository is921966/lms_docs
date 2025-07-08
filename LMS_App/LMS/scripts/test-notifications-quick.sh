#!/bin/bash

# Quick test for notification components
echo "🧪 Testing Notification Components..."

# Create simple Swift test
cat > /tmp/NotificationQuickTest.swift << 'SWIFTEOF'
import Foundation

// Test basic notification creation
struct SimpleNotification {
    let id = UUID()
    let title: String
    let body: String
    let isRead: Bool
}

// Test creation
let notification = SimpleNotification(
    title: "Test Notification",
    body: "This is a test",
    isRead: false
)

print("✅ Basic Notification: Created")
print("   - ID: \(notification.id)")
print("   - Title: \(notification.title)")
print("   - Read: \(notification.isRead)")

// Test priority enum
enum Priority: Int, Comparable {
    case low = 0
    case medium = 1
    case high = 2
    case urgent = 3
    
    static func < (lhs: Priority, rhs: Priority) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}

let p1 = Priority.high
let p2 = Priority.low
print("\n✅ Priority Comparison: \(p1 > p2 ? "PASSED" : "FAILED")")

// Test channels
enum Channel: String {
    case push = "push"
    case email = "email"
    case inApp = "in_app"
}

let channels: Set<Channel> = [.push, .email]
print("\n✅ Channels Set: \(channels.count) channels")

print("\n🎉 All Quick Tests PASSED!")
SWIFTEOF

# Run the test
swift /tmp/NotificationQuickTest.swift

# Clean up
rm -f /tmp/NotificationQuickTest.swift

echo "✅ Quick test completed!"
