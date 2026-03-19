/*
Purpose: Generate Table C8 - Difference-in-Differences — First Vatican Council
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

global ASSETS_DERIVED   "datastore/derived/assets"
global EVENTS_DERIVED   "datastore/derived/events"
global TABLES           "source/tables/raw"

global EC govt_head_death financial_crisis at_war default_first_5 recession assas_attempt assas_succ coup_detat

* ===========================================================================
* Main execution logic
* ===========================================================================

program define main

    use "${ASSETS_DERIVED}/all_excess_and_abnormal_returns.dta", clear
    merge 1:1 country year using "${EVENTS_DERIVED}/all_events.dta", keep(2 3) nogen
    sort country year

    tsset country_id year

    * Re-examine this to see if it is still used.
    gen default_first_5 = default_start
    replace default_first_5 = 1 if L.default_start == 1
    replace default_first_5 = 1 if L2.default_start == 1
    replace default_first_5 = 1 if L3.default_start == 1
    replace default_first_5 = 1 if L4.default_start == 1

	keep if year >= 1844 & year <= 1890	
	winsor2 capm_unexp2, replace

    gen maj_cath_auto2 = 1 if inlist(country,"AUT","BRA","CHL","COL","CUB","ESP","IRL","MEX","PRT")
    replace maj_cath_auto2 = 1 if inlist(country,"FRA", "BEL")
    replace maj_cath_auto2 = 0 if inlist(country,"AUS","CAN","DEU","DNK","EGY","GBR","IND")
    replace maj_cath_auto2 = 0 if inlist(country,"NLD","SWE","TUR","USA","ZAF")

    cap drop maj_cath_auto2_post
    gen maj_cath_auto2_post = maj_cath_auto2 if year >= 1871 & year <= 1890
    replace maj_cath_auto2_post = 0 if year <= 1863 & year >= 1844 & maj_cath_auto2 != .
    
    label var maj_cath_auto2_post "Majority Catholic Autocracy $\times$ Post"

    bys country: egen any_capm_unexp2 = count(capm_unexp2)
    keep if any_capm_unexp2 > 0
    keep if maj_cath_auto2 != .

    run_regressions
	export_table


end

* ===========================================================================
* Run regressions and create table
* ===========================================================================

program define run_regressions

    eststo clear
    eststo: reghdfe capm_unexp2 maj_cath_auto2_post $EC if year <= 1885 & year >= 1849, ///
        absorb(country_id year) cluster(country_id year)
    estadd local yearFE "Yes" , replace
    estadd local countryFE "Yes" , replace
    estadd local controls "Yes" , replace
    estadd local samp "1849--1885" , replace
    save_estimate, key("column1.pe") value(`=_b[maj_cath_auto2_post]') file("tableC8")
    save_estimate, key("column1.se") value(`=_se[maj_cath_auto2_post]') file("tableC8")

    eststo: reghdfe capm_unexp2 maj_cath_auto2_post $EC if year <= 1891 & year >= 1843, ///
        absorb(country_id year) cluster(country_id year)
    estadd local yearFE "Yes" , replace
    estadd local countryFE "Yes" , replace
    estadd local controls "Yes" , replace
    estadd local samp "1844--1890" , replace
    save_estimate, key("column2.pe") value(`=_b[maj_cath_auto2_post]') file("tableC8")
    save_estimate, key("column2.se") value(`=_se[maj_cath_auto2_post]') file("tableC8")
end

* ===========================================================================
* Export table to LaTeX
* ===========================================================================

program define export_table
    # delimit ;

    esttab   
        using "${TABLES}/table_C8_did_first_vatican.tex", transform(@*100 100) b(%9.2f) se(%9.2f) 
        drop(_cons $EC ) s(countryFE yearFE controls samp r2 N, label("Country FE" "Year FE" "Controls" "Sample" "R$^2$" "Observations") fmt(0 0 0 0 %9.2f %15.0gc)) style(tex) star(* 0.10 ** 0.05 *** 0.01)
        prehead("\begin{tabularx}{\linewidth}{@{} l*{@E}{Y} @{}}" 
                "\toprule" 
                " & \multicolumn{2}{c}{All Countries} \\ \cmidrule(lr){2-3} ")
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