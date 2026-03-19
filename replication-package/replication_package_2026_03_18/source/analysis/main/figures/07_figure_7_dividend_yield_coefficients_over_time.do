/*
Purpose: Generate Figure 7 - Democratization coefficients over rolling time windows
Author: Max Miller
Date: 2025
*/

* ===========================================================================
* Housekeeping
* ===========================================================================

clear all
version 19
set scheme s2color
adopath + "source/utils/analysis"

* ===========================================================================
* Set globals
* ===========================================================================

global ANALYSIS_DERIVED 		"datastore/derived/analysis"
global FIGURES 					"source/figures"

** Controls
global EC financial_crisis icb_crisis at_war default recession govt_head_death assas_succ assas_attempt md_high_action coup_detat

* ===========================================================================
* Main execution logic
* ===========================================================================

use "${ANALYSIS_DERIVED}/section_3_data.dta", clear

* Initialize matrix to store results
* 111 years from 1910 to 2020
mat dem_coef = J(111,4,.)

* Define democratization variable
local dem_var "combo_dem_minus_start"

* Loop through years with 60-year rolling window
local j = 0
forvalues i = 1910(1)2020 {
	local j = `j' + 1
	local start_year = `i' - 60

	* Run regression for this window
	reghdfe log_all_div_yld_5yr `dem_var' $EC ///
		if year >= `start_year' & year <= `i', absorb(country_id year) vce(cluster country_id year)

	* Store results
	mat dem_coef[`j',1] = `i'
	mat dem_coef[`j',2] = _b[`dem_var']
	mat dem_coef[`j',3] = _b[`dem_var'] - 1.645*_se[`dem_var']
	mat dem_coef[`j',4] = _b[`dem_var'] + 1.645*_se[`dem_var']
}

* Convert matrix to variables
cap drop dem_coef*
svmat dem_coef

* Convert to percentage
replace dem_coef2 = dem_coef2*100
replace dem_coef3 = dem_coef3*100
replace dem_coef4 = dem_coef4*100

* Create endash character
local endash = ustrunescape("\u2013")

* Set label size
local labSize = "large"

* Create the plot
two (connected dem_coef2 dem_coef1, color(red) msymbol(s) lw(.5)) ///
	(rcap dem_coef3 dem_coef4 dem_coef1, color(red) lw(.5)), ///
	graphregion(color(white)) ///
	ylabel(, nogrid labsize(`labSize')) ///
	xlabel(, nogrid labsize(`labSize')) ///
	xtitle("60-year estimation window (Start `endash' End)", size(`labSize') margin(medsmall)) ///
	bgcolor(white) ///
	ytitle("Change in dividend yield (%)", size(`labSize') margin(medsmall)) ///
	yline(0, lw(.4) lc(black) lp(dash)) ///
	legend(off) ///
	ysize(2.5) ///
	xsc(r(1906 2024)) ///
	xlabel(1920 "1860 `endash' 1920" ///
		   1940 "1880 `endash' 1940" ///
		   1960 "1900 `endash' 1960" ///
		   1980 "1920 `endash' 1980" ///
		   2000 "1940 `endash' 2000" ///
		   2020 "1960 `endash' 2020")

graph export "${FIGURES}/raw/figure_7_coefficients_over_time.pdf", replace
