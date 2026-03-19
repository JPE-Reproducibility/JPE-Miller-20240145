/*
Purpose: Generate Table 1 - Democratizations and changes in log dividend yields
Author: Max Miller
Date: 12-11-2025
*/

* ===========================================================================
* Housekeeping
* ===========================================================================

clear all
version 19
adopath + "source/utils/analysis"

* ===========================================================================
* Set globals
* ===========================================================================

global ANALYSIS_DERIVED 		"datastore/derived/analysis"
global TABLES 					"source/tables/raw"

* ===========================================================================
* Regression specifications
* ===========================================================================

** Fixed effects
global NO_FE							noabsorb
global ALL_FE							absorb(country_id year)
global COUNTRY_REG_YEAR					absorb(country_id year#e_regionpol)
global COUNTRY_REGIME_REGION_YEAR 		absorb(country_id year#region#L_autocracy)

** Controls
global CC log_ggdc_gdppc_i log_ggdc_gdppc_i_5yr v2x_clphy v2x_clphy_5yr log_all_cpi_5yr
global EC financial_crisis at_war default recession govt_head_death assas_succ assas_attempt md_high_action coup_detat

** Clustering of SEs
global CLUSTER_VARS     vce(cluster country_id year)

* ===========================================================================
* Main execution logic
* ===========================================================================

use "${ANALYSIS_DERIVED}/section_3_data.dta", clear

* Use sample with country-year fixed effects for all regressions
reghdfe log_all_div_yld_5yr combo_dem_minus_start $EC , $ALL_FE $CLUSTER_VARS
keep if e(sample) == 1

eststo clear

* Column 1: No fixed effects, no controls
eststo: reghdfe log_all_div_yld_5yr combo_dem_minus_start , $NO_FE $CLUSTER_VARS
estadd local date_fe "No" , replace
estadd local country_fe "No" , replace
estadd local reg_year "No" , replace
estadd local cont_reg_year "No" , replace
estadd local econtrols "No" , replace
estadd local controls "No" , replace
save_estimate, key("column1.pe") value(`=_b[combo_dem_minus_start]') file("table1")
save_estimate, key("column1.se") value(`=_se[combo_dem_minus_start]') file("table1")
sum combo_dem_minus_start if combo_dem_minus_start == 1 & e(sample) == 1
save_estimate, key("column1.nd") value(`r(N)') file("table1")
estadd local demSamp  `r(N)', replace

* Column 2: No fixed effects, with event controls
eststo: reghdfe log_all_div_yld_5yr combo_dem_minus_start $EC , $NO_FE $CLUSTER_VARS
estadd local date_fe "No" , replace
estadd local country_fe "No" , replace
estadd local reg_year "No" , replace
estadd local cont_reg_year "No" , replace
estadd local econtrols "Yes" , replace
estadd local controls "No" , replace
save_estimate, key("column2.pe") value(`=_b[combo_dem_minus_start]') file("table1")
save_estimate, key("column2.se") value(`=_se[combo_dem_minus_start]') file("table1")
sum combo_dem_minus_start if combo_dem_minus_start == 1 & e(sample) == 1
save_estimate, key("column2.nd") value(`r(N)') file("table1")
estadd local demSamp  `r(N)', replace

* Column 3: Country and year fixed effects
eststo: reghdfe log_all_div_yld_5yr combo_dem_minus_start $EC , $ALL_FE $CLUSTER_VARS
estadd local date_fe "Yes" , replace
estadd local country_fe "Yes" , replace
estadd local reg_year "No" , replace
estadd local cont_reg_year "No" , replace
estadd local econtrols "Yes" , replace
estadd local controls "No" , replace
save_estimate, key("column3.pe") value(`=_b[combo_dem_minus_start]') file("table1")
save_estimate, key("column3.se") value(`=_se[combo_dem_minus_start]') file("table1")
sum combo_dem_minus_start if combo_dem_minus_start == 1 & e(sample) == 1
save_estimate, key("column3.nd") value(`r(N)') file("table1")
estadd local demSamp  `r(N)', replace

* Column 4: Region-year fixed effects
eststo: reghdfe log_all_div_yld_5yr combo_dem_minus_start $EC , $COUNTRY_REG_YEAR $CLUSTER_VARS
estadd local date_fe "No" , replace
estadd local country_fe "Yes" , replace
estadd local reg_year "Yes" , replace
estadd local cont_reg_year "No" , replace
estadd local econtrols "Yes" , replace
estadd local controls "No" , replace
save_estimate, key("column4.pe") value(`=_b[combo_dem_minus_start]') file("table1")
save_estimate, key("column4.se") value(`=_se[combo_dem_minus_start]') file("table1")
sum combo_dem_minus_start if combo_dem_minus_start == 1 & e(sample) == 1
save_estimate, key("column4.nd") value(`r(N)') file("table1")
estadd local demSamp  `r(N)', replace

* Column 5: Continent-regime-year fixed effects
eststo: reghdfe log_all_div_yld_5yr combo_dem_minus_start $EC , $COUNTRY_REGIME_REGION_YEAR $CLUSTER_VARS
estadd local date_fe "No" , replace
estadd local country_fe "Yes" , replace
estadd local reg_year "No" , replace
estadd local cont_reg_year "Yes" , replace
estadd local econtrols "Yes" , replace
estadd local controls "No" , replace
save_estimate, key("column5.pe") value(`=_b[combo_dem_minus_start]') file("table1")
save_estimate, key("column5.se") value(`=_se[combo_dem_minus_start]') file("table1")
sum combo_dem_minus_start if combo_dem_minus_start == 1 & e(sample) == 1
save_estimate, key("column5.nd") value(`r(N)') file("table1")
estadd local demSamp  `r(N)', replace

* Column 6: With additional controls
eststo: reghdfe log_all_div_yld_5yr combo_dem_minus_start $EC $CC , $COUNTRY_REGIME_REGION_YEAR $CLUSTER_VARS
estadd local date_fe "No" , replace
estadd local country_fe "Yes" , replace
estadd local reg_year "No" , replace
estadd local cont_reg_year "Yes" , replace
estadd local econtrols "Yes" , replace
estadd local controls "Yes" , replace
save_estimate, key("column6.pe") value(`=_b[combo_dem_minus_start]') file("table1")
save_estimate, key("column6.se") value(`=_se[combo_dem_minus_start]') file("table1")
sum combo_dem_minus_start if combo_dem_minus_start == 1 & e(sample) == 1
save_estimate, key("column6.nd") value(`r(N)') file("table1")
estadd local demSamp  `r(N)', replace

# delimit ;

esttab using "${TABLES}/table_1_change_in_log_dividend_yields.tex", 
	transform(@*100 100) b(%9.2f) se(%9.2f) 
	drop(_cons $EC $CC) 
	s(country_fe date_fe reg_year cont_reg_year econtrols controls demSamp r2 N, 
		label("Country FE" "Year FE" "Region $\times$ Year FE" "Continent $\times$ Regime $\times$ Year FE" "Event Controls" "Controls" "Episode obs." "R$^2$" "Observations") 
		fmt(0 0 0 0 0 0 %9.0f %9.2f %15.0gc)) 
	style(tex) star(* 0.10 ** 0.05 *** 0.01)  
	prehead("\begin{tabularx}{\linewidth}{@{} l*{@E}{Y} @{}}" 
		   "\toprule" 
		   "\multicolumn{1}{l}{Dependent variable:} & \multicolumn{6}{c}{Five-year change in log dividend yields}\\ \cmidrule(lr){2-7}")
	posthead("\hline \addlinespace[0.75ex]")
	prefoot("\hline \addlinespace[0.75ex]")
	postfoot("\bottomrule" 
			"\end{tabularx}")
	addnotes("Standard errors clustered by country and year.") 
	nomtitle obslast label replace booktabs substitute(\_ _) ;

# delimit cr
