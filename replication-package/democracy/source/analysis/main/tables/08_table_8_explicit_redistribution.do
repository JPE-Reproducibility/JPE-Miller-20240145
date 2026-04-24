/*
Purpose: Generate Table 8 - Successful democratizations and explicit redistribution
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

global ANALYSIS_DERIVED 		"datastore/derived/analysis"
global TABLES 					"source/tables/raw"

* ===========================================================================
* Regression specifications
* ===========================================================================

** Main variables
global DEM_VARS post_combo_dem_succ20 post_combo_dem20 combo_dem_succ combo_dem

** Fixed effects
global FE absorb(country_id year)

** Clustering of SEs
global CLUSTER_VARS cluster(country_id)

** Controls
global CC log_ggdc_gdppc_i L.log_ggdc_gdppc_i
global EC financial_crisis at_war default recession govt_head_death assas_succ assas_attempt md_high_action coup_detat icb_crisis

* ===========================================================================
* Main execution logic
* ===========================================================================

use "${ANALYSIS_DERIVED}/section_3_data.dta", clear

replace govt_rev_gdp = govt_rev_gdp/100
replace swiid_gini_mkt = swiid_gini_mkt/100

eststo clear

* Column 1: Government Revenue/GDP
eststo: reghdfe D.govt_rev_gdp $DEM_VARS $EC $CC , $FE $CLUSTER_VARS
estadd local date_fe "Yes" , replace
estadd local country_fe "Yes" , replace
estadd local econtrols "Yes" , replace
estadd local clustering "Country" , replace
save_estimate, key("column1.pe") value(`=_b[post_combo_dem_succ20]') file("table8")
save_estimate, key("column1.se") value(`=_se[post_combo_dem_succ20]') file("table8")
sum combo_dem_start if combo_dem_end == 1 & e(sample) == 1
save_estimate, key("column1.nd") value(`r(N)') file("table8")
estadd local demSamp  `r(N)', replace

* Column 2: Tax Revenue/GDP
eststo: reghdfe D.tax $DEM_VARS $EC $CC , $FE $CLUSTER_VARS
estadd local date_fe "Yes" , replace
estadd local country_fe "Yes" , replace
estadd local econtrols "Yes" , replace
estadd local clustering "Country" , replace
save_estimate, key("column2.pe") value(`=_b[post_combo_dem_succ20]') file("table8")
save_estimate, key("column2.se") value(`=_se[post_combo_dem_succ20]') file("table8")
sum combo_dem_start if combo_dem_end == 1 & e(sample) == 1
save_estimate, key("column2.nd") value(`r(N)') file("table8")
estadd local demSamp  `r(N)', replace

* Column 3: Gini coefficient
eststo: reghdfe D.swiid_gini_mkt $DEM_VARS $EC $CC , $FE $CLUSTER_VARS
estadd local date_fe "Yes" , replace
estadd local country_fe "Yes" , replace
estadd local econtrols "Yes" , replace
estadd local clustering "Country" , replace
save_estimate, key("column3.pe") value(`=_b[post_combo_dem_succ20]') file("table8")
save_estimate, key("column3.se") value(`=_se[post_combo_dem_succ20]') file("table8")
sum combo_dem_start if combo_dem_end == 1 & e(sample) == 1
save_estimate, key("column3.nd") value(`r(N)') file("table8")
estadd local demSamp  `r(N)', replace

* Column 4: Labor share (employee compensation)
eststo: reghdfe D.comp_sh $DEM_VARS $EC $CC  if D.comp_sh  != 0 , $FE $CLUSTER_VARS
estadd local date_fe "Yes" , replace
estadd local country_fe "Yes" , replace
estadd local econtrols "Yes" , replace
estadd local clustering "Country" , replace
save_estimate, key("column4.pe") value(`=_b[post_combo_dem_succ20]') file("table8")
save_estimate, key("column4.se") value(`=_se[post_combo_dem_succ20]') file("table8")
sum combo_dem_start if combo_dem_end == 1 & e(sample) == 1
save_estimate, key("column4.nd") value(`r(N)') file("table8")
estadd local demSamp  `r(N)', replace

* 51 basis point higher growth in GDP per capita after democratization
reghdfe log_ggdc_gdppc_i_g $DEM_VARS $EC, $FE $CLUSTER_VARS
save_estimate, key("dem_growth_succ") value(`=_b[post_combo_dem_succ20]') file("table8")

# delimit ;

esttab using "${TABLES}/table_8_explicit_redistribution.tex",
	transform(@*100 100) b(%9.2f) se(%9.2f) order($DEM_VARS)
	drop(_cons $EC $CC)
	s(date_fe country_fe econtrols demSamp r2 N,
		label("Country FE" "Year FE" "Controls" "Episode obs." "R$^2$" "Observations")
		fmt(0 0 0 %9.0f %9.2f %15.0gc))
	style(tex) star(* 0.10 ** 0.05 *** 0.01)
	prehead("\begin{tabularx}{\linewidth}{@{} l*{@E}{Y} @{}}" 
		   "\toprule" 
		   "\multicolumn{1}{l}{Dependent variable:} & \multicolumn{2}{c}{Public Sector Size} & \multicolumn{2}{c}{Inequality and Labor Power} \\ \cmidrule(lr){2-3} \cmidrule(lr){4-5}"
		   " & \multicolumn{1}{c}{$\Delta$ Govt Rev/GDP} & \multicolumn{1}{c}{$\Delta$ Tax Rev/GDP} & \multicolumn{1}{c}{$\Delta$ Gini Coef} & \multicolumn{1}{c}{$\Delta$ Labor Share Emp} \\ \cmidrule(lr){2-5}")
	posthead("\hline \addlinespace[0.75ex]")
	prefoot("\hline \addlinespace[0.75ex]")
	postfoot("\bottomrule" 
				"\end{tabularx}")
	addnotes("Standard errors clustered by country.") 
	nomtitle obslast label replace booktabs substitute(\_ _) ;

# delimit cr