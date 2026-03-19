/*
Purpose: Generate Table 1 - Democratizations and changes in log dividend yields
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

* Different specifications
global SPEC1 "controls($EC) absorb(country_id year)"
global SPEC2 "controls($EC) absorb(country_id reg_year)"
global SPEC3 "controls($EC) absorb(country_id regime_region_year)"
global SPEC4 "controls($EC $CC) absorb(country_id regime_region_year)"

** Controls
global CC log_ggdc_gdppc_i log_ggdc_gdppc_i_5yr v2x_clphy v2x_clphy_5yr log_all_cpi_5yr
global EC at_war default recession govt_head_death assas_succ assas_attempt md_high_action coup_detat

* ===========================================================================
* Main execution logic
* ===========================================================================

use "${ANALYSIS_DERIVED}/section_3_data.dta", clear

egen reg_year = group(year e_regionpol)
egen regime_region_year = group(year region autocracy)

gen dem_ep_bef2 = F2.combo_dem_start
replace dem_ep_bef2 = 0 if dem_ep_bef2 == .

forvalues spec = 1/4 {

    * Run event study for democratizations
    esplot log_IK, event(dem_ep_bef2) w(-5 9, bin ) ///
        estimate_reference vce(cluster country_id) ${SPEC`spec'} ///
        savedata(${FIGURES}/data/figure_B3_IK_event_study_`spec', replace)

    * Run event study for financial crises
    esplot log_hc, event(dem_ep_bef2) w(-5 9, bin) ///
        estimate_reference vce(cluster country_id) ${SPEC`spec'} ///
        savedata(${FIGURES}/data/figure_B3_hc_event_study_`spec', replace)

}

forvalues spec = 1/4 {

    preserve

    * Load investment-capital ratio results
    use "${FIGURES}/data/figure_B3_IK_event_study_`spec'.dta", clear

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
    merge 1:1 t using "${FIGURES}/data/figure_B3_hc_event_study_`spec'.dta"

    rename lo_01 dem2_lb
    rename hi_01 dem2_ub
    rename b_01  dem2_pe
    rename se_01 dem2_se

    replace dem2_lb = 0 if dem2_lb == .
    replace dem2_ub = 0 if dem2_ub == .

    replace dem2_lb = dem2_pe - 1.645*dem2_se
    replace dem2_ub = dem2_pe + 1.645*dem2_se

    replace t = t-2

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
    local labSize = "med"
    two (rcap dem_lb dem_ub t, color(blue%70)) ///
        (connected dem_pe t, color(blue) msymbol(s) lw(.6)) ///
        (rcap dem2_lb dem2_ub t, color(red%70) yaxis(2)) ///
        (connected dem2_pe t, color(red) msymbol(s) lw(.6) yaxis(2)) ///
        (line store_mat_line t, color(black) lp(dash) lw(.33)), ///
        xlabel(, labsize(`labSize') nogrid valuelabel) graphregion(color(white)) ///
        ylabel(-.15(.05).2, nogrid labsize(`labSize') axis(1) labcolor(blue)) ///
        ylabel(-.015(.005).02, nogrid labsize(`labSize') axis(2) labcolor(red)) ///
        yscale(r(-.17 .16) axis(1)  lc(blue)) yscale(r(-.017 .016) axis(2)  lc(red)) ///
        xtitle("Years to/from start of democratization", size(`labSize') margin(medsmall)) ///
        bgcolor(white) subtitle(" ") ///
        ytitle("Log Investment-Capital Ratio", size(`labSize') axis(1) margin(medsmall) color(blue)) ///
        ytitle("Log Human Capital Index", size(`labSize') axis(2) margin(medsmall) color(red)) ///
        legend(off) ysize(6)

        graph export "${FIGURES}/raw/figure_B3_physical_human_capital_`spec'.pdf", replace
        restore

}


forvalues spec = 1/4 {

    * Run event study for democratizations
    locproj log_IK , shock(dem_ep_bef2) ///
        h(-3/7) fe ///
        ${SPEC`spec'} cluster(country_id) ylags(0) slags(0) tr("cmlt")

    mat irf = e(irf)
    preserve
    clear
    svmat irf

    gen t = -5 if _n == 1
    replace t = t[_n-1] + 1 if t == .

    rename irf1 b_01
    rename irf2 se_01
    rename irf3 lo_01
    rename irf4 hi_01
    save "${FIGURES}/data/figure_B3_IK_event_study_`spec'_lp.dta", replace
    restore

    * Run event study for democratizations
    locproj log_hc , shock(dem_ep_bef2) ///
        h(-3/7) fe ///
        ${SPEC`spec'} cluster(country_id) ylags(0) slags(0) tr("cmlt")
    
    mat irf = e(irf)
    preserve
    clear
    svmat irf

    gen t = -5 if _n == 1
    replace t = t[_n-1] + 1 if t == .

    rename irf1 b_01
    rename irf2 se_01
    rename irf3 lo_01
    rename irf4 hi_01
    save "${FIGURES}/data/figure_B3_hc_event_study_`spec'_lp.dta", replace
    restore

}

forvalues spec = 1/4 {

    preserve

    * Load investment-capital ratio results
    use "${FIGURES}/data/figure_B3_IK_event_study_`spec'_lp.dta", clear

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
    merge 1:1 t using "${FIGURES}/data/figure_B3_hc_event_study_`spec'_lp.dta"

    rename lo_01 dem2_lb
    rename hi_01 dem2_ub
    rename b_01  dem2_pe
    rename se_01 dem2_se

    replace dem2_lb = 0 if dem2_lb == .
    replace dem2_ub = 0 if dem2_ub == .

    replace dem2_lb = dem2_pe - 1.645*dem2_se
    replace dem2_ub = dem2_pe + 1.645*dem2_se

    replace t = t

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
    local labSize = "med"
    two (rcap dem_lb dem_ub t, color(blue%70)) ///
        (connected dem_pe t, color(blue) msymbol(s) lw(.6)) ///
        (rcap dem2_lb dem2_ub t, color(red%70) yaxis(2)) ///
        (connected dem2_pe t, color(red) msymbol(s) lw(.6) yaxis(2)) ///
        (line store_mat_line t, color(black) lp(dash) lw(.33)), ///
        xlabel(, labsize(`labSize') nogrid valuelabel) graphregion(color(white)) ///
        ylabel(-.15(.05).2, nogrid labsize(`labSize') axis(1) labcolor(blue)) ///
        ylabel(-.015(.005).02, nogrid labsize(`labSize') axis(2) labcolor(red)) ///
        yscale(r(-.17 .16) axis(1)  lc(blue)) yscale(r(-.017 .016) axis(2)  lc(red)) ///
        xtitle("Years to/from start of democratization", size(`labSize') margin(medsmall)) ///
        bgcolor(white) subtitle(" ") ///
        ytitle("Log Investment-Capital Ratio", size(`labSize') axis(1) margin(medsmall) color(blue)) ///
        ytitle("Log Human Capital Index", size(`labSize') axis(2) margin(medsmall) color(red)) ///
        legend(off) ysize(6)

        graph export "${FIGURES}/raw/figure_B3_physical_human_capital_`spec'_lp.pdf", replace
        restore

}

