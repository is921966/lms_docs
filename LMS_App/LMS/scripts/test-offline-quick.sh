#!/bin/bash

# Sprint 42 Day 2 - Quick Offline Tests Runner
# Запускает только тесты офлайн функциональности

echo "🚀 Running Offline Tests..."
echo "========================="

# Change to LMS directory
cd "$(dirname "$0")/.." || exit 1

# Clean build folder to avoid issues
echo "🧹 Cleaning build folder..."
rm -rf ~/Library/Developer/Xcode/DerivedData/LMS-*/

# Run offline-specific tests
echo "🧪 Running Offline Statement Store Tests..."
xcodebuild test \
    -scheme LMS \
    -destination 'platform=iOS Simulator,name=iPhone 16' \
    -only-testing:LMSTests/OfflineStatementStoreTests \
    | xcbeautify --is-ci

echo "🧪 Running Sync Manager Tests..."
xcodebuild test \
    -scheme LMS \
    -destination 'platform=iOS Simulator,name=iPhone 16' \
    -only-testing:LMSTests/SyncManagerTests \
    | xcbeautify --is-ci

echo "🧪 Running Conflict Resolver Tests..."
xcodebuild test \
    -scheme LMS \
    -destination 'platform=iOS Simulator,name=iPhone 16' \
    -only-testing:LMSTests/ConflictResolverTests \
    | xcbeautify --is-ci

echo "✅ Offline tests complete!" 