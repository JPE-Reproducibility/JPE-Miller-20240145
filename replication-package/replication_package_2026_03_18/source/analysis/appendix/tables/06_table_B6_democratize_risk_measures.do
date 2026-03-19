/*
Purpose: Generate Table B6 - Levels of political risk measures around democratizations
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
global TABLES                       "source/tables/raw"

* ===========================================================================
* Regression specifications
* ===========================================================================

** Main variables
global INC_VARS "combo_dem_start L_political_crisis_start aut_ep_start icb_crisis_start"

** Fixed effects
global NO_FE                        noabsorb
global ALL_FE                       absorb(country_id year)

** Clustering of SEs
global CLUSTER_VARS     vce(cluster country_id)

* ===========================================================================
* Main execution logic
* ===========================================================================

use "${ANALYSIS_DERIVED}/section_3_data.dta", clear

gen political_crisis_start = 1 if political_crisis == 1 & L.political_crisis == 0
replace political_crisis_start = 0 if political_crisis_start == .

cap drop L_political_crisis_start
gen L_political_crisis_start = L.political_crisis_start

cap gen physical_violence = 1-v2x_clphy

cap drop pol_violence
sum v2caviol, d
cap gen pol_violence = (v2caviol - `r(min)')/(`r(max)' - `r(min)')

sum v2cagenmob
cap gen mass_mob = (v2cagenmob - `r(min)')/(`r(max)' - `r(min)')

lab var combo_dem_start "Democratization start"
lab var L_political_crisis_start "Regime change start"
lab var aut_ep_start "Autocratization start"
lab var icb_crisis_start "International political crisis start"

keep if year >= 1918

eststo clear
eststo: reghdfe physical_violence $INC_VARS , $NO_FE $CLUSTER_VARS
estadd local date_fe "No" , replace
estadd local country_fe "No" , replace
estadd local econtrols "Yes" , replace
sum combo_dem_minus_start if combo_dem_start == 1 & e(sample) == 1
estadd local demSamp  `r(N)', replace

eststo: reghdfe physical_violence $INC_VARS , $ALL_FE $CLUSTER_VARS 
estadd local date_fe "Yes" , replace
estadd local country_fe "Yes" , replace
estadd local econtrols "Yes" , replace
sum combo_dem_minus_start if combo_dem_start == 1 & e(sample) == 1
estadd local demSamp  `r(N)', replace

eststo: reghdfe pol_violence $INC_VARS , $NO_FE $CLUSTER_VARS 
estadd local date_fe "No" , replace
estadd local country_fe "No" , replace
estadd local econtrols "Yes" , replace
sum combo_dem_minus_start if combo_dem_start == 1 & e(sample) == 1
estadd local demSamp  `r(N)', replace

eststo: reghdfe pol_violence $INC_VARS , $ALL_FE $CLUSTER_VARS 
estadd local date_fe "Yes" , replace
estadd local country_fe "Yes" , replace
estadd local econtrols "Yes" , replace
sum combo_dem_minus_start if combo_dem_start == 1 & e(sample) == 1
estadd local demSamp  `r(N)', replace

eststo: reghdfe mass_mob $INC_VARS , $NO_FE $CLUSTER_VARS 
estadd local date_fe "No" , replace
estadd local country_fe "No" , replace
estadd local econtrols "Yes" , replace
sum combo_dem_minus_start if combo_dem_start == 1 & e(sample) == 1
estadd local demSamp  `r(N)', replace

eststo: reghdfe mass_mob $INC_VARS , $ALL_FE $CLUSTER_VARS 
estadd local date_fe "Yes" , replace
estadd local country_fe "Yes" , replace
estadd local econtrols "Yes" , replace
sum combo_dem_minus_start if combo_dem_start == 1 & e(sample) == 1
estadd local demSamp  `r(N)', replace

# delimit ;

esttab   
    using "${TABLES}/table_B6_democratize_risk_measures.tex", transform(@*100 100) b(%9.2f) se(%9.2f) 
    drop(_cons ) s(country_fe date_fe demSamp r2 N, label("Country FE" "Year FE" "Democratization Years" "R$^2$" "Observations") fmt(0 0 %9.0f %9.2f %15.0gc)) style(tex) star(* 0.10 ** 0.05 *** 0.01)  
    prehead("\begin{tabularx}{\linewidth}{@{} l*{@E}{Y} @{}}" 
            "\toprule" 
            "\multicolumn{1}{l}{Dependent variable:} & \multicolumn{2}{c}{Physical Violence Index} & \multicolumn{2}{c}{Political Violence Index} & \multicolumn{2}{c}{Mass Mobilizations} \\ \cmidrule(lr){2-3} \cmidrule(lr){4-5} \cmidrule(lr){6-7}")
    posthead("\hline \addlinespace[0.75ex]")
    prefoot("\hline \addlinespace[0.75ex]")
    postfoot("\bottomrule" 
                "\end{tabularx}")
    addnotes("Standard errors clustered by year.") 
    nomtitle obslast label replace booktabs substitute(\_ _) ;

# delimit cr