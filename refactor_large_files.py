#!/usr/bin/env python3
"""
Automatic refactoring script for large Swift files
"""

import os
import re
import sys
from pathlib import Path

def extract_components_from_swift_file(file_path):
    """Extract struct/class definitions from Swift file"""
    with open(file_path, 'r') as f:
        content = f.read()
    
    # Pattern to match struct/class definitions
    pattern = r'(struct|class)\s+(\w+).*?\{.*?(?=\n(?:struct|class)\s+\w+|$)'
    
    components = []
    for match in re.finditer(pattern, content, re.DOTALL):
        component_type = match.group(1)
        component_name = match.group(2)
        component_code = match.group(0)
        
        # Skip the main view
        if component_name == Path(file_path).stem:
            continue
            
        components.append({
            'name': component_name,
            'type': component_type,
            'code': component_code
        })
    
    return components

def create_component_files(base_dir, components):
    """Create individual files for each component"""
    os.makedirs(base_dir, exist_ok=True)
    
    for comp in components:
        file_path = os.path.join(base_dir, f"{comp['name']}.swift")
        
        # Add import SwiftUI if not present
        code = comp['code']
        if 'import SwiftUI' not in code:
            code = 'import SwiftUI\n\n' + code
        
        with open(file_path, 'w') as f:
            f.write(code)
        
        print(f"Created: {file_path}")

def refactor_main_file(file_path, components):
    """Update main file to remove extracted components"""
    with open(file_path, 'r') as f:
        content = f.read()
    
    # Remove extracted components
    for comp in components:
        pattern = rf'{comp["type"]}\s+{comp["name"]}.*?\{{.*?(?=\n(?:struct|class)\s+\w+|$)'
        content = re.sub(pattern, '', content, flags=re.DOTALL)
    
    # Clean up extra newlines
    content = re.sub(r'\n{3,}', '\n\n', content)
    
    with open(file_path, 'w') as f:
        f.write(content)
    
    print(f"Updated main file: {file_path}")

def main():
    # Files to refactor
    large_files = [
        "LMS_App/LMS/LMS/Features/Profile/Views/ProfileView.swift",
        "LMS_App/LMS/LMS/Features/Onboarding/Views/OnboardingDashboard.swift",
        "LMS_App/LMS/LMS/Features/Tests/Views/TestDetailView.swift",
        # Add more files as needed
    ]
    
    for file_path in large_files:
        if not os.path.exists(file_path):
            print(f"File not found: {file_path}")
            continue
        
        print(f"\nRefactoring: {file_path}")
        
        # Extract components
        components = extract_components_from_swift_file(file_path)
        
        if not components:
            print(f"No components to extract from {file_path}")
            continue
        
        # Create subdirectory
        base_name = Path(file_path).stem
        base_dir = os.path.dirname(file_path)
        component_dir = os.path.join(base_dir, base_name)
        
        # Create component files
        create_component_files(component_dir, components)
        
        # Update main file
        refactor_main_file(file_path, components)
        
        print(f"Refactored {len(components)} components from {file_path}")

if __name__ == "__main__":
    main() 