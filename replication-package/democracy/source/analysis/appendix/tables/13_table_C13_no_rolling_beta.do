/*
Purpose: Generate Table C13 - Difference-in-differences, No rolling β estimatio
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

global ANALYSIS_DERIVED "datastore/derived/analysis"
global TABLES           "source/tables/raw"

* ===========================================================================
* Regression specifications
* ===========================================================================

** Global and regional returns
global GLO_RET c.world_return#i.country_id#i.post_1963
global REG_RET c.regional_return#i.country_id#i.post_1963

** Fixed effects
global FE absorb(country_id year vdem_regime $GLO_RET $REG_RET)

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

gen post_1963 = year > 1963
gen treatment = maj_cath_aut2_post
label var treatment "Majority Catholic Autocracy $\times$ Post"

reghdfe capm_unexp2 maj_cath_aut2_post_long $EC $CC if year <= 1983 , $FE $CLUSTER_VARS

keep if e(sample)

eststo clear

replace treatment = maj_cath_aut2_post

eststo: reghdfe all_exc_ret treatment $EC $CC if year <= 1976 , $FE $CLUSTER_VARS
estadd local yearFE "Yes" , replace
estadd local countryFE "Yes" , replace
estadd local controls "Yes" , replace
sum year if e(sample) == 1
estadd local samp "`r(min)'--`r(max)'" , replace

replace treatment = maj_cath_aut2_post_long

eststo: reghdfe all_exc_ret treatment $EC $CC if year <= 1983 , $FE $CLUSTER_VARS
estadd local yearFE "Yes" , replace
estadd local countryFE "Yes" , replace
estadd local controls "Yes" , replace
sum year if e(sample) == 1
estadd local samp "`r(min)'--`r(max)'" , replace

replace treatment = maj_cath_aut2_post

eststo: reghdfe all_exc_ret treatment $EC $CC if year <= 1976  & autSample2 == 1, $FE $CLUSTER_VARS
estadd local yearFE "Yes" , replace
estadd local countryFE "Yes" , replace
estadd local controls "Yes" , replace
sum year if e(sample) == 1
estadd local samp "`r(min)'--`r(max)'" , replace

replace treatment = maj_cath_aut2_post_long

eststo: reghdfe all_exc_ret treatment $EC $CC if year <= 1983  & autSample2 == 1, $FE $CLUSTER_VARS
estadd local yearFE "Yes" , replace
estadd local countryFE "Yes" , replace
estadd local controls "Yes" , replace
sum year if e(sample) == 1
estadd local samp "`r(min)'--`r(max)'" , replace

# delimit ;

esttab   
    using "${TABLES}/table_C13_did_no_rolling_beta.tex", transform(@*100 100) b(%9.2f) se(%9.2f) 
    drop(_cons $EC $CC ) s(countryFE yearFE controls samp r2 N, label("Country FE" "Year FE" "Controls" "Sample" "R$^2$" "Observations") fmt(0 0 0 0 %9.2f %15.0gc)) style(tex) star(* 0.10 ** 0.05 *** 0.01)
    prehead("\begin{tabularx}{\linewidth}{@{} l*{@E}{Y} @{}}" 
            "\toprule" 
            " & \multicolumn{2}{c}{All Countries} & \multicolumn{2}{c}{Autocracies Only} \\ \cmidrule(lr){2-3} \cmidrule(lr){4-5}")
    posthead("\hline \addlinespace[0.75ex]")
    prefoot("\hline \addlinespace[0.75ex]")
    postfoot("\bottomrule" 
                "\end{tabularx}")
    addnotes("Standard errors clustered by country and year.") 
    nomtitle obslast label replace booktabs substitute(\_ _) ;

# delimit cr