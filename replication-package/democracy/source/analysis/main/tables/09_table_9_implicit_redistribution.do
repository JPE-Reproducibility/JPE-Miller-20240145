/*
Purpose: Generate Table 9 - Successful democratizations and tacit redistribution
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

global ANALYSIS_DERIVED          "datastore/derived/analysis"
global TABLES                    "source/tables/raw"

* ===========================================================================
* Regression specifications
* ===========================================================================

** Main variables
global DEM_VARS combo_dem_succ combo_dem post_combo_dem_succ10 post_combo_dem10

** Fixed effects
global FE absorb(country_id year)

** Clustering of SEs
global CLUSTER_VARS cluster(country_id)

** Controls
global EC financial_crisis at_war default recession govt_head_death assas_succ assas_attempt md_high_action coup_detat icb_crisis

* ===========================================================================
* Main execution logic
* ===========================================================================

use "${ANALYSIS_DERIVED}/section_3_data.dta"

eststo clear

* Column 1: V-Dem Corruption Index
eststo: reghdfe D.v2x_pubcorr $DEM_VARS $EC , $FE $CLUSTER_VARS
estadd local country_fe "Yes", replace
estadd local date_fe "Yes", replace
estadd local econtrols "Yes", replace
save_estimate, key("column1.pe") value(`=_b[combo_dem_succ]') file("table9")
save_estimate, key("column1.se") value(`=_se[combo_dem_succ]') file("table9")
sum combo_dem_start if combo_dem_end == 1 & e(sample) == 1
save_estimate, key("column1.nd") value(`r(N)') file("table9")
estadd local demSamp  `r(N)', replace

* Column 2: V-Dem Bribery Index
eststo: reghdfe D.bribery_index $DEM_VARS $EC , $FE $CLUSTER_VARS
estadd local country_fe "Yes", replace
estadd local date_fe "Yes", replace
estadd local econtrols "Yes", replace
save_estimate, key("column2.pe") value(`=_b[combo_dem_succ]') file("table9")
save_estimate, key("column2.se") value(`=_se[combo_dem_succ]') file("table9")
sum combo_dem_start if combo_dem_end == 1 & e(sample) == 1
save_estimate, key("column2.nd") value(`r(N)') file("table9")
estadd local demSamp  `r(N)', replace

* Column 3: Pro-Competitive Regulation Score
eststo: reghdfe D.efi_5c_scale $DEM_VARS $EC , $FE $CLUSTER_VARS
estadd local country_fe "Yes", replace
estadd local date_fe "Yes", replace
estadd local econtrols "Yes", replace
save_estimate, key("column3.pe") value(`=_b[combo_dem_succ]') file("table9")
save_estimate, key("column3.se") value(`=_se[combo_dem_succ]') file("table9")
sum combo_dem_start if combo_dem_end == 1 & e(sample) == 1
save_estimate, key("column3.nd") value(`r(N)') file("table9")
estadd local demSamp  `r(N)', replace

* Column 4: Net Entry of Public Firms
eststo: reghdfe D.log_gfd_n_companies $DEM_VARS $EC , $FE $CLUSTER_VARS
estadd local country_fe "Yes", replace
estadd local date_fe "Yes", replace
estadd local econtrols "Yes", replace
save_estimate, key("column4.pe") value(`=_b[combo_dem_succ]') file("table9")
save_estimate, key("column4.se") value(`=_se[combo_dem_succ]') file("table9")
sum combo_dem_start if combo_dem_end == 1 & e(sample) == 1
save_estimate, key("column4.nd") value(`r(N)') file("table9")
estadd local demSamp  `r(N)', replace

# delimit ;

esttab 
   using "${TABLES}/table_9_implicit_redistribution.tex", transform(@*100 100) b(%9.2f) se(%9.2f) order($DEM_VARS)
   drop(_cons $EC) s(country_fe date_fe econtrols demSamp r2 N, label("Country FE" "Year FE" "Controls" "Episode obs." "R$^2$" "Observations") fmt(0 0 0 %9.0f %9.2f %15.0gc)) style(tex) star(* 0.10 ** 0.05 *** 0.01)
   prehead("\begin{tabularx}{\linewidth}{@{} l*{@E}{Y} @{}}" 
		   "\toprule" 
		   "\multicolumn{1}{l}{Dependent variable:} & \multicolumn{2}{c}{Rent Extraction} & \multicolumn{2}{c}{Competition and New Entry} \\ \cmidrule(lr){2-3} \cmidrule(lr){4-5}"
		   " & \multicolumn{1}{c}{$\Delta$ Corruption} & \multicolumn{1}{c}{$\Delta$ Bribery} & \multicolumn{1}{c}{$\Delta$ Pro-Comp. Regulation} & \multicolumn{1}{c}{$\Delta$ log(Firms)} \\ \cmidrule(lr){2-5}")
   posthead("\hline \addlinespace[0.75ex]")
   prefoot("\hline \addlinespace[0.75ex]")
   postfoot("\bottomrule" 
			"\end{tabularx}")
   addnotes("Standard errors clustered by country.") 
   nomtitle obslast label replace booktabs substitute(\_ _) ; 

# delimit cr
