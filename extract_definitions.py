
import os
import re

directory = r'd:\gotroot\GR_PROJECT\GR_Project_v5\04_db\atom_data\INFRA'

def extract_info(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        lines = f.readlines()
    
    name = None
    what = []
    in_definition = False
    in_what_block = False
    what_indent = 0
    
    for line in lines:
        stripped = line.strip()
        
        # Identity Name
        if not name and stripped.startswith('name:'):
            parts = stripped.split(':', 1)
            if len(parts) > 1:
                n = parts[1].strip()
                if n.startswith('"') and n.endswith('"'):
                    n = n[1:-1]
                name = n
        
        # Enter Definition Section
        if stripped.startswith('definition:'):
            in_definition = True
            continue
            
        # Found 'what' key
        if in_definition and stripped.startswith('what:'):
            # Check for inline content
            parts = stripped.split(':', 1)
            content = parts[1].strip()
            
            # Check if block scalar
            if content.startswith('>') or content.startswith('|'):
                in_what_block = True
                what_indent = len(line) - len(line.lstrip())
                continue
            else:
                # Inline content
                # remove quotes if present
                if content.startswith('"') and content.endswith('"'):
                    content = content[1:-1]
                what.append(content)
                # We typically only have one 'what', so we could stop here for 'what', 
                # but let's just unset in_definition to avoid false positives? 
                # No, we might want to capture more if we enriched this later. 
                # But for now, we are done with 'what'.
                in_definition = False 
                continue

        # Inside 'what' block
        if in_what_block:
            current_indent = len(line) - len(line.lstrip())
            if not stripped:
                what.append('')
                continue
                
            if current_indent <= what_indent:
                in_what_block = False
                in_definition = False
            else:
                what.append(stripped)

    return name, " ".join(what).strip()

print(f"Processing files in {directory}...")
count = 0
files = sorted([f for f in os.listdir(directory) if f.endswith(".yaml")])
for filename in files:
    filepath = os.path.join(directory, filename)
    try:
        name, definition = extract_info(filepath)
        print(f"File: {filename}")
        print(f"Name: {name}")
        # Truncate for cleaner output, or keep full for verification?
        # User wants verification, so full text is better, but console buffer might be issue.
        # I'll output up to 300 chars which should be enough to capture the gist.
        display_def = definition[:300] + "..." if definition and len(definition) > 300 else definition
        print(f"Definition: {display_def}")
        print("-" * 40)
        count += 1
    except Exception as e:
        print(f"Error reading {filename}: {e}")

print(f"Processed {count} files.")
