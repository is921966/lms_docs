#!/usr/bin/env python3
"""
Remove Info.plist from Copy Bundle Resources in Xcode project
"""

import re
import sys

def remove_info_plist_from_resources(project_file):
    """Remove Info.plist from Copy Bundle Resources build phase"""
    
    with open(project_file, 'r') as f:
        content = f.read()
    
    # Find all file references
    file_refs = {}
    pattern = r'([A-Z0-9]+) /\* (.+?) \*/ = \{isa = PBXFileReference'
    for match in re.finditer(pattern, content):
        file_id, file_name = match.groups()
        file_refs[file_name] = file_id
    
    # Find Info.plist reference
    info_plist_id = None
    for name, ref_id in file_refs.items():
        if 'Info.plist' in name and 'App/Info.plist' in name:
            info_plist_id = ref_id
            print(f"Found Info.plist reference: {ref_id} /* {name} */")
            break
    
    if not info_plist_id:
        print("❌ Could not find Info.plist reference")
        return False
    
    # Find and remove from PBXResourcesBuildPhase
    removed = False
    
    # Pattern to find the file in resources build phase
    resource_pattern = rf'\s*{info_plist_id}\s*/\*[^*]+\*/\s*in\s+Resources\s*\*/,?\s*\n?'
    
    # Remove the reference
    new_content, count = re.subn(resource_pattern, '', content)
    
    if count > 0:
        removed = True
        print(f"✅ Removed {count} reference(s) to Info.plist from Resources")
    
    # Also check for simpler format without "in Resources"
    if not removed:
        resource_pattern2 = rf'\s*{info_plist_id}\s*/\*[^*]+\*/,?\s*\n?'
        # Find within PBXResourcesBuildPhase sections
        sections = re.finditer(r'isa = PBXResourcesBuildPhase;.*?files = \((.*?)\);', content, re.DOTALL)
        
        for section in sections:
            section_content = section.group(1)
            if info_plist_id in section_content:
                # Remove from this section
                updated_section = re.sub(resource_pattern2, '', section_content)
                if updated_section != section_content:
                    new_content = content.replace(section_content, updated_section)
                    removed = True
                    print("✅ Removed Info.plist from Copy Bundle Resources")
                    break
    
    if removed:
        # Write the updated content
        with open(project_file, 'w') as f:
            f.write(new_content)
        print("✅ Project file updated successfully")
        return True
    else:
        print("⚠️  Info.plist not found in Copy Bundle Resources (might already be removed)")
        return False

if __name__ == "__main__":
    project_file = "LMS.xcodeproj/project.pbxproj"
    
    print("🔧 Removing Info.plist from Copy Bundle Resources...")
    
    if remove_info_plist_from_resources(project_file):
        print("\n✅ Done! Now test the build with: ./test_build_after_fix.sh")
    else:
        print("\n⚠️  No changes made. Info.plist might already be removed from resources.") 