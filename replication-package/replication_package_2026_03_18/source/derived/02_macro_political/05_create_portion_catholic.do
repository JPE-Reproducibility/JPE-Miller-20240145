/*
Purpose: create religion variables for main paper and appendix
Primary author: Max Miller
Contributors: Paul Kim
Date: 11-14-2025
*/

* ==============================================================================
* Housekeeping
* ==============================================================================

clear all
version 19

* ==============================================================================
* Set globals
* ==============================================================================

global RELIGION_ORIG 			"datastore/raw/cow/religion/orig"
global CROSSWALKS				"datastore/raw/crosswalks"
global MACRO_POLITICAL_DERIVED 	"datastore/derived/macro_political"

global START_YEAR = 1816
global END_YEAR = 2018

global DID_START_YEAR = 1939
global DID_END_YEAR = 1983

* ==============================================================================
* Main execution logic
* ==============================================================================

program main

	prepare_cow_iso3_crosswalk
	tempfile country_codes_map
	save "`country_codes_map'"

	* Load in % catholic
	import delimited "${RELIGION_ORIG}/WRP_national.csv", varnames(1) clear
	rename state ccode
	merge m:1 ccode using "`country_codes_map'", keep(3) nogen
    keep country year chrstcatpct
    order country year chrstcatpct
    rename chrstcatpct catholic_pct
    sort country year
	
	* Deals with East-West Germany (keeps West), Vietnam, and Yemen
	collapse (max) catholic_pct, by(country year)
	
	* Fill in information for Hong Kong with China data
	preserve
	fill_in_hong_kong
	tempfile HKG_fill
	save "`HKG_fill'"
	restore

	append using "`HKG_fill'"

	fill_from_1816_2018
	
    gen majority_catholic = 1 if catholic_pct > .5 & catholic_pct != .
    replace majority_catholic = 0 if majority_catholic == . & catholic_pct != .
    gen non_catholic = 1-majority_catholic
	
	* Discards invalid ISO3 codes referenced in valid_iso3_codes.dta creation script
	merge m:1 country using "${CROSSWALKS}/valid_iso3_codes.dta", keep(3) nogen
	
	save "${MACRO_POLITICAL_DERIVED}/catholic_pct_1816_2018.dta", replace

	keep if year >= $DID_START_YEAR & year <= $DID_END_YEAR
	collapse (mean) catholic_pct, by(country)
	
    gen majority_catholic = 1 if catholic_pct > .5 & catholic_pct != .
    replace majority_catholic = 0 if majority_catholic == . & catholic_pct != .
    gen non_catholic = 1-majority_catholic

	save "${MACRO_POLITICAL_DERIVED}/catholic_pct_1939_1983.dta", replace
	
end

program prepare_cow_iso3_crosswalk
	* Load in COW to ISO3 crosswalks
	import delimited "${CROSSWALKS}/cow_country_codes_to_iso3.csv", varnames(1) clear
	drop if ccode == .
	keep ccode country
	duplicates drop
end

program fill_in_hong_kong

	keep if country == "CHN"
	replace country = "HKG"

	* Add a 1816 observation for filling
	set obs `=_N+1'
	replace year = $START_YEAR in `=_N'
	replace country = "HKG" in `=_N'
	
	* Add a 2018 observation for filling
	set obs `=_N+1'
	replace year = $END_YEAR in `=_N'
	replace country = "HKG" in `=_N'
	
end

program fill_from_1816_2018

	egen i = group(country), label
	tsset i year
	tsfill, full

	decode i, gen(country_temp)
	replace country = country_temp if country == ""
	
    bys i: ipolate catholic_pct year, gen(catholic_pct_i)
	replace catholic_pct = catholic_pct_i if catholic_pct == .
	
	gsort i -year
	bys i: replace catholic_pct = catholic_pct[_n-1] if catholic_pct == .
	gsort i year
	bys i: replace catholic_pct = catholic_pct[_n-1] if catholic_pct == .

	drop country_temp i catholic_pct_i
	
end

* ==============================================================================
* Run script
* ==============================================================================

main