/*
Purpose: Generate Figure C3 - Predicting democratizations with anti-regime CSO activity vs. democratic mobilizations
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

global MACRO_POLITICAL_DERIVED 	"datastore/derived/macro_political"
global EVENTS_DERIVED 			"datastore/derived/events"
global FIGURES 					"source/figures"

* ===========================================================================
* Main execution logic
* ===========================================================================

program define main

    use "${MACRO_POLITICAL_DERIVED}/anti_system_cso_activity_and_mobilizations.dta", clear
    merge 1:1 country year using "${EVENTS_DERIVED}/all_events.dta", keep(2 3) nogen

    sort country_id year
    tsset country_id year

    create_anti_cso_prediction_plot

end

* ===========================================================================
* Create anti-regime CSO prediction plot
* ===========================================================================

program define create_anti_cso_prediction_plot
    
    sum combo_dem
    sca mean_dem = r(mean)

    cap drop coefs*

    mat coefs = J(25,7,.)
    forvalues i=1(1)25 {
        reghdfe combo_dem L`i'.v2cademmob_ord  L`i'.v2csantimv_ord if year > 1960, absorb(year country_id) cluster(country_id year)
        mat coefs[`i',1] = -`i'
        mat temp = r(table)
        mat coefs[`i',2] = 100*(temp[1,2])/mean_dem
        mat coefs[`i',3] = 100*(temp[1,1])/mean_dem
        mat coefs[`i',4] = 100*(temp[1,2] + 1.645*temp[2,2])/mean_dem
        mat coefs[`i',5] = 100*(temp[1,2] - 1.645*temp[2,2])/mean_dem
        mat coefs[`i',6] = 100*(temp[1,1] + 1.645*temp[2,1])/mean_dem
        mat coefs[`i',7] = 100*(temp[1,1] - 1.645*temp[2,1])/mean_dem
    }

    svmat coefs
    local labSize = "med"
    two (connected coefs2 coefs1, color(red) msymbol(s)) ///
        (rcap coefs4 coefs5 coefs1, color(red)) ///
        (connected coefs3 coefs1, color(blue) msymbol(s)) ///
        (rcap coefs6 coefs7 coefs1, color(blue)), ///
        graphregion(color(white)) ylabel(-40(20)120, nogrid labsize(`labSize')) xlabel(, nogrid) ///
        xtitle("") bgcolor(white) ytitle("Increase in democratization probability (%)", size(`labSize')) yline(0, lw(.4)  lc(black) lp(dash)) ///
        legend(size(med) order(1 "Anti-regime CSO Activity" 3 "Democratic Mobilizations") nobox region(lcolor(white)) ring(0) position(11) rows(2)) ysize(3)
    graph export "${FIGURES}/raw/figure_C3_democracy_activity_mobil.pdf", replace
    
end


* ===========================================================================
* Run script
* ===========================================================================

main