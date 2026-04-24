'''
Purpose: Convert section 3 estimates to LaTeX commands
Primary author: Max Miller
Date: 12-10-2025
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
OUTPUT_PATH = ROOT_PATH / 'source/paper/numbers/section_3.tex'

NUM_TO_WORD = {'1': 'One', '2': 'Two', '3': 'Three', '4': 'Four', '5': 'Five', '6': 'Six'}

# %% ==========================================================================
# Main execution logic
# =============================================================================

def main():
    lines = []
    
    with open(ESTIMATES_PATH, 'r') as f:
        data = json.load(f)
    
    # Table 1: Change in log dividend yield
    for col_num in range(1, 7):
        col_key = f'column{col_num}'
        prefix = 'col' + NUM_TO_WORD[str(col_num)]
        pe = data['table1'][col_key]['pe'] * 100
        sd = data['table1'][col_key]['se'] * 100
        lines.append(f"\\newcommand{{\\tabOne{prefix}PE}}{{{pe:.1f}}}")
        lines.append(f"\\newcommand{{\\tabOne{prefix}SE}}{{{sd:.1f}}}")
        lines.append(f"\\newcommand{{\\tabOne{prefix}ND}}{{{data['table1'][col_key]['nd']}}}")

    # Table B3: Risk premium measures
    tableB3 = data['tableB3']

    lines.append(f"\\newcommand{{\\tabBThreeAceDem}}{{{tableB3['acemoglu_democratizations']}}}")
    lines.append(f"\\newcommand{{\\tabBThreeCorpBondDem}}{{{tableB3['corp_bond_democratizations']}}}")

    def _add_tableB3_range(row_key: str, macro_stub: str):
    
        values = [tableB3[row_key][f'column{i}']['pe'] for i in range(1, 7)]
        low = min(values) * 100
        high = max(values) * 100
        lines.append(f"\\newcommand{{\\tabBThree{macro_stub}Low}}{{{low:.1f}}}")
        lines.append(f"\\newcommand{{\\tabBThree{macro_stub}High}}{{{high:.1f}}}")

    # Panel A: Ranges used in the Stylized Facts appendix text
    _add_tableB3_range('dem_ep_minus_start', 'ERTOnly')
    _add_tableB3_range('d_vdem_elect_g', 'IndexGrowth')
    _add_tableB3_range('d_vdem_elect_std', 'IndexDiff')
    _add_tableB3_range('dem_jump_large_minus', 'LargeJump')
    _add_tableB3_range('vod_demo_minus_start', 'Lindberg')
    _add_tableB3_range('ace_minus_start', 'Acemoglu')

    # Panel C: Alternate risk premium measures (ranges)
    dr_values = [tableB3['cum_dr_news_eq_tr_alt'][f'column{i}']['pe'] for i in range(1, 7)]
    dr_max = max(dr_values) * 100
    dr_min = min(dr_values) * 100
    lines.append(f"\\newcommand{{\\tabBThreeDRHigh}}{{{dr_max:.1f}}}")
    lines.append(f"\\newcommand{{\\tabBThreeDRLow}}{{{dr_min:.1f}}}")

    eq_vol_values = [tableB3['all_exc_ret_sd_f5yr'][f'column{i}']['pe'] for i in range(1, 7)]
    eq_vol_max = max(eq_vol_values) * 100
    eq_vol_min = min(eq_vol_values) * 100
    lines.append(f"\\newcommand{{\\tabBThreeEVolHigh}}{{{eq_vol_max:.1f}}}")
    lines.append(f"\\newcommand{{\\tabBThreeEVolLow}}{{{eq_vol_min:.1f}}}")

    corp_bond_values = [tableB3['log_gfd_corp_bond_yield_5yr'][f'column{i}']['pe'] for i in range(1, 7)]
    corp_bond_max = max(corp_bond_values) * 100
    corp_bond_min = min(corp_bond_values) * 100
    lines.append(f"\\newcommand{{\\tabBThreeCorpBondHigh}}{{{corp_bond_max:.1f}}}")
    lines.append(f"\\newcommand{{\\tabBThreeCorpBondLow}}{{{corp_bond_min:.1f}}}")

    exc_ret_values = [tableB3['all_exc_ret'][f'column{i}']['pe'] for i in range(1, 7)]
    exc_ret_max = max(exc_ret_values) * 100
    exc_ret_min = min(exc_ret_values) * 100
    lines.append(f"\\newcommand{{\\tabBThreeExcRetHigh}}{{{exc_ret_max:.1f}}}")
    lines.append(f"\\newcommand{{\\tabBThreeExcRetLow}}{{{exc_ret_min:.1f}}}")

    # Section 3 descriptive statistics
    section3 = data['section3']

    # Data section numbers
    lines.append(f"\\newcommand{{\\avgDivYldYears}}{{{section3['avg_div_yld_years']:.0f}}}")
    lines.append(f"\\newcommand{{\\demEpisodes}}{{{section3['dem_episodes']}}}")
    lines.append(f"\\newcommand{{\\demYears}}{{{section3['dem_years']}}}")
    lines.append(f"\\newcommand{{\\demEpisodesPre}}{{{section3['dem_episodes_before_1900']}}}")

    # Additional data macros potentially used in Stylized Facts text
    lines.append(f"\\newcommand{{\\avgDemEpisodeLength}}{{{section3['avg_dem_episode_length']:.1f}}}")
    lines.append(f"\\newcommand{{\\avgDemEpisodeLengthInt}}{{{section3['avg_dem_episode_length']:.0f}}}")
    lines.append(f"\\newcommand{{\\demEpisodesIK}}{{{section3['dem_episodes_IK']}}}")

    median_dem_change = section3['median_dem_index_change']
    lines.append(f"\\newcommand{{\\medianDemIndexChange}}{{{median_dem_change:.2f}}}")

    # Table 5: Regional waves IV results
    table5 = data['table5']
    iv_low = median_dem_change * table5['column3']['pe'] * 100
    iv_high = median_dem_change * table5['column4']['pe'] * 100
    max_fitted = table5['max_fitted_value']
    lines.append(f"\\newcommand{{\\tabFiveIVLow}}{{{iv_low:.1f}}}")
    lines.append(f"\\newcommand{{\\tabFiveIVHigh}}{{{iv_high:.1f}}}")
    lines.append(f"\\newcommand{{\\tabFiveMaxFittedValue}}{{{max_fitted:.2f}}}")

    with open(OUTPUT_PATH, 'w') as f:
        f.write('\n'.join(lines) + '\n')


# %% ==========================================================================
# Run script
# =============================================================================

if __name__ == '__main__':
    main()

# %%
