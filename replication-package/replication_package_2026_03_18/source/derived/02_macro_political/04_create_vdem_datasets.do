/*
Purpose: clean democracy variables for main paper and appendix
Primary author: Max Miller
Contributors: Paul Kim
Date: 11-22-2025
Details: used to load in e_migovdeb from Version 8... removing for now because 
	I don't think we use it
*/

* ==============================================================================
* Housekeeping
* ==============================================================================

clear all
version 19
adopath + "source/utils/analysis"

* ==============================================================================
* Set globals
* ==============================================================================

global CROSSWALKS				"datastore/raw/crosswalks"
global VDEM_ORIG				"datastore/raw/vdem/orig"
global VDEM_DATA				"datastore/raw/vdem/data"
global MACRO_POLITICAL_DERIVED 	"datastore/derived/macro_political"

* V-Dem variable descriptions
global IDS 			country_text_id year
global GEO 			e_regiongeo e_regionpol
global ANTI_SYS 	v2csantimv v2csantimv_ord v2csantimv_mean v2csanmvch_4 v2csanmvch_6
global PROTEST 		v2cagenmob v2cagenmob_mean v2cademmob v2cademmob_ord v2cademmob_mean
global VIOLENCE 	v2caviol v2x_clphy e_v2x_clphy_5C
global EQUALITY 	v2xeg_eqdr
global PROPERTY 	v2xcl_prpty v2xcl_rol
global CORRUPT 		v2exbribe v2x_corr v2x_pubcorr
global REGIME 		v2x_polyarchy v2x_regime v2regimpgroup v2x_regime_amb e_p_polity

* Variable range
global START_YEAR = 1816
global END_YEAR = 2018

* ==============================================================================
* Main execution logic
* ==============================================================================

program main

	* Get geographic classifiers
	load_vdem_vars "country_text_id ${GEO}"
	duplicates drop
	merge 1:1 country using "${CROSSWALKS}/region_map.dta", keep(1 3) nogen
	save "${MACRO_POLITICAL_DERIVED}/regions.dta", replace

	* Anti-system CSO activity
	load_vdem_vars "${IDS} ${ANTI_SYS} ${PROTEST}"
	keep if year >= $START_YEAR & year <= $END_YEAR
	save "${MACRO_POLITICAL_DERIVED}/anti_system_cso_activity_and_mobilizations.dta", replace

	* Physical and political violence
	load_vdem_vars "${IDS} ${VIOLENCE}"
	egen i = group(country), label
	tsset i year
	tsfill
	decode i, gen(country_temp)
	replace country = country_temp if country == ""
	bys i: ipolate v2x_clphy year , gen(v2x_clphy_i)
	gen v2x_clphy_5yr = v2x_clphy - L5.v2x_clphy
	gen v2x_clphy_i_5yr = v2x_clphy_i - L5.v2x_clphy_i
	keep if year >= $START_YEAR & year <= $END_YEAR
	drop i country_temp
	save "${MACRO_POLITICAL_DERIVED}/physical_and_political_violence.dta", replace

	* Resource inequality
	load_vdem_vars "${IDS} ${EQUALITY}"
	rename v2xeg_eqdr vdem_resource_equality
	gen vdem_resource_inequality = 1-vdem_resource_equality
	drop if vdem_resource_inequality == .
	keep if year >= $START_YEAR & year <= $END_YEAR
	save "${MACRO_POLITICAL_DERIVED}/resource_inequality.dta", replace

	* Property rights protections
	load_vdem_vars "${IDS} ${PROPERTY}"
	keep if year >= $START_YEAR & year <= $END_YEAR
	save "${MACRO_POLITICAL_DERIVED}/property_rights_protection.dta", replace
	
	* Corruption and bribery
	load_vdem_vars "${IDS} ${CORRUPT}"
	keep if year >= $START_YEAR & year <= $END_YEAR
	save "${MACRO_POLITICAL_DERIVED}/corruption_and_bribery.dta", replace
	
	* Regime characteristics and info
	load_vdem_vars "${IDS} ${REGIME}"
	
	rename v2x_polyarchy vdem_elect
	rename v2x_regime vdem_regime
	rename v2x_regime_amb vdem_regime_detail
	
	egen i = group(country), label
	tsset i year
	tsfill, full
	
	reghdfe vdem_regime vdem_elect F.vdem_regime, noabsorb
	forvalues i = 1(1)150 {
		replace vdem_regime = ///
			round(_b[_cons] + _b[F.vdem_regime]*F.vdem_regime + _b[vdem_elect] * vdem_elect,1) ///
			if vdem_regime == .
	}
	
	reghdfe vdem_regime_detail vdem_elect F.vdem_regime_detail, noabsorb
	forvalues i = 1(1)150 {
		replace vdem_regime_detail = ///
			round(_b[_cons] + _b[F.vdem_regime_detail]*F.vdem_regime_detail + _b[vdem_elect] * vdem_elect,1) ///
			if vdem_regime_detail == .
	}
	
	decode i, gen(country_temp)
	replace country = country_temp if country == ""
	
	gen autocracy = 1 if vdem_regime <= 1 & vdem_regime != .
	replace autocracy = 0 if vdem_regime > 1 & vdem_regime != .

	gen democracy = 1 if vdem_regime >= 2 & vdem_regime != .
	replace democracy = 0 if vdem_regime <= 1 & vdem_regime != .
	
	gsort i -year
	bys i: replace autocracy = autocracy[_n-1] if autocracy == .
	bys i: replace democracy = democracy[_n-1] if democracy == .
	gsort i year

	gen L_autocracy = L.autocracy
	
    gen impgroup_elite = inlist(v2regimpgroup,0,1,2,3)
    rangestat (max) impgroup_elite, i(year -2 0) by(i)
		
	merge m:1 country using "${MACRO_POLITICAL_DERIVED}/regions.dta", keep(1 3) nogen
	
    cap drop total_c
    bys e_regionpol year: egen reg_vdem_elect = total(vdem_elect)
    gen has_vdem_elect = vdem_elect != .
    bys e_regionpol year: egen total_c  = total(has_vdem_elect)
    gen Z_ace_vdem = (reg_vdem_elect-vdem_elect)/(total_c-1)
    sort i year
    
    * Generate 5-year change in democratization index
    cap drop Z_ace_vdem_5yr
    gen Z_ace_vdem_5yr = Z_ace_vdem - L5.Z_ace_vdem
    gen vdem_elect_5yr = vdem_elect - L5.vdem_elect
	
	drop country_temp i e_regiongeo e_regionpol country_name region
	
	keep if year >= $START_YEAR & year <= $END_YEAR
	
	save "${MACRO_POLITICAL_DERIVED}/democracy_index_and_regime_info.dta", replace
	
end


program load_vdem_vars
	args vars
	use `vars' ///
		using "${VDEM_ORIG}/version10/V-Dem-CY-Full+Others-v10.dta", clear
	rename country_text_id country

	* Discards invalid ISO3 codes referenced in valid_iso3_codes.dta creation script
	merge m:1 country using "${CROSSWALKS}/valid_iso3_codes.dta", keep(3) nogen

end

* ==============================================================================
* Run script
* ==============================================================================

main