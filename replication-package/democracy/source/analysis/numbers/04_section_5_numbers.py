'''
Purpose: Convert explicit redistribution JSON to LaTeX commands
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
OUTPUT_PATH = ROOT_PATH / 'source/paper/numbers/section_5.tex'

# %% ==========================================================================
# Main execution logic
# =============================================================================

NUM_TO_WORD = {'1': 'One', '2': 'Two', '3': 'Three', '4': 'Four'}

def main():
    with open(ESTIMATES_PATH, 'r') as f:
        data = json.load(f)
    
    table8 = data['table8']
    
    lines = []
    for col_num in ['1', '2', '3', '4']:
        col_key = f'column{col_num}'
        prefix = 'col' + NUM_TO_WORD[col_num]
        lines.append(f"\\newcommand{{\\tabEight{prefix}PE}}{{{table8[col_key]['pe']*100:.2f}}}")
        lines.append(f"\\newcommand{{\\tabEight{prefix}SE}}{{{table8[col_key]['se']*100:.2f}}}")
        lines.append(f"\\newcommand{{\\tabEight{prefix}ND}}{{{int(table8[col_key]['nd'])}}}")
    
    govt_rev_cum = 100 * (table8['column1']['pe'] * 20)
    tax_rev_cum = 100 * (table8['column2']['pe'] * 20)
    gini_cum = - 100 * (table8['column3']['pe'] * 20)
    lab_share_cum = 100 * (table8['column4']['pe'] * 20)

    lines.append(f"\\newcommand{{\\tabEightOneCE}}{{{govt_rev_cum:.1f}}}")
    lines.append(f"\\newcommand{{\\tabEightTwoCE}}{{{tax_rev_cum:.1f}}}")
    lines.append(f"\\newcommand{{\\tabEightThreeCE}}{{{gini_cum:.1f}}}")
    lines.append(f"\\newcommand{{\\tabEightFourCE}}{{{lab_share_cum:.1f}}}")

    table9 = data['table9']

    for col_num in ['1', '2', '3', '4']:
        col_key = f'column{col_num}'
        prefix = 'col' + NUM_TO_WORD[col_num]
        lines.append(f"\\newcommand{{\\tabNine{prefix}PE}}{{{abs(table9[col_key]['pe'])*100:.2f}}}")

    dem_len = int(round(float(data['section3']['avg_dem_episode_length'])))
    corr = -100 * table9['column1']['pe'] * dem_len
    brib = -100 * table9['column2']['pe'] * dem_len
    comp = 100 * table9['column3']['pe'] * dem_len
    firms = round(100 * table9['column4']['pe'] * dem_len / 10) * 10

    lines.append(f"\\newcommand{{\\tabNineOneCE}}{{{corr:.1f}}}")
    lines.append(f"\\newcommand{{\\tabNineTwoCE}}{{{brib:.1f}}}")
    lines.append(f"\\newcommand{{\\tabNineThreeCE}}{{{comp:.0f}}}")
    lines.append(f"\\newcommand{{\\tabNineFourCE}}{{{firms:.0f}}}")

    # Additional Section 5 text numbers
    table3 = data['table3']
    reg_vals = [float(table3[f'column{i}']['regime_change']['pe']) for i in range(1, 6)]
    lines.append(f"\\newcommand{{\\tabThreeRegChLow}}{{{100*min(reg_vals):.0f}}}")
    lines.append(f"\\newcommand{{\\tabThreeRegChHigh}}{{{100*max(reg_vals):.0f}}}")

    table10 = data['table10']
    low_risk_vals = [float(table10[f'column{i}']['no_elite']['pe']) for i in range(1, 7)]
    lines.append(f"\\newcommand{{\\tabTenLowRiskLow}}{{{100*min(low_risk_vals):.0f}}}")
    lines.append(f"\\newcommand{{\\tabTenLowRiskHigh}}{{{100*max(low_risk_vals):.0f}}}")

    pct_high = 100 * float(table10['column1']['nd']) / float(data['table1']['column1']['nd'])
    lines.append(f"\\newcommand{{\\pctHighRedistRisk}}{{{pct_high:.0f}}}")

    with open(OUTPUT_PATH, 'w') as f:
        f.write('\n'.join(lines) + '\n')

# %% ==========================================================================
# Run script
# =============================================================================

if __name__ == '__main__':
    main()

# %%
