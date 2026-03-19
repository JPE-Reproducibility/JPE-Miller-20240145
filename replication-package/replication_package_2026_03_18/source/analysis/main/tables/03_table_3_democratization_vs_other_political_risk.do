/*
Purpose: Generates Table 3 - Democratization vs other kinds of political risk
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
global TABLES                 "source/tables/raw"

* ===========================================================================
* Regression specifications
* ===========================================================================

** Main variables
global OUTCOME log_all_div_yld_5yr
global ME "combo_dem_minus_start"
global OE1 "L_political_crisis_minus_start"
global OE2 "aut_ep_minus_start"
global OE3 "icb_crisis_minus_start"
global IND_VARS $ME $OE1 $OE2 $OE3

** Controls
global CC log_ggdc_gdppc_i log_ggdc_gdppc_i_5yr v2x_clphy v2x_clphy_5yr log_all_cpi_5yr
global EC financial_crisis at_war default recession govt_head_death assas_succ assas_attempt md_high_action coup_detat

** Fixed effects
global NO_FE                        noabsorb
global ALL_FE							   absorb(country_id year)
global COUNTRY_REG_YEAR					absorb(country_id year#e_regionpol)
global COUNTRY_REGIME_REGION_YEAR   absorb(country_id year#region#L_autocracy)

** Clustering of SEs
global CLUSTER_VARS     vce(cluster country_id year)

* ===========================================================================
* Main execution logic
* ===========================================================================

use "${ANALYSIS_DERIVED}/section_3_data.dta"

* Set the sample
keep if year >= 1918

eststo clear

eststo: reghdfe $OUTCOME $IND_VARS , $NO_FE $CLUSTER_VARS
estadd local date_fe "No" , replace
estadd local country_fe "No" , replace
estadd local reg_year "No" , replace
estadd local cont_reg_year "No" , replace
estadd local econtrols "No" , replace
estadd local controls "No" , replace
save_estimate, key("column1.democratization.pe") value(`=_b[combo_dem_minus_start]') file("table3")
save_estimate, key("column1.democratization.se") value(`=_se[combo_dem_minus_start]') file("table3")
save_estimate, key("column1.regime_change.pe") value(`=_b[L_political_crisis_minus_start]') file("table3")
save_estimate, key("column1.regime_change.se") value(`=_se[L_political_crisis_minus_start]') file("table3")
save_estimate, key("column1.autocratization.pe") value(`=_b[aut_ep_minus_start]') file("table3")
save_estimate, key("column1.autocratization.se") value(`=_se[aut_ep_minus_start]') file("table3")
save_estimate, key("column1.icb_crisis.pe") value(`=_b[icb_crisis_minus_start]') file("table3")
save_estimate, key("column1.icb_crisis.se") value(`=_se[icb_crisis_minus_start]') file("table3")
test $ME = $OE1
local temp = round(`r(p)',.001)
estadd local ftest `temp' , replace
test $ME = $OE2
local temp = round(`r(p)',.001)
estadd local ftest2 `temp' , replace
test $ME = $OE3
local temp = round(`r(p)',.001)
estadd local ftest3 `temp' , replace
sum combo_dem_minus_start if combo_dem_minus_start == 1 & e(sample) == 1
estadd local demSamp  `r(N)', replace

eststo: reghdfe $OUTCOME $IND_VARS $EC , $NO_FE $CLUSTER_VARS
estadd local date_fe "No" , replace
estadd local country_fe "No" , replace
estadd local reg_year "No" , replace
estadd local cont_reg_year "No" , replace
estadd local econtrols "Yes" , replace
save_estimate, key("column2.democratization.pe") value(`=_b[combo_dem_minus_start]') file("table3")
save_estimate, key("column2.democratization.se") value(`=_se[combo_dem_minus_start]') file("table3")
save_estimate, key("column2.regime_change.pe") value(`=_b[L_political_crisis_minus_start]') file("table3")
save_estimate, key("column2.regime_change.se") value(`=_se[L_political_crisis_minus_start]') file("table3")
save_estimate, key("column2.autocratization.pe") value(`=_b[aut_ep_minus_start]') file("table3")
save_estimate, key("column2.autocratization.se") value(`=_se[aut_ep_minus_start]') file("table3")
save_estimate, key("column2.icb_crisis.pe") value(`=_b[icb_crisis_minus_start]') file("table3")
save_estimate, key("column2.icb_crisis.se") value(`=_se[icb_crisis_minus_start]') file("table3")
test $ME = $OE1
local temp = round(`r(p)',.001)
estadd local ftest `temp' , replace
test $ME = $OE2
local temp = round(`r(p)',.001)
estadd local ftest2 `temp' , replace
test $ME = $OE3
local temp = round(`r(p)',.001)
estadd local ftest3 `temp' , replace
sum combo_dem_minus_start if combo_dem_minus_start == 1 & e(sample) == 1
estadd local demSamp  `r(N)', replace

eststo: reghdfe $OUTCOME $IND_VARS $EC , $ALL_FE $CLUSTER_VARS
estadd local date_fe "Yes" , replace
estadd local country_fe "Yes" , replace
estadd local reg_year "No" , replace
estadd local cont_reg_year "No" , replace
estadd local econtrols "Yes" , replace
save_estimate, key("column3.democratization.pe") value(`=_b[combo_dem_minus_start]') file("table3")
save_estimate, key("column3.democratization.se") value(`=_se[combo_dem_minus_start]') file("table3")
save_estimate, key("column3.regime_change.pe") value(`=_b[L_political_crisis_minus_start]') file("table3")
save_estimate, key("column3.regime_change.se") value(`=_se[L_political_crisis_minus_start]') file("table3")
save_estimate, key("column3.autocratization.pe") value(`=_b[aut_ep_minus_start]') file("table3")
save_estimate, key("column3.autocratization.se") value(`=_se[aut_ep_minus_start]') file("table3")
save_estimate, key("column3.icb_crisis.pe") value(`=_b[icb_crisis_minus_start]') file("table3")
save_estimate, key("column3.icb_crisis.se") value(`=_se[icb_crisis_minus_start]') file("table3")
test $ME = $OE1
local temp = round(`r(p)',.001)
estadd local ftest `temp' , replace
test $ME = $OE2
local temp = round(`r(p)',.001)
estadd local ftest2 `temp' , replace
test $ME = $OE3
local temp = round(`r(p)',.001)
estadd local ftest3 `temp' , replace
sum combo_dem_minus_start if combo_dem_minus_start == 1 & e(sample) == 1
estadd local demSamp  `r(N)', replace

eststo: reghdfe $OUTCOME $IND_VARS $EC , $COUNTRY_REG_YEAR $CLUSTER_VARS
estadd local date_fe "No" , replace
estadd local country_fe "Yes" , replace
estadd local reg_year "Yes" , replace
estadd local cont_reg_year "No" , replace
estadd local econtrols "Yes" , replace
save_estimate, key("column4.democratization.pe") value(`=_b[combo_dem_minus_start]') file("table3")
save_estimate, key("column4.democratization.se") value(`=_se[combo_dem_minus_start]') file("table3")
save_estimate, key("column4.regime_change.pe") value(`=_b[L_political_crisis_minus_start]') file("table3")
save_estimate, key("column4.regime_change.se") value(`=_se[L_political_crisis_minus_start]') file("table3")
save_estimate, key("column4.autocratization.pe") value(`=_b[aut_ep_minus_start]') file("table3")
save_estimate, key("column4.autocratization.se") value(`=_se[aut_ep_minus_start]') file("table3")
save_estimate, key("column4.icb_crisis.pe") value(`=_b[icb_crisis_minus_start]') file("table3")
save_estimate, key("column4.icb_crisis.se") value(`=_se[icb_crisis_minus_start]') file("table3")
test $ME = $OE1
local temp = round(`r(p)',.001)
estadd local ftest `temp' , replace
test $ME = $OE2
local temp = round(`r(p)',.001)
estadd local ftest2 `temp' , replace
test $ME = $OE3
local temp = round(`r(p)',.001)
estadd local ftest3 `temp' , replace
sum combo_dem_minus_start if combo_dem_minus_start == 1 & e(sample) == 1
estadd local demSamp  `r(N)', replace

eststo: reghdfe $OUTCOME $IND_VARS $EC , $COUNTRY_REGIME_REGION_YEAR $CLUSTER_VARS
estadd local date_fe "No" , replace
estadd local country_fe "Yes" , replace
estadd local reg_year "No" , replace
estadd local cont_reg_year "Yes" , replace
estadd local econtrols "Yes" , replace
save_estimate, key("column5.democratization.pe") value(`=_b[combo_dem_minus_start]') file("table3")
save_estimate, key("column5.democratization.se") value(`=_se[combo_dem_minus_start]') file("table3")
save_estimate, key("column5.regime_change.pe") value(`=_b[L_political_crisis_minus_start]') file("table3")
save_estimate, key("column5.regime_change.se") value(`=_se[L_political_crisis_minus_start]') file("table3")
save_estimate, key("column5.autocratization.pe") value(`=_b[aut_ep_minus_start]') file("table3")
save_estimate, key("column5.autocratization.se") value(`=_se[aut_ep_minus_start]') file("table3")
save_estimate, key("column5.icb_crisis.pe") value(`=_b[icb_crisis_minus_start]') file("table3")
save_estimate, key("column5.icb_crisis.se") value(`=_se[icb_crisis_minus_start]') file("table3")
test $ME = $OE1
local temp = round(`r(p)',.001)
estadd local ftest `temp' , replace
test $ME = $OE2
local temp = round(`r(p)',.001)
estadd local ftest2 `temp' , replace
test $ME = $OE3
local temp = round(`r(p)',.001)
estadd local ftest3 `temp' , replace
sum combo_dem_minus_start if combo_dem_minus_start == 1 & e(sample) == 1
estadd local demSamp  `r(N)', replace

eststo: reghdfe $OUTCOME $IND_VARS $EC $CC , $COUNTRY_REGIME_REGION_YEAR $CLUSTER_VARS
estadd local date_fe "No" , replace
estadd local country_fe "Yes" , replace
estadd local reg_year "No" , replace
estadd local cont_reg_year "Yes" , replace
estadd local econtrols "Yes" , replace
estadd local controls "Yes" , replace
save_estimate, key("column6.democratization.pe") value(`=_b[combo_dem_minus_start]') file("table3")
save_estimate, key("column6.democratization.se") value(`=_se[combo_dem_minus_start]') file("table3")
save_estimate, key("column6.regime_change.pe") value(`=_b[L_political_crisis_minus_start]') file("table3")
save_estimate, key("column6.regime_change.se") value(`=_se[L_political_crisis_minus_start]') file("table3")
save_estimate, key("column6.autocratization.pe") value(`=_b[aut_ep_minus_start]') file("table3")
save_estimate, key("column6.autocratization.se") value(`=_se[aut_ep_minus_start]') file("table3")
save_estimate, key("column6.icb_crisis.pe") value(`=_b[icb_crisis_minus_start]') file("table3")
save_estimate, key("column6.icb_crisis.se") value(`=_se[icb_crisis_minus_start]') file("table3")
test $ME = $OE1
local temp = round(`r(p)',.001)
estadd local ftest `temp' , replace
test $ME = $OE2
local temp = round(`r(p)',.001)
estadd local ftest2 `temp' , replace
test $ME = $OE3
local temp = round(`r(p)',.001)
estadd local ftest3 `temp' , replace
sum combo_dem_minus_start if combo_dem_minus_start == 1 & e(sample) == 1
estadd local demSamp  `r(N)', replace

# delimit ;

esttab   
   using "${TABLES}/table_3_democratization_vs_other_political_risk.tex", transform(@*100 100) b(%9.2f) se(%9.2f) 
   drop(_cons $EC $CC) s(country_fe date_fe reg_year cont_reg_year econtrols demSamp ftest ftest2 ftest3 r2 N, ///
   label("Country FE" "Year FE" "Region $\times$ Year FE" "Continent $\times$ Regime $\times$ Year FE" "Event Controls" "Episode obs." ///
   "Democratization vs Regime change (p-value)" "Democratization vs Autocratization (p-value)" "Democratization vs International political crisis (p-value)" "R$^2$" "Observations") fmt(0 0 0 0 0 %9.0f %9.2f %9.2f %9.2f %9.2f %15.0gc)) style(tex) star(* 0.10 ** 0.05 *** 0.01)
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