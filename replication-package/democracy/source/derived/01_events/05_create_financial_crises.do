/*
Purpose: create financial crisis data
Primary author: Max Miller
Contributors: Paul Kim
Date: 11-20-2025
*/


* ==============================================================================
* Housekeeping
* ==============================================================================

clear all
version 19

* ==============================================================================
* Set globals
* ==============================================================================

global JST_ORIG 			"datastore/raw/jst/orig"
global OTHER_EVENTS_ORIG 	"datastore/raw/other_events/orig"
global EVENTS_DERIVED 		"datastore/derived/events"

global START_YEAR = 1816
global END_YEAR = 2018

* ==============================================================================
* Main execution logic
* ==============================================================================

program main

	get_jst_crisis
	tempfile jst_crisis
	save "`jst_crisis'"
	
	get_rr_crisis
	merge 1:1 country year using "`jst_crisis'", nogen

	keep if year >= $START_YEAR & year <= $END_YEAR
    egen financial_crisis = rowmax(rr_financial_crisis jst_financial_crisis)
	keep country year financial_crisis
	
	lab var country "Country ISO3 Code"
	lab var year "Year"
	lab var financial_crisis "Financial crisis ongoing == 1"

	save "${EVENTS_DERIVED}/financial_crisis.dta", replace

end

program get_jst_crisis

	use "${JST_ORIG}/JSTdatasetR5.dta", clear
	rename * jst_*
	rename jst_year year
	rename jst_iso country
	rename jst_crisisJST jst_financial_crisis
	keep country year jst_financial_crisis
	keep if jst_financial_crisis == 1
		
end

program get_rr_crisis
	
	import delimited "${OTHER_EVENTS_ORIG}/reinhart_rogoff_financial_crisis.csv", varnames(1) clear
	drop country_rr

end

* ==============================================================================
* Run script
* ==============================================================================

main