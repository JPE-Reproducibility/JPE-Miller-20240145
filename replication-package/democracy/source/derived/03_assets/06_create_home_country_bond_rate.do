/*
Purpose: fill in home country bond returns
Primary author: Max Miller
Date: 11-28-2025
*/


* ==============================================================================
* Housekeeping
* ==============================================================================

clear all
version 19
adopath ++ "source/utils/analysis"

* ==============================================================================
* Set globals
* ==============================================================================

global ASSETS_DERIVED           "datastore/derived/assets"
global MACRO_POLITICAL_DERIVED  "datastore/derived/macro_political"
global CROSSWALKS				"datastore/raw/crosswalks"
global PROGRAMS 		        "source/derived/programs"

* ==============================================================================
* Main execution logic
* ==============================================================================

program main

	use "${ASSETS_DERIVED}/all_fixed_income.dta", clear
	merge 1:1 country year using "${MACRO_POLITICAL_DERIVED}/all_inflation.dta", nogen update
	merge 1:1 country year using "${MACRO_POLITICAL_DERIVED}/gov_rev.dta", nogen
	
	egen country_id = group(country), label
	
	sort country_id year
	tsset country_id year
	
    gen log_gfd_govt_exp = log(gfd_govt_exp)
	gen log_gfd_govt_rev = log(gfd_govt_rev)

    gen all_rf = all_bond_rate

    reghdfe all_bond_rate all_bond_rate_ia , absorb(year) vce(r)
    predict temp
    replace all_rf = temp if all_rf == .
    drop temp

    reghdfe all_bond_rate F.all_bill_tr all_bill_tr L.all_bill_tr F.log_all_cpi_g log_all_cpi_g L.log_all_cpi_g , absorb(year) vce(r)
    predict temp
    replace all_rf = temp if all_rf == .
    drop temp

    reghdfe log_all_bond_rate F.log_all_cpi_g log_all_cpi_g L.log_all_cpi_g log_gfd_govt_exp log_gfd_govt_rev , absorb(year) vce(r)
    predict temp
    replace all_rf = exp(temp) - 1 if all_rf == .
    drop temp

    reghdfe log_all_bond_rate F.log_all_cpi_g log_all_cpi_g L.log_all_cpi_g , absorb(year) vce(r)
    predict temp
    replace all_rf = exp(temp) - 1 if all_rf == .
    drop temp

    reghdfe log_all_bond_rate log_all_cpi_g , absorb(year) vce(r)
    predict temp
    replace all_rf = exp(temp) - 1 if all_rf == .
    drop temp

    replace all_rf = (1+all_rf)/(1+all_cpi_g) - 1
    
	winsor2 all_rf, replace
	
	* Check out CSK and YUG
	merge m:1 country using "${CROSSWALKS}/valid_iso3_codes.dta", keep(3) nogen
	
	keep country year all_rf
	
	save "${ASSETS_DERIVED}/home_country_bond_rate.dta", replace

	
end

* ==============================================================================
* Run script
* ==============================================================================

main