#!/bin/bash

# Script to get next build number for TestFlight
# Uses a simple incremental counter stored in a file

BUILD_NUMBER_FILE="$HOME/.lms_build_number"

# Initialize if file doesn't exist
if [ ! -f "$BUILD_NUMBER_FILE" ]; then
    # Start from 100 to have nice 3-digit numbers
    echo "100" > "$BUILD_NUMBER_FILE"
fi

# Read current build number
CURRENT_BUILD=$(cat "$BUILD_NUMBER_FILE")

# Get the action (get or increment)
ACTION="${1:-get}"

case "$ACTION" in
    get)
        echo "$CURRENT_BUILD"
        ;;
    increment)
        # Increment and save
        NEXT_BUILD=$((CURRENT_BUILD + 1))
        echo "$NEXT_BUILD" > "$BUILD_NUMBER_FILE"
        echo "$NEXT_BUILD"
        ;;
    set)
        # Set specific build number
        if [ -z "$2" ]; then
            echo "Error: Please provide build number to set"
            exit 1
        fi
        echo "$2" > "$BUILD_NUMBER_FILE"
        echo "$2"
        ;;
    reset)
        # Reset to 100
        echo "100" > "$BUILD_NUMBER_FILE"
        echo "100"
        ;;
    *)
        echo "Usage: $0 [get|increment|set <number>|reset]"
        echo "  get       - Get current build number (default)"
        echo "  increment - Increment and return new build number"
        echo "  set <num> - Set specific build number"
        echo "  reset     - Reset to 100"
        exit 1
        ;;
esac 