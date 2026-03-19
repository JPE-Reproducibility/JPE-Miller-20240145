/*
Purpose: create gini fill var for main paper and appendix
Primary author: Paul Kim
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

global WIID_ORIG             	"datastore/raw/wiid/orig"
global SWIID_ORIG           	"datastore/raw/swiid/orig"
global CROSSWALKS				"datastore/raw/crosswalks"
global VDEM_ORIG 		    	"datastore/raw/vdem/orig"
global VDEM_DATA 		    	"datastore/raw/vdem/data"
global MACRO_POLITICAL_DERIVED 	"datastore/derived/macro_political"

global START_YEAR = 1816
global END_YEAR = 2018

* ==============================================================================
* Main execution logic
* ==============================================================================

program main

	get_wiid_gini
    tempfile wiid_gini
    save "`wiid_gini'"

    get_swiid_gini
    merge 1:1 country year using "`wiid_gini'", nogen

    keep if year >= $START_YEAR & year <= $END_YEAR

	* Discards invalid ISO3 codes referenced in valid_iso3_codes.dta creation script
	merge m:1 country using "${CROSSWALKS}/valid_iso3_codes.dta", keep(3) nogen

	save "${MACRO_POLITICAL_DERIVED}/gini_coefficients.dta", replace

end

program get_wiid_gini

    use "${WIID_ORIG}/wiidcountry.dta", clear

    keep if giniseries == 1
    encode c3, gen(cid)
    sort cid year
    bys cid: gen obs = year if _n == 1

    tsset cid year
    tsfill, full

    bys cid: egen first_year = min(obs)
    drop if year < first_year 
    keep cid year gini_std p100 dy5

    bys cid: ipolate gini_std year, generate(y2)
    replace gini_std = y2 if gini_std == .
    drop y2

    decode cid, gen(country)
    drop cid

    keep country year gini_std
		
end

program get_swiid_gini

	import delimited "${CROSSWALKS}/country_name_to_iso3.csv", varnames(1) clear
	duplicates drop
	tempfile country_name_to_iso3
	save "`country_name_to_iso3'"

    import delimited "${SWIID_ORIG}/swiid9_0_summary.csv", clear
    
	drop if country == "Czechoslovakia"
	
	replace country = "Ivory Coast" if country == "CÃ´te d'Ivoire"
    replace country = "South Korea" if country == "Korea"
    replace country = "Federated States of Micronesia" if country == "Micronesia"
    replace country = "St. Vincent and the Grenadines" if country == "St. Vincent and Grenadines"
    replace country = "Antigua & Barbuda" if country == "Antigua and Barbuda"
    replace country = "Sao Tome and Principe" if country ==  "SÃ£o TomÃ© and PrÃ­ncipe"
    replace country = "East Timor" if country ==  "Timor-Leste"
	
    rename * swiid_*
    rename swiid_year year
    rename swiid_country country_name
    merge m:1 country_name using "`country_name_to_iso3'", keep(3) nogen
    sort country year
	
    drop country_name
    order country
    keep country year swiid_gini_mkt
	
end

* ==============================================================================
* Run script
* ==============================================================================

main
