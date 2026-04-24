/*
Purpose: Generate Figure C4 - Dropping every country pair, 1946–1976
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

winsor2 capm_unexp2, replace

cap drop falsify*

local startD = $begYear
local endD = $endYear1
local treatD1 = 1959
local treatD2 = 1963
mat falsify = J(41,4,.)
local j = 1

forvalues i = -8/8 {
    local temp1 = `startD'+`i'
    local temp2 = `endD'+`i'
    local temp3 = `treatD1'+`i'
    local temp4 = `treatD2'+`i'
    
    cap drop tempTreat
    gen tempTreat = maj_cath_aut2 if year >= `temp4' & year <= `temp2'
    replace tempTreat = 0 if year >= `temp1' & year <= `temp3'
    
    reghdfe capm_unexp2 tempTreat $EC $CC if year <= `temp2' & year >= `temp1' , $FE $CLUSTER_VARS
    
    mat temp_mat = r(table)
    mat falsify[`j',1] = `temp3'
    mat falsify[`j',2] = temp_mat[1,1]
    mat falsify[`j',3] = temp_mat[1,1] + 1.96*temp_mat[2,1]
    mat falsify[`j',4] = temp_mat[1,1] - 1.96*temp_mat[2,1]
    local j = `j' + 1
    
}

svmat double falsify
replace falsify2 = falsify2*100
replace falsify3 = falsify3*100
replace falsify4 = falsify4*100

two (scatter falsify2 falsify1, color(blue) connect(l)) ///
    (rcap falsify4 falsify3 falsify1, color(blue)), yline(0) ///
    graphregion(color(white)) xtitle("") ///
    ylabel(0(10)30, nogrid) xlabel(, nogrid) legend(off) bgcolor(white) ///
    xline(`treatD1', lwidth(4.5) lc(gs12) lp(solid))
graph export "${FIGURES}/raw/figure_C4a_country_pair_falsification.pdf", replace

drop falsify*

local startD = $begYear
local endD = $endYear1
local treatD1 = 1959
local treatD2 = 1963
mat falsify = J(41,4,.)
local j = 1

forvalues i = -8/8 {
    local temp1 = `startD'+`i'
    local temp2 = `endD'+`i'
    local temp3 = `treatD1'+`i'
    local temp4 = `treatD2'+`i'
    
    cap drop tempTreat
    gen tempTreat = maj_cath_aut2 if year >= `temp4' & year <= `temp2'
    replace tempTreat = 0 if year >= `temp1' & year <= `temp3'
    
    reghdfe capm_unexp2 tempTreat $EC $CC if year <= `temp2' & year >= `temp1' & autSample2 == 1, $FE $CLUSTER_VARS
    
    mat temp_mat = r(table)
    mat falsify[`j',1] = `temp3'
    mat falsify[`j',2] = temp_mat[1,1]
    mat falsify[`j',3] = temp_mat[1,1] + 1.96*temp_mat[2,1]
    mat falsify[`j',4] = temp_mat[1,1] - 1.96*temp_mat[2,1]
    local j = `j' + 1
    
}

svmat double falsify
replace falsify2 = falsify2*100
replace falsify3 = falsify3*100
replace falsify4 = falsify4*100

two (scatter falsify2 falsify1, color(blue) connect(l)) ///
    (rcap falsify4 falsify3 falsify1, color(blue)), yline(0) ///
    graphregion(color(white)) xtitle("") ///
    ylabel(0(10)30, nogrid) xlabel(, nogrid) legend(off) bgcolor(white) ///
    xline(`treatD1', lwidth(4.5) lc(gs12) lp(solid))
graph export "${FIGURES}/raw/figure_C4b_country_pair_falsification_aut.pdf", replace
