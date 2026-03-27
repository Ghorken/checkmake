import os

replacements = {
    '0xFFD4AF37': '0xFFFFD700',
    '0xFF1E3A8A': '0xFF1A468E',
    '0xFF8B1E2D': '0xFFB22222',
    '0xFF0B0B10': '0xFFFDF5E6',
    '0xFFF8F7F2': '0xFFFDF5E6',
    '0xFF111626': '0xFF2C3E50',
    '0xFF16213E': '0xFF2C3E50',
    'Colors.white': 'Color(0xFFFDF5E6)',
    'Colors.white70': 'Color(0xCCFDF5E6)',
    'Colors.amber': 'Color(0xFFFFD700)',
    'Colors.black': 'Color(0xFF2C3E50)',
}

def process_dir(d):
    for root, dirs, files in os.walk(d):
        for file in files:
            if file.endswith('.dart') and file != 'main_menu_screen.dart':
                path = os.path.join(root, file)
                with open(path, 'r') as f:
                    content = f.read()
                
                original = content
                for old, new in replacements.items():
                    content = content.replace(old, new)
                
                if original != content:
                    with open(path, 'w') as f:
                        f.write(content)
                    print(f"Updated {path}")

process_dir('/Users/fiore/miei/checkmake/lib/screens')
process_dir('/Users/fiore/miei/checkmake/lib/widgets')
