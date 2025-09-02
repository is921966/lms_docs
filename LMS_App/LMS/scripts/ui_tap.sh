#!/bin/bash

# UI Tap Script
# Usage: ./ui_tap.sh X Y

X=$1
Y=$2

if [ -z "$X" ] || [ -z "$Y" ]; then
    echo "Usage: $0 X Y"
    exit 1
fi

# Get the active device
DEVICE=$(xcrun simctl list devices | grep "Booted" | head -1 | grep -o 'iPhone[^)]*' | head -1)

if [ -z "$DEVICE" ]; then
    echo "Error: No booted simulator found"
    exit 1
fi

echo "Tapping at ($X, $Y) on $DEVICE..."
xcrun simctl io "$DEVICE" tap $X $Y 