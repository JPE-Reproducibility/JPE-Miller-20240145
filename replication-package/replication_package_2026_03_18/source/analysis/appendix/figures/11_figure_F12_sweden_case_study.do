/*
Purpose: Generate Figure F12 - Electoral Democracy Index and dividend yield, Sweden 1917–1924
Author: Max Miller
Date: 12-10-2025
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

global ASSETS_DERIVED 			"datastore/derived/assets"
global MACRO_POLITICAL_DERIVED 	"datastore/derived/macro_political"
global FIGURES 					"source/figures"

global START_YEAR = 1910
global END_YEAR = 1930
global DEM_YEARS 1917 1918 1919 1920 1921 1922 1923 1924

* ===========================================================================
* Main execution logic
* ===========================================================================

program define main
    use "${ASSETS_DERIVED}/all_div_yld.dta", clear
    keep country year gfd_div_yld
    keep if gfd_div_yld != .
    merge 1:1 country year using "${MACRO_POLITICAL_DERIVED}/democracy_index_and_regime_info.dta", keep(1 3) nogen    
	keep if year >= $START_YEAR & year <= $END_YEAR & country == "SWE"
    create_sweden_case_study
end

* ===========================================================================
* Create Sweden plot
* ===========================================================================

program define create_sweden_case_study
    
    local labSize = "large"
    two (connected vdem_elect year , lc(blue) lw(.6) mc(blue)) ///
        (connected gfd_div_yld year , lc(red) lw(.6) yaxis(2) msymbol(s) mc(red) ), ///
        ylabel(,  axis(1) labcolor(blue) nogrid labsize(`labSize')) ///
		yscale(axis(1) lc(blue)) ///
		ytitle("Electoral Democracy Index", size(`labSize') margin(medsmall) color(blue)) ///
        ylabel(,  axis(2) labcolor(red) nogrid labsize(`labSize')) ///
		yscale(axis(2) lc(red)) ///
		ytitle("Dividend Yield", size(`labSize') margin(medsmall) axis(2) color(red)) ///
		ysize(3) ///
        xline($DEM_YEARS, lc(gs12) lwidth(12) lp(solid)) ///
		xlabel($START_YEAR(4)$END_YEAR, labsize(`labSize') nogrid) ///
		xtitle("") ///
        legend(off) ///
        graphregion(color(white)) ///
        bgcolor(white) subtitle(" ")
    graph export "${FIGURES}/raw/figure_F12_sweden_case_study.pdf", replace

end

* ===========================================================================
* Run script
* ===========================================================================

main