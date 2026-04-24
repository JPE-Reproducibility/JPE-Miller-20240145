/*
Purpose: create militarized interstate disputes
Primary author: Max Miller
Contributors: Paul Kim
Date: 11-11-2025
Details: Dropped countries are:
	- Antigua & Barbuda
	- Bahamas
	- Belize
	- Dominica
	- Grenada
	- Saint Lucia
	- Palau
	- Saint Vincent and the Grenadines
*/

* ==============================================================================
* Housekeeping
* ==============================================================================

clear all
version 19

* ===============================================================================
* Set globals
* ===============================================================================

global COW_ORIG			"datastore/raw/cow/militarized_interstate_disputes/orig"
global CROSSWALKS		"datastore/raw/crosswalks"
global EVENTS_DERIVED	"datastore/derived/events"

global START_YEAR = 1816
global END_YEAR = 2018

* ===============================================================================
* Main execution logic
* ===============================================================================

program main

	import delimited "${CROSSWALKS}/cow_country_codes_to_iso3.csv", varnames(1) clear
	drop if stateabb == ""
	rename stateabb stabb
	tempfile country_codes_map
	save "`country_codes_map'"

	import delimited "${COW_ORIG}/MID-level/MIDB_4.2.csv", encoding(ISO-8859-1) clear
	collapse (min) year1 = styear (max) year2 = endyear, by(dispnum3 stabb hiact)
	reshape long year, i(dispnum3 stabb hiact) j(year_num)
	drop year_num
	duplicates drop

	egen i = group(dispnum3 stabb), label
	tsset i year
	tsfill

	replace dispnum3 = L.dispnum3 if dispnum3 == .
	replace hiact = L.hiact if hiact == .
	replace stabb = stabb[_n-1] if stabb == ""

	drop i

	merge m:1 stabb using "`country_codes_map'", keep(1 3) nogen

	collapse (max) md_high_action = hiact , by(country year)
	
	keep if year >= $START_YEAR & year <= $END_YEAR
	
	* Drops the following countries - ATG, BHS, BLZ, DMA, GRD, LCA, PLW, VCT
	merge m:1 country using "${CROSSWALKS}/valid_iso3_codes.dta", keep(3) nogen
	
	save "${EVENTS_DERIVED}/militarized_interstate_disputes.dta", replace

end

* ==============================================================================
* Run script
* ==============================================================================

main