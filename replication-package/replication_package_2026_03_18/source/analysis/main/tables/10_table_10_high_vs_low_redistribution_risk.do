/*
Purpose: Generate Table 10 - Elite democratizations and changes in log dividend yields
Author: Max Miller
Date: 2025
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

** Main variables
global OUTCOME log_all_div_yld_5yr
global IND_VARS combo_dem_minus_start_elite combo_dem_minus_start_no_elite

** Controls
global CC log_ggdc_gdppc_i log_ggdc_gdppc_i_5yr v2x_clphy v2x_clphy_5yr log_all_cpi_5yr
global EC financial_crisis icb_crisis at_war default recession govt_head_death assas_succ assas_attempt md_high_action coup_detat

** Fixed effects
global NO_FE							noabsorb
global ALL_FE							absorb(country_id year)
global COUNTRY_REG_YEAR					absorb(country_id year#e_regionpol)
global COUNTRY_REGIME_REGION_YEAR 		absorb(country_id year#region#L_autocracy)

** Clustering of SEs
global CLUSTER_VARS     vce(cluster country_id year)

* ===========================================================================
* Main execution logic
* ===========================================================================

use "${ANALYSIS_DERIVED}/section_3_data.dta"
keep if $OUTCOME != .

* Other important support groups (9 military, 7 Urban middle class, 4 ethnic or racial group )
tab v2regimpgroup if combo_dem_minus_start == 1 & impgroup_elite_max != 1

* Create sample variable
reghdfe $OUTCOME $IND_VARS $EC , $ALL_FE $CLUSTER_VARS
keep if e(sample)

eststo clear

* Column 1: No fixed effects, no controls
eststo: reghdfe $OUTCOME $IND_VARS , $NO_FE $CLUSTER_VARS
estadd local date_fe "No", replace
estadd local country_fe "No", replace
estadd local reg_year "No", replace
estadd local cont_reg_year "No", replace
estadd local econtrols "No", replace
estadd local controls "No", replace
save_estimate, key("column1.elite.pe") value(`=_b[combo_dem_minus_start_elite]') file("table10")
save_estimate, key("column1.elite.se") value(`=_se[combo_dem_minus_start_elite]') file("table10")
save_estimate, key("column1.no_elite.pe") value(`=_b[combo_dem_minus_start_no_elite]') file("table10")
save_estimate, key("column1.no_elite.se") value(`=_se[combo_dem_minus_start_no_elite]') file("table10")
sum combo_dem_minus_start if combo_dem_minus_start_elite == 1 & e(sample) == 1
save_estimate, key("column1.nd") value(`r(N)') file("table10")
estadd local demSamp  `r(N)', replace

* Column 2: No fixed effects, with event controls
eststo: reghdfe $OUTCOME $IND_VARS $EC , $NO_FE $CLUSTER_VARS
estadd local date_fe "No", replace
estadd local country_fe "No", replace
estadd local reg_year "No", replace
estadd local cont_reg_year "No", replace
estadd local econtrols "Yes", replace
estadd local controls "No", replace
save_estimate, key("column2.elite.pe") value(`=_b[combo_dem_minus_start_elite]') file("table10")
save_estimate, key("column2.elite.se") value(`=_se[combo_dem_minus_start_elite]') file("table10")
save_estimate, key("column2.no_elite.pe") value(`=_b[combo_dem_minus_start_no_elite]') file("table10")
save_estimate, key("column2.no_elite.se") value(`=_se[combo_dem_minus_start_no_elite]') file("table10")
sum combo_dem_minus_start if combo_dem_minus_start_elite == 1 & e(sample) == 1
save_estimate, key("column2.nd") value(`r(N)') file("table10")
estadd local demSamp  `r(N)', replace

* Column 3: Country and year fixed effects
eststo: reghdfe $OUTCOME $IND_VARS $EC , $ALL_FE $CLUSTER_VARS
estadd local date_fe "Yes", replace
estadd local country_fe "Yes", replace
estadd local reg_year "No", replace
estadd local cont_reg_year "No", replace
estadd local econtrols "Yes", replace
estadd local controls "No", replace
save_estimate, key("column3.elite.pe") value(`=_b[combo_dem_minus_start_elite]') file("table10")
save_estimate, key("column3.elite.se") value(`=_se[combo_dem_minus_start_elite]') file("table10")
save_estimate, key("column3.no_elite.pe") value(`=_b[combo_dem_minus_start_no_elite]') file("table10")
save_estimate, key("column3.no_elite.se") value(`=_se[combo_dem_minus_start_no_elite]') file("table10")
sum combo_dem_minus_start if combo_dem_minus_start_elite == 1 & e(sample) == 1
save_estimate, key("column3.nd") value(`r(N)') file("table10")
estadd local demSamp  `r(N)', replace

* Column 4: Region-year fixed effects
eststo: reghdfe $OUTCOME $IND_VARS  $EC , $COUNTRY_REG_YEAR $CLUSTER_VARS
estadd local date_fe "No", replace
estadd local country_fe "Yes", replace
estadd local reg_year "Yes", replace
estadd local cont_reg_year "No", replace
estadd local econtrols "Yes", replace
estadd local controls "No", replace
save_estimate, key("column4.elite.pe") value(`=_b[combo_dem_minus_start_elite]') file("table10")
save_estimate, key("column4.elite.se") value(`=_se[combo_dem_minus_start_elite]') file("table10")
save_estimate, key("column4.no_elite.pe") value(`=_b[combo_dem_minus_start_no_elite]') file("table10")
save_estimate, key("column4.no_elite.se") value(`=_se[combo_dem_minus_start_no_elite]') file("table10")
sum combo_dem_minus_start if combo_dem_minus_start_elite == 1 & e(sample) == 1
save_estimate, key("column4.nd") value(`r(N)') file("table10")
estadd local demSamp  `r(N)', replace

* Column 5: Continent-regime-year fixed effects
eststo: reghdfe $OUTCOME $IND_VARS  $EC , $COUNTRY_REGIME_REGION_YEAR $CLUSTER_VARS
estadd local date_fe "No", replace
estadd local country_fe "Yes", replace
estadd local reg_year "No", replace
estadd local cont_reg_year "Yes", replace
estadd local econtrols "Yes", replace
estadd local controls "No", replace
save_estimate, key("column5.elite.pe") value(`=_b[combo_dem_minus_start_elite]') file("table10")
save_estimate, key("column5.elite.se") value(`=_se[combo_dem_minus_start_elite]') file("table10")
save_estimate, key("column5.no_elite.pe") value(`=_b[combo_dem_minus_start_no_elite]') file("table10")
save_estimate, key("column5.no_elite.se") value(`=_se[combo_dem_minus_start_no_elite]') file("table10")
sum combo_dem_minus_start if combo_dem_minus_start_elite == 1 & e(sample) == 1
save_estimate, key("column5.nd") value(`r(N)') file("table10")
estadd local demSamp  `r(N)', replace

* Column 6: With additional controls
eststo: reghdfe $OUTCOME $IND_VARS  $EC $CC , $COUNTRY_REGIME_REGION_YEAR $CLUSTER_VARS
estadd local date_fe "No", replace
estadd local country_fe "Yes", replace
estadd local reg_year "No", replace
estadd local cont_reg_year "Yes", replace
estadd local econtrols "Yes", replace
estadd local controls "Yes", replace
save_estimate, key("column6.elite.pe") value(`=_b[combo_dem_minus_start_elite]') file("table10")
save_estimate, key("column6.elite.se") value(`=_se[combo_dem_minus_start_elite]') file("table10")
save_estimate, key("column6.no_elite.pe") value(`=_b[combo_dem_minus_start_no_elite]') file("table10")
save_estimate, key("column6.no_elite.se") value(`=_se[combo_dem_minus_start_no_elite]') file("table10")
sum combo_dem_minus_start if combo_dem_minus_start_elite == 1 & e(sample) == 1
save_estimate, key("column6.nd") value(`r(N)') file("table10")
estadd local demSamp  `r(N)', replace

# delimit ;

esttab using "${TABLES}/table_10_high_vs_low_redistribution_risk.tex", 
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