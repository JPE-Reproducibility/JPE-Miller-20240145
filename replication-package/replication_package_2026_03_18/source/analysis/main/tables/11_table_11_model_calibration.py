'''
Purpose: Generate Table 11 - Model Calibration
Primary author: Max Miller
Date: 2025
'''
# %% ==========================================================================
# Load in modules
# =============================================================================

import json
from source.config import ROOT_PATH
from source.derived.model.democratization_model import DemocratizationModel

# ==============================================================================
# Set globals
# ==============================================================================

TABLES = ROOT_PATH / 'source/tables/raw'
ESTIMATES_PATH = ROOT_PATH / 'empirics_numbers.json'
PARAMS_PATH = ROOT_PATH / 'source/derived/model/baseline_params.json'
PARAMS_PATH_HIGHER_GROWTH = ROOT_PATH / 'source/derived/model/baseline_params_higher_growth.json'

# %% ==========================================================================
# Main execution logic
# =============================================================================

def main():

    # Create parameters from literature
    baseline_params = {}
    baseline_params['beta'] = 0.9608
    baseline_params['gamma'] = 6.00
    baseline_params['psi'] = 1.50
    baseline_params['delta'] = 0.07
    baseline_params['xi'] = 0.77
    baseline_params['Delta_tau_div'] = 0.10
    baseline_params['Upsilon'] = 2.6
    baseline_params['y_A'] = 0.017
    baseline_params['Delta_y_D'] = 0.000
    baseline_params['sigma_y'] = 0.073
    baseline_params['tau_div_A'] = 0.20

    # Add explicit redistribution parameters
    with open(ESTIMATES_PATH, 'r') as f:
        data = json.load(f)

    dem_length = data['section3']['avg_dem_episode_length']
    baseline_params['P_mu'] = [
            [0.99, 0.01, 0.000],
            [1/(2*dem_length), 1 - 1/dem_length, 1/(2*dem_length)],
            [0.000, 0.000, 1.000]
        ]


    baseline_params['tau_A'] = data['section6']['autocracy_tax']
    baseline_params['Delta_tau'] = 20 * data['table8']['column1']['pe']

    baseline_params['theta_A'] = data['section6']['autocracy_gini']/100 + baseline_params['delta']
    baseline_params['Delta_theta'] = 20 * (data['table8']['column4']['pe'] - data['table8']['column3']['pe'])/2 

    baseline_params['q'] = data['figureD10']['q']
    baseline_params['H_f'] = data['figureD10']['pe_ld'] / (data['figureD10']['pe_ld'] + data['figureD10']['pe_oth'])

    baseline_params['nu_A'] = data['section6']['autocracy_corrupt']
    baseline_params['Delta_nu'] = - dem_length * (data['table9']['column1']['pe'] + data['table9']['column2']['pe'])/2 

    with open(PARAMS_PATH, 'w') as f:
        json.dump(baseline_params, f, indent=4)


    baseline_params_higher_growth = baseline_params.copy()
    baseline_params_higher_growth['higher_growth'] = True
    baseline_params_higher_growth['higher_growth_rate'] = 0.006
    baseline_params_higher_growth['higher_growth_years'] = 20
    baseline_params_higher_growth['incumbent_loss_adj'] = 0.24
    with open(PARAMS_PATH_HIGHER_GROWTH, 'w') as f:
        json.dump(baseline_params_higher_growth, f, indent=4)


    m = DemocratizationModel(PARAMS_PATH)
    
    # Derived values for table
    θD = m.θA - m.Δθ
    νD = m.νA - m.Δν
    τDdiv = 0.20 + m.Δτd
    ξloss = 1 - m.ξ
    ω = (m.ωH + m.ωL) / 2
    
    latex = f"""
\\begin{{tabularx}}{{\\linewidth}}{{@{{ }} l*{{3}}{{Y}} @{{ }}}}
\\toprule
\\multicolumn{{1}}{{l}}{{Parameter}} & \\multicolumn{{1}}{{c}}{{Value}} & \\multicolumn{{1}}{{c}}{{Description}} & \\multicolumn{{1}}{{c}}{{Source}} \\\\
\\hline \\addlinespace
\\textbf{{Lucas Tree:}}  &  & & \\\\ \\hline
\\addlinespace
$\\qquad \\qquad \\bar{{y}}$     & {m.yA:.3f} & Income growth & Maddison Historical Statistics \\\\
$\\qquad \\qquad \\sigma_y$      & {m.σy:.3f} & Income standard deviation & Maddison Historical Statistics \\\\
\\addlinespace \\hline
\\textbf{{Inequality parameters:}}  &  & & \\\\ \\hline
\\addlinespace
$\\qquad \\qquad \\theta^A$ & {m.θA:.3f} & Inequality in autocracy & SWIID \\\\
$\\qquad \\qquad \\theta^D$ & {θD:.3f} & Avg. Inequality in democracy & Author estimation \\\\
$\\qquad \\qquad \\nu^A$ & {m.νA:.3f} & Rent diversion in autocracy & V-Dem \\\\
$\\qquad \\qquad \\nu^D$ & {νD:.3f} & Avg. rent diversion in democracy & Author estimation \\\\
$\\qquad \\qquad \\delta$ & {m.δ:.2f} & Fraction of elites & \\cite{{Tian2021}} \\\\
$\\qquad \\qquad \\tau^A$ & {m.τA:.3f} & Tax rate in autocracy & Autocracy Gov. Rev.-GDP ratio \\\\
$\\qquad \\qquad \\omega$ & {ω:.2f} & Avg. democracy taxation cost & Democracy Gov. Rev.-GDP ratio \\\\
\\addlinespace \\hline
\\textbf{{Dividend claim:}}  &  & & \\\\ \\hline
\\addlinespace
$\\qquad \\qquad \\Upsilon$ & {m.Υ:.2f} & Leverage of dividend claim & \\cite{{Wachter2013}} \\\\
$\\qquad \\qquad \\tau^D_{{Div}}$ & {τDdiv:.2f} & Dividend tax in democracy & \\cite{{Genschel2016}} \\\\
$\\qquad \\qquad \\xi$ & {ξloss:.2f} & Incumbent disadvantage & \\cite{{Fisman2001}} \\\\
\\addlinespace \\hline
\\textbf{{Uncertainty parameters:}}  &  & & \\\\ \\hline
\\addlinespace
$\\qquad \\qquad q$ & {m.q:.2f} & Likelihood of high redistribution & Author estimation \\\\
$\\qquad \\qquad \\aleph$ & {m.Hf:.2f} & Redistribution in high state & Author estimation \\\\
\\textbf{{Preference parameters:}}  &  & & \\\\ \\hline
\\addlinespace
$\\qquad \\qquad \\beta$ & {m.β:.4f} & Subjective discount rate & Match PD ratio in autocracy \\\\
$\\qquad \\qquad \\gamma$ & {m.γ:.0f} & Relative risk aversion & \\cite{{Catherine2021}} \\\\
$\\qquad \\qquad \\psi$ & {m.ψ:.1f} & IES & \\cite{{Bansal2010}} \\\\
\\bottomrule
\\end{{tabularx}}
"""
    
    output_path = TABLES / 'table_11_model_calibration.tex'
    with open(output_path, 'w') as f:
        f.write(latex)
    print(f"Saved to: {output_path}")

# %% ==========================================================================
# Run script
# =============================================================================

if __name__ == '__main__':
    main()

# %%
