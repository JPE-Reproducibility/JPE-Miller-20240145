'''
Purpose: Convert section 4 table JSONs to LaTeX commands
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
# ==============================================================================

ESTIMATES_PATH = ROOT_PATH / 'empirics_numbers.json'
OUTPUT_PATH = ROOT_PATH / 'source/paper/numbers/section_4.tex'

NUM_TO_WORD = {'1': 'One', '2': 'Two', '3': 'Three', '4': 'Four'}

# %% ==========================================================================
# Main execution logic
# =============================================================================

def main():
    lines = []
    
    with open(ESTIMATES_PATH, 'r') as f:
        data = json.load(f)
    
    table7 = data['table7']
    # Table 7: DID results
    for col, values in table7.items():
        if col.startswith('column'):
            prefix = 'col' + NUM_TO_WORD[col[-1]]
            pe = values['pe'] * 100
            sd = values['se'] * 100
            lines.append(f"\\newcommand{{\\tabSeven{prefix}PE}}{{{pe:.1f}}}")
            lines.append(f"\\newcommand{{\\tabSeven{prefix}SE}}{{{sd:.1f}}}")
        

    eq_tr_values = [float(table7[f'column{i}']['pe']) for i in range(1, 5)]
    eq_tr_max = max(eq_tr_values) * 100
    eq_tr_min = min(eq_tr_values) * 100

    lines.append(f"\\newcommand{{\\tabSevenHigh}}{{{eq_tr_max:.1f}}}")
    lines.append(f"\\newcommand{{\\tabSevenLow}}{{{eq_tr_min:.1f}}}")

    # Additional Section 4 macros from empirics_numbers.json
    sec4 = data['section4']
    lines.append(f"\\newcommand{{\\pctAutMajCatholic}}{{{100*float(sec4['pct_aut_maj_catholic_1963']):.0f}}}")
    lines.append(f"\\newcommand{{\\pctMajCatholicSucc}}{{{100*float(sec4['pct_maj_catholic_succ_1963_1983']):.0f}}}")

    tf = table7['two_factor_fit']
    lines.append(f"\\newcommand{{\\twoFactorRTwoMean}}{{{float(tf['mean']):.2f}}}")
    lines.append(f"\\newcommand{{\\twoFactorRTwoMedian}}{{{float(tf['median']):.2f}}}")

    # Table C7: Probability of democratization post Vatican II (successful democratizations)
    tableC7 = data['tableC7']
    c7_vals = [float(tableC7['column2']['pe']), float(tableC7['column4']['pe'])]
    lines.append(f"\\newcommand{{\\tabCSevenSuccLow}}{{{100*min(c7_vals):.0f}}}")
    lines.append(f"\\newcommand{{\\tabCSevenSuccHigh}}{{{100*max(c7_vals):.0f}}}")

    # Figure 5: Structural break tests
    fig5 = data['figure5']
    lines.append(f"\\newcommand{{\\figFiveBreakCSO}}{{{int(float(fig5['cso_diff_swald']))}}}")
    lines.append(f"\\newcommand{{\\figFiveBreakMob}}{{{int(float(fig5['mob_diff_swald']))}}}")
    lines.append("\\newcommand{\\figFiveBreakWindowStart}{1940}")
    lines.append("\\newcommand{\\figFiveBreakWindowEnd}{1989}")

    # Table C8: First Vatican Council falsification
    tableC8 = data['tableC8']
    c8_vals = [abs(float(tableC8['column1']['pe'])), abs(float(tableC8['column2']['pe']))]
    lines.append(f"\\newcommand{{\\tabCEightLow}}{{{100*min(c8_vals):.1f}}}")
    lines.append(f"\\newcommand{{\\tabCEightHigh}}{{{100*max(c8_vals):.1f}}}")

    with open(OUTPUT_PATH, 'w') as f:
        f.write('\n'.join(lines) + '\n')

# %% ==========================================================================
# Run script
# =============================================================================

if __name__ == '__main__':
    main()

# %%
