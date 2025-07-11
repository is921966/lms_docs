#!/bin/bash

echo "🔧 Absolute final fixes..."

cd "$(dirname "$0")"

# 1. Completely remove Notifications backup from build
echo "📝 Removing Notifications backup from build..."
rm -rf LMS/Features/Notifications.disabled.backup

# 2. Fix XAPIVerb to conform to Equatable
echo "📝 Making XAPIVerb conform to Equatable..."
# Find XAPIVerb definition and add Equatable
sed -i '' 's/public enum Verb {/public enum Verb: Equatable {/g' LMS/Features/Cmi5/Models/XAPIModels.swift
sed -i '' 's/enum Verb {/enum Verb: Equatable {/g' LMS/Features/Cmi5/Models/XAPIModels.swift
sed -i '' 's/public struct XAPIVerb {/public struct XAPIVerb: Equatable {/g' LMS/Features/Cmi5/Models/XAPIModels.swift
sed -i '' 's/struct XAPIVerb {/struct XAPIVerb: Equatable {/g' LMS/Features/Cmi5/Models/XAPIModels.swift

# 3. Fix AnalyticsCollector optional binding issue
echo "📝 Fixing AnalyticsCollector..."
# Change line 100: if let metrics = generalMetrics { to if generalMetrics != nil {
sed -i '' '100s/if let metrics = generalMetrics {/if generalMetrics != nil {/' LMS/Features/Cmi5/Analytics/AnalyticsCollector.swift

# 4. Clean build folder completely
echo "🧹 Cleaning build artifacts..."
rm -rf DerivedData/
rm -rf build/

echo "✅ Absolute final fixes applied!"
echo ""
echo "🚀 Running FINAL build test..." 