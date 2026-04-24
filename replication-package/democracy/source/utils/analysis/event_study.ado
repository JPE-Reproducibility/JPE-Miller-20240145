* ==============================================================================
* TWFE event study
* ==============================================================================

program define event_study
    // Define required arguments and options
    syntax varlist(min=2 max=2) [if] [in] ///
        , tlags(numlist integer min=2 max=2) /// Required: lags leads
        reflag(integer) /// Required reference lag
        cluster(varlist) /// Required clustering of SE
        [absorb(varlist)] /// Required fixed effects specification
		[controls(varlist)] /// Optional control variables
        [savedata(string)] /// Optional savedata name
        [country_time_trend]
		
    // Assign variables from the `syntax` command to locals
    local outcome "`1'"  // Outcome variable from varlist
    local treatment "`2'"  // Treatment variable from varlist
    local controls "`controls'"  // Control variables from options
    local n_lag : word 1 of `tlags'  // Number of lags
    local n_lead : word 2 of `tlags'  // Number of leads
    local ref_lag "`reflag'"  // Reference lag
    local fe_spec "`absorb'"  // Fixed effects specification
	
	// Remove any trailing commas that might cause issues
	local treatment : subinstr local treatment "," "", all

    * Define total number of observations for the event study window
    local total_obs = `n_lag' + `n_lead' + 1

    preserve

    qui {
        levelsof year, local(years)
        local n_years : word count `years'
    }

    * 1. Create lead/lag indicators
    forval i = 0/`n_years' {
        cap gen L`i'_treat = cond(missing(L`i'.`treatment'), 0, L`i'.`treatment')
    }
    forval i = 1/`n_years' {
        cap gen F`i'_treat = cond(missing(F`i'.`treatment'), 0, F`i'.`treatment')
    }

    local n_lead_p = `n_lead' + 1
    local n_lag_p = `n_lag' + 1

    * 2. Bin endpoints outside window
    egen F_bin = rowmax(F`n_lag_p'_treat-F`n_years'_treat)
    egen L_bin = rowmax(L`n_lead_p'_treat-L`n_years'_treat)

    local vars ""
    forvalues i = `n_lag'(-1)1 {
        local vars "`vars' F`i'_treat"
    }
    forvalues i = 0/`n_lead' {
        local vars "`vars' L`i'_treat"
    }

    di "`vars'"
    * 3. Run regression

    if "`absorb'" == "" {
        local absorb "noabsorb"
    }
    else {
        local absorb "absorb(`absorb')"
    }

    if "`country_time_trend'" != "" {
        local tt "i.country_id#c.year"
    }
    else {
        local tt ""
    }

    reghdfe `outcome' `vars' F_bin L_bin `controls' `tt' `if' `in', `absorb' vce(cluster `cluster')

    * 4. Extract coefficients relative to reference lag
    mat results = J(`total_obs',3,.)
    local row = 1
    foreach v in `vars' {
        qui lincom `v' - F`ref_lag'_treat
        mat results[`row', 1] = `row' - `n_lag' - 1
        mat results[`row', 2] = r(estimate)
        mat results[`row', 3] = r(se)
        local ++row
    }

	clear
	svmat results
	rename results1 t
	rename results2 b_01
	rename results3 se_01
	gen lo_01 = b_01 - 1.96*se_01
	gen hi_01 = b_01 + 1.96*se_01

	two (line b_01 t, color(red)) (rarea lo_01 hi_01 t, color(red%50)), ///

    if "`savedata'" != "" {
        save "`savedata'", replace
    }

    restore

end


****** Reminder: this is basically what ESPLOT is doing

/*


* ===========================================================================
* Run event study
* ===========================================================================

program run_event_study
    preserve
    * 1. Create lead/lag indicators
    forval i = 0/203 {
        cap gen L`i'_dem = cond(missing(L`i'.dem_ep_m_bef2), 0, L`i'.dem_ep_m_bef2)
    }
    forval i = 1/203 {
        cap gen F`i'_dem = cond(missing(F`i'.dem_ep_m_bef2), 0, F`i'.dem_ep_m_bef2)
    }

    * 2. Bin endpoints outside window
    egen F_bin = rowmax(F4_dem-F203_dem)
    egen L_bin = rowmax(L8_dem-L203_dem)

    * 3. Run regression
    reghdfe log_all_div_yld ///
        F3_dem F2_dem F1_dem ///
        L0_dem L1_dem L2_dem L3_dem L4_dem L5_dem L6_dem L7_dem ///
        F_bin L_bin ${EVENT_CONTROLS} i.country_id#c.year, ///
        noabsorb vce(cluster year country_id)

    * 4. Extract coefficients using lincom (relative to F1)
    clear
    set obs 11
    gen t = _n - 4
    gen b = .
    gen se = .

    local row = 1
    foreach v in F3 F2 F1 L0 L1 L2 L3 L4 L5 L6 L7 {
        qui lincom `v'_dem - F1_dem
        replace b = r(estimate) in `row'
        replace se = r(se) in `row'
        local ++row
    }
    gen lo = b - 1.96*se
    gen hi = b + 1.96*se

    save "${FIGURES}/figure_1_democratization_event_study", replace
    restore

end


*/