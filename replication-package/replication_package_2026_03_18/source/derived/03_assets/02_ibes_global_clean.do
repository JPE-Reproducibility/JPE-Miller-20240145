/*
Purpose: create IBES annual dividend yields
Primary author: Max Miller
Date: 12-12-2025
*/

* ==============================================================================
* Housekeeping
* ==============================================================================

clear all
version 19

* ==============================================================================
* Set globals
* ==============================================================================

global WRDS_ORIG "datastore/raw/wrds/orig"
global CROSSWALKS "datastore/raw/crosswalks"
global ASSETS_DERIVED "datastore/derived/assets"

* ==============================================================================
* Main execution logic
* ==============================================================================

program main

	import delimited "${CROSSWALKS}/ibes_country_to_iso3_codes.csv", varnames(1) clear
	rename country_name Country_Name
	drop countryid
	tempfile ibes_country_match
	save "`ibes_country_match'"

	use date Code Country_Name DivYLD Price using "${WRDS_ORIG}/ibes_global_actual.dta", clear

	duplicates drop
	sort Code date
	gen year = year(date)

	bys Code year: egen max_date = max(date)
	keep if date == max_date

	collapse (min) DivYLD Price, by(date Country_Name Code year)
	drop date
	sort Code year
	tsset Code year
	gen ibes_eq_capgain = Price/L.Price - 1
	gen ibes_div_yld = DivYLD/100
	drop if ibes_div_yld == 0 | ibes_div_yld > .5

	collapse (mean) ibes_div_yld ibes_eq_capgain [w = Price], by(Country_Name year)
	gen ibes_eq_tr = ibes_eq_capgain + ibes_div_yld

	* This drops returns for groups, but not any other country
	merge m:1 Country_Name using "`ibes_country_match'", keep(3) nogen
	drop Country*
	
	* This catches no countries, but is kept in to track ISO3 codes
	merge m:1 country using "${CROSSWALKS}/valid_iso3_codes.dta", keep(3) nogen


	save "${ASSETS_DERIVED}/ibes_global.dta", replace

end

* ==============================================================================
* Run script
* ==============================================================================

main