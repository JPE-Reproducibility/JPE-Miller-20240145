/*
Purpose: Generate Figure 5 - DID event study of anti-regime CSO activity and democratic mobilizations
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

global MACRO_POLITICAL_DERIVED "datastore/derived/macro_political"
global FIGURES "source/figures"

* ===========================================================================
* Main execution logic
* ===========================================================================

program define main

    use "${MACRO_POLITICAL_DERIVED}/anti_system_cso_activity_and_mobilizations.dta", clear
    merge 1:1 country year using "${MACRO_POLITICAL_DERIVED}/catholic_pct_1816_2018.dta", nogen
    merge 1:1 country year using "${MACRO_POLITICAL_DERIVED}/democracy_index_and_regime_info.dta", nogen

    gen maj_cath_auto = majority_catholic * autocracy
    drop if maj_cath_auto == .

    gen svc_all = maj_cath_auto if year == 1960
    replace svc_all = 0 if svc_all == .

    egen country_id = group(country), label
    tsset country_id year

	keep if autocracy == 1

    perform_structural_break_tests

	* Estimate event study plot
	event_study v2csantimv_mean svc_all, tlags(25 25) reflag(1) cluster(country_id) absorb(country_id year) ///
		savedata(${FIGURES}/data/figure_5a_event_study_anti_system_cso)

	* Estimate event study plot
	event_study v2cademmob_mean svc_all, tlags(25 25) reflag(1) cluster(country_id) absorb(country_id year) ///
		savedata(${FIGURES}/data/figure_5b_event_study_democratic_protests)

    * Panel A: Anti-regime CSO activity
    create_single_plot "figure_5a_event_study_anti_system_cso"

    * Panel B: Democratic mobilizations
    create_single_plot "figure_5b_event_study_democratic_protests"

end

* ===========================================================================
* Create individual plot
* ===========================================================================

program define create_single_plot
    args plot_name

    * Load event study results
    use "${FIGURES}/data/`plot_name'.dta", clear

    * Rename variables
    rename lo_01 dem_lb
    rename hi_01 dem_ub
    rename b_01  dem_pe
    rename se_01 dem_se

    * Create reference line
    gen store_mat_line = 0

    * Convert time to years
    replace t = t + 1960

    * Handle missing values
    replace dem_lb = 0 if dem_lb == .
    replace dem_ub = 0 if dem_ub == .

    * Calculate 90% confidence intervals
    replace dem_lb = dem_pe - 1.645*dem_se
    replace dem_ub = dem_pe + 1.645*dem_se

    * Create the plot
    local labSize = "large"

    two (rcap dem_lb dem_ub t, color(red)) ///
        (connected dem_pe t, color(red) msymbol(s) lw(.6)) ///
        (line store_mat_line t, color(black) lp(dash) lw(.33)), ///
        xlabel(1940(10)1980, nogrid labsize(`labSize')) ///
        graphregion(color(white)) ///
        ylabel(, nogrid labsize(`labSize')) ///
        xtitle("") ///
        bgcolor(white) ///
        subtitle(" ") ///
        ytitle("Cummulative change in index (0-4 scale)", size(`labSize')) ///
        legend(off) ///
        ysize(5) ///
        xline(1959 1960 1961 1962 1963, lwidth(4) lc(gs12) lpattern(solid))

    graph export "${FIGURES}/raw/`plot_name'.pdf", replace

end

program perform_structural_break_tests

    preserve

    local var1 = "v2csantimv_ord"
    local var2 = "v2cademmob_ord"

    collapse (mean) `var1' `var2', by(year maj_cath_auto)
    reshape wide `var1' `var2' , i(year) j(maj_cath_auto)

    gen cso_diff = `var1'1 - `var1'0
    gen mob_diff = `var2'1 - `var2'0

    keep if year >= 1940 & year <= 1989
    tsset year

    reg cso_diff year
    estat sbsingle, swald
    save_estimate, key("cso_diff_swald") value(`r(breakdate)') file("figure5")
    estat sbsingle, slr
    save_estimate, key("cso_diff_slr") value(`r(breakdate)') file("figure5")

    reg mob_diff year
    estat sbsingle, swald
    save_estimate, key("mob_diff_swald") value(`r(breakdate)') file("figure5")
    estat sbsingle, slr
    save_estimate, key("mob_diff_slr") value(`r(breakdate)') file("figure5")
    restore


end

* ===========================================================================
* Run script
* ===========================================================================

main
