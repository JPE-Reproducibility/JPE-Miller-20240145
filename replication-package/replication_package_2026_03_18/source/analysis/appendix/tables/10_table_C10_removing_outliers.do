/*
Purpose: Generate Table C10 - Difference-in-differences, Removing outliers
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

global ANALYSIS_DERIVED   "datastore/derived/analysis"
global TABLES             "source/tables/raw"

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

program define main

    use "${ANALYSIS_DERIVED}/section_4_data.dta", clear

    keep if year >= 1939 & year <= 1983	
    winsor2 capm_unexp2, replace

    winsor2 capm_unexp2, c(5 95)
    rename capm_unexp2_w capm_unexp2_w5
    winsor2 capm_unexp2, c(10 90)
    rename capm_unexp2_w capm_unexp2_w10

    gen capm_unexp2_no_67_69 = capm_unexp2 if year < 1967 | year > 1969

    replace maj_cath_aut2_post = . if year > 1976
	
    gen treatment = .
    label var treatment "Maj. Catholic Aut. $\times$ Post"
	
    run_regressions $treat1 1946 1976
    export_table $treat1

    run_regressions $treat2 1939 1983
    export_table $treat2
    
end

* ===========================================================================
* Run regressions and create table
* ===========================================================================

program define run_regressions
	args treat_var begYear endYear
	
    replace treatment = `treat_var'
	
    eststo clear
    eststo: reghdfe capm_unexp2_w5 treatment $EC $CC , $FE $CLUSTER_VARS
    estadd local yearFE "Yes" , replace
    estadd local countryFE "Yes" , replace
    estadd local controls "Yes" , replace
    estadd local subsamp "All" , replace
    save_estimate, key("`spec'.column1.pe") value(`=_b[treatment]') file("tableC10")
    save_estimate, key("`spec'.column1.se") value(`=_se[treatment]') file("tableC10")
    sum year if e(sample) == 1
    estadd local samp "`r(min)'--`r(max)'" , replace

    eststo: reghdfe capm_unexp2_w5 treatment $EC $CC if autSample2 ==1, $FE $CLUSTER_VARS
    estadd local yearFE "Yes" , replace
    estadd local countryFE "Yes" , replace
    estadd local controls "Yes" , replace
    estadd local subsamp "Autocracy" , replace
    save_estimate, key("`spec'.column2.pe") value(`=_b[treatment]') file("tableC10")
    save_estimate, key("`spec'.column2.se") value(`=_se[treatment]') file("tableC10")
    sum year if e(sample) == 1
    estadd local samp "`r(min)'--`r(max)'" , replace

    eststo: reghdfe capm_unexp2_w10 treatment $EC $CC , $FE $CLUSTER_VARS
    estadd local yearFE "Yes" , replace
    estadd local countryFE "Yes" , replace
    estadd local controls "Yes" , replace
    estadd local subsamp "All" , replace
    save_estimate, key("`spec'.column3.pe") value(`=_b[treatment]') file("tableC10")
    save_estimate, key("`spec'.column3.se") value(`=_se[treatment]') file("tableC10")
    sum year if e(sample) == 1
    estadd local samp "`r(min)'--`r(max)'" , replace

    eststo: reghdfe capm_unexp2_w10 treatment $EC $CC if autSample2 ==1, $FE $CLUSTER_VARS
    estadd local yearFE "Yes" , replace
    estadd local countryFE "Yes" , replace
    estadd local controls "Yes" , replace
    estadd local subsamp "Autocracy" , replace
    save_estimate, key("`spec'.column4.pe") value(`=_b[treatment]') file("tableC10")
    save_estimate, key("`spec'.column4.se") value(`=_se[treatment]') file("tableC10")
    sum year if e(sample) == 1
    estadd local samp "`r(min)'--`r(max)'" , replace

    eststo: reghdfe capm_unexp2_no_67_69 treatment $EC $CC , ///
		absorb(country_id year vdem_regime) cluster(country_id year)
    estadd local yearFE "Yes" , replace
    estadd local countryFE "Yes" , replace
    estadd local controls "Yes" , replace
    estadd local subsamp "Autocracy" , replace
    save_estimate, key("`spec'.column5.pe") value(`=_b[treatment]') file("tableC10")
    save_estimate, key("`spec'.column5.se") value(`=_se[treatment]') file("tableC10")
    sum year if e(sample) == 1
    estadd local samp "`r(min)'--`r(max)'" , replace

    eststo: reghdfe capm_unexp2_no_67_69 treatment $EC $CC if autSample2 == 1, ///
		absorb(country_id year vdem_regime) cluster(country_id year)
    estadd local yearFE "Yes" , replace
    estadd local countryFE "Yes" , replace
    estadd local controls "Yes" , replace
    estadd local subsamp "Autocracy" , replace
    save_estimate, key("`spec'.column6.pe") value(`=_b[treatment]') file("tableC10")
    save_estimate, key("`spec'.column6.se") value(`=_se[treatment]') file("tableC10")
    sum year if e(sample) == 1
    estadd local samp "`r(min)'--`r(max)'" , replace

end

* ===========================================================================
* Export table to LaTeX
* ===========================================================================

program define export_table
	args treat_var
	
	if "`treat_var'" == "$treat1" {
		local filename "table_C10a_removing_outliers_short_sample"
	}
	else if "`treat_var'" == "$treat2" {
		local filename "table_C10b_removing_outliers_long_sample"
	}

    # delimit ;

    esttab   
        using "${TABLES}/`filename'.tex", transform(@*100 100) b(%9.2f) se(%9.2f) 
        drop(_cons $EC $CC ) s(countryFE yearFE controls samp r2 N, label("Country FE" "Year FE" "Controls" "Sample" "R$^2$" "Observations") fmt(0 0 0 0 %9.2f %15.0gc)) style(tex) star(* 0.10 ** 0.05 *** 0.01)
        prehead("\begin{tabularx}{\linewidth}{@{} l*{@E}{Y} @{}}" 
                "\toprule" 
                " & \multicolumn{2}{c}{Winsorized: 5\% and 95\%} & \multicolumn{2}{c}{Winsorized: 10\% and 90\%} & \multicolumn{2}{c}{Excluding 1967--1969} \\ \cmidrule(lr){2-3} \cmidrule(lr){4-5} \cmidrule(lr){6-7}")
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