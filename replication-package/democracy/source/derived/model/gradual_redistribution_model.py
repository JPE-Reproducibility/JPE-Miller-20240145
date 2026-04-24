'''
Purpose: Generate Table 11 - Model Calibration
Primary author: Max Miller
Date: 2025
'''
# %% ==========================================================================
# Load in modules
# =============================================================================

import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
from math import gamma
from scipy.optimize import fmin
from scipy.optimize import differential_evolution
import json
from source.config import ROOT_PATH

PARAMS_PATH = ROOT_PATH / 'source/derived/model/baseline_params.json'

# ========================================================================================================
# Parameters
# ========================================================================================================

with open(PARAMS_PATH, 'r') as f:
    p = json.load(f)

# Preference parameters
β, γ, ψ  = p['beta'], p['gamma'], p['psi']
α = (1-γ)/(1-(1/ψ))

# Production process
yA, σy, ξ  = p['y_A'], p['sigma_y'], p['xi']
q, Hf = p['q'], p['H_f']
Υ  = p['Upsilon']

ΔyD = .0095
yrH = yA - (Hf/q)*ΔyD
yrL = yA - ((1-Hf)/(1-q))*ΔyD

# Unpack grid and transition matrix for μ and τ
Pμ = np.array(p['P_mu'])

βsA   = β*np.exp((1-1/ψ)*yA + .5*(1-γ)*(1-1/ψ)*σy**2)     # Adjusted beta in autocracy
βsDH   = β*np.exp((1-1/ψ)*yrH + .5*(1-γ)*(1-1/ψ)*σy**2)     # Adjusted beta in democracy
βsDL   = β*np.exp((1-1/ψ)*yrL + .5*(1-γ)*(1-1/ψ)*σy**2)     # Adjusted beta in democracy

# Third state wealth consunption ratio
κ_H = 1/(1 - βsDH)
κ_L = 1/(1 - βsDL)

# Third state price dividend ratio
βpdA  = (β**α)*np.exp((Υ-γ)*yA + .5*((Υ-γ)**2)*σy**2)                   # Adjusted beta in democracy
βpdDH = β*np.exp((Υ-1/ψ)*yrH + .5*((Υ-γ)**2 + (1-γ)*(γ-1/ψ))*σy**2)     # Adjusted beta in democracy
βpdDL = β*np.exp((Υ-1/ψ)*yrL + .5*((Υ-γ)**2 + (1-γ)*(γ-1/ψ))*σy**2)     # Adjusted beta in democracy

pd_H = βpdDH/(1-βpdDH)
pd_L = βpdDL/(1-βpdDL)

# %% =====================================================================================================
# Create PD and consumption-wealth ratio functions
# ========================================================================================================

# Consumption-wealth ratio
def consumptionWealth(κ0):

    κα3 = q * κ_H**α * np.exp(-(1-γ)*yrH) + (1-q) * κ_L**α * np.exp(-(1-γ)*yrL)
    κα = [κ0[0]**α, κ0[1]**α, κα3] 

    Δ = np.array([
                  κ0[0] - 1 - βsA*(Pμ[0,:] @ κα )**(1/α),
                  κ0[1] - 1 - βsA*(Pμ[1,:] @ κα )**(1/α),
    ])

    return(Δ.T @ Δ)

def priceDividend(pd0):

    pd3 = q * κ_H**(α-1) * (1+pd_H) * np.exp(-(Υ-γ)*yrH) + (1-q) * κ_L**(α-1) * (1+pd_L) * np.exp(-(Υ-γ)*yrL)
    pd_trans = np.array([κ[0]**(α-1) * (1+pd0[0]), κ[1]**(α-1) * (1+pd0[1]), pd3])

    Δ = np.array([
                  pd0[0] - βpdA * (Pμ[0,:] @ (pd_trans * (κ[0]-1)**(1-α)) ),
                  pd0[1] - βpdA * (Pμ[1,:] @ (pd_trans * (κ[1]-1)**(1-α)) ),
    ])

    return Δ.T @ Δ

# %% =====================================================================================================
# Run optimizer
# ========================================================================================================

κ = fmin(func   = consumptionWealth,
         x0     = [20,20],
         ftol   = 0.00000001,
         disp   = True
        )

pd = fmin(func   = priceDividend,
                x0     = [20,20],
                ftol   = 1**(-10),
                disp   = True
               )

# %% =====================================================================================================
# Get change in dividend yield
# ========================================================================================================

Δdp = np.log(1/pd[1]) - np.log(1/pd[0])

print(pd)
print(Δdp)
print(1/pd[1] - 1/pd[0])
print(1/pd)

# %%
