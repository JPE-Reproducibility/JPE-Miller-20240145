*! save_estimate.ado - Save estimates to a running JSON file
*! Version 1.2

capture program drop save_estimate
program define save_estimate
    version 16.0
    syntax, key(string) value(string) file(string)
    
    python: _save_estimate("`key'", `value', "`file'")
end

python:
import json
import os
from sfi import SFIToolkit

def _save_estimate(key, value, filename):
    # Store in source/numbers/ directory with .json extension
    filepath = f"source/numbers/{filename}.json"
    
    # Ensure directory exists
    os.makedirs(os.path.dirname(filepath), exist_ok=True)
    
    # Load existing or start fresh
    if os.path.exists(filepath):
        with open(filepath, 'r') as f:
            try:
                data = json.load(f)
            except json.JSONDecodeError:
                data = {}
    else:
        data = {}
    
    # Support nested keys with dot notation (e.g., "col1.beta")
    keys = key.split('.')
    d = data
    for k in keys[:-1]:
        d = d.setdefault(k, {})
    d[keys[-1]] = value
    
    # Write back
    with open(filepath, 'w') as f:
        json.dump(data, f, indent=2)
    
    SFIToolkit.display(f"Saved to {filepath}: {key} = {value}")
end
