#!/bin/bash

# Create temporary app icons using system tools
echo "Creating temporary app icons..."

# Create a simple icon using sips (built-in macOS tool)
# First, create a base 1024x1024 image

# Create a temporary directory
mkdir -p temp_icons

# Generate a simple colored square with "LMS" text using osascript
osascript <<EOF
tell application "Preview"
    activate
end tell
EOF

# Alternative: Create icons using Python (which is built-in on macOS)
python3 << 'PYTHON_SCRIPT'
from PIL import Image, ImageDraw, ImageFont
import os

# Create directory for icons
os.makedirs("LMS/Assets.xcassets/AppIcon.appiconset", exist_ok=True)

# Define all required icon sizes
icon_sizes = [
    (20, 1), (20, 2), (20, 3),      # 20pt
    (29, 1), (29, 2), (29, 3),      # 29pt  
    (40, 1), (40, 2), (40, 3),      # 40pt
    (60, 2), (60, 3),               # 60pt
    (76, 1), (76, 2),               # 76pt  
    (83.5, 2),                      # 83.5pt
    (120, 2), (120, 3),             # 120pt (required)
    (152, 2),                       # 152pt (required)
    (167, 2),                       # 167pt
    (180, 3),                       # 180pt
    (1024, 1)                       # App Store
]

# Create base image
for base_size, scale in icon_sizes:
    size = int(base_size * scale)
    
    # Create image with blue background
    img = Image.new('RGB', (size, size), color='#007AFF')
    
    # Add text
    draw = ImageDraw.Draw(img)
    
    # Try to use a font (fallback to default if not available)
    try:
        # Adjust font size based on icon size
        font_size = size // 3
        font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", font_size)
    except:
        font = None
    
    # Draw text
    text = "LMS"
    if font:
        bbox = draw.textbbox((0, 0), text, font=font)
        text_width = bbox[2] - bbox[0]
        text_height = bbox[3] - bbox[1]
    else:
        text_width = size // 2
        text_height = size // 3
    
    position = ((size - text_width) // 2, (size - text_height) // 2)
    draw.text(position, text, fill='white', font=font)
    
    # Save icon
    if scale == 1:
        filename = f"Icon-{int(base_size)}.png"
    else:
        filename = f"Icon-{int(base_size)}@{int(scale)}x.png"
    
    filepath = f"LMS/Assets.xcassets/AppIcon.appiconset/{filename}"
    img.save(filepath, "PNG")
    print(f"Created: {filename}")

print("All icons created successfully!")
PYTHON_SCRIPT

# Check if Python failed and provide alternative
if [ $? -ne 0 ]; then
    echo "Python PIL not available. Creating basic icons..."
    
    # Create a basic 1024x1024 blue square using built-in tools
    # This is a base64 encoded 1x1 blue pixel that we'll resize
    echo "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==" | base64 -D > temp_pixel.png
    
    # Resize to different sizes
    sips -z 120 120 temp_pixel.png --out LMS/Assets.xcassets/AppIcon.appiconset/Icon-60@2x.png
    sips -z 180 180 temp_pixel.png --out LMS/Assets.xcassets/AppIcon.appiconset/Icon-60@3x.png
    sips -z 152 152 temp_pixel.png --out LMS/Assets.xcassets/AppIcon.appiconset/Icon-76@2x.png
    sips -z 167 167 temp_pixel.png --out LMS/Assets.xcassets/AppIcon.appiconset/Icon-83.5@2x.png
    sips -z 1024 1024 temp_pixel.png --out LMS/Assets.xcassets/AppIcon.appiconset/Icon-1024.png
    
    rm temp_pixel.png
fi

echo "Icons created. Now updating Contents.json..." 