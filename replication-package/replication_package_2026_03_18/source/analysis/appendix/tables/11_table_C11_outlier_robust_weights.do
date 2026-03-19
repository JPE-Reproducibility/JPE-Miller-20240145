/*
Purpose: Generate Table C11 - Difference-in-differences, Outlier robust weights
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

global ANALYSIS_DERIVED "datastore/derived/analysis"
global TABLES           "source/tables/raw"

* ===========================================================================
* Regression specifications
* ===========================================================================

** Fixed effects
global FE absorb(country_id year vdem_regime)

** Clustering of SEs
global CLUSTER_VARS cluster(country_id year)

** Controls
global EC govt_head_death financial_crisis icb_crisis at_war default_first_5 recession assas_attempt assas_succ coup_detat
global CC log_ggdc_gdppc_i log_ggdc_gdppc_i_g

** Treatment variables
global treat1 maj_cath_aut2_post
global treat2 maj_cath_aut2_post_long

* ===========================================================================
* Main execution logic
* ===========================================================================

use "${ANALYSIS_DERIVED}/section_4_data.dta", clear
	
keep if year >= 1939 & year <= 1983	
winsor2 capm_unexp2, replace

gen treatment = .
label var treatment "Majority Catholic $\times$ Post"

rreg capm_unexp2 $treat2 i.year i.country_id $EC $CC if year <= 1983 , tune(7) genwt(temp_wgt)

replace treatment = $treat1

eststo clear
eststo: reghdfe capm_unexp2 treatment $EC $CC [aweight=temp_wgt] if year <= 1976 , $FE $CLUSTER_VARS
estadd local yearFE "Yes" , replace
estadd local countryFE "Yes" , replace
estadd local controls "Yes" , replace
estadd local subsamp "All" , replace
save_estimate, key("column1.pe") value(`=_b[treatment]') file("tableC11")
save_estimate, key("column1.se") value(`=_se[treatment]') file("tableC11")
sum year if e(sample) == 1
estadd local samp "`r(min)'--`r(max)'" , replace

replace treatment = $treat2

eststo: reghdfe capm_unexp2 treatment $EC $CC [aweight=temp_wgt] if year <= 1983 , $FE $CLUSTER_VARS
estadd local yearFE "Yes" , replace
estadd local countryFE "Yes" , replace
estadd local controls "Yes" , replace
estadd local subsamp "Autocracy" , replace
save_estimate, key("column2.pe") value(`=_b[treatment]') file("tableC11")
save_estimate, key("column2.se") value(`=_se[treatment]') file("tableC11")
sum year if e(sample) == 1
estadd local samp "`r(min)'--`r(max)'" , replace

replace treatment = $treat1

eststo: reghdfe capm_unexp2 treatment $EC $CC [aweight=temp_wgt] if year <= 1976 & autSample2 ==1 , $FE $CLUSTER_VARS
estadd local yearFE "Yes" , replace
estadd local countryFE "Yes" , replace
estadd local controls "Yes" , replace
estadd local subsamp "All" , replace
save_estimate, key("column3.pe") value(`=_b[treatment]') file("tableC11")
save_estimate, key("column3.se") value(`=_se[treatment]') file("tableC11")
sum year if e(sample) == 1
estadd local samp "`r(min)'--`r(max)'" , replace

replace treatment = $treat2

eststo: reghdfe capm_unexp2 treatment $EC $CC [aweight=temp_wgt] if year <= 1983 & autSample2 == 1 , $FE $CLUSTER_VARS
estadd local yearFE "Yes" , replace
estadd local countryFE "Yes" , replace
estadd local controls "Yes" , replace
estadd local subsamp "Autocracy" , replace
save_estimate, key("column4.pe") value(`=_b[treatment]') file("tableC11")
save_estimate, key("column4.se") value(`=_se[treatment]') file("tableC11")
sum year if e(sample) == 1
estadd local samp "`r(min)'--`r(max)'" , replace

# delimit ;

esttab   
    using "${TABLES}/table_C11_did_robust_weights.tex", transform(@*100 100) b(%9.2f) se(%9.2f) 
    drop(_cons $EC $CC ) s(countryFE yearFE controls samp r2 N, label("Country FE" "Year FE" "Controls" "Sample" "R$^2$" "Observations") fmt(0 0 0 0 %9.2f %15.0gc)) style(tex) star(* 0.10 ** 0.05 *** 0.01)
    prehead("\begin{tabularx}{\linewidth}{@{} l*{@E}{Y} @{}}" 
            "\toprule" 
            " & \multicolumn{2}{c}{All countries} & \multicolumn{2}{c}{Autocracies only} \\ \cmidrule(lr){2-3} \cmidrule(lr){4-5}")
    posthead("\hline \addlinespace[0.75ex]")
    prefoot("\hline \addlinespace[0.75ex]")
    postfoot("\bottomrule" 
                "\end{tabularx}")
    addnotes("Standard errors clustered by country and year.") 
    nomtitle obslast label replace booktabs substitute(\_ _) ;

# delimit cr
