/*
Purpose: Generate Figure 3 - Distribution of GDP and consumption in democratizations
Author: Max Miller
Date: 2025
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

global ANALYSIS_DERIVED 		"datastore/derived/analysis"
global FIGURES 					"source/figures"

* ===========================================================================
* Main execution logic
* ===========================================================================

use "${ANALYSIS_DERIVED}/section_3_data.dta"

winsor2 log_ggdc_gdp_g, cuts(.25 99.75)
winsor2 log_rconna_g, cuts(.25 99.75)

local labSize = "medlarge"

two (hist log_ggdc_gdp_g_w if combo_dem_minus != 1, width(.015) color(blue%30)) ///
    (hist log_ggdc_gdp_g_w if combo_dem_minus == 1, width(.015) color(red%30)), ///
    legend(size(`labSize') order(1 "Not Democratization" 2 "Democratization") ///
        nobox region(lcolor(white)) ring(0) position(11) rows(2)) ///
    ylabel(none, labsize(`labSize')) xlabel(, labsize(`labSize')) ///
    ytitle(" ") xtitle(" ") bgcolor(white) ///
    graphregion(color(white)) xlabel(-.3(.1).3)
graph export "${FIGURES}/raw/figure_3a_gdp_growth_distribution.pdf", replace

two (hist log_rconna_g_w if combo_dem_minus != 1, width(.02) color(blue%30)) ///
    (hist log_rconna_g_w if combo_dem_minus == 1, width(.02) color(red%30)), ///
    legend(size(`labSize') order(1 "Not Democratization" 2 "Democratization") ///
        nobox region(lcolor(white)) ring(0) position(2) rows(2)) ///
    ylabel(none) ytitle(" ") xtitle(" ") bgcolor(white) ///
    graphregion(color(white))
graph export "${FIGURES}/raw/figure_3b_consumption_growth_distribution.pdf", replace
