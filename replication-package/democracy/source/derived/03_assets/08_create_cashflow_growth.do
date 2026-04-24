/*
Purpose: create dividend growth
Primary author: Max Miller
Date: 11-23-2025
*/

* ==============================================================================
* Housekeeping
* ==============================================================================

clear all
version 19
adopath ++ "source/utils/analysis"
* ==============================================================================
* Set globals
* ==============================================================================

global ASSETS_DERIVED 		"datastore/derived/assets"
global CROSSWALKS 			"datastore/raw/crosswalks"
global MACRO_POLITICAL_DERIVED		"datastore/derived/macro_political"

global START_YEAR = 1816
global END_YEAR = 2018

* ==============================================================================
* Main execution logic
* ==============================================================================

program main

	use "${ASSETS_DERIVED}/all_equity_returns.dta", clear
	merge 1:1 country year using "${ASSETS_DERIVED}/all_div_yld.dta", nogen

	** Dividend growth
	gen gfd_div_g = (1+gfd_div_yld_g)*(1+gfd_eq_capgain)-1
	gen jst_div_g = (1+jst_div_yld_g)*(1+jst_eq_capgain)-1
	gen gfd_lse_div_g = (1+gfd_lse_div_yld_g)*(1+gfd_lse_eq_capgain)-1
	gen ibes_div_g = exp(log_ibes_div_yld_g)*(1+ibes_eq_capgain)-1
	gen factset_div_g = exp(log_factset_div_yld_g)*(1+factset_eq_capgain)-1
	winsor2 *_div_g, c(1 99) replace // the very high values of dividend growth are throwing off the regression (like more than 500% dividend growth)

	** Log dividend growth
	gen log_gfd_div_g = log(1+gfd_div_g)
	gen log_jst_div_g = log(1+jst_div_g)
	gen log_gfd_lse_div_g = log(1+gfd_lse_div_g)
	gen log_ibes_div_g = log(1+ibes_div_g)
	gen log_factset_div_g = log(1+factset_div_g)

	gen all_div_g = gfd_div_g
	replace all_div_g = jst_div_g if all_div_g == .
	replace all_div_g = gfd_lse_div_g if all_div_g == .
	replace all_div_g = ibes_div_g if all_div_g == .
	replace all_div_g = factset_div_g if all_div_g == .

	gen log_all_div_g = log(1+all_div_g)

	keep country year all_div_g log_all_div_g

	save "${ASSETS_DERIVED}/all_cashflow_growth.dta", replace

end
	
* ==============================================================================
* Run script
* ==============================================================================

main
	
