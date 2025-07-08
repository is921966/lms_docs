#!/bin/bash

echo "🔧 Final visibility fixes..."

cd "$(dirname "$0")"

# 1. Fix protocols in SyncManager
echo "📝 Making SyncManager protocols public..."
sed -i '' 's/^protocol StatementProcessorProtocol/public protocol StatementProcessorProtocol/g' LMS/Features/Cmi5/Services/SyncManager.swift
sed -i '' 's/^protocol NetworkMonitorProtocol/public protocol NetworkMonitorProtocol/g' LMS/Features/Cmi5/Services/SyncManager.swift

# 2. Fix XAPIStatement type if needed
echo "📝 Making XAPIStatement public..."
sed -i '' 's/^struct XAPIStatement/public struct XAPIStatement/g' LMS/Features/Cmi5/Models/XAPIModels.swift

# 3. Clean up NotificationService warnings
echo "📝 Cleaning up Notifications module..."
# Move disabled notifications out of compilation
mkdir -p LMS/Features/Notifications.disabled.backup
mv LMS/Features/Notifications.disabled/* LMS/Features/Notifications.disabled.backup/ 2>/dev/null || true

echo "✅ Final visibility fixes applied!"
echo ""
echo "🏗️ Running final build..."
rm -rf DerivedData/ 