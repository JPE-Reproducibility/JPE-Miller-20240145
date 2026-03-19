/*
Purpose: Generate Figure 6 - Main DID event study of risk-adjusted returns
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

global ANALYSIS_DERIVED "datastore/derived/analysis"
global FIGURES			"source/figures"

global EC govt_head_death financial_crisis icb_crisis at_war default_first_5 recession assas_attempt assas_succ coup_detat
global CC log_ggdc_gdppc_i log_ggdc_gdppc_i_g regime_1 regime_2 regime_3 regime_4

global START_YEAR = 1939
global END_YEAR = 1983

* ===========================================================================
* Main execution logic
* ===========================================================================

program define main

	use "${ANALYSIS_DERIVED}/section_4_data.dta", clear

    * Create treatment indicator for Second Vatican Council
    cap drop svc
    gen svc = maj_cath_aut2 if year == 1959
    replace svc = 0 if svc == .

	tabulate vdem_regime, generate(regime_)

    * Create smoothed risk-adjusted returns (5-year average)
	winsor2 capm_unexp2, replace
    cap gen capm_unexp2_smooth5 = (capm_unexp2 + L.capm_unexp2 + L2.capm_unexp2 + L3.capm_unexp2 + L4.capm_unexp2)/5

	keep if year <= ${END_YEAR} & year >= ${START_YEAR} & autSample2 == 1

	* Estimate event study plot
	event_study capm_unexp2_smooth5 svc, tlags(9 17) reflag(1) cluster(country_id year) absorb(country_id year) controls($EC $CC ) savedata($FIGURES/data/figure_6_did_event_study_returns)

    * Load event study results
    use "${FIGURES}/data/figure_6_did_event_study_returns.dta", clear

    * Rename variables
    rename lo_01 dem_lb
    rename hi_01 dem_ub
    rename b_01  dem_pe
    rename se_01 dem_se

    * Create reference line
    gen store_mat_line = 0

    * Convert time to years
    replace t = t + 1959

    * Handle missing values
    replace dem_lb = 0 if dem_lb == .
    replace dem_ub = 0 if dem_ub == .

    * Calculate 90% confidence intervals
    replace dem_lb = dem_pe - 1.645*dem_se
    replace dem_ub = dem_pe + 1.645*dem_se

    * Convert to percentage
    replace dem_pe = dem_pe*100
    replace dem_lb = dem_lb*100
    replace dem_ub = dem_ub*100

    * Create the plot
    local labSize = "large"

    two (rcap dem_lb dem_ub t, color(red)) ///
        (connected dem_pe t, color(red) msymbol(s) lw(.6)) ///
        (line store_mat_line t, color(black) lp(dash) lw(.33)), ///
        xlabel(, nogrid labsize(`labSize')) ///
        graphregion(color(white)) ///
        ylabel(-20(10)40, nogrid labsize(`labSize')) ///
        xtitle("") ///
        bgcolor(white) ///
        subtitle(" ") ///
        yscale(r(-20 20)) ///
        ytitle("Five-year average abnormal return (%)", size(`labSize')) ///
        legend(off) ///
        ysize(3) ///
        xline(1959 1960 1961 1962 1963, lwidth(8) lc(gs12) lpattern(solid))

    graph export "${FIGURES}/raw/figure_6_did_event_study_returns.pdf", replace

end

* ===========================================================================
* Run script
* ===========================================================================

main
