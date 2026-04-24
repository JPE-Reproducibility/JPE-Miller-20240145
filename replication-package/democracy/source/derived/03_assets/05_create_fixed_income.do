/*
Purpose: create equity return and price data
Primary author: Max Miller
Date: 12-12-2025
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

global JST_ORIG					"datastore/raw/jst/orig"
global ASSETS_DERIVED           "datastore/derived/assets"
global MACRO_POLITICAL_DERIVED  "datastore/derived/macro_political"
global PROGRAMS 		        "source/derived/programs"

do "${PROGRAMS}/create_gfd_data.do"

global START_YEAR = 1816
global END_YEAR = 2018

* ==============================================================================
* Main execution logic
* ==============================================================================

program main

	use "${MACRO_POLITICAL_DERIVED}/all_inflation.dta", clear
	tempfile all_inflation
	save "`all_inflation'"

	get_gfd_data "gfd_bond_rate" "close/100"
	tempfile gfd_bond_rate
	save "`gfd_bond_rate'"

	get_gfd_data "gfd_lse_bond_rate" "close/100"
	tempfile gfd_lse_bond_rate
	save "`gfd_lse_bond_rate'"
	
	get_gfd_data "gfd_bill_tr" "close/L.close - 1"
	tempfile gfd_bill_tr
	save "`gfd_bill_tr'"

	get_gfd_data "gfd_bill_tr_ia" "close/L.close - 1"
	tempfile gfd_bill_tr_ia
	save "`gfd_bill_tr_ia'"

	get_gfd_data "gfd_bond_capgain" "close/L.close - 1"
	tempfile gfd_bond_capgain
	save "`gfd_bond_capgain'"

	get_gfd_data "gfd_lse_bond_capgain" "close/L.close - 1"
	tempfile gfd_lse_bond_capgain
	save "`gfd_lse_bond_capgain'"

	get_gfd_data "gfd_corp_bond_yield" "close/100"
	tempfile gfd_corp_bond_yield
	save "`gfd_corp_bond_yield'"
	
	get_jst_fixed_income
	merge 1:1 country year using "`gfd_bond_rate'", nogen
	merge 1:1 country year using "`gfd_lse_bond_rate'", nogen
	merge 1:1 country year using "`gfd_bill_tr'", nogen
	merge 1:1 country year using "`gfd_bill_tr_ia'", nogen
	merge 1:1 country year using "`gfd_bond_capgain'", nogen
	merge 1:1 country year using "`gfd_lse_bond_capgain'", nogen
	merge 1:1 country year using "`gfd_corp_bond_yield'", nogen
	merge 1:1 country year using "`all_inflation'", keep(1 3) nogen
	
	keep if year >= $START_YEAR & year <= $END_YEAR
	
	** Create all bond rate variable
	gen all_bond_rate = gfd_bond_rate
	replace all_bond_rate = jst_bond_rate if all_bond_rate == .
	replace all_bond_rate = gfd_lse_bond_rate if all_bond_rate == .

	** Create log all bond return variable
	gen log_all_bond_rate = log(1+all_bond_rate)
	
	** Create inflation adjusted bond yields
	gen gfd_bond_rate_ia = (1+gfd_bond_rate)/(1+all_cpi_g) - 1
	gen gfd_lse_bond_rate_ia = (1+gfd_lse_bond_rate)/(1+all_cpi_g) - 1
	gen jst_bond_rate_ia = (1+jst_bond_rate)/(1+jst_cpi_g) - 1
	gen jst_bond_tr_ia = (1+jst_bond_tr)/(1+jst_cpi_g) - 1

	** Create all bond rate variable
	gen all_bond_rate_ia = gfd_bond_rate_ia
	replace all_bond_rate_ia = jst_bond_rate_ia if all_bond_rate_ia == .
	replace all_bond_rate_ia = gfd_lse_bond_rate_ia if all_bond_rate_ia == .

	** Create log all bond return variable
	gen log_all_bond_rate_ia = log(1+all_bond_rate_ia)

	* Bond total return
	gen gfd_bond_tr = (1+gfd_bond_capgain)/(1+USA_inflation_exp) + gfd_bond_rate_ia - 1
	gen gfd_lse_bond_tr = (1+gfd_lse_bond_capgain)/(1+USA_inflation_exp) + gfd_lse_bond_rate_ia - 1

	gen all_bond_tr = gfd_bond_tr
	replace all_bond_tr = jst_bond_tr_ia if all_bond_tr == .
	replace all_bond_tr = gfd_lse_bond_tr if all_bond_tr == .

	winsor2 gfd_bill_tr*, c(1 99) replace
	gen all_bill_tr = gfd_bill_tr_ia
	replace all_bill_tr = all_bond_tr if all_bill_tr == .

	keep country year all_bond_tr all_bill_tr gfd_bill_tr_ia all_bond_rate_ia log_all_bond_rate_ia all_bond_rate log_all_bond_rate

	save "${ASSETS_DERIVED}/all_fixed_income.dta", replace

	** Global riskfree asset
	keep if (country == "GBR" & year < 1914) | (country == "USA" & year >= 1914)
	keep year gfd_bill_tr_ia
	drop if gfd_bill_tr_ia == .
	rename gfd_bill_tr_ia global_rf	
	save "${ASSETS_DERIVED}/global_safe_asset.dta", replace
	
end

program get_jst_fixed_income

	use "${JST_ORIG}/JSTdatasetR5.dta", clear
	rename * jst_*
	rename jst_year year
	rename jst_iso country
	
	keep country year jst_bond_rate jst_bond_tr

end

* ==============================================================================
* Run script
* ==============================================================================

main
