/*
Purpose: Generate Table D16 - Future inequality and price declines
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

global ANALYSIS_DERIVED 			"datastore/derived/analysis"
global ASSETS_DERIVED 			    "datastore/derived/assets"
global MACRO_POLITICAL_DERIVED 	    "datastore/derived/macro_political"
global TABLES 					    "source/tables/raw"

* ===========================================================================
* Regression specifications
* ===========================================================================

** Include variables
global INCLUDE_VARS             temp_interact combo_dem rolling_log_eq_capgain_3yr_tot

** Fixed effects
global NO_FE                    noabsorb
global ALL_FE                   absorb(country_id year)

** Clustering of SEs
global CLUSTER_VARS             vce(cluster country_id year)

* ===========================================================================
* Main execution logic
* ===========================================================================

use "${ANALYSIS_DERIVED}/section_3_data.dta", clear

gen swiid_f5yr = F5.swiid_gini_mkt-F.swiid_gini_mkt
gen swiid_f10yr = F10.swiid_gini_mkt-F.swiid_gini_mkt

gen rolling_log_eq_capgain_3yr_tot = (log_all_eq_capgain + L.log_all_eq_capgain + L2.log_all_eq_capgain)/3

gen temp_interact = c.rolling_log_eq_capgain_3yr_tot*combo_dem

drop if log_all_div_yld_1yr == .

label var temp_interact "Democratization $\times$ 3-year Price Change"
label var rolling_log_eq_capgain_3yr_tot "3-year Price Change"
label var combo_dem "Democratization"

eststo clear
eststo: reghdfe swiid_f5yr $INCLUDE_VARS if D.swiid_gini_mkt != 0, $NO_FE $CLUSTER_VARS
estadd local date_fe "No" , replace
estadd local country_fe "No" , replace
estadd local reg_year "No" , replace
estadd local cont_reg_year "No" , replace
estadd local econtrols "No" , replace
sum combo_dem_minus_start if combo_dem == 1 & e(sample) == 1
estadd local demSamp  `r(N)', replace

eststo: reghdfe swiid_f5yr $INCLUDE_VARS if D.swiid_gini_mkt != 0, $ALL_FE $CLUSTER_VARS
estadd local date_fe "Yes" , replace
estadd local country_fe "Yes" , replace
estadd local reg_year "No" , replace
estadd local cont_reg_year "No" , replace
estadd local econtrols "No" , replace
sum combo_dem_minus_start if combo_dem == 1 & e(sample) == 1
estadd local demSamp  `r(N)', replace

eststo: reghdfe swiid_f10yr $INCLUDE_VARS  if D.swiid_gini_mkt != 0, $NO_FE $CLUSTER_VARS
estadd local date_fe "No" , replace
estadd local country_fe "No" , replace
estadd local reg_year "No" , replace
estadd local cont_reg_year "No" , replace
estadd local econtrols "No" , replace
sum combo_dem_minus_start if combo_dem == 1 & e(sample) == 1
estadd local demSamp  `r(N)', replace

eststo: reghdfe swiid_f10yr $INCLUDE_VARS if D.swiid_gini_mkt != 0, $ALL_FE $CLUSTER_VARS
estadd local date_fe "Yes" , replace
estadd local country_fe "Yes" , replace
estadd local reg_year "No" , replace
estadd local cont_reg_year "No" , replace
estadd local econtrols "No" , replace
sum combo_dem_minus_start if combo_dem == 1 & e(sample) == 1
estadd local demSamp  `r(N)', replace

# delimit ;

esttab   
    using "${TABLES}/table_D16_inequality_price_decline.tex", b(%9.2f) se(%9.2f) order($INCLUDE_VARS)
    drop(_cons) s(country_fe date_fe reg_year cont_reg_year econtrols demSamp r2 N, label("Country FE" "Year FE" "Region $\times$ Year FE" "Continent $\times$ Regime $\times$ Year FE" "Controls" "Episode obs." "R$^2$" "Observations") fmt(0 0 0 0 0 %9.0f %9.2f %15.0gc)) style(tex) star(* 0.10 ** 0.05 *** 0.01)  
    prehead("\begin{tabularx}{\linewidth}{@{} l*{@E}{Y} @{}}" 
            "\toprule" 
            "\multicolumn{1}{l}{Dependent variable:} & \multicolumn{2}{c}{Five-year change in Gini coef.} & \multicolumn{2}{c}{Ten-year change in Gini coef.} \\ \cmidrule(lr){2-3} \cmidrule(lr){4-5}")
    posthead("\hline \addlinespace[0.75ex]")
    prefoot("\hline \addlinespace[0.75ex]")
    postfoot("\bottomrule" 
                "\end{tabularx}")
    addnotes("Standard errors clustered by country and year.") 
    nomtitle obslast label replace booktabs substitute(\_ _) ;

# delimit cr