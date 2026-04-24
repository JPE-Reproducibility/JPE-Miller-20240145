/*
Purpose: create international political crisis indicators
Primary author: Max Miller 
Contributors: Paul Kim
Date: 11-26-2025
Details: Dropped countries are:
	- Grenada
*/


* ==============================================================================
* Housekeeping
* ==============================================================================

clear all
version 19

* ==============================================================================
* Set globals
* ==============================================================================

global CROSSWALKS		"datastore/raw/crosswalks"
global ICB_ORIG 		"datastore/raw/icb/orig"
global EVENTS_DERIVED 	"datastore/derived/events"

global START_YEAR = 1816
global END_YEAR = 2018

* ==============================================================================
* Main execution logic
* ==============================================================================

program main
	
	import delimited "${CROSSWALKS}/icb_country_code_to_iso3.csv", varnames(1) clear
	keep actor country
	duplicates drop
	tempfile icb_to_country
	save "`icb_to_country'"

	import delimited "${ICB_ORIG}/icb2v12.csv", varnames(1) clear
	merge m:1 actor using "`icb_to_country'", nogen keep(3)
	get_crisis_level_data
	reshape_data_long
	fill_in_missing_years
	gen icb_crisis = 1
	collapse (max) icb_crisis , by(country year)
	keep if year >= $START_YEAR & year <= $END_YEAR

	* Drops only Grenada
	merge m:1 country using "${CROSSWALKS}/valid_iso3_codes.dta", keep(3) nogen
	
	lab var country "Country ISO3 Code"
	lab var year "Year"
	lab var icb_crisis "International crisis ongoing == 1"

	save "${EVENTS_DERIVED}/icb_crisis.dta", replace

end

program get_crisis_level_data
	
	collapse (min) year1 = systrgyr (max) year2 = yrterm, by(crisno country)
	egen i = group(country crisno), label
	drop if year1 == .

end

program reshape_data_long

	reshape long year, i(crisno country i) j(year_number)
	drop year_number
	duplicates drop

end

program fill_in_missing_years

	tsset i year
	tsfill
	sort i year

	foreach var in crisno country {
		by i: carryforward `var', replace
	}
	
	drop if year == .

end

* ==============================================================================
* Run script
* ==============================================================================

main