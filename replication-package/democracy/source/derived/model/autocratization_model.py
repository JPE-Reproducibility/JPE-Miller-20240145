'''
Purpose: Simplified Autocratization Model
Primary author: Max Miller
Date: 2025
Details: Model of autocratic reversals. Uses same params as democratization model.
'''

import json
import numpy as np
from pathlib import Path
from scipy.optimize import fmin
import warnings
warnings.filterwarnings('ignore')


class AutocratizationModel:
    '''Model of autocratic reversals where Elites can attempt to overthrow democracy.'''
    
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
        
        # Uncertainty and dividend parameters
        self.q = p['q']
        self.Hf = p['H_f']
        self.ξ = p['xi']
        self.Υ = p['Upsilon']
        
        # Autocratization transition: [fail, continue, succeed]
        self.Qg = np.array(p.get('Q_g', [0.10, 0.80, 0.10]))
        
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
        
        # After-tax incomes
        self.ŷDrH = self._ŷ(self.τH, self.srDH, self.sgrDH, self.ωH)
        self.ŷDrL = self._ŷ(self.τL, self.srDL, self.sgrDL, self.ωL)
        self.ŷAr = self._ŷ(self.τA, self.srA, self.sgrA, self.ωL)
        self.ŷDr = (self.ŷDrH + self.ŷDrL) / 2  # Average democracy income
        
        # Value functions
        self.vA = (((1 - self.β) / (1 - self.βsA))**(1 / (1 - 1/self.ψ))) * self.ŷAr
        self.vD = (((1 - self.β) / (1 - self.βsD))**(1 / (1 - 1/self.ψ))) * self.ŷDr
    
    def _ŷ(self, τ, s, sg, ω):
        '''After-tax income.'''
        return (1 - τ) * s + (sg * τ - 0.5 * ω * τ**2)
    
    def _χ(self, power, Z):
        '''Disaster outcome for autocratization.'''
        χF = ((self.ŷDr * (1 - Z)) / self.ŷDr)**power
        χS = (self.ŷAr / self.ŷDr)**power
        return np.array([χF, 1, χS])
    
    def solve_vT(self, Z):
        '''Solve for value function during transition.'''
        def objective(vT):
            vDF = self.vD * (1 - Z)
            vgrid = np.array([vDF, vT[0], self.vA])
            Δ = vT[0]**(1 - 1/self.ψ) - (1 - self.β) * self.ŷDr**(1 - 1/self.ψ) - \
                self.βsA * (self.Qg @ (vgrid**(1 - self.γ)))**((1 - 1/self.ψ) / (1 - self.γ))
            return Δ**2
        
        return fmin(objective, [6], ftol=1e-10, disp=False)[0]
    
    def solve_Zstar(self):
        '''Find Z* that makes Elites indifferent between democracy and autocratization.'''
        def objective(Z):
            vT = self.solve_vT(Z[0])
            return abs(vT - self.vD)
        
        return fmin(objective, [0.5], ftol=1e-10, disp=False)[0]
    
    def solve_κ(self, Z):
        '''Solve for consumption-wealth ratio given Z.'''
        χg = self._χ(1 - self.γ, Z)
        
        def objective(κ):
            Δ = np.array([
                κ[0] - 1 - self.βsA * (κ[0]**self.α)**(1/self.α),
                κ[1] - 1 - self.βsA * (self.Qg @ ((κ**self.α) * χg))**(1/self.α),
                κ[2] - 1 - self.βsA * (κ[2]**self.α)**(1/self.α)
            ])
            return Δ.T @ Δ
        
        return fmin(objective, [20, 20, 25], ftol=1e-8, disp=False)
    
    def solve_pd(self, Z, κ):
        '''Solve for price-dividend ratio given Z and κ.'''
        χg = self._χ(self.Υ - self.γ, Z)
        βA = (self.β**self.α) * np.exp(
            (self.Υ - self.γ) * self.yA + 0.5 * ((self.Υ - self.γ)**2) * self.σy**2
        )
        
        def objective(pd):
            Δ = np.array([
                pd[0] - βA * ((κ[0] / (κ[0] - 1))**(self.α - 1) * (pd[0] + 1)),
                pd[1] - βA * (self.Qg @ ((κ / (κ[1] - 1))**(self.α - 1) * χg * (pd + 1))),
                pd[2] - βA * ((κ[2] / (κ[2] - 1))**(self.α - 1) * (pd[2] + 1))
            ])
            return Δ.T @ Δ
        
        return fmin(objective, [20, 20, 25], ftol=1e-10, disp=False)
    
    def compute_baseline(self):
        '''Compute baseline results.'''
        cg = self.ŷAr / self.ŷDr
        Z = self.solve_Zstar()
        κ = self.solve_κ(Z)
        pd = self.solve_pd(Z, κ)
        Δdp = np.log(1 / pd[1]) - np.log(1 / pd[0])
        return {'cg': cg, 'Z': Z, 'Δdp': Δdp, 'pd': pd}
    
    def compute_range(self, cg_min=1.0, cg_max=1.5, n=501):
        '''Compute results for a range of consumption growth values.'''
        original_ŷAr = self.ŷAr
        original_vA = self.vA
        results = []
        
        for cg in np.linspace(cg_min, cg_max, n):
            self.ŷAr = self.ŷDr * cg
            self.vA = (((1 - self.β) / (1 - self.βsA))**(1 / (1 - 1/self.ψ))) * self.ŷAr
            
            Z = self.solve_Zstar()
            κ = self.solve_κ(Z)
            pd = self.solve_pd(Z, κ)
            Δdp = np.log(1 / pd[1]) - np.log(1 / pd[0])
            results.append([cg, Z, Δdp])
        
        self.ŷAr = original_ŷAr
        self.vA = original_vA
        return results


if __name__ == '__main__':
    JSON_PATH = Path(__file__).parent / 'model_params.json'
    m = AutocratizationModel(JSON_PATH)
    
    baseline = m.compute_baseline()
    print(f"Baseline consumption growth: {baseline['cg']:.3f}")
    print(f"Z* (failure penalty): {baseline['Z']:.3f}")
    print(f"Log dividend yield change: {baseline['Δdp']:.3f}")
