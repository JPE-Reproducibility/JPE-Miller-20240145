program define lp
    // Define required arguments and options
    syntax varlist(min=2 max=2) [if] [in] ///
        , tlags(numlist integer min=1 max=2) /// Required number of lags (or lags and leads)
        reflag(integer) /// Required reference lag
        absorb(varlist) /// Required fixed effects specification
        cluster(varlist) /// Required clustering of SE
        shocklags(integer) /// number of lags for shocks
        [controls(varlist)] /// Optional control variables
    
    // Assign variables from the `syntax` command to locals
    local outcome "`1'"  // Outcome variable from varlist
    local shock "`2'"  // Treatment variable from varlist
    local controls "`controls'"  // Control variables from options
    
	// Parse tlags - can be either single value or two values (lags and leads)
    tokenize `tlags'
    local n_lag "`1'"  // Number of lags
    if "`2'" == "" {
        local n_lead "`1'"  // If only one value, use same for leads
    }
    else {
        local n_lead "`2'"  // Otherwise use second value for leads
    }
    
    local ref_lag "`reflag'"  // Reference lag
    local fe_spec "`absorb'"  // Fixed effects specification
    local clustering "`cluster'"
    
    local total_obs = `n_lag' + `n_lead' + 1
        
    preserve
    
    forvalues i = 1(1)`shocklags' {
        gen _l`i'_treat = L`i'.`shock'
    }
    
    if `shocklags' == 0 {
        local lag_shock_vars ""
    }
    else {
        local lag_shock_vars "_l*_treat"
    }
	
    // Run regressions and collect results
    mat results = J(`total_obs', 3, .)
    local j = 1
    
    forvalues i = -`n_lag'(1)`n_lead' {
        if `i' < 0 {
            local k = -`i'
            qui gen temp_`outcome' = L`k'.`outcome' - L`ref_lag'.`outcome'
        }
        else if `i' >= 0 {
            qui gen temp_`outcome' = F`i'.`outcome' - L`ref_lag'.`outcome'
        }
        
        reghdfe temp_`outcome' `shock' `controls' `lag_shock_vars' `if'`in', absorb(`fe_spec') cluster(`clustering')
        
        mat results[`j', 1] = `i'
        mat results[`j', 2] = _b[`shock']
        mat results[`j', 3] = _se[`shock']
        
        local j = `j' + 1
        drop temp_`outcome'
    }
	
end