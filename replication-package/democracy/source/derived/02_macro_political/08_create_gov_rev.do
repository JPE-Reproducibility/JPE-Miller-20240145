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

global CROSSWALKS "datastore/raw/crosswalks"
global GFD_ORIG "datastore/raw/gfd/orig"
global GFD_DATA "datastore/raw/gfd/data"
global VDEM_ORIG "datastore/raw/vdem/orig"
global JST_ORIG "datastore/raw/jst/orig"
global MACRO_POLITICAL_DERIVED 	"datastore/derived/macro_political"
global PROGRAMS 		"source/derived/programs"

do "${PROGRAMS}/create_gfd_data.do"

global START_YEAR = 1816
global END_YEAR = 2018

* ==============================================================================
* Main execution logic
* ==============================================================================

program main

    get_gfd_govt_rev_exp
    tempfile gfd_govt_rev_exp
    save "`gfd_govt_rev_exp'"

    get_debt_data
    
    merge 1:1 country year using "`gfd_govt_rev_exp'", nogen
    
    keep if year >= $START_YEAR & year <= $END_YEAR
    
    * Everything is matched to valid ISO3 codes
    merge m:1 country using "${CROSSWALKS}/valid_iso3_codes.dta", keep(3) nogen
    
    sort country year
    order country year gfd_govt_exp gfd_govt_rev all_debt_gdp
    keep country year gfd_govt_exp gfd_govt_rev all_debt_gdp

	save "${MACRO_POLITICAL_DERIVED}/gov_rev.dta", replace

end

program get_gfd_govt_rev_exp

    get_gfd_data "gfd_govt_exp" "close"
    tempfile gfd_govt_exp_data
    save "`gfd_govt_exp_data'"

    get_gfd_data "gfd_govt_rev" "close"
    merge 1:1 country year using "`gfd_govt_exp_data'", keep(3) nogen

end

program get_debt_data


    use "${VDEM_ORIG}/version8/V-Dem-CY+Others-v8.dta", clear
    rename country_text_id country
    keep country year e_migovdeb
    rename e_migovdeb vdem_debt_gdp
    replace vdem_debt_gdp = vdem_debt_gdp/100
    drop if vdem_debt_gdp == .
    tempfile vdem_debt_gdp
    save "`vdem_debt_gdp'"
	
    use "${JST_ORIG}/JSTdatasetR5.dta", clear
    rename debtgdp jst_debtgdp
    keep iso year jst_debtgdp
	rename iso country
	levelsof country, local(jst_countries)
	
    merge 1:1 country year using "`vdem_debt_gdp'", nogen

	gen is_jst_country = 0
	foreach c in `jst_countries' {
		replace is_jst_country = 1 if country == "`c'"
	}
	
    gen all_debt_gdp = jst_debtgdp if is_jst_country == 1
    replace all_debt_gdp = vdem_debt_gdp if is_jst_country == 0

    sort country year
    keep country year all_debt_gdp
    order country year all_debt_gdp

end

* ==============================================================================
* Run script
* ==============================================================================

main
