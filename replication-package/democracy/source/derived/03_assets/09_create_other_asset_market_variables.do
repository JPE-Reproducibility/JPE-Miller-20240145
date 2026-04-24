/*
Purpose: create other asset market variables from GFD
Primary author: Max Miller
Date: 11-10-2025
*/

* ==============================================================================
* Housekeeping
* ==============================================================================

clear all
version 19

* ==============================================================================
* Set globals
* ==============================================================================

global CROSSWALKS 		"datastore/raw/crosswalks"
global GFD_ORIG 		"datastore/raw/gfd/orig"
global ASSETS_DERIVED 	"datastore/derived/assets"
global PROGRAMS 		"source/derived/programs"

do "${PROGRAMS}/create_gfd_data.do"

global START_YEAR = 1816
global END_YEAR = 2018

* ==============================================================================
* Main execution logic
* ==============================================================================

program main

	* GFD Price Index
	get_gfd_data "gfd_eq_capgain" "close"
	rename gfd_eq_capgain gfd_eq_prc_ind
	tempfile gfd_eq_prc_ind
	save "`gfd_eq_prc_ind'"

	* Cyclically Adjusted Price Earnings Ratio
	foreach i of numlist 3 5 7 {
		get_gfd_data "gfd_cape_`i'yr" "close"
		tempfile gfd_cape_`i'yr
		save "`gfd_cape_`i'yr'"
	}

	* Corporate Bond Yields
	get_gfd_data "gfd_corp_bond_yield" "close/100"
	tempfile gfd_corp_bond_yield
	save "`gfd_corp_bond_yield'"

	* Price Earnings Ratio
	import delimited "${GFD_ORIG}/supplements/price_earnings_clean.csv", encoding(UTF-8) clear 
	keep year country gfd_pe

	merge 1:1 country year using "`gfd_cape_3yr'", nogen
	merge 1:1 country year using "`gfd_cape_5yr'", nogen
	merge 1:1 country year using "`gfd_cape_7yr'", nogen
	merge 1:1 country year using "`gfd_corp_bond_yield'", nogen
	merge 1:1 country year using "`gfd_eq_prc_ind'", nogen
	
	* This catches no countries, but is kept in to track ISO3 codes
	merge m:1 country using "${CROSSWALKS}/valid_iso3_codes.dta", keep(3) nogen

	save "${ASSETS_DERIVED}/other_asset_market_variables.dta", replace

end

* ==============================================================================
* Run script
* ==============================================================================

main