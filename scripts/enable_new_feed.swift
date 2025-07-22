#!/usr/bin/swift

import Foundation

let appBundleId = "ru.tsum.lms.igor"
let defaults = UserDefaults(suiteName: appBundleId) ?? UserDefaults.standard

print("🚀 Enabling New Feed Design")
print("========================")

// Set the flag to true
defaults.set(true, forKey: "useNewFeedDesign")
defaults.synchronize()

// Verify the change
let newValue = defaults.bool(forKey: "useNewFeedDesign")
print("✅ New Feed Design enabled: \(newValue)")

// Also check FeedDesignManager state
print("\n📋 Feed Design Status:")
print("  - useNewFeedDesign: \(newValue ? "✅ Enabled" : "❌ Disabled")")

// Force sync
CFPreferencesAppSynchronize(kCFPreferencesCurrentApplication)

print("\n🎉 New feed design is now active!")
print("   Restart the app to see the changes.") 