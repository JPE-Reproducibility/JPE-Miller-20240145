/*
Purpose: Generate Table C7 - Democratization likelihood after Vatican II
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

global ANALYSIS_DERIVED                 "datastore/derived/analysis"
global MACRO_POLITICAL_DERIVED 	        "datastore/derived/macro_political"
global EVENTS_DERIVED 			"datastore/derived/events"
global TABLES				"source/tables/raw"

* ===========================================================================
* Main execution logic
* ===========================================================================

use country year autSample2 maj_cath_aut2 using "${ANALYSIS_DERIVED}/section_4_data.dta", clear
merge 1:1 country year using  "${EVENTS_DERIVED}/all_events.dta", keep(2 3) nogen
merge 1:1 country year using "${MACRO_POLITICAL_DERIVED}/democracy_index_and_regime_info.dta", keep(3) nogen
merge m:1 country using "${MACRO_POLITICAL_DERIVED}/catholic_pct_1939_1983.dta", keep(3) nogen

gen temp = autocracy if year == 1959
bys country_id: egen autocracy_1959 = min(temp)
drop temp

gen combo_dem_start_succ = combo_dem_start * combo_dem_succ

keep if autocracy == 1
keep if year < 1990 & year > 1946

gen treatment = majority_catholic * autocracy_1959 * (year>1963)
label var treatment "Majority Catholic Autocracy $\times$ Post"

eststo clear
eststo: reghdfe combo_dem_start treatment , absorb(country_id year) cluster(country_id year)
estadd local yearFE "Yes" , replace
estadd local countryFE "Yes" , replace
estadd local demType "All" , replace

eststo: reghdfe combo_dem_start_succ treatment , absorb(country_id year) cluster(country_id year)
estadd local yearFE "Yes" , replace
estadd local countryFE "Yes" , replace
estadd local demType "Successful" , replace
save_estimate, key("column2.pe") value(`=_b[treatment]') file("tableC7")
save_estimate, key("column2.se") value(`=_se[treatment]') file("tableC7")

cap drop treatment
cap gen treatment = maj_cath_aut2 * (year>1963)

label var treatment "Majority Catholic Autocracy $\times$ Post"

eststo: reghdfe combo_dem_start treatment if autSample2 == 1 , absorb(country_id year) cluster(country_id year)
estadd local yearFE "Yes" , replace
estadd local countryFE "Yes" , replace
estadd local demType "All" , replace

eststo: reghdfe combo_dem_start_succ treatment if autSample2 == 1 , absorb(country_id year) cluster(country_id year)
estadd local yearFE "Yes" , replace
estadd local countryFE "Yes" , replace
estadd local demType "Successful" , replace
save_estimate, key("column4.pe") value(`=_b[treatment]') file("tableC7")
save_estimate, key("column4.se") value(`=_se[treatment]') file("tableC7")

# delimit ;

esttab   
using "${TABLES}/table_C7_probability_democratize_post_vatican_ii.tex", transform(@*100 100) b(%9.2f) se(%9.2f) 
drop(_cons) s(countryFE yearFE demType r2 N, label("Country FE" "Year FE" "Democratization type" "R$^2$" "Observations") fmt(0 0 0 %9.2f %15.0gc)) style(tex) star(* 0.10 ** 0.05 *** 0.01)
prehead("\begin{tabularx}{\linewidth}{@{} l*{@E}{Y} @{}}" 
        "\toprule" 
        " & \multicolumn{2}{c}{All autocracies} & \multicolumn{2}{c}{Asset pricing sample} \\ \cmidrule(lr){2-3} \cmidrule(lr){4-5}")
posthead("\hline \addlinespace[0.75ex]")
prefoot("\hline \addlinespace[0.75ex]")
postfoot("\bottomrule" 
            "\end{tabularx}")
addnotes("Standard errors clustered by country and year.") 
nomtitle obslast label replace booktabs substitute(\_ _) ;

# delimit cr