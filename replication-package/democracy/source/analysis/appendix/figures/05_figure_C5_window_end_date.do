/*
Purpose: Generate Figure C5 - Different estimation window end dates
Author: Max Miller
Date: 12-10-2025
*/

* ===========================================================================
* Housekeeping
* ===========================================================================

clear all
version 19
set scheme s2color
adopath ++ "source/utils/analysis"

* ===========================================================================
* Set globals
* ===========================================================================

global ASSETS_DERIVED   "datastore/derived/assets"
global ANALYSIS_DERIVED "datastore/derived/analysis"
global FIGURES          "source/figures"

global begYear = 1946
global endYear1 = 1976

global EC govt_head_death financial_crisis icb_crisis at_war default_first_5 recession combo_dem assas_attempt assas_succ coup_detat
global CC log_ggdc_gdppc_i log_ggdc_gdppc_i_g

global CLUSTER_VARS cluster(country_id year)
global FE absorb(country_id year vdem_regime)

* ===========================================================================
* Main execution logic
* ===========================================================================

use "${ANALYSIS_DERIVED}/section_4_data.dta", clear

keep if year >= 1939 & year <= 1983
winsor2 capm_unexp2, replace

cap drop end_year_test*
local i = 1
mat end_year_test = J(14,4,.)
forvalues j = 1970(1)1983 {
    reghdfe capm_unexp2 maj_cath_aut2_post $CC $EC if year <= `j' , $FE $CLUSTER_VARS
    mat temp_mat = r(table)
    mat end_year_test[`i',1] = `j'
    mat end_year_test[`i',2] = _b[maj_cath_aut2_post]*100
    mat end_year_test[`i',3] = _b[maj_cath_aut2_post]*100 + 1.96*_se[maj_cath_aut2_post]*100
    mat end_year_test[`i',4] = _b[maj_cath_aut2_post]*100 - 1.96*_se[maj_cath_aut2_post]*100
    local i = `i' + 1
}

svmat double end_year_test
cap drop store_mat_line
gen store_mat_line = 0
local labSize = "large"
two (rcap end_year_test3 end_year_test4 end_year_test1, color(red%70)) ///
    (connected end_year_test2 end_year_test1, color(red) msymbol(s) lw(.6)) ///
    (line store_mat_line end_year_test1, color(black) lp(dash) lw(.33)), ///
    xlabel(1970(4)1983, valuelabel labsize(`labSize')) graphregion(color(white)) ylabel(0(5)20, nogrid labsize(`labSize')) ///
    bgcolor(white) subtitle(" ") xtitle("") ///
    ytitle("Percentage points", size(`labSize') margin(medsmall)) ///
    legend(off) ysize(3.5)
graph export "${FIGURES}/raw/figure_C5a_window_end_date_all.pdf", replace

drop end_year_test*

local i = 1
mat end_year_test = J(14,4,.)
forvalues j = 1970(1)1983 {
    reghdfe capm_unexp2 maj_cath_aut2_post $CC $EC if year <= `j' & autSample2 == 1, $FE $CLUSTER_VARS
    mat temp_mat = r(table)
    mat end_year_test[`i',1] = `j'
    mat end_year_test[`i',2] = _b[maj_cath_aut2_post]*100
    mat end_year_test[`i',3] = _b[maj_cath_aut2_post]*100 + 1.96*_se[maj_cath_aut2_post]*100
    mat end_year_test[`i',4] = _b[maj_cath_aut2_post]*100 - 1.96*_se[maj_cath_aut2_post]*100
    local i = `i' + 1
}

svmat double end_year_test
cap drop store_mat_line
gen store_mat_line = 0
local labSize = "large"
two (rcap end_year_test3 end_year_test4 end_year_test1, color(red%70)) ///
    (connected end_year_test2 end_year_test1, color(red) msymbol(s) lw(.6)) ///
    (line store_mat_line end_year_test1, color(black) lp(dash) lw(.33)), ///
    xlabel(1970(4)1983, valuelabel labsize(`labSize')) graphregion(color(white)) ylabel(0(5)20, nogrid labsize(`labSize')) ///
    bgcolor(white) subtitle(" ") xtitle("") ///
    ytitle("Percentage points", size(`labSize') margin(medsmall)) ///
    legend(off) ysize(3.5)
graph export "${FIGURES}/raw/figure_C5b_window_end_date_aut.pdf", replace
