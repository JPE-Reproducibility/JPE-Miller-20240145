/*
Purpose: Generate Figure 4 - Regional waves of democratization
Author: Max Miller
Date: 2025
*/

* ===========================================================================
* Housekeeping
* ===========================================================================

clear all
version 19
set scheme s2color

* ===========================================================================
* Set globals
* ===========================================================================

global ANALYSIS_DERIVED 		"datastore/derived/analysis"
global FIGURES 					"source/figures"

* ===========================================================================
* Main execution logic
* ===========================================================================

use "${ANALYSIS_DERIVED}/section_3_data.dta"
collapse Z_ace_vdem_5yr, by(year e_regionpol)

* Set label size
local labSize "large"

* Create the plot with multiple regions
two (line Z_ace_vdem_5yr year if e_regionpol == 5 & year >= 1900 & year <= 2020, ///
        color(blue) lp(solid) lw(.7)) ///
    (line Z_ace_vdem_5yr year if e_regionpol == 2 & year >= 1900 & year <= 2020, ///
        color(red) lp(dash) lw(.7)) ///
    (line Z_ace_vdem_5yr year if e_regionpol == 7 & year >= 1900 & year <= 2020, ///
        color(green) lp(longdash) lw(.7)) ///
    (connected Z_ace_vdem_5yr year if e_regionpol == 3 & year >= 1900 & year <= 2020, ///
        color(orange) lp(solid) ms(X) lw(.7)), ///
    xsc(r(1900 2020)) xlabel(1900(20)2020, nogrid labsize(`labSize')) ///
    graphregion(color(white)) ylabel(-.2(.1).4, nogrid labsize(`labSize')) ///
    xtitle("") bgcolor(white) subtitle(" ") ///
    ytitle("Portion of democratizing countries", size(`labSize') margin(medsmall)) ///
    legend(size(vsmall) order(1 "North American and Western Europe" 2 "Latin America" ///
        3 "Southeast Asia" 4 "Middle East and North Africa") ///
        nobox region(lcolor(white)) ring(0) position(11) rows(4)) ysize(3)

graph export "${FIGURES}/raw/figure_4_regional_waves.pdf", replace
