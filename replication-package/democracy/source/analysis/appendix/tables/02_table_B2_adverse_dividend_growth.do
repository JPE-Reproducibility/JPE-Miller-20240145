/*
Purpose: Generate Table B2 - Dividend growth in adverse democratizations
Author: Max Miller
Date: 12-11-2025
*/

* ===========================================================================
* Housekeeping
* ===========================================================================

clear all
version 19
adopath ++ "source/utils/analysis"

* ===========================================================================
* Set globals
* ===========================================================================

global ANALYSIS_DERIVED         "datastore/derived/analysis"
global TABLES 					"source/tables/raw"

* ===========================================================================
* Regression specifications
* ===========================================================================

** Main variables
global IND_VARS combo_dem_adv_start_bef1 combo_dem_adv_start combo_dem_adv_start_aft1 combo_dem_adv_aft_start

** Fixed effects
global NO_FE					noabsorb
global ALL_FE					absorb(country_id year)

** Clustering of SEs
global CLUSTER_VARS     		vce(cluster country_id year)

* ===========================================================================
* Main execution logic
* ===========================================================================

program define main

	use "${ANALYSIS_DERIVED}/section_3_data.dta", clear

	** Log rolling dividend growth (3 and 5 years)
	gen rolling_log_div_3yr_tot = (log_all_div_g + L.log_all_div_g + L2.log_all_div_g)
	gen rolling_log_eq_capgain_3yr_tot = (log_all_eq_capgain + L.log_all_eq_capgain + L2.log_all_eq_capgain)

	cap gen combo_dem_aft_start = combo_dem
	cap replace combo_dem_aft_start = 0 if combo_dem_start == 1

	gen combo_dem_adv = combo_dem
	replace combo_dem_adv = 0 if combo_dem_minus == 1

	gen combo_dem_adv_start = combo_dem_start
	replace combo_dem_adv_start = 0 if combo_dem_minus_start == 1
		
	cap gen combo_dem_adv_aft_start = combo_dem_adv
	cap replace combo_dem_adv_aft_start = 0 if combo_dem_adv_start == 1

	gen combo_dem_adv_start_bef1 = F.combo_dem_adv_start
	gen combo_dem_adv_start_aft1 = L.combo_dem_adv_start
	
	label var combo_dem_adv_start "Adverse Democratization Start"
	label var combo_dem_adv_aft_start "Adverse Democratization After Start"

	label var combo_dem_adv_start_bef1 "Adverse Democratization Start, Year Prior"
	label var combo_dem_adv_start_aft1 "Adverse Democratization Start, Year After"
	
    run_regressions
	export_table

	reghdfe log_all_div_yld_5yr combo_dem_adv_start , $ALL_FE $CLUSTER_VARS
	
end

* ===========================================================================
* Run regressions and create table
* ===========================================================================

program define run_regressions

	reghdfe rolling_log_div_3yr_tot $IND_VARS if rolling_log_eq_capgain_3yr_tot != . , $ALL_FE $CLUSTER_VARS
	gen samp1 = e(sample)

	reghdfe rolling_log_eq_capgain_3yr_tot $IND_VARS if rolling_log_div_3yr != . , $ALL_FE $CLUSTER_VARS
	gen samp2 = e(sample)

	eststo clear
	eststo: reghdfe rolling_log_div_3yr_tot $IND_VARS if samp1 == 1, $NO_FE $CLUSTER_VARS
	estadd local date_fe "No" , replace
	estadd local country_fe "No" , replace

	eststo: reghdfe rolling_log_div_3yr_tot $IND_VARS if samp1 == 1, $ALL_FE $CLUSTER_VARS
	estadd local date_fe "Yes" , replace
	estadd local country_fe "Yes" , replace

	eststo: reghdfe rolling_log_eq_capgain_3yr_tot $IND_VARS if samp2 == 1, $NO_FE $CLUSTER_VARS
	estadd local date_fe "No" , replace
	estadd local country_fe "No" , replace

	eststo: reghdfe rolling_log_eq_capgain_3yr_tot $IND_VARS if samp2 == 1, $ALL_FE $CLUSTER_VARS
	estadd local date_fe "Yes" , replace
	estadd local country_fe "Yes" , replace
end

* ===========================================================================
* Export table to LaTeX
* ===========================================================================

program define export_table
	# delimit ;

	esttab   
		using "${TABLES}/table_B2_adverse_dividend_growth.tex", transform(@*100 100) b(%9.2f) se(%9.2f) 
		drop(_cons) s(country_fe date_fe r2 N, label("Country FE" "Year FE" "R$^2$" "Observations") fmt(0 0 %9.2f %15.0gc)) style(tex) star(* 0.10 ** 0.05 *** 0.01)  
		prehead("\begin{tabularx}{\linewidth}{@{} l*{@E}{Y} @{}}" 
				"\toprule" 
				"\multicolumn{1}{l}{Dependent variable:} & \multicolumn{2}{c}{Three-year change in log dividends} & \multicolumn{2}{c}{Three-year change in log prices} \\ \cmidrule(lr){2-3} \cmidrule(lr){4-5}")
		posthead("\hline \addlinespace[0.75ex]")
		prefoot("\hline \addlinespace[0.75ex]")
		postfoot("\bottomrule" 
					"\end{tabularx}")
		addnotes("Standard errors clustered by country and year.") 
		nomtitle obslast label replace booktabs substitute(\_ _) ;

	# delimit cr
end

* ===========================================================================
* Run script
* ===========================================================================

main