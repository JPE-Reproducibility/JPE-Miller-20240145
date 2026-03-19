/*
Purpose: prepare coup d'etats
Author: Max Miller
Date: 11-11-2025
*/

* ===========================================================================
* Housekeeping
* ===========================================================================

clear all
version 19
local current_dir = c(pwd)
local project_root = substr("`current_dir'", 1, strpos("`current_dir'", "democracy") + 8)
cd "`project_root'"

* ===========================================================================
* Set globals
* ===========================================================================

global VDEM_ORIG "datastore/raw/vdem/orig"
global OTHER_EVENTS_ORIG "datastore/raw/other_events/orig"
global EVENTS_DERIVED "datastore/derived/events"

global START_YEAR = 1816
global END_YEAR = 2018

* ===========================================================================
* Main execution logic
* ===========================================================================

program main
	
	use country_text_id year e_coups e_pt_coup using "${VDEM_ORIG}/version10/V-Dem-CY-Full+Others-v10.dta", clear
	rename country_text_id country
	gen coup_detat = 1 if e_coups > 0 & e_coups != .
	replace coup_detat = 1 if e_pt_coup == 2
	keep if coup_detat == 1
	keep country year coup_detat
	keep if year >= $START_YEAR & year <= $END_YEAR

	lab var country "Country ISO3 Code"
	lab var year "Year"
	lab var coup_detat "Coup d'etat ongoing == 1"

	save "${EVENTS_DERIVED}/coup_detat.dta", replace
	
end

* ==============================================================================
* Run script
* ==============================================================================

main