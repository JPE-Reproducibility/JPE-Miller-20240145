'''
Purpose: Generate Table 12 - Model Results
Primary author: Max Miller
Date: 2025
'''

# %% ==========================================================================
# Load in modules
# =============================================================================

import json
import numpy as np
from source.config import ROOT_PATH
from source.derived.model.democratization_model import DemocratizationModel

# ==============================================================================
# Set globals
# ==============================================================================

TABLES = ROOT_PATH / 'source/tables/raw'
NUMBERS = ROOT_PATH / 'source/numbers'
ESTIMATES_PATH = ROOT_PATH / 'empirics_numbers.json'
PARAMS_PATH = ROOT_PATH / 'source/derived/model/baseline_params.json'
PARAMS_PATH_HIGHER_GROWTH = ROOT_PATH / 'source/derived/model/baseline_params_higher_growth.json'

# %% ==========================================================================
# Main execution logic
# =============================================================================

def main():
    m = DemocratizationModel(PARAMS_PATH)
    r = compute_results(m)
    ch = compute_channel_contributions(PARAMS_PATH)
    
    # Elite consumption change
    Δcr = 1 - m.q * (m.ŷDrH / m.ŷAr) - (1 - m.q) * (m.ŷDrL / m.ŷAr)

    # Table 1: Change in log dividend yield
    with open(ESTIMATES_PATH, 'r') as f:
        data = json.load(f)
    
    autocracy_div_yld = data['section6']['autocracy_div_yld']
    div_yld_change = data['table1']['column3']['pe']
    democratization_div_yld = autocracy_div_yld * np.exp(div_yld_change)

    latex = f"""
\\begin{{tabularx}}{{\\linewidth}}{{@{{ }} l*{{2}}{{Y}} @{{ }}}}
\\toprule
\\textbf{{Panel A:}} Elites cost of democracy &  &  \\\\
\\hline \\addlinespace
Inequality reduction $\\theta^A - \\theta^D$   &  & {m.Δθ:.3f}   \\\\
\\addlinespace
Tax increase $\\tau^D-\\tau^A$  & & {m.Δτ:.3f}   \\\\
\\addlinespace
Corruption reduction $\\nu^D- \\nu^A$  & & {m.Δν:.3f}   \\\\
\\addlinespace
Average reduction in Elite consumption (\\%)  & & {Δcr * 100:.1f}   \\\\
\\addlinespace  \\hline
\\textbf{{Panel B:}} Baseline Model & Model  & Data  \\\\  \\hline
\\addlinespace
Dividend yield autocracy  &  {r['div_yield_A']:.3f}  & {autocracy_div_yld:.3f}  \\\\
\\addlinespace
Dividend yield democratization  &  {r['div_yield_T']:.3f}  & {democratization_div_yld:.3f}  \\\\
\\addlinespace
Change in dividend yield (\\%)  & {r['log_dy_change'] * 100:.1f}  & {div_yld_change * 100:.1f}  \\\\
\\addlinespace  \\hline
\\textbf{{Panel C:}} Contribution of different components (\\%) & Model  &   \\\\  \\hline
\\addlinespace
Risk premium  & {r['risk_premium']:.1f}  &   \\\\
\\addlinespace
Cashflow growth & {r['cashflow']:.1f}  &  \\\\
\\addlinespace
Riskfree rate  & {r['riskfree']:.1f}  &  \\\\
\\addlinespace  \\hline
\\textbf{{Panel D:}} Contribution of different channels (\\%) & Model  &   \\\\  \\hline
\\addlinespace
Increased competition  & {ch['competition']:.1f}  &   \\\\
\\addlinespace
Increased taxes & {ch['taxes']:.1f}  &  \\\\
\\addlinespace
Decreased inequality  & {ch['inequality']:.1f}  &  \\\\
\\addlinespace
Decreased corruption  & {ch['corruption']:.1f}  &  \\\\
\\bottomrule
\\end{{tabularx}}
"""
    
    output_path = TABLES / 'table_12_model_results.tex'
    with open(output_path, 'w') as f:
        f.write(latex)
    print(f"Saved to: {output_path}")
    print(f"\nKey results:")
    print(f"  Dividend yield change: {r['log_dy_change'] * 100:.1f}%")
    print(f"  Risk premium contribution: {r['risk_premium']:.1f}%")

    citizens_div_yld_change, limited_participation_div_yld_change = limited_participation_effect()
    higher_growth_div_yld_change, higher_growth_adj = higher_growth_effect()

    # Export JSON with all model numbers
    json_output = {
        'panel_a': {
            'inequality_reduction': m.Δθ,
            'tax_increase': m.Δτ,
            'corruption_reduction': m.Δν,
            'elite_consumption_reduction_pct': Δcr * 100,
        },
        'panel_b': {
            'div_yield_autocracy_model': r['div_yield_A'],
            'div_yield_autocracy_data': autocracy_div_yld,
            'div_yield_democratization_model': r['div_yield_T'],
            'div_yield_democratization_data': democratization_div_yld,
            'change_div_yield_pct_model': r['log_dy_change'] * 100,
            'change_div_yield_pct_data': div_yld_change * 100,
        },
        'panel_c': {
            'risk_premium_pct': r['risk_premium'],
            'cashflow_growth_pct': r['cashflow'],
            'riskfree_rate_pct': r['riskfree'],
        },
        'panel_d': {
            'competition_pct': ch['competition'],
            'taxes_pct': ch['taxes'],
            'inequality_pct': ch['inequality'],
            'corruption_pct': ch['corruption'],
        },
        'limited_participation': {
            'citizens_div_yld_change': citizens_div_yld_change,
            'total_div_yld_change': limited_participation_div_yld_change,
        },
        'higher_growth': {
            'higher_growth_div_yld_change': higher_growth_div_yld_change,
            'higher_growth_adj': higher_growth_adj,
        },
    }
    json_path = ROOT_PATH / 'model_numbers.json'
    with open(json_path, 'w') as f:
        json.dump(json_output, f, indent=2)
    print(f"Saved JSON to: {json_path}")

