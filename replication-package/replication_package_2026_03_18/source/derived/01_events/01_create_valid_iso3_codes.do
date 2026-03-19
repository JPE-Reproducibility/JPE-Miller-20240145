/*
Purpose: create list of valid ISO3 codes for the analysis
Primary author: Max Miller
Date: 11-26-2025
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

* ==============================================================================
* Main execution logic
* ==============================================================================

program main

	** This is giving a list of all countries we will want to analyze
	use country_text_id using "${VDEM_ORIG}/version10/V-Dem-CY-Full+Others-v10.dta", clear
	rename country_text_id country
	
	** Drop all the German principalities
	* We are using the "DEU" series for Germany
	* Drops Baden, Brunswick, German Democratic Republic (East Germany),
	* Hesse-Darmstadt, Hesse-Kassel, Hamburg, Hanover, Mecklenburg Schwerin,
	* Nassau, Oldenburg, Saxe-Weimar-Eisenach, Saxony, Württemberg
	drop if inlist(country, "BDN", "BRW", "DDR", "HDM", "HKS", "HRG", "HVR", "MCL", "NSS")
	drop if inlist(country, "OLD", "SAX", "SXN", "WRG")
	
	** Drop all the Italian states
	* The ITA series does not start until 1861, but will drop the Italian states
	* Drops Modena, Papal States, Parma, Piedmont-Sardinia, Tuscany, Two Sicilies
	drop if inlist(country, "MDN", "PPS", "PRM", "SPD", "TSC", "TWS")
	
	** Drop Palestinian territories (keep only the West Bank series PSE)
	drop if inlist(country, "PSB", "PSG")
	
	** Drop Republic of Vietnam
	drop if country == "VDR"
	
	duplicates drop
	
	** Add Timor-Leste and Democratic Republic of the Congo
	set obs `=_N+1'
	replace country = "TMP" if country == ""

	set obs `=_N+1'
	replace country = "CDR" if country == ""
	
	save "${CROSSWALKS}/valid_iso3_codes.dta", replace
	
end

* ==============================================================================
* Run script
* ==============================================================================

main