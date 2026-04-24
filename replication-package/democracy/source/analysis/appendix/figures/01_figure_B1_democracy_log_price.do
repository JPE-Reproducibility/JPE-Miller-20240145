/*
Purpose: Generate Figure B1 - Change in log prices in democratizations
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

global ANALYSIS_DERIVED			"datastore/derived/analysis"
global MACRO_POLITICAL_DERIVED 	"datastore/derived/macro_political"
global EVENTS_DERIVED 			"datastore/derived/events"
global FIGURES 					"source/figures"

* ===========================================================================
* Main execution logic
* ===========================================================================

program define main

    use "${ANALYSIS_DERIVED}/section_3_data.dta", clear

    gen log_all_div_yld = log_gfd_div_yld
    replace log_all_div_yld = log_jst_div_yld if log_all_div_yld == .

    gen log_gfd_eq_prc_ind = log(gfd_eq_prc_ind)
    gen log_gfd_div_index = log_all_div_yld + log_gfd_eq_prc_ind
		
    keep if log_all_div_yld != .
    drop if log_all_div_yld_5yr == .
    drop if L5.log_gfd_eq_prc_ind == . |  L5.log_gfd_div_index == .
    
	generate_price_event_study
	generate_price_lps
	
    use "${ANALYSIS_DERIVED}/section_3_data.dta", clear

	generate_gdppc_event_study
	generate_gdppc_lps

    * Create the plot
    create_price_event_study_plot
    create_dividend_event_study_plot
    create_gdppc_event_study_plot

	* Create local projection plots
    create_price_event_study_plot lp
    create_dividend_event_study_plot lp
    create_gdppc_event_study_plot lp

	
end

* ===========================================================================
* Generate price and dividend event study
* ===========================================================================

program define generate_price_event_study

	* Price event study plots
	event_study log_gfd_eq_prc_ind combo_dem_minus_start , tlags(5 5) reflag(3) ///
		cluster(country_id year) absorb(country_id year) ///
		savedata("${FIGURES}/data/figure_B1a_log_price_event_study.dta")

	event_study log_gfd_eq_prc_ind financial_crisis , tlags(5 5) reflag(3) ///
		cluster(country_id year) absorb(country_id year) ///
		savedata("${FIGURES}/data/figure_B1a_log_price_event_study_fc.dta")

	* Dividend event study plots
	event_study log_gfd_div_index combo_dem_minus_start , tlags(5 5) reflag(3) ///
		cluster(country_id year) absorb(country_id year) ///
		savedata("${FIGURES}/data/figure_B1b_log_dividend_growth_event_study.dta")

	event_study log_gfd_div_index financial_crisis , tlags(5 5) reflag(3) /// 
		cluster(country_id year) absorb(country_id year) ///
		savedata("${FIGURES}/data/figure_B1b_log_dividend_growth_event_study_fc.dta")

end

program define generate_price_lps
    
	lp log_gfd_eq_prc_ind combo_dem_minus_start , tlags(5) reflag(3) shocklags(0) ///
		cluster(country_id year) absorb(country_id year)
	save_lp_data "figure_B1a_log_price_event_study_lp"
	
	lp log_gfd_eq_prc_ind financial_crisis , tlags(5) reflag(3) shocklags(0) ///
		cluster(country_id year) absorb(country_id year)
	save_lp_data "figure_B1a_log_price_event_study_fc_lp"
		
    lp log_gfd_div_index combo_dem_minus_start , tlags(5) reflag(3) shocklags(0) /// 
		cluster(country_id year) absorb(country_id year)
	save_lp_data "figure_B1b_log_dividend_growth_event_study_lp"
	
    lp log_gfd_div_index financial_crisis , tlags(5) reflag(3) shocklags(0) ///
		cluster(country_id year) absorb(country_id year)
	save_lp_data "figure_B1b_log_dividend_growth_event_study_fc_lp"
	
end

* ===========================================================================
* Generate GDP per capita event study
* ===========================================================================

program define generate_gdppc_event_study

    event_study log_ggdc_gdppc_i combo_dem_minus_start , tlags(5 5) reflag(3) cluster(country_id year) absorb(country_id year) savedata("${FIGURES}/data/figure_B1c_log_gdp_per_capita_event_study.dta")

    event_study log_ggdc_gdppc_i financial_crisis , tlags(5 5) reflag(3) cluster(country_id year) absorb(country_id year) savedata("${FIGURES}/data/figure_B1c_log_gdp_per_capita_event_study_fc.dta")

end

program define generate_gdppc_lps
    
	lp log_ggdc_gdppc combo_dem_minus_start , tlags(5) reflag(3) shocklags(0) /// 
		cluster(country_id year) absorb(country_id year)
	save_lp_data "figure_B1c_log_gdp_per_capita_event_study_lp"

	lp log_ggdc_gdppc financial_crisis , tlags(5) reflag(3) shocklags(0) ///
		cluster(country_id year) absorb(country_id year)
	save_lp_data "figure_B1c_log_gdp_per_capita_event_study_fc_lp"
	
end


* ===========================================================================
* Create event study plot
* ===========================================================================

program define create_price_event_study_plot
    args lp
	
	if "`lp'" != "" {
		local lp_suf "_lp"
	}
	else {
		local lp_suf ""		
	}
	
    use "${FIGURES}/data/figure_B1a_log_price_event_study`lp_suf'.dta", clear

    rename lo_01 dem_lb
    rename hi_01 dem_ub
    rename b_01  dem_pe
    rename se_01 dem_se

    merge 1:1 t using "${FIGURES}/data/figure_B1a_log_price_event_study_fc`lp_suf'.dta", nogen

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
    label values t tplus

    replace dem_pe = dem_pe*100
    replace fc_pe = fc_pe*100
    replace dem_lb = dem_lb*100
    replace dem_ub = dem_ub*100


    local labSize = "large"
    two (rcap dem_lb dem_ub t, color(red%70)) ///
        (connected dem_pe t, color(red) msymbol(s) lw(.6)) ///
        (connected fc_pe t, color(blue)  msymbol(c) lp(dash) lw(.6)) ///
        (line store_mat_line t, color(black) lp(dash) lw(.33)), ///
        xlabel(0(1)10, valuelabel labsize(`labSize')) graphregion(color(white)) ylabel(-40(20)20, nogrid labsize(`labSize')) ///
        xtitle("Years to/from start of democratization", size(`labSize')) bgcolor(white) subtitle(" ") ///
        yscale(r(-50 22)) ytitle("Change in price (%)", size(`labSize')) ///
        legend(size(`labSize') order(2 "Democratization" 3 "Financial Crisis") nobox region(lcolor(white)) ring(0) position(7) rows(2)) ysize(3)
    graph export "${FIGURES}/raw/figure_B1a_log_price_event_study`lp_suf'.pdf", replace
    
end


program define create_dividend_event_study_plot
    args lp
	
	if "`lp'" != "" {
		local lp_suf "_lp"
	}
	else {
		local lp_suf ""		
	}
	
    use "${FIGURES}/data/figure_B1b_log_dividend_growth_event_study`lp_suf'.dta", clear

    rename lo_01 dem_lb
    rename hi_01 dem_ub
    rename b_01  dem_pe
    rename se_01 dem_se

    merge 1:1 t using "${FIGURES}/data/figure_B1b_log_dividend_growth_event_study_fc`lp_suf'.dta", nogen

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
    label values t tplus

    replace dem_pe = dem_pe*100
    replace fc_pe = fc_pe*100
    replace dem_lb = dem_lb*100
    replace dem_ub = dem_ub*100

    local labSize = "large"
    two (rcap dem_lb dem_ub t, color(red)) ///
        (connected dem_pe t, color(red) msymbol(s) lw(.6)) ///
        (connected fc_pe t, color(blue)  msymbol(c) lp(dash) lw(.6)) ///
        (line store_mat_line t, color(black) lp(dash) lw(.33)), ///
        xlabel(0(1)10, valuelabel labsize(`labSize')) graphregion(color(white)) ylabel(, nogrid labsize(`labSize')) ///
        xtitle("Years to/from event", size(`labSize')  margin(medsmall)) bgcolor(white) subtitle(" ") ytitle("Change in average dividend growth (%)", size(`labSize')  margin(medsmall)) ///
        legend(size(`labSize') order(2 "Democratization" 3 "Financial Crisis") nobox region(lcolor(white)) ring(0) position(7) rows(2)) ysize(3)
    graph export "${FIGURES}/raw/figure_B1b_log_dividend_growth_event_study`lp_suf'.pdf", replace

end


program define create_gdppc_event_study_plot
    
    args lp
	
	if "`lp'" != "" {
		local lp_suf "_lp"
	}
	else {
		local lp_suf ""		
	}
	
    use "${FIGURES}/data/figure_B1c_log_gdp_per_capita_event_study`lp_suf'.dta", clear

    rename lo_01 dem_lb
    rename hi_01 dem_ub
    rename b_01  dem_pe
    rename se_01 dem_se

    merge 1:1 t using "${FIGURES}/data/figure_B1c_log_gdp_per_capita_event_study_fc`lp_suf'.dta", nogen

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
    label values t tplus

    replace dem_pe = dem_pe*100
    replace fc_pe = fc_pe*100
    replace dem_lb = dem_lb*100
    replace dem_ub = dem_ub*100

    local labSize = "large"
    two (rcap dem_lb dem_ub t, color(red)) ///
        (connected dem_pe t, color(red) msymbol(s) lw(.6)) ///
        (connected fc_pe t, color(blue)  msymbol(c) lp(dash) lw(.6)) ///
        (line store_mat_line t, color(black) lp(dash) lw(.33)), ///
        xlabel(0(1)10, valuelabel labsize(`labSize')) graphregion(color(white)) ylabel(, nogrid labsize(`labSize')) ///
        xtitle("Years to/from event", size(`labSize')  margin(medsmall)) bgcolor(white) subtitle(" ") ytitle("Change in GDP per capita (%)", size(`labSize')  margin(medsmall)) ///
        legend(size(`labSize') order(2 "Democratization" 3 "Financial Crisis") nobox region(lcolor(white)) ring(0) position(7) rows(2)) ysize(3)
    graph export "${FIGURES}/raw/figure_B1c_log_gdp_per_capita_event_study`lp_suf'.pdf", replace
end


program save_lp_data
	args filename
	preserve
    clear
    svmat results
    rename results1 t
    rename results2 b_01
    rename results3 se_01
    gen lo_01 = b_01 - 1.96*se_01
    gen hi_01 = b_01 + 1.96*se_01
    save "${FIGURES}/data/`filename'.dta", replace
    restore

end

* ===========================================================================
* Run script
* ===========================================================================

main