/*
Purpose: create democracy variables for main paper and appendix
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

global CROSSWALKS			"datastore/raw/crosswalks"
global REGIME_CHANGE_ORIG   "datastore/raw/regime_change/orig"
global EVENTS_DERIVED 		"datastore/derived/events"
global VDEM_DATA			"datastore/raw/vdem/data"
global VDEM_ORIG			"datastore/raw/vdem/orig"

global START_YEAR = 1816
global END_YEAR = 2018

* ==============================================================================
* Main execution logic
* ==============================================================================

program main

    get_ert_autocratizations
    tempfile autocratizations
    save "`autocratizations'"
	
    get_vdem_regime_change
    tempfile regime_change
    save "`regime_change'"
	
    get_lindberg_democratizations
    tempfile lindberg_data
    save "`lindberg_data'"

	get_anrr_democratizations
	tempfile anrr_data
	save "`anrr_data'"

    get_ert_democratizations
    merge 1:1 country year using "`lindberg_data'", nogen
    merge 1:1 country year using "${VDEM_DATA}/pre1900_dem.dta", nogen
	merge 1:1 country year using "`anrr_data'", nogen
    merge 1:1 country year using "`autocratizations'", nogen
    merge 1:1 country year using "`regime_change'", nogen
	
	* Keep only valid country codes (this adds ARE, KAZ, SSD, and TKM)
	merge m:1 country using "${CROSSWALKS}/valid_iso3_codes.dta", keep(2 3) nogen
	replace year = $START_YEAR if year == .
	
    replace dem_ep = 1 if pre_dem_ep == 1
    drop pre_dem_ep
    keep if year >= $START_YEAR & year <= $END_YEAR	
	create_full_panel
	
	local dem_vars dem_ep dem_ep_succ dem_ep_fail vod_demo vod_demo_fail vod_demo_succ vod_demo_cens acemoglu_dem
	local aut_vars aut_ep aut_ep_outcome_agg
	local reg_vars regime_change
	
	foreach var in `dem_vars' `aut_vars' `reg_vars' {
		replace `var' = 0 if `var' == .
	}
	
	create_combined_democratization

	lab var country_id "Country Numeric ID (with labels)"
	lab var country "Country ISO3 Code"
	lab var year "Year"
	lab var combo_dem "Democratization ongoing == 1"
	lab var combo_dem_start "Democratization, year of start == 1"
	lab var combo_dem_end "Democratization, year of end == 1"
	lab var combo_dem_end_succ "Democratization, year of end, successful == 1"
	lab var combo_dem_end_fail "Democratization, year of end, failed == 1"
	lab var combo_dem_succ "Democratization ongoing, successful == 1"
	lab var combo_dem_fail "Democratization ongoing, failed == 1"
	lab var post_combo_dem10 "Post-democratization, 10 year window == 1"
	lab var post_combo_dem20 "Post-democratization, 20 year window, ongoing == 1"
	lab var post_combo_dem_succ10 "Post-democratization, 10 year window, successful == 1"
	lab var post_combo_dem_succ20 "Post-democratization, 20 year window, successful == 1"
	lab var combo_dem_id "Democratization ID"
	lab var aut_ep "Autocratization ongoing == 1"
	lab var aut_ep_outcome_agg "Autocratization outcome"
	lab var regime_change "Regime change == 1"

    save "${EVENTS_DERIVED}/regime_change.dta", replace

end

program get_ert_democratizations

    import delimited "${REGIME_CHANGE_ORIG}/ERT.csv", varnames(1) clear
	
	gen dem_ep_succ = dem_ep
	replace dem_ep_succ = 0 if dem_ep_outcome_agg == 2

	gen dem_ep_fail = dem_ep
	replace dem_ep_fail = 0 if dem_ep_outcome_agg == 1 | dem_ep_outcome_agg == 3
	
    keep country_text_id year dem_ep dem_ep_succ dem_ep_fail
    rename country_text_id country
    order country year
    keep if dem_ep == 1

end

program get_ert_autocratizations

    import delimited "${REGIME_CHANGE_ORIG}/ERT.csv", varnames(1) clear
    keep country_text_id year aut_ep aut_ep_outcome_agg
    rename country_text_id country
    order country year
    keep if aut_ep == 1

end

program get_lindberg_democratizations

    import delimited "${REGIME_CHANGE_ORIG}/vod_democratizations.csv", clear
    gen year = year(date(date,"YMD"))
    order country year
    drop date
    duplicates drop

end

program get_anrr_democratizations

    use "${REGIME_CHANGE_ORIG}/DDCGdata_final.dta", clear
	keep year wbcode dem
	replace wbcode = "ROU" if wbcode == "ROM"
	replace wbcode = "TWN" if wbcode == "TAW"
	replace wbcode = "SRB" if wbcode == "SER"
	egen country_id = group(wbcode), label

	tsset country_id year
	keep if dem == 1 & L.dem == 0

	decode country_id, gen(country)
	rename dem acemoglu_dem
	keep country year acemoglu_dem

end

program create_full_panel

	egen country_id = group(country), label
	order country_id
	tsset country_id year
	tsfill, full
	
	decode country_id, gen(country_temp)
	replace country = country_temp if country == ""
	drop country_temp
	
end

program get_vdem_regime_change

	use country_text_id year v2reginfo using "${VDEM_ORIG}/version10/V-Dem-CY-Full+Others-v10.dta", clear
    rename country_text_id country
    egen i = group(country), label
    egen regime_id = group(v2reginfo), label
    replace regime_id = . if v2reginfo == ""

    tsset i year
    gen regime_change = regime_id != F.regime_id if regime_id != . & F.regime_id != .

    keep country year regime_change
    keep if regime_change == 1

end

program create_combined_democratization

	gen combo_dem = dem_ep
	replace combo_dem = 1 if L.combo_dem == 1 & vod_demo == 1

	gen combo_dem_start = 1 if combo_dem == 1 & L.combo_dem == 0
	replace combo_dem_start = 0 if combo_dem_start == . & combo_dem != .

	gen combo_dem_end = 1 if combo_dem == 1 & F.combo_dem == 0
	replace combo_dem_end = 0 if combo_dem_end == . & combo_dem != .
	replace combo_dem_end = 1 if combo_dem == 1 & year == 2018
	
	gen combo_dem_end_succ = 1 if combo_dem_end == 1 & (vod_demo_succ == 1 | dem_ep_succ == 1)
	replace combo_dem_end_succ = 0 if combo_dem_end_succ == . & combo_dem != .

	gen combo_dem_end_fail = 1 if combo_dem_end == 1 & (vod_demo_fail == 1 | dem_ep_fail == 1)
	replace combo_dem_end_fail = 0 if combo_dem_end_fail == . & combo_dem != .

	gen combo_dem_succ = 1 if combo_dem == 1 & (vod_demo_succ == 1 | dem_ep_succ == 1)
	replace combo_dem_succ = 0 if combo_dem_succ == . & combo_dem != .

	gen combo_dem_fail = 1 if combo_dem == 1 & (vod_demo_fail == 1 | dem_ep_fail == 1)
	replace combo_dem_fail = 0 if combo_dem_fail == . & combo_dem != .

	cap gen post_combo_dem_succ10 = 0 if combo_dem != .
	cap gen post_combo_dem10 = 0 if combo_dem != .

	forvalues i = 1(1)11 {
		replace post_combo_dem_succ10 = 1 if L`i'.combo_dem_end_succ == 1
		replace post_combo_dem10 = 1 if L`i'.combo_dem_end == 1
	}

	cap gen post_combo_dem_succ20 = 0 if combo_dem != .
	cap gen post_combo_dem20 = 0 if combo_dem != .

	forvalues i = 1(1)21 {
		replace post_combo_dem_succ20 = 1 if L`i'.combo_dem_end_succ == 1
		replace post_combo_dem20 = 1 if L`i'.combo_dem_end == 1
	}
	
	egen combo_dem_id = group(country year) if combo_dem_start == 1, label
	replace combo_dem_id = L.combo_dem_id if L.combo_dem == 1 & combo_dem == 1

end

* ==============================================================================
* Run script
* ==============================================================================

main