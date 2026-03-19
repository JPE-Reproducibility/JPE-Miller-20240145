/*
Purpose: Generate Table 6 - Balance tests across regime types
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

global ANALYSIS_DERIVED         "datastore/derived/analysis"
global TABLES 					"source/tables/raw"

* ===========================================================================
* Main execution logic
* ===========================================================================

program define main

use "${ANALYSIS_DERIVED}/section_4_data.dta"

    * Create scaled versions of variables for display
    replace ggdc_gdppc_i = ggdc_gdppc_i/(1000*100)
    replace gini_std = gini_std/(100)
	
	keep if year >= 1946 & year <= 1958
	
    run_balance_tests
    
    * Create table using texdoc
    texdoc init "${TABLES}/table_6_balance_tests.tex", replace force
    
    tex \begin{tabularx}{\linewidth}{@{} l*{6}{Y} @{}}
    tex \hline \hline
    tex & \textbf{\makecell{Maj. Cath. \\ Autocracy}} & \textbf{\makecell{Non-Cath. \\ Autocracy}} &  \textbf{Democracy} &  \textbf{\makecell{All Country \\ Diff}} &  \textbf{\makecell{Autocracy \\ Diff.}}  \\ \cmidrule(lr){2-6}
    tex &\multicolumn{1}{c}{(1)} & \multicolumn{1}{c}{(2)}&\multicolumn{1}{c}{(3)}&\multicolumn{1}{c}{(4)} &\multicolumn{1}{c}{(5)} \\
    tex \hline \addlinespace[0.75ex]
    tex \textit{Finance}						 				&         	    &			    &   		    &			    &				\\
    tex \hspace{0.5cm} Excess returns (\%)						& `_1_1_str'	&`_1_2_str' 	&`_1_3_str'	    &`_1_4_str' 	&`_1_5_str'		\\
    tex \hspace{0.5cm} Risk-adjusted returns (\%)				& `_2_1_str'	&`_2_2_str' 	&`_2_3_str'	    &`_2_4_str' 	&`_2_5_str'		\\
    tex \hspace{0.5cm} Dividend growth (\%)						& `_3_1_str'	&`_3_2_str' 	&`_3_3_str'	    &`_3_4_str' 	&`_3_5_str'		\\
    tex      													&			    &			    &			    &			    &				\\
    tex \textit{Macroeconomy}						 			&         	    &			    &   		    &			    &				\\
    tex \hspace{0.5cm} GDP per capita (\\$000)					& `_4_1_str'	&`_4_2_str' 	&`_4_3_str'	    &`_4_4_str' 	&`_4_5_str'		\\
    tex \hspace{0.5cm} Inflation (\%)							& `_5_1_str'	&`_5_2_str' 	&`_5_3_str'	    &`_5_4_str' 	&`_5_5_str'		\\
    tex \hspace{0.5cm} Annual GDP per capita growth (\%)		& `_6_1_str'	&`_6_2_str' 	&`_6_3_str'	    &`_6_4_str' 	&`_6_5_str'		\\
    tex \hspace{0.5cm} Debt/GDP (\%) 							& `_7_1_str'	&`_7_2_str' 	&`_7_3_str'	    &`_7_4_str' 	&`_7_5_str'		\\
    tex      													&			    &			    &			    &			    &				\\
    tex \textit{Inequality}						 				&         	    &			    &   		    &			    &				\\
    tex \hspace{0.5cm} Gini coefficient 						& `_8_1_str'	&`_8_2_str' 	&`_8_3_str'	    &`_8_4_str' 	&`_8_5_str'		\\
    tex \hspace{0.5cm} Resource inequality index 				& `_9_1_str'	&`_9_2_str' 	&`_9_3_str'	    &`_9_4_str' 	&`_9_5_str'		\\
    tex \bottomrule
    tex \end{tabularx}
end

* ===========================================================================
* Run balance tests
* ===========================================================================

program define run_balance_tests
    local i = 1
    
    foreach var of varlist all_exc_ret capm_unexp2 all_div_g ggdc_gdppc_i all_cpi_g ggdc_gdppc_g all_debt_gdp gini_std vdem_resource_inequality {

        reg `var' maj_cath_aut2 non_cath_auto2 demSample2, nocons cluster(country)
        local b_val_1: di %3.1fc 100*_b[maj_cath_aut2]
        c_local _`i'_1_str = string(100*_b[maj_cath_aut2], "%3.1fc")
        local b_val_2: di %3.1fc 100*_b[non_cath_auto2]
        c_local _`i'_2_str = string(100*_b[non_cath_auto2], "%3.1fc")
        c_local _`i'_3_str = string(100*_b[demSample2], "%3.1fc")

        reghdfe `var' maj_cath_aut2 , noabsorb cluster(country)
        local b_val = 100*_b[maj_cath_aut2]
        local se_val = 100*_se[maj_cath_aut2]
        c_local _`i'_4_b  = `b_val'
        c_local _`i'_4_se = `se_val'
        local t4 = _b[maj_cath_aut2]/_se[maj_cath_aut2]
        format_coefficient `i' 4 `t4' `b_val' `se_val'
        c_local _`i'_4_str = r(coefficient_str)

        reghdfe `var' maj_cath_aut2 if autSample2 == 1, noabsorb cluster(country)
        local b_val = `b_val_1' - `b_val_2'
        local se_val = 100*_se[maj_cath_aut2]
        c_local _`i'_5_b  = `b_val'
        c_local _`i'_5_se = `se_val'
        local t5 = _b[maj_cath_aut2]/_se[maj_cath_aut2]
        format_coefficient `i' 5 `t5' `b_val' `se_val'
        c_local _`i'_5_str = r(coefficient_str)

        local i = `i' + 1
    }
end

* ===========================================================================
* Format coefficient with significance stars
* ===========================================================================

program define format_coefficient, rclass
    args i col t b_val se_val
    
    local b_str = string(`b_val', "%3.1fc")
    local se_str = string(`se_val', "%3.1fc")
    
    if abs(`t') >= 2.576 {
        local _`i'_`col'_str "`b_str'\sym{***} (`se_str')"
    }
    else if abs(`t') >= 1.96 {
        local _`i'_`col'_str "`b_str'\sym{**} (`se_str')"
    }
    else if abs(`t') >= 1.645 {
        local _`i'_`col'_str "`b_str'\sym{*} (`se_str')"
    }
    else {
        local _`i'_`col'_str "`b_str' (`se_str')"
    }
    return local coefficient_str `"`_`i'_`col'_str'"'
end


* ===========================================================================
* Run script
* ===========================================================================

main