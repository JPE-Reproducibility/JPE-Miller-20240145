'''
Purpose: Simplified Democratization Model
Primary author: Max Miller
Date: 2025
Details: Loads parameters from JSON and solves for consumption-wealth ratio
         and price-dividend ratio. Analysis functions live in source/analysis/model/.
'''

import json
import numpy as np
from pathlib import Path
from scipy.optimize import fmin
import warnings
warnings.filterwarnings('ignore')


class DemocratizationModel:
    '''Consumption-based asset pricing model with democratic transitions.'''
    
    def __init__(self, json_path):
        '''Initialize model by unpacking parameters from JSON file.'''
        with open(json_path, 'r') as f:
            p = json.load(f)
        
        # Preference parameters
        self.β = p['beta']
        self.γ = p['gamma']
        self.ψ = p['psi']
        self.α = (1 - self.γ) / (1 - (1 / self.ψ))
        
        # Production parameters
        self.δ = p['delta']
        self.θA = p['theta_A']
        self.Δθ = p['Delta_theta']
        self.yA = p['y_A']
        self.ΔyD = p['Delta_y_D']
        self.σy = p['sigma_y']
        self.νA = p['nu_A']
        self.Δν = p['Delta_nu']
        
        # Tax parameters
        self.τA = p['tau_A']
        self.Δτ = p['Delta_tau']
        self.Δτd = p['Delta_tau_div']
        
        # Uncertainty and dividend parameters
        self.q = p['q']
        self.Hf = p['H_f']
        self.ξ = p['xi']
        self.Υ = p['Upsilon']
        self.Pμ = np.array(p['P_mu'])
        
        # Higher growth variant (optional)
        self.higher_growth = p.get('higher_growth', False)
        self.hg_rate = p.get('higher_growth_rate', 0.0)
        self.hg_years = p.get('higher_growth_years', 0)
        self.hg_adj = p.get('incumbent_loss_adj', 0)
        
        self._compute_derived_params()
    
    def _compute_derived_params(self):
        '''Compute derived parameters from base parameters.'''
        self.yD = self.yA + self.ΔyD
        
        # Inequality parameters
        self.θDH = self.θA - (self.Hf / self.q) * self.Δθ
        self.θDL = self.θA - ((1 - self.Hf) / (1 - self.q)) * self.Δθ
        
        # Rent diversion
        self.νDH = self.νA - (self.Hf / self.q) * self.Δν
        self.νDL = self.νA - ((1 - self.Hf) / (1 - self.q)) * self.Δν
        
        # Tax parameters
        self.τH = self.τA + (self.Hf / self.q) * self.Δτ
        self.τL = self.τA + ((1 - self.Hf) / (1 - self.q)) * self.Δτ
        self.ωH = (self.θDH - self.δ) / (self.τH * (1 - self.δ))
        self.ωL = (self.θDL - self.δ) / (self.τL * (1 - self.δ))
        
        # Adjusted betas
        term = 0.5 * (1 - self.γ) * (1 - 1/self.ψ) * self.σy**2
        self.βsA = self.β * np.exp((1 - 1/self.ψ) * self.yA + term)
        self.βsD = self.β * np.exp((1 - 1/self.ψ) * self.yD + term)
        
        # Elite income shares
        self.srA = self.θA / self.δ
        self.srDH = self.θDH / self.δ
        self.srDL = self.θDL / self.δ
        self.sgrA = self.νA / self.δ
        self.sgrDH = self.νDH / self.δ
        self.sgrDL = self.νDL / self.δ
        
        # Citizen income shares
        self.spA = (1 - self.θA) / (1 - self.δ)
        self.spDH = (1 - self.θDH) / (1 - self.δ)
        self.spDL = (1 - self.θDL) / (1 - self.δ)
        self.sgpA = (1 - self.νA) / (1 - self.δ)
        self.sgpDH = (1 - self.νDH) / (1 - self.δ)
        self.sgpDL = (1 - self.νDL) / (1 - self.δ)
        
        # After-tax incomes (Elites)
        self.ŷDrH = self._ŷ(self.τH, self.srDH, self.sgrDH, self.ωH)
        self.ŷDrL = self._ŷ(self.τL, self.srDL, self.sgrDL, self.ωL)
        self.ŷAr = self._ŷ(self.τA, self.srA, self.sgrA, self.ωL)
        
        # After-tax incomes (Citizens)
        self.ŷDpH = self._ŷ(self.τH, self.spDH, self.sgpDH, self.ωH)
        self.ŷDpL = self._ŷ(self.τL, self.spDL, self.sgpDL, self.ωL)
        self.ŷAp = self._ŷ(self.τA, self.spA, self.sgpA, self.ωL)
    
    def _ŷ(self, τ, s, sg, ω):
        '''After-tax income.'''
        return (1 - τ) * s + (sg * τ - 0.5 * ω * τ**2)
    
    def _χ(self, power):
        '''Disaster outcome for Elites. Note the 0.8 and 0.2 come the dividend tax in autocracy'''
        if self.higher_growth:
            ZDH = 1 - (self.Hf / self.q) * (1 - ((1 - (0.2 + self.Δτd)) / 0.8) * self.ξ)
            ZDL = 1 - ((1 - self.Hf) / (1 - self.q)) * (1 - ((1 - (0.2 + self.Δτd)) / 0.8) * self.ξ)
            hg_term = self.hg_rate * self.hg_years
            χTH = (self.ŷDrH / self.ŷAr + hg_term - (1 - ZDH) * self.hg_adj)**power
            χTL = (self.ŷDrL / self.ŷAr + hg_term - (1 - ZDL) * self.hg_adj)**power
        else:
            χTH = (self.ŷDrH / self.ŷAr)**power
            χTL = (self.ŷDrL / self.ŷAr)**power
        return self.q * χTH + (1 - self.q) * χTL
    
    def _χp(self, power):
        '''Disaster outcome for Citizens.'''
        χTH = (self.ŷDpH / self.ŷAp)**power
        χTL = (self.ŷDpL / self.ŷAp)**power
        return self.q * χTH + (1 - self.q) * χTL
    
    def _χD(self, power):
        '''Cashflow drop for incumbent dividend claim (Elites).'''
        ZDH = 1 - (self.Hf / self.q) * (1 - ((1 - (0.2 + self.Δτd)) / 0.8) * self.ξ)
        ZDL = 1 - ((1 - self.Hf) / (1 - self.q)) * (1 - ((1 - (0.2 + self.Δτd)) / 0.8) * self.ξ)
        χTH = (self.ŷDrH / self.ŷAr)**power
        χTL = (self.ŷDrL / self.ŷAr)**power
        return self.q * χTH * ZDH + (1 - self.q) * χTL * ZDL
    
    def _χDp(self, power):
        '''Cashflow drop for incumbent dividend claim (Citizens).'''
        ZDH = 1 - (self.Hf / self.q) * (1 - ((1 - (0.2 + self.Δτd)) / 0.8) * self.ξ)
        ZDL = 1 - ((1 - self.Hf) / (1 - self.q)) * (1 - ((1 - (0.2 + self.Δτd)) / 0.8) * self.ξ)
        χTH = (self.ŷDpH / self.ŷAp)**power
        χTL = (self.ŷDpL / self.ŷAp)**power
        return self.q * χTH * ZDH + (1 - self.q) * χTL * ZDL
    
    def solve_κ(self):
        '''Solve for consumption-wealth ratio (Elites).'''
        χg = np.array([1, 1, self._χ(1 - self.γ)])
        
        def objective(κ):
            Δ = np.array([
                κ[0] - 1 - self.βsA * (self.Pμ[0, :] @ ((κ**self.α) * χg))**(1/self.α),
                κ[1] - 1 - self.βsA * (self.Pμ[1, :] @ ((κ**self.α) * χg))**(1/self.α),
                κ[2] - 1 - self.βsD * (self.Pμ[2, :] @ (κ**self.α))**(1/self.α)
            ])
            return Δ.T @ Δ
        
        return fmin(objective, [20, 20, 25], ftol=1e-8, disp=False)
    
    def solve_κp(self):
        '''Solve for consumption-wealth ratio (Citizens).'''
        χg = np.array([1, 1, self._χp(1 - self.γ)])
        
        def objective(κ):
            Δ = np.array([
                κ[0] - 1 - self.βsA * (self.Pμ[0, :] @ ((κ**self.α) * χg))**(1/self.α),
                κ[1] - 1 - self.βsA * (self.Pμ[1, :] @ ((κ**self.α) * χg))**(1/self.α),
                κ[2] - 1 - self.βsD * (self.Pμ[2, :] @ (κ**self.α))**(1/self.α)
            ])
            return Δ.T @ Δ
        
        return fmin(objective, [20, 20, 25], ftol=1e-8, disp=False)
    
    def solve_pd(self, κ):
        '''Solve for price-dividend ratio (Elites).'''
        βA = (self.β**self.α) * np.exp(
            (self.Υ - self.γ) * self.yA + 0.5 * ((self.Υ - self.γ)**2) * self.σy**2
        )
        βD = (self.β**self.α) * np.exp(
            (self.Υ - self.γ) * self.yD + 0.5 * ((self.Υ - self.γ)**2) * self.σy**2
        )
        χgD = np.array([1, 1, self._χD(-self.γ)])
        
        def objective(pd):
            Δ = np.array([
                pd[0] - βA * (self.Pμ[0, :] @ ((κ / (κ[0] - 1))**(self.α - 1) * χgD * (pd + 1))),
                pd[1] - βA * (self.Pμ[1, :] @ ((κ / (κ[1] - 1))**(self.α - 1) * χgD * (pd + 1))),
                pd[2] - βD * (self.Pμ[2, :] @ ((κ / (κ[2] - 1))**(self.α - 1) * (pd + 1)))
            ])
            return Δ.T @ Δ
        
        return fmin(objective, [20, 20, 25], ftol=1e-10, disp=False)
    
    def solve_pdp(self, κp):
        '''Solve for price-dividend ratio (Citizens).'''
        βA = (self.β**self.α) * np.exp(
            (self.Υ - self.γ) * self.yA + 0.5 * ((self.Υ - self.γ)**2) * self.σy**2
        )
        βD = (self.β**self.α) * np.exp(
            (self.Υ - self.γ) * self.yD + 0.5 * ((self.Υ - self.γ)**2) * self.σy**2
        )
        χgD = np.array([1, 1, self._χDp(-self.γ)])
        
        def objective(pd):
            Δ = np.array([
                pd[0] - βA * (self.Pμ[0, :] @ ((κp / (κp[0] - 1))**(self.α - 1) * χgD * (pd + 1))),
                pd[1] - βA * (self.Pμ[1, :] @ ((κp / (κp[1] - 1))**(self.α - 1) * χgD * (pd + 1))),
                pd[2] - βD * (self.Pμ[2, :] @ ((κp / (κp[2] - 1))**(self.α - 1) * (pd + 1)))
            ])
            return Δ.T @ Δ
        
        return fmin(objective, [20, 20, 25], ftol=1e-10, disp=False)


if __name__ == '__main__':
    from source.config import ROOT_PATH

    # Baseline model
    print("=== Baseline Model ===")
    m = DemocratizationModel(ROOT_PATH / 'source/derived/model/baseline_params.json')
    κ = m.solve_κ()
    pd = m.solve_pd(κ)
    print(f"Elites κ: {κ}")
    print(f"Elites pd: {pd}")
    print(f"Div yield change: {np.log(1/pd[1]) - np.log(1/pd[0]):.3f}")
    
    # Higher growth model
    print("\n=== Higher Growth Model ===")
    m_hg = DemocratizationModel(ROOT_PATH / 'source/derived/model/baseline_params_higher_growth.json')
    κ_hg = m_hg.solve_κ()
    pd_hg = m_hg.solve_pd(κ_hg)
    print(f"Elites κ: {κ_hg}")
    print(f"Elites pd: {pd_hg}")
    print(f"Div yield change: {np.log(1/pd_hg[1]) - np.log(1/pd_hg[0]):.3f}")
