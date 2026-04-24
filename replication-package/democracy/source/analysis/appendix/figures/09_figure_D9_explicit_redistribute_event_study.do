/*
Purpose: Generate Figure D9 - Explicit redistribution event study
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

global ANALYSIS_DERIVED         "datastore/derived/analysis"
global FIGURES 					"source/figures"

** Controls
global CC log_ggdc_gdppc_i
global EC financial_crisis at_war default recession govt_head_death assas_succ assas_attempt md_high_action coup_detat icb_crisis

* ===========================================================================
* Main execution logic
* ===========================================================================

program define main

    use "${ANALYSIS_DERIVED}/section_3_data.dta", clear

    gen govt_rev_gdp_5yr = (govt_rev_gdp - L5.govt_rev_gdp)/5
    gen d_swiid_gini_mkt_5yr = (swiid_gini_mkt - L5.swiid_gini_mkt)/5

    esplot govt_rev_gdp_5yr , event(combo_dem_end_succ) compare(combo_dem_end_fail) ///
     w(-5 20, bin) estimate_reference vce(cluster country_id) ///
        controls($EC $CC combo_dem combo_dem_succ) absorb(country_id year)    ///
        savedata(${FIGURES}/data/figure_D9a_explicit_redistribute_event_study_govt_rev_gdp, replace)

    esplot d_swiid_gini_mkt_5yr , event(combo_dem_end_succ) compare(combo_dem_end_fail) ///
        w(-5 20, bin) estimate_reference vce(cluster country_id) ///
        controls($EC $CC combo_dem combo_dem_succ) absorb(country_id year)    ///
        savedata(${FIGURES}/data/figure_D9b_explicit_redistribute_event_study_swiid, replace)

    * Create the plot
    create_govt_rev_gdp_plot
    create_swiid_plot

end

* ===========================================================================
* Create event study plot
* ===========================================================================

program define create_govt_rev_gdp_plot
    
    use "${FIGURES}/data/figure_D9a_explicit_redistribute_event_study_govt_rev_gdp.dta", clear

    rename lo_01 dem_lb
    rename hi_01 dem_ub
    rename b_01  dem_pe
    rename se_01 dem_se

    gen store_mat_line = 0

    replace dem_lb = 0 if dem_lb == .
    replace dem_ub = 0 if dem_ub == .

    replace dem_lb = dem_pe - 1.645*dem_se
    replace dem_ub = dem_pe + 1.645*dem_se

    label values t tplus

    local labSize = "large"
    two (rcap dem_lb dem_ub t, color(red%70)) ///
        (connected dem_pe t, color(red) msymbol(s) lw(.6)) ///
        (line store_mat_line t, color(black) lp(dash) lw(.33)), ///
        xlabel(, labsize(`labSize')) graphregion(color(white)) ylabel(, nogrid labsize(`labSize')) ///
        xtitle("Years to/from start of democratization", size(`labSize') margin(medsmall)) bgcolor(white) subtitle(" ") ///
        ytitle("Change in govt. revenue-GDP ratio (p.p.)", size(`labSize') margin(medsmall)) ///
        legend(off) ysize(3.5)
    graph export "${FIGURES}/raw/figure_D9a_explicit_redistribute_event_study_govt_rev_gdp.pdf", replace

end


program define create_swiid_plot

    use "${FIGURES}/data/figure_D9b_explicit_redistribute_event_study_swiid.dta", clear

    rename lo_01 dem_lb
    rename hi_01 dem_ub
    rename b_01  dem_pe
    rename se_01 dem_se

    gen store_mat_line = 0

    replace dem_lb = 0 if dem_lb == .
    replace dem_ub = 0 if dem_ub == .

    replace dem_lb = dem_pe - 1.645*dem_se
    replace dem_ub = dem_pe + 1.645*dem_se
    
    label values t tplus

    local labSize = "large"
    two (rcap dem_lb dem_ub t, color(red%70)) ///
        (connected dem_pe t, color(red) msymbol(s) lw(.6)) ///
        (line store_mat_line t, color(black) lp(dash) lw(.33)), ///
        xlabel(, labsize(`labSize')) graphregion(color(white)) ylabel(, nogrid labsize(`labSize')) ///
        xtitle("Years to/from start of democratization", size(`labSize') margin(medsmall)) bgcolor(white) subtitle(" ") ///
        ytitle("Change in Gini coefficient (p.p.)", size(`labSize') margin(medsmall)) ///
        legend(off) ysize(3.5)
    graph export "${FIGURES}/raw/figure_D9b_explicit_redistribute_event_study_swiid.pdf", replace
end


* ===========================================================================
* Run script
* ===========================================================================

main