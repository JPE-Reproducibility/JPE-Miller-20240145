/*
Purpose: create sovereign defaults indicator
Primary author: Max Miller
Contributors: Paul Kim
Date: 11-26-2025
Details: Dropped countries are:
	- Antigua & Barbuda
	- Belize
	- Cook Islands
	- Dominica
	- Grenada
	- Nauru
	- St Kitts & Nevis
*/

* ==============================================================================
* Housekeeping
* ==============================================================================

clear all
version 19

* ==============================================================================
* Set globals
* ==============================================================================

global OTHER_EVENTS_ORIG	"datastore/raw/other_events/orig"
global CROSSWALKS			"datastore/raw/crosswalks"
global EVENTS_DERIVED		"datastore/derived/events"

global START_YEAR = 1816
global END_YEAR = 2018

* ==============================================================================
* Main execution logic
* ==============================================================================

program main

	import delimited "${CROSSWALKS}/country_name_to_iso3.csv", varnames(1) clear
	replace country = "SRB" if country == "YUG"
	tempfile country_name_to_iso3
	save "`country_name_to_iso3'"

	use "${OTHER_EVENTS_ORIG}/reinhart_rogoff_defaults.dta", clear
	rename date year
	replace country_name = strtrim(country_name)
	
	* Does not drop any countries
	merge m:1 country_name using "`country_name_to_iso3'", keep(3) nogen
	
	* Drops the following countries - ATG, BLZ, COK, DMA, GRD, KNA, NRU
	merge m:1 country using "${CROSSWALKS}/valid_iso3_codes.dta", keep(3) nogen
	
	assert country != ""
	order country year
	sort country year
	collapse (max) default, by(country year)
	keep if default == 1
	keep if year >= $START_YEAR & year <= $END_YEAR
	
	lab var country "Country ISO3 Code"
	lab var year "Year"
	lab var default "Default ongoing == 1"

	save "${EVENTS_DERIVED}/default.dta", replace

end

* ==============================================================================
* Run script
* ==============================================================================

main