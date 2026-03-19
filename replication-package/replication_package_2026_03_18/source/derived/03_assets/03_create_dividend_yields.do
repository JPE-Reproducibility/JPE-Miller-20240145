/*
Purpose: create dividend yield variables for main paper and appendix
Primary author: Max Miller
Date: 11-10-2025
*/

* ==============================================================================
* Housekeeping
* ==============================================================================

clear all
version 19
adopath + "source/utils/analysis"

* ==============================================================================
* Set globals
* ==============================================================================

global JST_ORIG 		"datastore/raw/jst/orig"
global ASSETS_DERIVED 	"datastore/derived/assets"
global CROSSWALKS		"datastore/raw/crosswalks"
global PROGRAMS 		"source/derived/programs"

do "${PROGRAMS}/create_gfd_data.do"

global START_YEAR = 1816
global END_YEAR = 2018

* ==============================================================================
* Main execution logic
* ==============================================================================

program main

	get_gfd_div_yld
	tempfile gfd_div_yld
	save "`gfd_div_yld'"

	get_gfd_lse_div_yld
	tempfile gfd_lse_div_yld
	save "`gfd_lse_div_yld'"
	
	get_jst_div_yld
	tempfile jst_div_yld
	save "`jst_div_yld'"
	
	merge 1:1 country year using "`gfd_div_yld'", nogen
	merge 1:1 country year using "`gfd_lse_div_yld'", nogen	
	merge 1:1 country year using "${ASSETS_DERIVED}/factset.dta", nogen	
	merge 1:1 country year using "${ASSETS_DERIVED}/ibes_global.dta", nogen
	
	keep year country *_div_yld
	
	foreach var of varlist *_div_yld {
		create_vars `var'
	}
	
	** Winsorize total returns to get rid of very high and low values
	** Note: factset and IBES excluded -- they do not have crazy outliers
	foreach var in jst gfd gfd_lse {
		winsor2 `var'_div_yld_g, c(.1 99.9) replace
		winsor2 `var'_div_yld_5yr, c(.1 99.9) replace
	}
	
	keep if year >= $START_YEAR & year <= $END_YEAR
	
	forvalues i = 1/5 {
		gen log_all_div_yld_`i'yr = log_gfd_div_yld_`i'yr
		replace log_all_div_yld_`i'yr = log_jst_div_yld_`i'yr if log_all_div_yld_`i'yr == .
		replace log_all_div_yld_`i'yr = log_factset_div_yld_`i'yr if log_all_div_yld_`i'yr == .
		replace log_all_div_yld_`i'yr = log_ibes_div_yld_`i'yr if log_all_div_yld_`i'yr == .
		replace log_all_div_yld_`i'yr = log_gfd_lse_div_yld_`i'yr if log_all_div_yld_`i'yr == .
	}
	
	* This catches no countries, but is kept in to track ISO3 codes
	merge m:1 country using "${CROSSWALKS}/valid_iso3_codes.dta", keep(3) nogen

	
	save "${ASSETS_DERIVED}/all_div_yld.dta", replace

end

program get_gfd_div_yld

	* Dividend Yield
	get_gfd_data "gfd_div_yld" "close/100"
	replace gfd_div_yld = . if gfd_div_yld < 0
	winsor2 gfd_div_yld, c(.1 99.9) replace // There are some weird dividend yield oberservations
	
end

program get_gfd_lse_div_yld

	* Dividend Yield (London Stock Exchange)
	get_gfd_data "gfd_lse_div_yld" "close/100"
	winsor2 gfd_lse_div_yld, c(.1 99.9) replace // There are some weird dividend yield oberservations

	** Drop 35 observation with dividend yields above 1
	replace gfd_lse_div_yld = . if gfd_lse_div_yld >= 1

end

program get_jst_div_yld

	use "${JST_ORIG}/JSTdatasetR5.dta", clear
	rename * jst_*
	rename jst_year year
	rename jst_iso country
	rename jst_eq_dp jst_div_yld
	keep country year jst_div_yld
		
end

program create_vars

	args var
	
	egen i = group(country)
	gen t = year
	
	tsset i t
	
	gen log_`var' = log(`var')
	gen log_`var'_g = log(`var')-log(L.`var')
	gen `var'_g = `var'/L.`var' - 1

	forvalues i = 1/5 {
		gen `var'_`i'yr = `var' - L`i'.`var'
		gen log_`var'_`i'yr = log_`var' - L`i'.log_`var'
	}
	
	drop i t
	
end


* ==============================================================================
* Run script
* ==============================================================================

main