
global CI_MULTIPLIER 1.96

program stacked_did
    // Define required arguments and options
    syntax varlist(min=2 max=2) [if] [in] ///
        , i(varlist) 			/// cross-sectional identifier
		t(varlist) 				/// time variable
		tlags(integer) 			/// Required number of lags
        reflag(integer) 		/// Required reference lag
		[extra_fe(varlist)] 	/// Optional extra fixed effects to absorb
		[controls(varlist)] 	/// Optional control variables
		[savedata(string)]		/// Option to save the stacked_did data
		
    local outcome "`1'"  // Outcome variable from varlist
    local treatment "`2'"  // Treatment variable from varlist
    local controls "`controls'"  // Control variables from options
	
    * Define total number of observations for the event study window
    local total_obs = 2 * `tlags' + 1
	
	preserve
	
	tempfile main_data
	save `main_data'
	
	levelsof `t' if `treatment' == 1, local(eventyear)
	foreach eventyr of local eventyear {
		
		use `main_data', clear
		
		* Include yet-to-be-treated as controls, in addition to never treated
		gen dummy = (`t' == `eventyr') & (`treatment' == 1)
		bysort `i': egen treated = max(dummy)
		
		gen _t_exit = `t' - `eventyr'
		assert !missing(_t_exit)

		keep if inrange(_t_exit,-`tlags', `tlags')	
		gen cohort = `eventyr'
			
		sort cohort `i' `t' 
		
		keep `i' _t_exit cohort treated `outcome' `controls' `extra_fe'
		
		tempfile cohort_`eventyr'
		save `cohort_`eventyr''
				
	}

	clear
	foreach eventyr of local eventyear {
		append using `cohort_`eventyr''
	}

	egen time = group(_t_exit cohort)
	egen i = group(`i')
	
	bys cohort: egen min_time = min(_t_exit)
	bys cohort: egen max_time = max(_t_exit)
	drop if min_time != -`tlags' | max_time != `tlags'
	sort i time
	
	gen _d_shifted = (_t_exit + `tlags' + 1)	
	xtset i time
	
	// Specify whether observations should be the same in all regressions
    if "`savedata'" != "" {
        save `savedata', replace
    }
    else {
        di "Stacked DiD data will not be saved"
    }
	
    * Define the position of the reference lag for baseline comparison
    local lag_pos = `tlags' + 1 - `reflag'

	if "`extra_fe'" != "" {
		local fe_spec absorb(i time#`extra_fe')
	}
	else {
		local fe_spec absorb(i time)
	}
	
    reghdfe `outcome' ib`lag_pos'._d_shifted##i.treated `controls' , `fe_spec' cluster(i time)
	
	mat results = J(`total_obs',4,.)
	forvalues i=1(1)`total_obs'{
		mat results[`i',1] = `i'
		mat results[`i',2] = _b[i`i'._d_shifted#1.treated]
		mat results[`i',3] = _b[i`i'._d_shifted#1.treated] + ${CI_MULTIPLIER}*_se[i`i'._d_shifted#1.treated]
		mat results[`i',4] = _b[i`i'._d_shifted#1.treated] - ${CI_MULTIPLIER}*_se[i`i'._d_shifted#1.treated]
	}

	rename _t_exit t
	
	clear
	cap drop t pe ub lb store_mat_line
	svmat results
	rename results1 t
	rename results2 pe
	rename results3 ub
	rename results4 lb
	gen store_mat_line = 0

    * Adjust labels for time periods
    cap label drop tplus
    label define tplus ///
        9999 "Something Random"
        
    forvalues j = 1/`total_obs' {
        local i = `j' - `tlags' - 1  // Adjusts the index to start from 0
        if `i' < 0 {
            label define tplus `j' "t`i'", add
        }
        else if `i' == 0 {
            label define tplus `j' "t", add
        }
        else {
            label define tplus `j' "t+`i'", add
        }
    }

    label values t tplus
	
	local labSize = "large"
	two (rcap lb ub t, color(red) msymbol(s)) ///
		(connected pe t, lp(solid) color(red) msymbol(s) lw(.6)) ///
		(line store_mat_line t, color(black) lp(dash) lw(.33)), ///
		xlabel(1(1)`total_obs', valuelabel nogrid labsize(`labSize')) graphregion(color(white)) ylabel(, nogrid labsize(`labSize')) ///
		xtitle("") bgcolor(white) subtitle(" ") ///
		legend(off) ysize(3.5)
	
	restore
	
end