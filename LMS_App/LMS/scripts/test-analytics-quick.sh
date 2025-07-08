#!/bin/bash

# Sprint 42 Day 3 - Quick Analytics Tests Runner
# Запускает только тесты аналитики и отчетов

echo "🚀 Running Analytics Tests..."
echo "========================="

# Change to LMS directory
cd "$(dirname "$0")/.." || exit 1

# Clean build folder to avoid issues
echo "🧹 Cleaning build folder..."
rm -rf ~/Library/Developer/Xcode/DerivedData/LMS-*/

# Run analytics-specific tests
echo "🧪 Running Analytics Collector Tests..."
xcodebuild test \
    -scheme LMS \
    -destination 'platform=iOS Simulator,name=iPhone 16' \
    -only-testing:LMSTests/AnalyticsCollectorTests \
    | xcbeautify --is-ci

echo "🧪 Running Report Generator Tests..."
xcodebuild test \
    -scheme LMS \
    -destination 'platform=iOS Simulator,name=iPhone 16' \
    -only-testing:LMSTests/ReportGeneratorTests \
    | xcbeautify --is-ci

echo "✅ Analytics tests complete!" 