#!/bin/bash

# Script to check installed provisioning profiles
echo "🔍 Checking Provisioning Profiles"
echo "=================================="

# Path to provisioning profiles
PROFILES_DIR=~/Library/MobileDevice/Provisioning\ Profiles

echo -e "\n📁 Provisioning profiles location:"
echo "$PROFILES_DIR"

if [ -d "$PROFILES_DIR" ]; then
    echo -e "\n📋 Installed profiles:"
    
    # Count profiles
    count=$(ls -1 "$PROFILES_DIR"/*.mobileprovision 2>/dev/null | wc -l)
    
    if [ $count -eq 0 ]; then
        echo "❌ No provisioning profiles found"
        echo ""
        echo "To install a profile:"
        echo "1. Download from Apple Developer Portal"
        echo "2. Double-click the .mobileprovision file"
        echo "3. Or drag it into Xcode"
    else
        echo "✅ Found $count provisioning profile(s):"
        echo ""
        
        # List profiles with details
        for profile in "$PROFILES_DIR"/*.mobileprovision; do
            if [ -f "$profile" ]; then
                # Extract profile name using security command
                name=$(security cms -D -i "$profile" 2>/dev/null | grep -A1 "<key>Name</key>" | tail -1 | sed 's/.*<string>\(.*\)<\/string>.*/\1/')
                uuid=$(basename "$profile" .mobileprovision)
                
                echo "  • $name"
                echo "    UUID: $uuid"
                echo ""
            fi
        done
    fi
else
    echo "❌ Provisioning profiles directory not found"
    echo "This might be a fresh Xcode installation"
fi

echo -e "\n🔧 To view in Xcode:"
echo "1. Open Xcode"
echo "2. Go to Window → Devices and Simulators"
echo "3. Right-click on your device → Show Provisioning Profiles"
echo ""
echo "Or for the project:"
echo "1. Open your project in Xcode"
echo "2. Select the project in navigator"
echo "3. Go to Signing & Capabilities tab"
echo "4. Check 'Automatically manage signing' or select profile manually" 