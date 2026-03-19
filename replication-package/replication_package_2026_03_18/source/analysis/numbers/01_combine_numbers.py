'''
Purpose: Combine all JSON files from source/numbers/ into a single all_numbers.json
Primary author: Max Miller
Date: 2025
'''
# %% ==========================================================================
# Load in modules
# =============================================================================

import json
from source.config import ROOT_PATH

# ==============================================================================
# Set globals
# =============================================================================

NUMBERS_PATH = ROOT_PATH / 'source/numbers'
OUTPUT_PATH = ROOT_PATH / 'empirics_numbers.json'

# %% ==========================================================================
# Main execution logic
# =============================================================================

def main():
    combined = {}
    
    for json_file in sorted(NUMBERS_PATH.glob('*.json')):
        master_key = json_file.stem
        with open(json_file, 'r') as f:
            combined[master_key] = json.load(f)
    
    with open(OUTPUT_PATH, 'w') as f:
        json.dump(combined, f, indent=2)
    
    print(f"Combined {len(combined)} files into {OUTPUT_PATH}")

# %% ==========================================================================
# Run script
# =============================================================================

if __name__ == '__main__':
    main()

# %%
