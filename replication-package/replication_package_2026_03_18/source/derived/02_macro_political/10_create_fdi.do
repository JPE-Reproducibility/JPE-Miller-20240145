/*
Purpose: clean fdi for main paper and appendix
Primary author: Max Miller
Contributors: Paul Kim
Date: 12-1-2025
*/

* ==============================================================================
* Housekeeping
* ==============================================================================

clear all
version 19

* ==============================================================================
* Set globals
* ==============================================================================

global FDI_ORIG                 "datastore/raw/fdi/orig"
global MACRO_POLITICAL_DERIVED  "datastore/derived/macro_political"
global CROSSWALKS               "datastore/raw/crosswalks"

* ==============================================================================
* Main execution logic
* ==============================================================================

program main

    get_fdi_inflows
    tempfile fdi_inflows
    save "`fdi_inflows'"

    get_fdi_outflows

    merge 1:1 country year using "`fdi_inflows'", nogen

    drop if fdi_inflow == . & fdi_outflow == .
    sort country year
    order country year fdi_inflow fdi_outflow

    * Drops invalid ISO3 codes and region aggregates
	merge m:1 country using "${CROSSWALKS}/valid_iso3_codes.dta", keep(3) nogen
	
	save "${MACRO_POLITICAL_DERIVED}/fdi_clean.dta", replace
	

end

program get_fdi_inflows

    import delimited "${FDI_ORIG}/fdi_inflows_raw.csv", varnames(5) clear
    drop countryname indicatorname indicatorcode v67

    rename countrycode country
    
    * Reshape from wide to long format
    reshape long v, i(country) j(year)
    replace year = year + 1955
    rename v fdi_inflow
    
end

program get_fdi_outflows

    import delimited "${FDI_ORIG}/fdi_outflows_raw.csv", varnames(5) clear
    drop countryname indicatorname indicatorcode v67

    rename countrycode country
    
    * Reshape from wide to long format
    reshape long v, i(country) j(year)
    replace year = year + 1955
    rename v fdi_outflow

end

* ==============================================================================
* Run script
* ==============================================================================

main