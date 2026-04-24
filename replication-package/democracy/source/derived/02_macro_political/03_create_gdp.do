/*
Purpose: create ggdc gdp variables for main paper and appendix
Primary author: Paul Kim
Date: 11-26-2025
Details: Drops countries:
	- Czechoslovakia (merged into Czech Republic)
	- Yugoslavia (merged into Serbia)
	- Soviet Union (merged into Russia)
	- Dominica
	- Saint Lucia
	- Puerto Rico
*/

* ==============================================================================
* Housekeeping
* ==============================================================================

clear all
version 19

* ==============================================================================
* Set globals
* ==============================================================================

global CROSSWALKS					"datastore/raw/crosswalks"
global GGDC_ORIG 					"datastore/raw/ggdc/orig"
global MACRO_POLITICAL_DERIVED		"datastore/derived/macro_political"

global START_YEAR = 1816
global END_YEAR = 2018

* ==============================================================================
* Main execution logic
* ==============================================================================

program main

    use "${GGDC_ORIG}/mpd2020.dta", clear
	drop country
    rename * ggdc_*
    rename ggdc_year year
    rename ggdc_countrycode country
	
    egen i = group(country), label
    tsset i year
    tsfill, full
    
    decode i, generate(country_temp)
    replace country = country_temp if country == ""
    drop country_temp

	fill_in_country , new("RUS") old("SUN")
	fill_in_country , new("SRB") old("YUG")
	fill_in_country , new("CZE") old("CSK")
	
    bys i: ipolate ggdc_gdppc year, gen(ggdc_gdppc_i)
    bys i: ipolate ggdc_pop year, gen(ggdc_pop_i)

    gen ggdc_gdp = ggdc_gdppc*ggdc_pop
    gen ggdc_gdp_i = ggdc_gdppc_i*ggdc_pop_i
	gen log_ggdc_gdp = log(ggdc_gdp)
	gen log_ggdc_gdp_i = log(ggdc_gdp_i)

    gen log_ggdc_gdppc = log(ggdc_gdppc)
    gen log_ggdc_gdppc_i = log(ggdc_gdppc_i)
    gen log_ggdc_gdppc_i_5yr = log_ggdc_gdppc_i - L5.log_ggdc_gdppc_i

	gen ggdc_gdppc_g = ggdc_gdppc/L.ggdc_gdppc - 1
	gen ggdc_gdppc_i_g = ggdc_gdppc_i/L.ggdc_gdppc_i - 1
	
	gen log_ggdc_gdppc_g = log_ggdc_gdppc - L.log_ggdc_gdppc
	gen log_ggdc_gdppc_i_g = log_ggdc_gdppc_i - L.log_ggdc_gdppc_i

	gen log_ggdc_gdp_g = log_ggdc_gdp - L.log_ggdc_gdp
	gen log_ggdc_gdp_i_g = log_ggdc_gdp_i - L.log_ggdc_gdp_i

	forvalues i = 1(1)5{
		gen L`i'_log_ggdc_gdppc_i = L`i'.log_ggdc_gdppc_i
		gen F`i'_log_ggdc_gdppc_i = F`i'.log_ggdc_gdppc_i
	}
	
	keep if year >= $START_YEAR & year <= $END_YEAR
	
    sort country year
    drop i

	* Drops the following countries - DMA, LCA, PRI
	* Drops recent history for CSK, SUN, and YUG
	merge m:1 country using "${CROSSWALKS}/valid_iso3_codes.dta", keep(3) nogen
	
    save "${MACRO_POLITICAL_DERIVED}/real_gdp.dta", replace

end

program fill_in_country
	
	syntax , new(string) old(string)
	
	foreach var in ggdc_gdppc ggdc_pop {
		* Fill in Russia past with Soviet Union if missing
		sum year if country == "`new'" & `var' != .
		local fill_year = r(min)

		sum `var' if year == `fill_year' & country == "`old'"
		local old_country_val = r(mean)

		sum `var' if year == `fill_year' & country == "`new'"
		local new_country_val = r(mean)

		gen temp = `var' * (`new_country_val' / `old_country_val') if country == "`old'"
		bys year: egen temp_`var' = min(temp)
		
		replace `var' = temp_`var' if year < `fill_year' & country == "`new'"
		
		drop temp temp_`var'
		sort i year
	}	
	
end

* ==============================================================================
* Run script
* ==============================================================================

main

// * ==============================================================================
// * Check against old data
// * ==============================================================================
//
// check_dataset_diffs_numeric "${MACRO_POLITICAL_DERIVED}/real_gdp.dta"
