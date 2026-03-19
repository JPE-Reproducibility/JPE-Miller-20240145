/*
Purpose: Generate Figure C8 - Event study plot of the dividend yield
Author: Max Miller
Date: 12-12-2025
*/

* ===========================================================================
* Housekeeping
* ===========================================================================

clear all
version 19
adopath + "source/utils/analysis"
set scheme s2color

* ===========================================================================
* Set globals
* ===========================================================================

global ANALYSIS_DERIVED			"datastore/derived/analysis"
global ASSETS_DERIVED 			"datastore/derived/assets"
global MACRO_POLITICAL_DERIVED 	"datastore/derived/macro_political"
global EVENTS_DERIVED 			"datastore/derived/events"
global FIGURES 					"source/figures"

global EC govt_head_death financial_crisis icb_crisis at_war default recession combo_dem_start aut_ep_start
global CC log_ggdc_gdppc_i log_ggdc_gdppc_i_g v2x_clphy log_all_cpi_g regime_1 regime_2 regime_3 regime_4

global CLUSTER_VARS cluster(country_id year)
global FE absorb(country_id year)

* ===========================================================================
* Main execution logic
* ===========================================================================

program define main

	create_div_yld_data
	tempfile log_all_div_yld_avg3
	save "`log_all_div_yld_avg3'"
	
	use "${ANALYSIS_DERIVED}/section_4_data.dta", clear
	merge 1:1 country year using "`log_all_div_yld_avg3'", keep(3) nogen
    merge 1:1 country year using "${MACRO_POLITICAL_DERIVED}/all_inflation.dta", keep(1 3) nogen
    merge 1:1 country year using "${MACRO_POLITICAL_DERIVED}/physical_and_political_violence.dta", keep(1 3) nogen
	
    gen svc = maj_cath_aut2 if year == 1959
    replace svc = 0 if svc == .
	
	keep if year >= 1946 & year <= 1976
	
	tabulate vdem_regime, generate(regime_)

    generate_div_yld_event_study
	create_div_yld_plot


end

* ===========================================================================
* Create dividend yield data
* ===========================================================================

program define create_div_yld_data

    use "${ASSETS_DERIVED}/all_excess_and_abnormal_returns.dta", clear
	merge 1:1 country year using "${ASSETS_DERIVED}/all_equity_returns.dta", nogen
	merge 1:1 country year using "${ASSETS_DERIVED}/all_div_yld.dta", nogen

    gen alt_div_yld = (gfd_eq_tr - gfd_eq_capgain)*(1+gfd_eq_capgain)
	sum alt_div_yld, d
    replace alt_div_yld = . if alt_div_yld < 0
    replace alt_div_yld = . if alt_div_yld > r(p99)
    gen log_alt_div_yld = log(alt_div_yld)

	gen lse_alt_div_yld = (gfd_lse_eq_tr - gfd_lse_eq_capgain)*(1+gfd_lse_eq_capgain)
	sum lse_alt_div_yld, d
	replace lse_alt_div_yld = . if lse_alt_div_yld < 0
	replace lse_alt_div_yld = . if lse_alt_div_yld > r(p99)
	gen log_lse_alt_div_yld = log(lse_alt_div_yld)
	
    cap gen log_all_div_yld = log_gfd_div_yld
    sum log_gfd_div_yld
    local dy_mean = r(mean)
    local dy_sd = r(sd)

    foreach var in log_jst_div_yld log_factset_div_yld log_gfd_lse_div_yld log_alt_div_yld log_lse_alt_div_yld {
        sum `var'
        replace log_all_div_yld = `dy_sd'*((`var'-r(mean))/r(sd)) + `dy_mean' if log_all_div_yld == .

    }
	
	egen country_id = group(country), label
	tsset country_id year
    gen log_all_div_yld_avg3 = (log_all_div_yld + L.log_all_div_yld + L2.log_all_div_yld)/3

	keep country year log_all_div_yld_avg3
	drop if log_all_div_yld_avg3 == .

end

* ===========================================================================
* Generate dividend yield event study plots
* ===========================================================================

program define generate_div_yld_event_study

	keep if autSample2 == 1
	sort country_id year

	event_study log_all_div_yld_avg3 svc , tlags(5 8) reflag(1) ///
		$CLUSTER_VARS $FE controls($EC $CC) ///
		savedata("${FIGURES}/data/figure_C8_dividend_yield_event_study.dta")

end

* ===========================================================================
* Create event study plot
* ===========================================================================

program define create_div_yld_plot
    
    use "${FIGURES}/data/figure_C8_dividend_yield_event_study.dta", clear

	rename lo_01 dem_lb
	rename hi_01 dem_ub
	rename b_01  dem_pe
	rename se_01 dem_se

	gen store_mat_line = 0
	replace t = t+1959

	replace dem_lb = 0 if dem_lb == .
	replace dem_ub = 0 if dem_ub == .

	replace dem_lb = dem_pe - 1.645*dem_se
	replace dem_ub = dem_pe + 1.645*dem_se

	replace dem_pe = dem_pe*100
	replace dem_lb = dem_lb*100
	replace dem_ub = dem_ub*100

	local labSize = "large"
	two (rcap dem_lb dem_ub t, color(red)) ///
		(connected dem_pe t, color(red) msymbol(s) lw(.6)) ///
		(line store_mat_line t, color(black) lp(dash) lw(.33)), ///
		xlabel(1955(5)1965, labsize(`labSize') nogrid) graphregion(color(white)) ylabel(-40(40)100, nogrid labsize(`labSize')) ///
		xtitle("") bgcolor(white) subtitle(" ") yscale(r(-20 20)) ytitle("Three-year average log dividend yield", size(`labSize')) ///
		legend(off) ysize(4) xline(1959 1960 1961 1962 1963, lwidth(12.5) lc(gs12) lp(solid))
	graph export "${FIGURES}/raw/figure_C8_dividend_yield_event_study.pdf", replace

end


* ===========================================================================
* Run script
* ===========================================================================

main