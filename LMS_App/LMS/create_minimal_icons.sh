#!/bin/bash

echo "Creating minimal icon set..."

# Create a simple blue square PNG using base64
# This is a 1x1 blue pixel that we'll resize
BLUE_PIXEL="iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg=="

# Decode the blue pixel
echo $BLUE_PIXEL | base64 -d > temp_blue.png

# Create required icons
echo "Creating 120x120 icon..."
sips -z 120 120 temp_blue.png --out LMS/Assets.xcassets/AppIcon.appiconset/Icon-120.png

echo "Creating 152x152 icon..."
sips -z 152 152 temp_blue.png --out LMS/Assets.xcassets/AppIcon.appiconset/Icon-152.png

echo "Creating 1024x1024 icon..."
sips -z 1024 1024 temp_blue.png --out LMS/Assets.xcassets/AppIcon.appiconset/Icon-1024.png

# Clean up
rm temp_blue.png

echo "Basic icons created!" 