/*
Purpose: Generate Table B5 - Democratizations and probability of adverse events
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
global EVENTS_DERIVED 			"datastore/derived/events"
global ASSETS_DERIVED 			"datastore/derived/assets"
global TABLES 					"source/tables/raw"

* ===========================================================================
* Main execution logic
* ===========================================================================

program define main

    use "${ANALYSIS_DERIVED}/section_3_data.dta", clear
    keep if log_all_div_yld_5yr != .
    keep country
    duplicates drop
    tempfile div_yld_countries
    save "`div_yld_countries'"

    create_market_loss
    tempfile market_loss
    save "`market_loss'"

    use "${ANALYSIS_DERIVED}/section_3_data.dta", clear
    merge 1:1 country year using "`market_loss'", nogen
	drop if country_id == .
	sort country_id year
	tsset country_id year
    
    replace market_loss = 0 if market_loss == .

    lab var combo_dem "Democratization"
    lab var aut_ep "Autocratization"
    lab var political_crisis "Other Regime Change"

    drop if vdem_elect == .
    drop if year < 1900 // No autocratization data before 1900

    run_regressions
	export_table "table_B5a_adverse_probability_all"

    merge m:1 country using "`div_yld_countries'", keep(3) nogen

    run_regressions
	export_table "table_B5b_adverse_probability_div_yld"

end

* ===========================================================================
* Prepare variables
* ===========================================================================

program create_market_loss
    use "${ANALYSIS_DERIVED}/section_3_data.dta", clear
    sort country year
    gen has_eq_data = 1 if all_eq_tr != . | all_eq_capgain != .
    drop if has_eq_data == .

    keep country_id country year has_eq_data
    sort country_id year
    tsset country_id year
    tsfill

    gen market_loss = 1 if has_eq_data == . & L.has_eq_data != .

    drop country
    decode country_id, generate(country)
    keep country year market_loss
    keep if market_loss == 1
end

* ===========================================================================
* Run regressions and create table
* ===========================================================================

program define run_regressions
    eststo clear
    eststo: reghdfe adverse_event_start combo_dem aut_ep political_crisis, absorb(country_id year) cluster(country_id)
    estadd local date_fe "No" , replace
    estadd local country_fe "No" , replace
    estadd local reg_year "No" , replace
    estadd local cont_reg_year "No" , replace
    estadd local econtrols "No" , replace
    sum combo_dem_minus_start if combo_dem_start == 1 & e(sample) == 1
    estadd local demSamp  `r(N)', replace

    eststo: reghdfe default_start combo_dem aut_ep political_crisis , absorb(country_id year) cluster(country_id)
    estadd local date_fe "No" , replace
    estadd local country_fe "No" , replace
    estadd local reg_year "No" , replace
    estadd local cont_reg_year "No" , replace
    estadd local econtrols "No" , replace
    sum combo_dem_minus_start if combo_dem_start == 1 & e(sample) == 1
    estadd local demSamp  `r(N)', replace

    eststo: reghdfe at_war_start combo_dem aut_ep political_crisis , absorb(country_id year) cluster(country_id)
    estadd local date_fe "No" , replace
    estadd local country_fe "No" , replace
    estadd local reg_year "No" , replace
    estadd local cont_reg_year "No" , replace
    estadd local econtrols "No" , replace
    sum combo_dem_minus_start if combo_dem_start == 1 & e(sample) == 1
    estadd local demSamp  `r(N)', replace

    eststo: reghdfe financial_crisis_start combo_dem aut_ep political_crisis , absorb(country_id year) cluster(country_id)
    estadd local date_fe "No" , replace
    estadd local country_fe "No" , replace
    estadd local reg_year "No" , replace
    estadd local cont_reg_year "No" , replace
    estadd local econtrols "No" , replace
    sum combo_dem_minus_start if combo_dem_start == 1 & e(sample) == 1
    estadd local demSamp  `r(N)', replace

    eststo: reghdfe recession_start combo_dem aut_ep political_crisis , absorb(country_id year) cluster(country_id)
    estadd local date_fe "No" , replace
    estadd local country_fe "No" , replace
    estadd local reg_year "No" , replace
    estadd local cont_reg_year "No" , replace
    estadd local econtrols "No" , replace
    sum combo_dem_minus_start if combo_dem_start == 1 & e(sample) == 1
    estadd local demSamp  `r(N)', replace

    eststo: reghdfe market_loss combo_dem aut_ep political_crisis , absorb(country_id year) cluster(country_id)
    estadd local date_fe "No" , replace
    estadd local country_fe "No" , replace
    estadd local reg_year "No" , replace
    estadd local cont_reg_year "No" , replace
    estadd local econtrols "No" , replace
    sum combo_dem_minus_start if combo_dem_start == 1 & e(sample) == 1
    estadd local demSamp  `r(N)', replace
end

* ===========================================================================
* Export table to LaTeX
* ===========================================================================

program define export_table
    args table_name

    # delimit ;

    esttab   
        using "${TABLES}/`table_name'.tex", transform(@*100 100) b(%9.2f) se(%9.2f) 
        drop(_cons ) s( demSamp r2 N, label("Democratization obs." "R$^2$" "Observations") fmt(%15.0gc %9.2f %15.0gc)) style(tex) star(* 0.10 ** 0.05 *** 0.01)  
        prehead("\begin{tabularx}{\linewidth}{@{} l*{@E}{Y} @{}}" 
                "\toprule" 
                "\multicolumn{1}{l}{Dependent variable:} & \multicolumn{1}{c}{Adverse Event} & \multicolumn{1}{c}{Default} & \multicolumn{1}{c}{War} & \multicolumn{1}{c}{Financial Crisis} & \multicolumn{1}{c}{Recession} & \multicolumn{1}{c}{Market Loss} \\ \cmidrule(lr){2-7}")
        posthead("\hline \addlinespace[0.75ex]")
        prefoot("\hline \addlinespace[0.75ex]")
        postfoot("\bottomrule" 
                    "\end{tabularx}")
        addnotes("Standard errors clustered by country.") 
        nomtitle obslast label replace booktabs substitute(\_ _) ;

    # delimit cr
end


* ===========================================================================
* Run script
* ===========================================================================

main