# =============================================================================
# Helper functions
# =============================================================================

def compute_results(m):
    '''Compute model results: dividend yields, decomposition.'''
    κ = m.solve_κ()
    pd = m.solve_pd(κ)
    
    div_yield_A = 1 / pd[0]
    div_yield_T = 1 / pd[1]
    log_dy_change = np.log(div_yield_T) - np.log(div_yield_A)
    
    # Risk-free rates
    χval = m.q * (m.ŷDrH / m.ŷAr)**(-m.γ) + (1 - m.q) * (m.ŷDrL / m.ŷAr)**(-m.γ)
    χrf = np.array([1, 1, χval])
    βrf = (m.β**m.α) * np.exp(-m.γ * m.yA + 0.5 * (m.γ**2) * m.σy**2)
    
    M0 = βrf * χrf * (κ / (κ[0] - 1))**(m.α - 1)
    M1 = βrf * χrf * (κ / (κ[1] - 1))**(m.α - 1)
    Rf0 = 1 / (m.Pμ[0, :] @ M0)
    Rf1 = 1 / (m.Pμ[1, :] @ M1)
    
    # Expected dividend growth
    ZDH = 1 - (m.Hf / m.q) * (1 - ((1 - (0.2 + m.Δτd)) / 0.8) * m.ξ)
    ZDL = 1 - ((1 - m.Hf) / (1 - m.q)) * (1 - ((1 - (0.2 + m.Δτd)) / 0.8) * m.ξ)
    Z_vals = np.array([1, 1, m.q * ZDH + (1 - m.q) * ZDL])
    
    ED0 = np.exp(m.Υ * m.yA + 0.5 * (m.Υ**2) * m.σy**2)
    ED1 = ED0 * (m.Pμ[1, :] @ Z_vals)
    
    # Returns
    R0 = ((m.Pμ[0, :] @ (pd + 1)) / pd[0]) * ED0
    R1 = ((m.Pμ[1, :] @ (pd + 1)) / pd[1]) * ED1
    
    # Decomposition
    C1 = np.log(R1 / Rf1) - np.log(R0 / Rf0)    # risk premium
    C2 = -(np.log(ED1) - np.log(ED0))           # cashflow growth
    C3 = np.log(Rf1) - np.log(Rf0)              # risk-free rate
    C = C1 + C2 + C3
    
    return {
        'div_yield_A': div_yield_A,
        'div_yield_T': div_yield_T,
        'log_dy_change': log_dy_change,
        'risk_premium': C1 / C * 100,
        'cashflow': C2 / C * 100,
        'riskfree': C3 / C * 100
    }

