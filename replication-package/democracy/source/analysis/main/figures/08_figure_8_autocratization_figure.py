'''
Purpose: Generate Figure 8 - Autocratization Model
Primary author: Max Miller
Date: 12-12-2025
'''

# %% ==========================================================================
# Load in modules
# =============================================================================

import json
import pandas as pd
import matplotlib.pyplot as plt
from source.config import ROOT_PATH
from source.derived.model.autocratization_model import AutocratizationModel

# ==============================================================================
# Set globals
# ==============================================================================

FIGURES = ROOT_PATH / 'source/figures'
PARAMS_PATH = ROOT_PATH / 'source/derived/model/baseline_params.json'
MODEL_NUMBERS_PATH = ROOT_PATH / 'model_numbers.json'

# %% ==========================================================================
# Main execution logic
# =============================================================================

def main():
    m = AutocratizationModel(PARAMS_PATH)
    
    # Get baseline and range results
    baseline = m.compute_baseline()
    results = m.compute_range(cg_min=1.0, cg_max=1.5, n=501)
    df = pd.DataFrame(results, columns=['cg', 'Z', 'Δdp'])
    
    # Create figure
    fig, ax = plt.subplots(figsize=(10, 4.75))
    
    ax.plot(df['cg'], df['Z'], color='blue', label=r'Failure penalty, $Z^{*}$', linestyle='-')
    ax.plot(df['cg'], df['Δdp'], color='red', label='Change in log dividend yield', linestyle='--')
    
    # Baseline reference lines
    ax.plot([baseline['cg'], baseline['cg']], [0, baseline['Z']], color='black', linestyle=':')
    ax.plot([1, baseline['cg']], [baseline['Z'], baseline['Z']], color='black', linestyle=':')
    ax.plot([1, baseline['cg']], [baseline['Δdp'], baseline['Δdp']], color='black', linestyle=':')
    
    ax.set_xlim(1, df['cg'].max())
    ax.set_ylim(0, max(df['Z'].max(), df['Δdp'].max()))
    ax.tick_params(axis='both', which='major', labelsize=12)
    ax.legend(loc='lower right', frameon=False, fontsize=14)
    ax.set_xlabel('Consumption growth', fontsize=14)
    
    plt.tight_layout()
    
    # Save PDF
    output_pdf = FIGURES / 'raw/figure_8_autocratization_model.pdf'
    plt.savefig(output_pdf, format='pdf', bbox_inches='tight')
    print(f"Saved to: {output_pdf}")
    
    plt.close()
    
    print(f"\nBaseline results:")
    print(f"  Consumption growth: {baseline['cg']:.3f}")
    print(f"  Z* (failure penalty): {baseline['Z']:.3f}")
    print(f"  Log dividend yield change: {baseline['Δdp']:.3f}")

    with open(MODEL_NUMBERS_PATH, 'r') as f:
        model_numbers = json.load(f)

    model_numbers['autocratization'] = {
        'consumption_growth': baseline['cg']-1,
        'failure_penalty': baseline['Z'],
        'log_dividend_yield_change': baseline['Δdp'],
    }

    with open(MODEL_NUMBERS_PATH, 'w') as f:
        json.dump(model_numbers, f, indent=2)

# %% ==========================================================================
# Run script
# =============================================================================

if __name__ == '__main__':
    main()

# %%
