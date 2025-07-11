#!/bin/bash

# Script to fix Info.plist duplication issue in LMS project

echo "🔧 Fixing Info.plist duplication issue..."

PROJECT_FILE="LMS_App/LMS/LMS.xcodeproj/project.pbxproj"

# Backup project file
cp "$PROJECT_FILE" "$PROJECT_FILE.backup"
echo "✅ Created backup: $PROJECT_FILE.backup"

# Function to update build settings for a target
update_target_settings() {
    local target_name=$1
    echo "📝 Updating settings for target: $target_name"
    
    # Find the build configuration section for the target and update it
    # This is a simplified approach - in production, use a proper pbxproj parser
    
    # For now, let's create a Python script to properly update the project file
    cat > update_pbxproj.py << 'EOF'
import re
import sys

def update_project_file(filename):
    with open(filename, 'r') as f:
        content = f.read()
    
    # Pattern to find build settings blocks
    pattern = r'(buildSettings = \{[^}]+GENERATE_INFOPLIST_FILE = YES;[^}]+\})'
    
    def replace_settings(match):
        settings = match.group(1)
        
        # Add INFOPLIST_FILE if it's the main app target (has CFBundleDisplayName)
        if 'INFOPLIST_KEY_CFBundleDisplayName' in settings:
            # Replace GENERATE_INFOPLIST_FILE = YES with NO
            settings = settings.replace('GENERATE_INFOPLIST_FILE = YES;', 'GENERATE_INFOPLIST_FILE = NO;')
            
            # Add INFOPLIST_FILE setting if not present
            if 'INFOPLIST_FILE = ' not in settings:
                # Insert after GENERATE_INFOPLIST_FILE
                settings = settings.replace(
                    'GENERATE_INFOPLIST_FILE = NO;',
                    'GENERATE_INFOPLIST_FILE = NO;\n\t\t\t\tINFOPLIST_FILE = "LMS/App/Info.plist";'
                )
        
        return settings
    
    # Replace all occurrences
    updated_content = re.sub(pattern, replace_settings, content, flags=re.DOTALL)
    
    # Write back
    with open(filename, 'w') as f:
        f.write(updated_content)
    
    print("✅ Updated project file")

if __name__ == "__main__":
    update_project_file(sys.argv[1])
EOF

    python3 update_pbxproj.py "$PROJECT_FILE"
    rm update_pbxproj.py
}

# Update the main app target
update_target_settings "LMS"

# Remove any duplicate Info.plist in the root LMS folder
if [ -f "LMS_App/LMS/LMS/Info.plist" ]; then
    echo "🗑️  Removing duplicate Info.plist from LMS root folder..."
    rm "LMS_App/LMS/LMS/Info.plist"
    echo "✅ Removed duplicate Info.plist"
fi

echo "✅ Info.plist duplication issue fixed!"
echo ""
echo "📌 Next steps:"
echo "1. Open the project in Xcode"
echo "2. Clean build folder (Cmd+Shift+K)"
echo "3. Build the project to verify the fix"
echo ""
echo "ℹ️  The project now uses: LMS/App/Info.plist" 