def compute_channel_contributions(params_path):
    '''Compute contribution of each redistribution channel.'''
    with open(params_path, 'r') as f:
        p = json.load(f)
    
    orig = {k: p[k] for k in ['xi', 'Delta_tau', 'Delta_tau_div', 'Delta_theta', 'Delta_nu']}
    results = []
    
    # 1. Only competition (xi)
    p['Delta_tau'], p['Delta_tau_div'], p['Delta_theta'], p['Delta_nu'] = 0, 0, 0, 0
    m = DemocratizationModel.__new__(DemocratizationModel)
    _init_from_dict(m, p)
    r1 = compute_results(m)['log_dy_change']
    results.append(('competition', r1))
    
    # 2. Add taxes
    p['Delta_tau'], p['Delta_tau_div'] = orig['Delta_tau'], orig['Delta_tau_div']
    _init_from_dict(m, p)
    r2 = compute_results(m)['log_dy_change']
    results.append(('taxes', r2 - r1))
    
    # 3. Add inequality
    p['Delta_theta'] = orig['Delta_theta']
    _init_from_dict(m, p)
    r3 = compute_results(m)['log_dy_change']
    results.append(('inequality', r3 - r2))
    
    # 4. Add corruption
    p['Delta_nu'] = orig['Delta_nu']
    _init_from_dict(m, p)
    r4 = compute_results(m)['log_dy_change']
    results.append(('corruption', r4 - r3))
    
    return {name: (val / r4) * 100 for name, val in results}

def _init_from_dict(m, p):
    '''Initialize model from dictionary (helper for channel contributions).'''
    m.β, m.γ, m.ψ = p['beta'], p['gamma'], p['psi']
    m.α = (1 - m.γ) / (1 - (1 / m.ψ))
    m.δ, m.θA, m.Δθ = p['delta'], p['theta_A'], p['Delta_theta']
    m.yA, m.ΔyD, m.σy = p['y_A'], p['Delta_y_D'], p['sigma_y']
    m.νA, m.Δν = p['nu_A'], p['Delta_nu']
    m.τA, m.Δτ, m.Δτd = p['tau_A'], p['Delta_tau'], p['Delta_tau_div']
    m.q, m.Hf, m.ξ, m.Υ = p['q'], p['H_f'], p['xi'], p['Upsilon']
    m.Pμ = np.array(p['P_mu'])
    m.higher_growth = p.get('higher_growth', False)
    m._compute_derived_params()

def limited_participation_effect():

    m = DemocratizationModel(PARAMS_PATH)
    κ = m.solve_κ()
    pd = m.solve_pd(κ)
    
    κp = m.solve_κp()
    pdp = m.solve_pdp(κp)
    # Citizens dividend yield rises by 6.6%
    citizens_div_yld_change = -(np.log(pdp[1]) - np.log(pdp[0]))
    print(f"Citizens dividend rises by {citizens_div_yld_change*100:.1f}")

    pd_limited_part = .23 * pdp[1] + .77 * pd[1]
    # If citizens participated it would lead to 14.9% higher dividend yield
    limited_participation_div_yld_change = -(np.log(pd_limited_part) - np.log(pd[0]))
    print(f"Limited participation would lead to {limited_participation_div_yld_change*100:.1f}% higher dividend yield")

    return citizens_div_yld_change, limited_participation_div_yld_change

def higher_growth_effect():

    m = DemocratizationModel(PARAMS_PATH_HIGHER_GROWTH)
    κ = m.solve_κ()
    pd = m.solve_pd(κ)
    # 24% of consumption growth comes from increased competition offsets the effect
    higher_growth_div_yld_change = np.log(pd[1]) - np.log(pd[0])
    print(higher_growth_div_yld_change)
    
    return higher_growth_div_yld_change, m.hg_adj

# %% ==========================================================================
# Run script
# =============================================================================

if __name__ == '__main__':
    main()

# %%
