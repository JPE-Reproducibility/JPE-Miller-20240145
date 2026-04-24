/*
Purpose: Run Campbell (1991 VAR) for all 5 variable combinations
Primary author: Max Miller
Date: 12-12-2025
*/

clear all
version 19

global ASSETS_DERIVED 			"datastore/derived/assets"
global MACRO_POLITICAL_DERIVED 	"datastore/derived/macro_political"
global PROGRAMS 				"source/derived/programs"

do "${PROGRAMS}/run_campbell_1991_var.do"

global rt   "log_all_eq_tr"
global rft  "log_all_bond_rate"
global div  "log_gfd_div_yld"
global cg   "log_all_eq_capgain"
global gdpg "log_ggdc_gdppc_i_g"
global dy   "log_all_div_yld"

global MIN_OBS = 20

* ==============================================================================
* Main execution logic
* ==============================================================================

program main

	get_var_data
	
	preserve
	keep country_id country
	duplicates drop
	tempfile country_id_map
	save "`country_id_map'"
	restore
	
	tempfile var_data
	save "`var_data'"
	
	* Run VAR for each combination
	local comb1 "$rt $div $rft $cg $gdpg"
	local comb2 "$rt $div $cg $gdpg"
	local comb3 "$rt $div $rft"
	local comb4 "$rt $div $cg"
	local comb5 "$rt $cg $gdpg"
	
	forval i = 1/5 {
		use "`var_data'", clear
		run_var_for_comb `i' "`comb`i''"
		tempfile shocks`i'
		save "`shocks`i''"
	}
	
	* Merge all shocks together
	use "`shocks1'", clear
	forval i = 2/5 {
		merge 1:1 country_id year using "`shocks`i''", nogen
	}
	
	merge m:1 country_id using "`country_id_map'", keep(3) nogen
	drop country_id
	
	foreach var in cf dr {
		gen `var'_news_eq_tr = `var'_news_1
		replace `var'_news_eq_tr = `var'_news_2 if `var'_news_eq_tr == .
		replace `var'_news_eq_tr = `var'_news_3 if `var'_news_eq_tr == .
		replace `var'_news_eq_tr = `var'_news_4 if `var'_news_eq_tr == .
		replace `var'_news_eq_tr = `var'_news_5 if `var'_news_eq_tr == .
	}
	
// 	keep country year dr_news_eq_tr cf_news_eq_tr
	order country year dr_news_eq_tr cf_news_eq_tr
	
	save "${ASSETS_DERIVED}/campbell_1991_var_shocks.dta", replace

end

program run_var_for_comb

	args comb_num varlist
	
	preserve
	
	mat shocks_mat = J(1, 4, .)
	levelsof country_id if ret_obs >= $MIN_OBS & avg_div_yld != .
	local countries = r(levels)

	foreach c of local countries {
		* Check if enough observations for this combination
		local miss_cond "country_id == `c'"
		foreach v of local varlist {
			local miss_cond "`miss_cond' & `v' != ."
		}
		qui count if `miss_cond'
		if r(N) >= $MIN_OBS {
			qui run_campbell_1991_var `c' "`varlist'"
		}
	}
		
	* Convert shocks matrix to dataset
	clear
	svmat shocks_mat
	rename shocks_mat1 year
	rename shocks_mat2 country_id
	rename shocks_mat3 cf_news_`comb_num'
	rename shocks_mat4 dr_news_`comb_num'
	drop if year == .
	
	restore, not

end

program get_var_data

	use "${ASSETS_DERIVED}/all_equity_returns.dta", clear
	merge 1:1 country year using "${ASSETS_DERIVED}/all_fixed_income.dta", nogen
	merge 1:1 country year using "${ASSETS_DERIVED}/all_div_yld.dta", nogen
	merge 1:1 country year using "${MACRO_POLITICAL_DERIVED}/real_gdp.dta", nogen
	sort country year
		
	egen country_id = group(country), label
	tsset country_id year
	
	gen log_all_div_yld = log_gfd_div_yld
	replace log_all_div_yld = log_jst_div_yld if log_all_div_yld == .
	replace log_all_div_yld = log_factset_div_yld if log_all_div_yld == .
	replace log_all_div_yld = log_ibes_div_yld if log_all_div_yld == .
	replace log_all_div_yld = log_gfd_lse_div_yld if log_all_div_yld == .

	keep country_id year country $rt $rft $div $cg $gdpg $dy

	bys country_id: egen ret_obs = total($rt != .)
	drop if ret_obs == 0 | $rt == .

	bys country_id: egen avg_div_yld = mean($dy)
	
end

* ==============================================================================
* Run script
* ==============================================================================

main
