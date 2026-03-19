/*
Purpose: Generate Figure 2 - Physical and human capital in democratizations
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

* ===========================================================================
* Main execution logic
* ===========================================================================

use "${ANALYSIS_DERIVED}/section_3_data.dta", clear

event_study log_IK combo_dem_start , tlags(5 5) reflag(3) cluster(country_id year) absorb(country_id year) ///
    savedata("${FIGURES}/data/figure_2_investment_capital_ratio_event_study.dta")

event_study log_hc combo_dem_start, tlags(5 5) reflag(3) cluster(country_id year) absorb(country_id year) ///
    savedata("${FIGURES}/data/figure_2_human_capital_event_study.dta")

* Load investment-capital ratio results
use "${FIGURES}/data/figure_2_investment_capital_ratio_event_study.dta", clear

rename lo_01 dem_lb
rename hi_01 dem_ub
rename b_01  dem_pe
rename se_01 dem_se

gen store_mat_line = 0

replace dem_lb = 0 if dem_lb == .
replace dem_ub = 0 if dem_ub == .

replace dem_lb = dem_pe - 1.645*dem_se
replace dem_ub = dem_pe + 1.645*dem_se

* Merge with human capital results
merge 1:1 t using "${FIGURES}/data/figure_2_human_capital_event_study.dta"

rename lo_01 dem2_lb
rename hi_01 dem2_ub
rename b_01  dem2_pe
rename se_01 dem2_se

replace dem2_lb = 0 if dem2_lb == .
replace dem2_ub = 0 if dem2_ub == .

replace dem2_lb = dem2_pe - 1.645*dem2_se
replace dem2_ub = dem2_pe + 1.645*dem2_se

local sy = 5

drop if t > `sy' | t < -`sy'

replace t = t+5

cap label drop tplus
label define tplus ///
    0 "t-5" ///
    1 "t-4" ///
    2 "t-3" ///
    3 "t-2" ///
    4 "t-1" ///
    5 "t" ///
    6 "t+1" ///
    7 "t+2" ///
    8 "t+3" ///
    9 "t+4" ///
    10 "t+5"

label values t tplus

* Create the plot with dual y-axes
local labSize = "large"
two (rcap dem_lb dem_ub t, color(blue%70)) ///
    (connected dem_pe t, color(blue) msymbol(s) lw(.6)) ///
    (rcap dem2_lb dem2_ub t, color(red%70) yaxis(2)) ///
    (connected dem2_pe t, color(red) msymbol(s) lw(.6) yaxis(2)) ///
    (line store_mat_line t, color(black) lp(dash) lw(.33)), ///
    xlabel(, labsize(`labSize') nogrid valuelabel) graphregion(color(white)) ///
    ylabel(-.2(.1).25, nogrid labsize(`labSize') axis(1) labcolor(blue)) ///
    ylabel(-.02(.01).025, nogrid labsize(`labSize') axis(2) labcolor(red)) ///
    yscale(r(-.17 .16) axis(1)  lc(blue)) yscale(r(-.017 .016) axis(2)  lc(red)) ///
    xtitle("Years to/from start of democratization", size(`labSize') margin(medsmall)) ///
    bgcolor(white) subtitle(" ") ///
    ytitle("Log Investment-Capital Ratio", size(`labSize') axis(1) margin(medsmall) color(blue)) ///
    ytitle("Log Human Capital Index", size(`labSize') axis(2) margin(medsmall) color(red)) ///
    legend(off) ysize(2.5)

graph export "${FIGURES}/raw/figure_2_physical_human_capital.pdf", replace

