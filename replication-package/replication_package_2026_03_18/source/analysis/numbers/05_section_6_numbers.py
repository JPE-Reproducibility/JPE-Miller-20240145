'''
Purpose: Convert section 6 table JSONs to LaTeX commands
Primary author: Max Miller
Date: 12-11-2025
'''

# %% ==========================================================================
# Load in modules
# =============================================================================

import json
from source.config import ROOT_PATH

# ==============================================================================
# Set globals
# ==============================================================================

MODEL_NUMBERS_PATH = ROOT_PATH / 'model_numbers.json'
EMPIRICS_NUMBERS_PATH = ROOT_PATH / 'empirics_numbers.json'
OUTPUT_PATH = ROOT_PATH / 'source/paper/numbers/section_6.tex'

# %% ==========================================================================
# Main execution logic
# =============================================================================

def main():
    lines = []
    
    with open(MODEL_NUMBERS_PATH, 'r') as f:
        model = json.load(f)

    with open(EMPIRICS_NUMBERS_PATH, 'r') as f:
        empirics = json.load(f)

    # Table 12: Model results (model_numbers.json)
    pa = model['panel_a']
    pb = model['panel_b']
    pc = model['panel_c']
    pd = model['panel_d']

    lines.append(f"\\newcommand{{\\tabTwelveDeltaTheta}}{{{float(pa['inequality_reduction']):.3f}}}")
    lines.append(f"\\newcommand{{\\tabTwelveDeltaTau}}{{{float(pa['tax_increase']):.3f}}}")
    lines.append(f"\\newcommand{{\\tabTwelveDeltaNu}}{{{float(pa['corruption_reduction']):.3f}}}")
    lines.append(f"\\newcommand{{\\tabTwelveEliteConsDrop}}{{{float(pa['elite_consumption_reduction_pct']):.1f}}}")

    lines.append(f"\\newcommand{{\\tabTwelveDivYldAutModel}}{{{float(pb['div_yield_autocracy_model']):.3f}}}")
    lines.append(f"\\newcommand{{\\tabTwelveDivYldAutData}}{{{float(pb['div_yield_autocracy_data']):.3f}}}")
    lines.append(f"\\newcommand{{\\tabTwelveDivYldDemModel}}{{{float(pb['div_yield_democratization_model']):.3f}}}")
    lines.append(f"\\newcommand{{\\tabTwelveDivYldDemData}}{{{float(pb['div_yield_democratization_data']):.3f}}}")
    lines.append(f"\\newcommand{{\\tabTwelveDYChangeModel}}{{{float(pb['change_div_yield_pct_model']):.1f}}}")
    lines.append(f"\\newcommand{{\\tabTwelveDYChangeData}}{{{float(pb['change_div_yield_pct_data']):.1f}}}")

    lines.append(f"\\newcommand{{\\tabTwelveRiskPrem}}{{{float(pc['risk_premium_pct']):.1f}}}")
    lines.append(f"\\newcommand{{\\tabTwelveCashflow}}{{{float(pc['cashflow_growth_pct']):.1f}}}")
    lines.append(f"\\newcommand{{\\tabTwelveRiskfree}}{{{float(pc['riskfree_rate_pct']):.1f}}}")
    risk_prem_pos = float(pc['risk_premium_pct']) / (float(pc['risk_premium_pct']) + float(pc['cashflow_growth_pct'])) * 100
    lines.append(f"\\newcommand{{\\tabTwelveRiskPremPos}}{{{risk_prem_pos:.1f}}}")

    competition_pct = float(pd['competition_pct'])
    non_competition_pct = 100 - competition_pct
    lines.append(f"\\newcommand{{\\tabTwelveComp}}{{{competition_pct:.1f}}}")
    lines.append(f"\\newcommand{{\\tabTwelveNonComp}}{{{non_competition_pct:.1f}}}")
    lines.append(f"\\newcommand{{\\tabTwelveTaxes}}{{{float(pd['taxes_pct']):.1f}}}")
    lines.append(f"\\newcommand{{\\tabTwelveInequality}}{{{float(pd['inequality_pct']):.1f}}}")
    lines.append(f"\\newcommand{{\\tabTwelveCorruption}}{{{float(pd['corruption_pct']):.1f}}}")

    lp = model['limited_participation']
    lines.append(f"\\newcommand{{\\modelCitizenDY}}{{{100*float(lp['citizens_div_yld_change']):.1f}}}")
    lines.append(f"\\newcommand{{\\modelLimitedPartDY}}{{{100*float(lp['total_div_yld_change']):.1f}}}")

    hg = model['higher_growth']
    lines.append(f"\\newcommand{{\\modelHigherGrowthAdj}}{{{100*float(hg['higher_growth_adj']):.0f}}}")

    # Empirics moments used in Section 6 text (empirics_numbers.json)
    dem_len = float(empirics['section3']['avg_dem_episode_length'])
    lines.append(f"\\newcommand{{\\demEpisodeLength}}{{{dem_len:.2f}}}")

    dem_fail = (1 - float(empirics['section6']['pct_dem_succ'])) * 100
    lines.append(f"\\newcommand{{\\pctDemFail}}{{{dem_fail:.0f}}}")

    aut_tax = float(empirics['section6']['autocracy_tax']) * 100
    lines.append(f"\\newcommand{{\\autocracyTax}}{{{aut_tax:.1f}}}")

    aut_dy = float(empirics['section6']['autocracy_div_yld'])
    lines.append(f"\\newcommand{{\\autocracyDivYld}}{{{aut_dy:.2f}}}")

    lib_share = float(empirics['figureD10']['q']) * 100
    lines.append(f"\\newcommand{{\\pctLibDem}}{{{lib_share:.0f}}}")

    vol_vals = [float(empirics['tableB3']['all_exc_ret_sd_f5yr'][f'column{i}']['pe']) for i in range(1, 7)]
    lines.append(f"\\newcommand{{\\demVolLow}}{{{100*min(vol_vals):.1f}}}")
    lines.append(f"\\newcommand{{\\demVolHigh}}{{{100*max(vol_vals):.1f}}}")

    # Middle row of transition matrix (implied by democratization length)
    p21 = 1 / (2 * dem_len)
    p22 = 1 - (1 / dem_len)
    p23 = p21
    p23_pct = p21 * 100
    lines.append(f"\\newcommand{{\\transPTwoOne}}{{{p21:.3f}}}")
    lines.append(f"\\newcommand{{\\transPTwoTwo}}{{{p22:.3f}}}")
    lines.append(f"\\newcommand{{\\transPTwoThree}}{{{p23:.3f}}}")
    lines.append(f"\\newcommand{{\\transPTwoThreePct}}{{{p23_pct:.1f}}}")

    # Autocratization model results
    autocratization = model['autocratization']
    lines.append(f"\\newcommand{{\\autoCG}}{{{100*autocratization['consumption_growth']:.1f}}}")
    lines.append(f"\\newcommand{{\\autoZ}}{{{autocratization['failure_penalty']:.3f}}}")
    lines.append(f"\\newcommand{{\\autoDivYldChange}}{{{100*autocratization['log_dividend_yield_change']:.1f}}}")

    with open(OUTPUT_PATH, 'w') as f:
        f.write('\n'.join(lines) + '\n')

# %% ==========================================================================
# Run script
# =============================================================================

if __name__ == '__main__':
    main()

# %%
