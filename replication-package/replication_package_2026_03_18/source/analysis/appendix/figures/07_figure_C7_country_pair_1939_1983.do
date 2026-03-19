/*
Purpose: Generate Figure C7 - Dropping every country pair, 1939–1983
Author: Max Miller
Date: 12-10-2025
*/

* ===========================================================================
* Housekeeping
* ===========================================================================

clear all
version 19
set scheme s2color
adopath + "source/utils/analysis"

* ===========================================================================
* Set globals
* ===========================================================================

global ASSETS_DERIVED   "datastore/derived/assets"
global ANALYSIS_DERIVED "datastore/derived/analysis"
global FIGURES          "source/figures"

global begYear = 1946
global endYear1 = 1976
global endYear2 = 1983

global EC govt_head_death financial_crisis icb_crisis at_war default_first_5 recession combo_dem assas_attempt assas_succ coup_detat
global CC log_ggdc_gdppc_i log_ggdc_gdppc_i_g

global CLUSTER_VARS cluster(country_id year)
global FE absorb(country_id year vdem_regime)

* ===========================================================================
* Main execution logic
* ===========================================================================

program define main

    use "${ANALYSIS_DERIVED}/section_4_data.dta", clear
    keep if year >= 1939 & year <= 1983
	winsor2 capm_unexp2, replace

    create_country_pair_data
    create_aut_country_pair_data
	create_drop_pair_plots

end

* ===========================================================================
* Create window end date plot
* ===========================================================================

program define create_country_pair_data
    local i = 1
    qui levelsof country
    set matsize 3000
    mat less_country = J(3000,2,.)
    foreach c1 in `r(levels)'{
		qui levelsof country
        foreach c2 in `r(levels)'{
            qui reghdfe capm_unexp2 maj_cath_aut2_post_long $CC $EC if country != "`c1'" & country != "`c2'", $FE $CLUSTER_VARS
            mat temp_mat = r(table)
            mat less_country[`i',1] = _b[maj_cath_aut2_post]
            mat less_country[`i',2] = _b[maj_cath_aut2_post]/_se[maj_cath_aut2_post]
            local i = `i' + 1
        }
		di "Finished excluding all combinations with `c1'"
    }

	preserve
	clear
    svmat double less_country
	rename less_country1 pe
	rename less_country2 t_stat
	drop if pe == .
    replace pe = pe*100
	save "${FIGURES}/data/figure_C7a_country_pair_long.dta", replace
	restore
	
end


program define create_aut_country_pair_data
    local i = 1
    qui levelsof country if autSample2 == 1
    set matsize 3000
    mat less_country = J(3000,2,.)
    foreach c1 in `r(levels)'{
        qui levelsof country if autSample2 == 1
        foreach c2 in `r(levels)'{
            qui reghdfe capm_unexp2 maj_cath_aut2_post_long $CC $EC if country != "`c1'" & country != "`c2'" & autSample2 == 1, $FE $CLUSTER_VARS
            mat temp_mat = r(table)
            mat less_country[`i',1] = _b[maj_cath_aut2_post]
            mat less_country[`i',2] = _b[maj_cath_aut2_post]/_se[maj_cath_aut2_post]
            local i = `i' + 1
        }
		di "Finished excluding all combinations with `c1'"
    }

	preserve
	clear
    svmat double less_country
	rename less_country1 pe
	rename less_country2 t_stat
	drop if pe == .
    replace pe = pe*100
	save "${FIGURES}/data/figure_C7b_country_pair_long_aut.dta", replace
	restore
	
end

program create_drop_pair_plots

	use "${FIGURES}/data/figure_C7a_country_pair_long.dta", clear

	sum pe
	local width = `r(sd)'/1.5
    hist pe, width(`width') ///
		xtitle("") xlabel(, nogrid) ///
        graphregion(color(white)) color(blue%40) ///
		ytitle("") ylabel(, nogrid) bgcolor(white)
    graph export "${FIGURES}/raw/figure_C7a_country_pair_PE_long.pdf", replace

	sum t_stat	
	local width = `r(sd)'/1.5
    hist t_stat, width(`width') ///
		xtitle("") xlabel(, nogrid) ///
        graphregion(color(white)) color(blue%40) ///
		ytitle("") ylabel(, nogrid) bgcolor(white)
    graph export "${FIGURES}/raw/figure_C7a_country_pair_T_long.pdf", replace
	
	use "${FIGURES}/data/figure_C7b_country_pair_long_aut.dta", clear
	
	sum pe
	local width = `r(sd)'/1.75
	hist pe, width(`width') ///
		xtitle("") xlabel(, nogrid) ///
        graphregion(color(white)) color(blue%40) ///
		ytitle("") ylabel(, nogrid) bgcolor(white)
    graph export "${FIGURES}/raw/figure_C7b_country_pair_PE_long_aut.pdf", replace
    
	sum t_stat	
	local width = `r(sd)'/1.75
	hist t_stat, width(`width') ///
		xtitle("") xlabel(, nogrid) ///
        graphregion(color(white)) color(blue%40) ///
		ytitle("") ylabel(, nogrid) bgcolor(white)
    graph export "${FIGURES}/raw/figure_C7b_country_pair_T_long_aut.pdf", replace

end


* ===========================================================================
* Run script
* ===========================================================================

main