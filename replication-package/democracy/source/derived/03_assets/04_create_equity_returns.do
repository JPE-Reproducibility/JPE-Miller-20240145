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

global JST_ORIG 				"datastore/raw/jst/orig"
global ASSETS_DERIVED 			"datastore/derived/assets"
global MACRO_POLITICAL_DERIVED 	"datastore/derived/macro_political"
global CROSSWALKS				"datastore/raw/crosswalks"
global PROGRAMS 				"source/derived/programs"

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

	get_gfd_eq_tr
	tempfile gfd_eq_tr
	save "`gfd_eq_tr'"

	get_gfd_data "gfd_lse_eq_tr" "close/L.close - 1"
	replace country = "XKX" if country == "KSV"
	tempfile gfd_lse_eq_tr
	save "`gfd_lse_eq_tr'"
	
	get_gfd_data "gfd_eq_capgain" "close/L.close - 1"
	tempfile gfd_eq_capgain
	save "`gfd_eq_capgain'"

	get_gfd_data "gfd_lse_eq_capgain" "close/L.close - 1"
	replace country = "XKX" if country == "KSV"
	tempfile gfd_lse_eq_capgain
	save "`gfd_lse_eq_capgain'"

	get_jst_eq_tr
	merge 1:1 country year using "`gfd_eq_tr'", nogen
	merge 1:1 country year using "`gfd_eq_capgain'", nogen
	merge 1:1 country year using "`gfd_lse_eq_tr'", nogen
	merge 1:1 country year using "`gfd_lse_eq_capgain'", nogen
	merge 1:1 country year using "${ASSETS_DERIVED}/factset.dta", nogen	
	merge 1:1 country year using "${ASSETS_DERIVED}/ibes_global.dta", nogen
	merge 1:1 country year using "`all_inflation'", keep(1 3) nogen
	
	keep year country *_eq_tr *_eq_capgain USA_inflation_exp all_cpi_g log_all_cpi_g
	keep if year >= $START_YEAR & year <= $END_YEAR
	
	** Remove inflation
	foreach var of varlist gfd_* jst_* {
		replace `var' = (1+`var')/(1+USA_inflation_exp) - 1
		gen log_`var' = log(1+`var')
	}

	* Remove home country inflation from Factset and IBES
	foreach var of varlist factset_* ibes_* {
		replace `var' = (1+`var')/(1+all_cpi_g) - 1
		gen log_`var' = log(1+`var')
	}

	* There are two very large IBES observations after this
	* They are replaced by GFD data in the final dataset
	winsor2 gfd_* jst_* ibes_* factset_*, c(.1 99.9) replace
	
	merge 1:1 country year using "${ASSETS_DERIVED}/all_div_yld.dta", nogen
	
	gen all_eq_tr = gfd_eq_tr
	replace all_eq_tr = jst_eq_tr if all_eq_tr == .
	replace all_eq_tr = gfd_eq_capgain + gfd_div_yld if all_eq_tr == .
	replace all_eq_tr = gfd_eq_capgain + gfd_lse_div_yld if all_eq_tr == .
	replace all_eq_tr = ibes_eq_tr if all_eq_tr == .
	replace all_eq_tr = factset_eq_tr if all_eq_tr == .
	replace all_eq_tr = gfd_lse_eq_tr if all_eq_tr == .

	gen all_eq_capgain = gfd_eq_capgain
	replace all_eq_capgain = jst_eq_capgain if all_eq_capgain == .
	replace all_eq_capgain = ibes_eq_capgain if all_eq_capgain == .
	replace all_eq_capgain = factset_eq_capgain if all_eq_capgain == .
	replace all_eq_capgain = gfd_lse_eq_capgain if all_eq_capgain == .
	
	gen log_all_eq_tr = log(1+all_eq_tr)
	gen log_all_eq_capgain = log(1+all_eq_capgain)
	
	* Drops Bermuda; will look into
	merge m:1 country using "${CROSSWALKS}/valid_iso3_codes.dta", keep(3) nogen
	sort country year

	keep country year *_eq_tr *_capgain

	save "${ASSETS_DERIVED}/all_equity_returns.dta", replace

end

program get_gfd_eq_tr

	create_eq_tr_supplement
	tempfile gfd_eq_tr_supplement
	save "`gfd_eq_tr_supplement'"

	* Equity Total Returns
	get_gfd_data "gfd_eq_tr" "close/L.close - 1"
	* Use the India, Ireland, and Italy indices from the supplement
	drop if country == "IND" | country == "IRL" | country == "ITA" | country == "NOR"
	append using "`gfd_eq_tr_supplement'"
	sort country year

end

* ==============================================================================
* Create Supplemental Datasets
* ==============================================================================

program define create_eq_tr_supplement

	* Equity Total Returns
	import excel "${GFD_ORIG}/supplements/extraTotalReturnsClean.xlsx", sheet("Price Data") firstrow clear
	gen year = year(date(date,"MDY"))
	drop date
	order country year
	encode country, gen(country_id)
	tsset country_id year
	gen gfd_eq_tr = gfd_total_ret_sup/L.gfd_total_ret_sup - 1
	drop if gfd_eq_tr == .
	keep country year gfd_eq_tr
	sort country year
	drop if country == "BEL" & year >= 1897
	drop if country == "VEN" // use the longer index from previous download

end 

program get_jst_eq_tr

	use "${JST_ORIG}/JSTdatasetR5.dta", clear
	rename * jst_*
	rename jst_year year
	rename jst_iso country
	egen i = group(country) , label
	tsset i year

	** Switch JST to dollars
	gen jst_xusd_mult = L.jst_xrusd/jst_xrusd
	replace jst_eq_tr = jst_eq_tr*jst_xusd_mult
	replace jst_eq_capgain = jst_eq_capgain*jst_xusd_mult

	keep country year jst_eq_tr jst_eq_capgain

end

* ==============================================================================
* Run script
* ==============================================================================

main