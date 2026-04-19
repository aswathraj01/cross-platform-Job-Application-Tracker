import os
import re

folder = 'g:\\Github\\cross-platform-Job-Application-Tracker\\frontend\\lib'
for root, dirs, files in os.walk(folder):
    for f in files:
        if f.endswith('.dart'):
            filepath = os.path.join(root, f)
            with open(filepath, 'r', encoding='utf-8') as file:
                content = file.read()
            
            # Use regex to find and replace .withOpacity(...) with .withValues(alpha: ...)
            if '.withOpacity(' in content:
                new_content = re.sub(r'\.withOpacity\(([^)]+)\)', r'.withValues(alpha: \1)', content)
                with open(filepath, 'w', encoding='utf-8') as file:
                    file.write(new_content)
                print(f"Updated {f}")
