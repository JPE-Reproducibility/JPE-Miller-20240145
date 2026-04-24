/*
Purpose: create investment capital ratio data
Primary author: Max Miller
Date: 11-11-2025
*/

* ==============================================================================
* Housekeeping
* ==============================================================================

clear all
version 19

* ==============================================================================
* Set globals
* ==============================================================================

global PWT_ORIG 				"datastore/raw/pwt/orig"
global MACRO_POLITICAL_DERIVED 	"datastore/derived/macro_political"
global CROSSWALKS				"datastore/raw/crosswalks"

global START_YEAR = 1816
global END_YEAR = 2018

* ==============================================================================
* Main execution logic
* ==============================================================================

program main

	use countrycode year hc rconna using "${PWT_ORIG}/pwt100.dta", clear
	drop if hc == . & rconna == .
	tempfile pwt
	save "`pwt'"

	use countrycode year comp_sh using "${PWT_ORIG}/pwt100-labor-detail.dta", clear
	drop if comp_sh == .
	tempfile pwt_labor
	save "`pwt_labor'"
	
	local Ic_vars Ic_Struc Ic_Mach Ic_TraEq Ic_Other
	local Nc_vars Nc_Struc Nc_Mach Nc_TraEq Nc_Other
	use countrycode year `Ic_vars' `Nc_vars' using "${PWT_ORIG}/pwt100-capital-detail.dta", clear
	
	merge 1:1 countrycode year using "`pwt'", nogen
	merge 1:1 countrycode year using "`pwt_labor'", nogen
	rename countrycode country
	
	gen Ic = Ic_Struc + Ic_Mach + Ic_TraEq + Ic_Other
	gen Nc = Nc_Struc + Nc_Mach + Nc_TraEq + Nc_Other
	gen IK = Ic/Nc
	gen log_IK = log(IK)
	gen log_hc = log(hc)
	
	keep country year IK log_IK hc log_hc comp_sh rconna

	keep if year >= $START_YEAR & year <= $END_YEAR
	
	* Drops ABW, AIA, ANT, ATG, BHS, BLZ, BMU, BRN, CUW, CYM, DMA, GRD, KNA, 
	* LCA, LIE, MAC, MHL, MSR, PLW, SMR, SXM, TCA, VCT, VGB
	merge m:1 country using "${CROSSWALKS}/valid_iso3_codes.dta", keep(3) nogen

	save "${MACRO_POLITICAL_DERIVED}/investment_capital_ratio.dta", replace

end
	
* ==============================================================================
* Run script
* ==============================================================================

main

* ==============================================================================
* Check against old data
* ==============================================================================

// check_dataset_diffs_numeric "${MACRO_POLITICAL_DERIVED}/investment_capital_ratio.dta"