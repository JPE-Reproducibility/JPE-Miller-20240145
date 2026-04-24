/*
Purpose: create Factset annual dividend yields
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

global WRDS_ORIG "datastore/raw/wrds/orig"
global CROSSWALKS "datastore/raw/crosswalks"
global ASSETS_DERIVED "datastore/derived/assets"

* ==============================================================================
* Main execution logic
* ==============================================================================

program main

	import delimited "${CROSSWALKS}/iso2_codes_to_iso3_codes.csv", varnames(1) clear
	tempfile iso2iso3
	save "`iso2iso3'"
	
	use FF_PRICE_CLOSE_FP FF_DPS DATE FF_SHS_FLOAT region using "${WRDS_ORIG}/factset_annual_fiscal.dta", clear

	gen year = year(DATE)
	gen month = month(DATE) 
	gen date = ym(year, month)

	rename FF_PRICE_CLOSE_FP price
	drop if price < .5

	drop if FF_DPS < 0.01
	drop if FF_DPS == .
	gen mkt_cap = FF_SHS_FLOAT*price
	drop if mkt_cap <= 0

	gcollapse (mean) price FF_DPS [w=mkt_cap], by(region year)
	drop if region == ""

	gen factset_div_yld = FF_DPS/price
	replace factset_div_yld = . if factset_div_yld >= .35

	merge m:1 region using "`iso2iso3'", keep(3) nogen
	order country year
	drop region

	encode country, gen(country_id)
	tsset country_id year 

	gen factset_eq_capgain = price/L.price - 1
	replace factset_eq_capgain = . if factset_eq_capgain > 4
	replace factset_eq_capgain = . if factset_eq_capgain < -.9

	gen factset_eq_tr = factset_eq_capgain + (factset_div_yld*(1+factset_eq_capgain))

	keep country year factset_eq_tr factset_eq_capgain factset_div_yld

	* This drops Guernsey (GGY); will revisit
	merge m:1 country using "${CROSSWALKS}/valid_iso3_codes.dta", keep(3) nogen

	
	save "${ASSETS_DERIVED}/factset.dta", replace

end

* ==============================================================================
* Run script
* ==============================================================================

main