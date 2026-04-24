/*
Purpose: create tax rate var for main paper and appendix
Primary author: Paul Kim
Date: 11-25-2025
*/

* ==============================================================================
* Housekeeping
* ==============================================================================

clear all
version 19

* ==============================================================================
* Set globals
* ==============================================================================

global CROSSWALKS				"datastore/raw/crosswalks"
global GFD_ORIG 				"datastore/raw/gfd/orig"
global ARPC_ORIG 				"datastore/raw/arpc/orig"
global MACRO_POLITICAL_DERIVED 	"datastore/derived/macro_political"

global START_YEAR = 1816
global END_YEAR = 2018

* ==============================================================================
* Main execution logic
* ==============================================================================

program main

    * Load in prerequisite data
	get_arpc_data
    tempfile arpc_data
    save "`arpc_data'"

	* This was downloaded via their website
    use "${GFD_ORIG}/govt_rev_gdp.dta", clear
    drop Ticker
    sort country year

    order country year govt_rev_gdp    
    merge 1:1 country year using "`arpc_data'", nogen
    keep if year >= $START_YEAR & year <= $END_YEAR
        
    sort country year
    order country year tax govt_rev_gdp

	* Discards invalid ISO3 codes referenced in valid_iso3_codes.dta creation script
	merge m:1 country using "${CROSSWALKS}/valid_iso3_codes.dta", keep(3) nogen

	save "${MACRO_POLITICAL_DERIVED}/tax_rates.dta", replace

end

program get_arpc_data

    use "${ARPC_ORIG}/arpc_2020_comp.dta", clear
    sort country year
    keep country year tax

end


* ==============================================================================
* Run script
* ==============================================================================

main
