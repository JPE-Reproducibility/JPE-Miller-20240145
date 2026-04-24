/*
Purpose: prepare head of government and state deaths and coup d'etats
Author: Max Miller
Date: 11-11-2025
Details: Wikipedia HoG deaths come from WikiHoG comes from: https://en.wikipedia.org/wiki/List_of_heads_of_state_and_government_who_died_in_office
*/

* ===========================================================================
* Housekeeping
* ===========================================================================

clear all
version 19

* ===========================================================================
* Set globals
* ===========================================================================

global VDEM_ORIG "datastore/raw/vdem/orig"
global OTHER_EVENTS_ORIG "datastore/raw/other_events/orig"
global EVENTS_DERIVED "datastore/derived/events"
global CROSSWALKS "datastore/raw/crosswalks"

global START_YEAR 1816
global END_YEAR 2018

program main

	get_jones_olken_deaths
	tempfile jones_olken
	save "`jones_olken'"
	
	get_wiki_hog_deaths
	tempfile wiki_hog
	save "`wiki_hog'"
	
	get_vdem_hog_deaths
	merge 1:1 country year using "`jones_olken'", nogen
	merge 1:1 country year using "`wiki_hog'", nogen
	
	foreach var in assas_succ assas_attempt wiki_hog {
		replace `var' = 0 if `var' == .
	}
	
	** All government head death variable -- 
	egen govt_head_death = rowmax(vdem_govt_head_death assas_succ wiki_hog)
	replace govt_head_death = 0 if govt_head_death == .
	
	keep country year govt_head_death assas_succ assas_attempt
	sort country year
	keep if govt_head_death == 1 | assas_attempt == 1
	
	keep if year >= $START_YEAR & year <= $END_YEAR

	* Drops German principalities and Vietnam Democratic Republic
	merge m:1 country using "${CROSSWALKS}/valid_iso3_codes.dta", keep(3) nogen
	
	lab var country "Country ISO3 Code"
	lab var year "Year"
	lab var govt_head_death "Government head death in year == 1"
	lab var assas_succ "Assassination successful in year == 1"
	lab var assas_attempt "Assassination attempted in year == 1"

	save "${EVENTS_DERIVED}/head_of_government_deaths.dta", replace
	
end

program get_vdem_hog_deaths

	use country_text_id country_name year v2exdeathog v2exdeathos using "${VDEM_ORIG}/version10/V-Dem-CY-Full+Others-v10.dta", clear
	rename country_text_id country

	** Rename Head of Government/State death variables
	cap rename v2exdeathog vdem_hog_death
	cap rename v2exdeathos vdem_hos_death

	** Head of government death (check this again)
	gen vdem_govt_head_death = 1 if vdem_hog_death == year | vdem_hos_death == year
	replace vdem_govt_head_death = 0 if vdem_govt_head_death == . & (vdem_hog_death != . | vdem_hos_death != .)

end

program get_jones_olken_deaths

	use "${OTHER_EVENTS_ORIG}/assassinations_data.dta", clear
	rename country country_name
	merge m:1 country_name using "${OTHER_EVENTS_ORIG}/country_names_to_iso3.dta", keep(1 3) nogen
	
	* Map country names to ISO3 codes
	replace country = "AFG" if country_name == "Afghanistan"
	replace country = "BTN" if country_name == "Bhutan"
	replace country = "GIN" if country_name == "Guineau"  // Note: likely misspelled "Guinea"
	replace country = "CIV" if country_name == "Ivory Coast"
	replace country = "KOR" if country_name == "Korea"  // South Korea (see note below)
	replace country = "SLV" if country_name == "Salvador"  // El Salvador
	replace country = "SOM" if country_name == "Somalia"
	replace country = "SYR" if country_name == "Syria"
	replace country = "RUS"	if country_name == "Russia"	
	replace country = "SRB" if country_name == "Yugoslavia"
	
	assert country != ""
	
	collapse (max) assas_succ = success  assas_attempt = attempt, by(country year)

end

program get_wiki_hog_deaths

	import delimited "${OTHER_EVENTS_ORIG}/HOG_death.csv", clear
	rename year date_str
	gen date = date(date_str,"YMD")
	gen year = year(date)
	keep country year wiki_hog	
	
end

* ==============================================================================
* Run script
* ==============================================================================

main