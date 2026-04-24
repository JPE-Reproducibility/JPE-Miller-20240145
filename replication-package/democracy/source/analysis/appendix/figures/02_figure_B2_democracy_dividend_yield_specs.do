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
adopath ++ "source/utils/analysis"

* ===========================================================================
* Set globals
* ===========================================================================

global ANALYSIS_DERIVED 		"datastore/derived/analysis"
global FIGURES 					"source/figures"

* Different specifications
global SPEC1 "absorb(country_id year)"
global SPEC2 "absorb(country_id reg_year)"
global SPEC3 "absorb(country_id regime_region_year)"
global SPEC4 "controls($EC $CC) absorb(country_id regime_region_year)"

** Controls
global CC log_ggdc_gdppc_i log_ggdc_gdppc_i_5yr v2x_clphy v2x_clphy_5yr log_all_cpi_5yr
global EC at_war default recession govt_head_death assas_succ assas_attempt md_high_action coup_detat

* ===========================================================================
* Main execution logic
* ===========================================================================

use "${ANALYSIS_DERIVED}/section_3_data.dta", clear

gen log_all_div_yld = log_gfd_div_yld
replace log_all_div_yld = log_jst_div_yld if log_all_div_yld == .
keep if log_all_div_yld != .
drop if log_all_div_yld_5yr == . // Restrict to table 1 sample

egen reg_year = group(year e_regionpol)
egen regime_region_year = group(year region L_autocracy)

forvalues spec = 1/4 {

    event_study log_all_div_yld combo_dem_minus_start, tlags(5 5) reflag(3) cluster(country_id year) ${SPEC`spec'} ///
        savedata("${FIGURES}/data/figure_B2_democratization_event_study_`spec'.dta")
        
    event_study log_all_div_yld financial_crisis, tlags(5 5) reflag(3) cluster(country_id year) ${SPEC`spec'} ///
        savedata("${FIGURES}/data/figure_B2_financial_crisis_event_study_`spec'.dta")

}

forvalues spec = 1/4 {

    preserve
    use "${FIGURES}/data/figure_B2_democratization_event_study_`spec'.dta", clear

    rename lo_01 dem_lb
    rename hi_01 dem_ub
    rename b_01  dem_pe
    rename se_01 dem_se

    merge 1:1 t using "${FIGURES}/data/figure_B2_financial_crisis_event_study_`spec'.dta", nogen

    rename b_01  fc_pe

    gen store_mat_line = 0

    replace dem_lb = 0 if dem_lb == .
    replace dem_ub = 0 if dem_ub == .

    replace dem_lb = dem_pe - 1.645*dem_se
    replace dem_ub = dem_pe + 1.645*dem_se

    local sy = 5

    drop if t > `sy' | t < -`sy'

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

    replace t = t + `sy'
    replace dem_pe = dem_pe*100
    replace fc_pe = fc_pe*100
    replace dem_lb = dem_lb*100
    replace dem_ub = dem_ub*100

    label values t tplus

    local labSize = "med"
    two (rcap dem_lb dem_ub t, color(red%70)  lw(.65)) ///
        (connected dem_pe t, color(red) msymbol(S) lw(.6)) ///
        (connected fc_pe t, color(blue)  msymbol(C) lp(dash) lw(.6)) ///
        (line store_mat_line t, color(black) lp(dash) lw(.33)), ///
        xlabel(0(1)10, nogrid valuelabel labsize(`labSize')) ///
        graphregion(color(white)) ///
        ylabel(-20(20)40, nogrid labsize(`labSize')) ///
        xtitle("Years to/from start of democratization", size(`labSize') margin(medsmall)) ///
        bgcolor(white) subtitle(" ") ///
        yscale(r(-22 50)) ytitle("Change in dividend yield (%)", size(`labSize') margin(medsmall)) ///
        legend(size(`labSize') order(2 "Democratization" 3 "Financial Crisis") nobox region(lcolor(white)) ring(0) position(11) rows(2)) ///
        ysize(6)

    graph export "${FIGURES}/raw/figure_B2_dividend_yield_event_study_`spec'.pdf", replace

    restore

}


forvalues spec = 1/4 {

    * Run event study for democratizations
    lp log_all_div_yld combo_dem_minus_start , tlags(5) reflag(3) shocklags(0) ${SPEC`spec'} cluster(country_id year)

    preserve
    clear
    svmat results
    rename results1 t
    rename results2 b_01
    rename results3 se_01
    gen lo_01 = b_01 - 1.96*se_01
    gen hi_01 = b_01 + 1.96*se_01
    save "${FIGURES}/data/figure_B2_democratization_event_study_`spec'_lp.dta", replace
    restore

    * Run event study for democratizations
    lp log_all_div_yld financial_crisis , tlags(5) reflag(3) shocklags(0) ${SPEC`spec'} cluster(country_id year)
    
    preserve
    clear
    svmat results
    rename results1 t
    rename results2 b_01
    rename results3 se_01
    gen lo_01 = b_01 - 1.96*se_01
    gen hi_01 = b_01 + 1.96*se_01
    save "${FIGURES}/data/figure_B2_financial_crisis_event_study_`spec'_lp.dta", replace
    restore

}

forvalues spec = 1/4 {

    preserve
    use "${FIGURES}/data/figure_B2_democratization_event_study_`spec'_lp.dta", clear

    rename lo_01 dem_lb
    rename hi_01 dem_ub
    rename b_01  dem_pe
    rename se_01 dem_se

    merge 1:1 t using "${FIGURES}/data/figure_B2_financial_crisis_event_study_`spec'_lp.dta", nogen

    rename b_01  fc_pe

    gen store_mat_line = 0
    replace t = t

    replace dem_lb = 0 if dem_lb == .
    replace dem_ub = 0 if dem_ub == .

    replace dem_lb = dem_pe - 1.645*dem_se
    replace dem_ub = dem_pe + 1.645*dem_se

    local sy = 5

    drop if t > `sy' | t < -`sy'

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

    replace t = t + `sy'
    replace dem_pe = dem_pe*100
    replace fc_pe = fc_pe*100
    replace dem_lb = dem_lb*100
    replace dem_ub = dem_ub*100

    label values t tplus

    local labSize = "med"
    two (rcap dem_lb dem_ub t, color(red%70)  lw(.65)) ///
        (connected dem_pe t, color(red) msymbol(S) lw(.6)) ///
        (connected fc_pe t, color(blue)  msymbol(C) lp(dash) lw(.6)) ///
        (line store_mat_line t, color(black) lp(dash) lw(.33)), ///
        xlabel(0(1)10, nogrid valuelabel labsize(`labSize')) ///
        graphregion(color(white)) ///
        ylabel(-20(20)40, nogrid labsize(`labSize')) ///
        xtitle("Years to/from start of democratization", size(`labSize') margin(medsmall)) ///
        bgcolor(white) subtitle(" ") ///
        yscale(r(-22 50)) ytitle("Change in dividend yield (%)", size(`labSize') margin(medsmall)) ///
        legend(size(`labSize') order(2 "Democratization" 3 "Financial Crisis") nobox region(lcolor(white)) ring(0) position(4) rows(2)) ///
        ysize(6)

    graph export "${FIGURES}/raw/figure_B2_dividend_yield_event_study_`spec'_lp.pdf", replace

    restore
}