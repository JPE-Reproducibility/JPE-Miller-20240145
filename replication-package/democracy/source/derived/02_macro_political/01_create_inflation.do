/*
Purpose: Create inflation variables from all sources (GFD, JST, V-Dem)
Primary author: Max Miller
Date: 11-11-2025
Details: Dropped countries are
	- Aruba
	- Anguilla
	- Bahamas
	- Belize
	- Bermuda
	- Brunei Darussalam
    - Curaçao
    - Cayman Islands
    - Faroe Islands
	- Grenada
	- Saint Kitts and Nevis
	- Saint Lucia
	- Macao
	- Montserrat
	- New Caledonia
	- Lao PDR
	- Puerto Rico
	- San Marino
	- Samoa
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

global CROSSWALKS					"datastore/raw/crosswalks"
global JST_ORIG 					"datastore/raw/jst/orig"
global GFD_DATA 					"datastore/raw/gfd/data"
global VDEM_ORIG 					"datastore/raw/vdem/orig"
global MACRO_POLITICAL_DERIVED 		"datastore/derived/macro_political"
global PROGRAMS						"source/derived/programs"

do "${PROGRAMS}/create_gfd_data.do"

global START_YEAR = 1816
global END_YEAR = 2018

* ==============================================================================
* Main execution logic
* ==============================================================================

program main

	get_gfd_cpi
	tempfile gfd_cpi
	save "`gfd_cpi'"
	
	get_jst_cpi
	tempfile jst_cpi
	save "`jst_cpi'"
	
	get_vdem_cpi
	tempfile vdem_cpi
	save "`vdem_cpi'"
	
	merge 1:1 country year using "`gfd_cpi'", nogen
	merge 1:1 country year using "`jst_cpi'", nogen
	
	keep if year >= $START_YEAR & year <= $END_YEAR
	
	create_inflation_vars
	
	merge m:1 country using "${CROSSWALKS}/valid_iso3_codes.dta", keep(3) nogen
	
	save "${MACRO_POLITICAL_DERIVED}/all_inflation.dta", replace

end

program get_gfd_cpi

	* Consumer Price Index
	get_gfd_data "gfd_cpi" "close"
	create_growth_vars gfd_cpi
	
	replace country = "XKX" if country == "KSV"
	
end

program get_jst_cpi

	use year iso cpi using "${JST_ORIG}/JSTdatasetR5.dta", clear
	rename * jst_*
	rename jst_year year
	rename jst_iso country
	rename jst_cpi jst_cpi
	keep country year jst_cpi
	create_growth_vars jst_cpi
		
end

program get_vdem_cpi

	use country_text_id year e_miinflat /// 
		using "${VDEM_ORIG}/version10/V-Dem-CY-Full+Others-v10.dta", clear
	rename country_text_id country
	rename e_miinflat vdem_cpi_g
	replace vdem_cpi_g = vdem_cpi_g/100
	winsor2 vdem_cpi_g, c(.1 99.9) replace
	
end

program create_inflation_vars

	* Create combined inflation variable
	egen all_cpi_g = rowmean(gfd_cpi_g jst_cpi_g vdem_cpi_g)
	gen log_all_cpi_g = log(1+all_cpi_g)
	
	encode country, generate(i)
	tsset i year
	gen log_all_cpi_5yr = log_all_cpi_g + L1.log_all_cpi_g + L2.log_all_cpi_g + L3.log_all_cpi_g + L4.log_all_cpi_g
	drop i
	
	* Create expected inflation using an AR(1)
	country_ar1 log_all_cpi_g
	
	* Create USA expected inflation
	bys year: egen temp = min(log_all_cpi_g_exp) if country  == "USA"
	bys year: egen log_USA_inflation_exp = min(temp)
	drop temp
	sort country year
	
	gen USA_inflation_exp = exp(log_USA_inflation_exp) - 1
	
	keep country year gfd_cpi_g jst_cpi_g vdem_cpi_g all_cpi_g log_all_cpi_g log_all_cpi_g_exp log_all_cpi_5yr log_USA_inflation_exp USA_inflation_exp
	
end

program create_growth_vars
args var
	
	encode country, generate(i)
	tsset i year
	tsfill, full

	decode i, generate(tmp_country)
	replace country = tmp_country if country == ""
	
	bys i: ipolate `var' year, gen(`var'_i)

	gen log_`var' = log(`var')
	gen log_`var'_g = log(`var')-log(L.`var')
	gen `var'_g = `var'/L.`var' - 1
	gen log_`var'_5yr = log(`var'_i) - log(L5.`var'_i)

	drop i tmp_country

end

program country_ar1
args var

	egen i = group(country)
	gen t = year
	tsset i t

	gen lag_`var' = L.`var'
	bys i: asreg `var' lag_`var', fitted
	gen `var'_exp = _fitted
	drop i t _* lag_`var'

end

* ==============================================================================
* Run script
* ==============================================================================

main

