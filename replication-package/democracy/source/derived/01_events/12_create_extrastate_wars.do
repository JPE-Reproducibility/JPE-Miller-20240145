/*
Purpose: create extrastate wars variables
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
global WARS_ORIG 		"datastore/raw/cow/wars/orig"
global EVENTS_DERIVED	"datastore/derived/events"
global PROGRAMS 		"source/derived/programs"

do "${PROGRAMS}/war_dummies.do"

global START_YEAR 1816
global END_YEAR 2018

* ===============================================================================
* Main execution logic
* ===============================================================================

program main

	import delimited "${CROSSWALKS}/cow_country_codes_to_iso3.csv", varnames(1) clear
	drop if ccode == .
	keep ccode country area
	duplicates drop
	tempfile country_codes_map
	save "`country_codes_map'"

	use "${WARS_ORIG}/Extra-StateWarData_v4.0.dta", clear
	foreach l in 1 2 {
		replace ccode`l' = . if ccode`l' < 0
	}
	
	egen ccode = rowmin(ccode*) 
	drop if ccode == .
	
	rename startyear1 year1
	gen year2 = max(endyear1, endyear2)
	
	replace year2 = 2018 if warnum == 481
	replace year2 = 2018 if warnum == 482

	collapse (min) year1 (max) year2 , by(warnum ccode wherefought)

	reshape long year, i(warnum ccode wherefought) j(year_number)
	drop year_number

	duplicates drop
	egen id = group(warnum ccode) , label

	tsset id year
	tsfill
	sort id year

	foreach var in warnum ccode wherefought {
		by id: carryforward `var', replace
	}

	merge m:1 ccode using "`country_codes_map'", keep(1 3) nogen
	
	war_dummies "extrastate_war"

	collapse (max) extrastate_war*, by(country year)
	sort country year

	lab var extrastate_war 		"Extrastate war ongoing == 1"
	lab var extrastate_war_far 	"Extrastate war ongoing == 1; not in country area"
	lab var extrastate_war_near "Extrastate war ongoing == 1; in country area"

	keep if year >= $START_YEAR & year <= $END_YEAR

	save "${EVENTS_DERIVED}/extrastate_wars.dta", replace

end

* ==============================================================================
* Run script
* ==============================================================================

main