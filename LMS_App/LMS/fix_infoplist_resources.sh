#!/bin/bash

echo "🔧 Removing Info.plist from Copy Bundle Resources..."

cd "$(dirname "$0")"

# Create a Python script to remove Info.plist from resources
cat > remove_infoplist.py << 'EOF'
import re

# Read the project file
with open('LMS.xcodeproj/project.pbxproj', 'r') as f:
    content = f.read()

# Find the PBXResourcesBuildPhase section
resources_pattern = r'(/\* Resources \*/.*?files = \(.*?\);)'
resources_match = re.search(resources_pattern, content, re.DOTALL)

if resources_match:
    resources_section = resources_match.group(0)
    # Remove Info.plist reference from resources
    # Look for line like: XXXXXXXXX /* Info.plist in Resources */,
    info_plist_pattern = r'\s*[A-Z0-9]+ /\* Info\.plist in Resources \*/,?\s*'
    updated_section = re.sub(info_plist_pattern, '', resources_section)
    
    # Replace in content
    content = content.replace(resources_section, updated_section)
    
    # Write back
    with open('LMS.xcodeproj/project.pbxproj', 'w') as f:
        f.write(content)
    
    print("✅ Removed Info.plist from Copy Bundle Resources")
else:
    print("❌ Could not find Resources section")
EOF

# Run the Python script
python3 remove_infoplist.py

# Clean up
rm remove_infoplist.py

echo "✅ Info.plist resource reference removed!"
echo ""
echo "Testing build again..." 