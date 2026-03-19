/*
Purpose: combine all event variables into comprehensive events dataset
Primary author: Max Miller
Contributors: Paul Kim
Date: 11-21-2025
*/

* ==============================================================================
* Housekeeping
* ==============================================================================

clear all
version 19
adopath + "source/derived/programs"

* ==============================================================================
* Set globals
* ==============================================================================

global EVENTS_DERIVED "datastore/derived/events"

* ==============================================================================
* Main execution logic
* ==============================================================================

program main

    use "${EVENTS_DERIVED}/regime_change.dta", clear
	merge 1:1 country year using "${EVENTS_DERIVED}/coup_detat.dta", keep(1 3) nogen
	merge 1:1 country year using "${EVENTS_DERIVED}/financial_crisis.dta", keep(1 3) nogen
	merge 1:1 country year using "${EVENTS_DERIVED}/default.dta", keep(1 3) nogen
	merge 1:1 country year using "${EVENTS_DERIVED}/head_of_government_deaths.dta", keep(1 3) nogen
	merge 1:1 country year using "${EVENTS_DERIVED}/icb_crisis.dta", keep(1 3) nogen
	merge 1:1 country year using "${EVENTS_DERIVED}/recession.dta", keep(1 3) nogen
	merge 1:1 country year using "${EVENTS_DERIVED}/interstate_wars.dta", keep(1 3) nogen
	merge 1:1 country year using "${EVENTS_DERIVED}/intrastate_wars.dta", keep(1 3) nogen
	merge 1:1 country year using "${EVENTS_DERIVED}/extrastate_wars.dta", keep(1 3) nogen
	merge 1:1 country year using "${EVENTS_DERIVED}/militarized_interstate_disputes.dta", keep(1 3) nogen
	
	local political_events coup_detat govt_head_death assas_succ assas_attempt icb_crisis
	local interstate_wars interstate_war interstate_war_near interstate_war_far 
	local intrastate_wars intrastate_war intrastate_war_near intrastate_war_far 
	local extrastate_wars extrastate_war extrastate_war_near extrastate_war_far
	local economic_events financial_crisis default recession

	foreach var in `political_events' `economic_events' `interstate_wars' `intrastate_wars' `extrastate_wars' {
		replace `var' = 0 if `var' == .
	}

	replace md_high_action = 0 if md_high_action == .

	tsset country_id year
	create_event_columns "aut_ep"
	create_event_columns "default"
	create_event_columns "financial_crisis"
	create_event_columns "icb_crisis"
	create_event_columns "recession"
	create_event_columns "interstate_war"
	create_event_columns "intrastate_war"
	create_event_columns "extrastate_war"

	lab var default_start "Default start year == 1"
	lab var default_ep_id "Default episode identifier"
	lab var years_in_default "Number of years in default
	
	lab var financial_crisis_start "Financial crisis start year == 1"
	lab var financial_crisis_ep_id "Financial crisis episode identifier"
	lab var years_in_financial_crisis "Number of years in financial crisis"
	
	egen at_war = rowmax(interstate_war intrastate_war extrastate_war)
	gen at_war_start = 1 if at_war == 1 & L.at_war == 0
	replace at_war_start = 0 if at_war_start == .
	
	egen adverse_event = rowmax(financial_crisis default recession at_war)
	gen adverse_event_start = 1 if adverse_event == 1 & L.adverse_event == 0
	replace adverse_event_start = 0 if adverse_event_start == .

	gen adverse_event2 = 1 if interstate_war_near == 1
	replace adverse_event2 = 1 if intrastate_war_near == 1 & adverse_event2 == .
	replace adverse_event2 = 1 if default == 1 & years_in_default < 10 & adverse_event2 == .
	replace adverse_event2 = 0 if adverse_event2 == .
	
    gen combo_dem_minus_start = combo_dem_start
    replace combo_dem_minus_start = 0 if adverse_event2 == 1

	gen combo_dem_minus = combo_dem_minus_start
	replace combo_dem_minus = 1 if L.combo_dem_minus == 1 & combo_dem == 1
	
    gen aut_ep_minus_start = aut_ep_start
    replace aut_ep_minus_start = 0 if adverse_event2 == 1

	gen aut_ep_minus = aut_ep_minus_start
	replace aut_ep_minus = 1 if L.aut_ep_minus == 1 & aut_ep == 1
	
    gen icb_crisis_minus_start = icb_crisis_start
    replace icb_crisis_minus_start = 0 if adverse_event2 == 1
// 	replace icb_crisis_minus_start = 0 if combo_dem == 1

	gen icb_crisis_minus = icb_crisis_minus_start
	replace icb_crisis_minus = 1 if L.icb_crisis_minus == 1 & icb_crisis == 1

    egen political_crisis = rowmax(coup_detat regime_change) 
    replace political_crisis = 0 if combo_dem_minus == 1
    replace political_crisis = 0 if aut_ep_minus == 1
    replace political_crisis = 0 if icb_crisis_minus == 1
    gen political_crisis_minus = political_crisis
    replace political_crisis_minus = 0 if adverse_event2 == 1

    gen political_crisis_minus_start = 1 if political_crisis_minus == 1 & L.political_crisis_minus == 0
    replace political_crisis_minus_start = 0 if political_crisis_minus_start == .

	gen L_political_crisis_minus_start = L.political_crisis_minus_start
	
    save "${EVENTS_DERIVED}/all_events.dta", replace

end

* ==============================================================================
* Run script
* ==============================================================================

main

