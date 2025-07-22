#!/bin/bash

# Build script for LMS v3
set -e

echo "🚀 Building LMS v3..."

# Create Xcode project from SPM
echo "📦 Creating Xcode project..."
swift package generate-xcodeproj

# Open in Xcode
echo "📱 Opening in Xcode..."
open LMS.xcodeproj

echo "✅ Project created!"
echo ""
echo "To build and run:"
echo "1. Select LMS scheme"
echo "2. Select a simulator"
echo "3. Press Cmd+R to run"
echo ""
echo "Alternative: Build from command line:"
echo "xcodebuild -scheme LMS -destination 'platform=iOS Simulator,name=iPhone 16' build" 