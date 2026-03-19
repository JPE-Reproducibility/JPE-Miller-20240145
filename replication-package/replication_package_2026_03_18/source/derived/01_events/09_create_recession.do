/*
Purpose: create recession data
Primary author: Paul Kim
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

global GFD_ORIG 		"datastore/raw/gfd/orig"
global EVENTS_DERIVED 	"datastore/derived/events"

global START_YEAR = 1816
global END_YEAR = 2018

* ==============================================================================
* Main execution logic
* ==============================================================================

program main

	import delimited "${GFD_ORIG}/gfd_recessions.csv", clear
    gen year = year(date(date,"YMD"))
	collapse (max) gfd_recession, by(country year)
    keep if year >= $START_YEAR & year <= $END_YEAR
    rename gfd_recession recession 
	lab var country "Country ISO3 Code"
	lab var year "Year"
	lab var recession "Recession ongoing == 1"
	save "${EVENTS_DERIVED}/recession.dta", replace

end

* ==============================================================================
* Run script
* ==============================================================================

main