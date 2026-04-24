/*
Purpose: Generate Table B4- Other macroeconomic and political risk measures
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

global ANALYSIS_DERIVED         "datastore/derived/analysis"
global TABLES 					"source/tables/raw"

* ===========================================================================
* Regression specifications
* ===========================================================================

** Fixed effects
global NO_FE							noabsorb
global ALL_FE							absorb(country_id year)
global COUNTRY_REG_YEAR					absorb(country_id year#e_regionpol)
global COUNTRY_REGIME_REGION_YEAR 		absorb(country_id year#region#L_autocracy)

** Clustering of SEs
global CLUSTER_VARS     vce(cluster country_id)

** Controls
global CC "log_ggdc_gdppc_i log_ggdc_gdppc_i_g v2x_clphy L.v2x_clphy log_all_cpi_g"
global EC financial_crisis at_war default recession govt_head_death assas_succ assas_attempt md_high_action coup_detat

** Other globals
global head "\begin{tabular}{@{}p{1.1cm}p{1.1cm}@{}}"
global foot "\end{tabular}"

* ===========================================================================
* Main execution logic
* ===========================================================================

program define main
    use "${ANALYSIS_DERIVED}/section_3_data.dta", clear
    prepare_variables
    run_regressions
end

* ===========================================================================
* Prepare variables
* ===========================================================================

program define prepare_variables
    
    gen net_fdi_gdp = (fdi_inflow - fdi_outflow)/100
    winsor2 net_fdi_gdp, replace
    gen vdem_violence_index = (1-v2x_clphy)

    foreach var in log_ggdc_gdppc {
        gen `var'_f10yr = (F10.`var' - `var')/10
        gen `var'_5yr  = (`var' - L5.`var')/5
    }

    gen log_all_div_f10yr = (log_all_div_g + F1.log_all_div_g + F2.log_all_div_g + F3.log_all_div_g + F4.log_all_div_g + F5.log_all_div_g + F6.log_all_div_g + F7.log_all_div_g + F8.log_all_div_g + F9.log_all_div_g)/10
    gen log_all_div_5yr  = (log_all_div_g + L1.log_all_div_g + L2.log_all_div_g + L3.log_all_div_g + L4.log_all_div_g)/5

    gen log_all_cpi_f10yr = (log_all_cpi_g + F1.log_all_cpi_g + F2.log_all_cpi_g + F3.log_all_cpi_g + F4.log_all_cpi_g + F5.log_all_cpi_g + F6.log_all_cpi_g + F7.log_all_cpi_g + F8.log_all_cpi_g + F9.log_all_cpi_g)/10
    gen log_all_cpi_f5yr = (log_all_cpi_g + F1.log_all_cpi_g + F2.log_all_cpi_g + F3.log_all_cpi_g + F4.log_all_cpi_g)/5

    foreach var in net_fdi_gdp fdi_inflow fdi_outflow {

        gen `var'_5yr = (`var' + L1.`var' + L2.`var' + L3.`var' + L4.`var')/5
        gen `var'_f5yr = (`var' + F1.`var' + F2.`var' + F3.`var' + F4.`var')/5
        gen `var'_f10yr = (`var' + F1.`var' + F2.`var' + F3.`var' + F4.`var' + F5.`var' + F6.`var' + F7.`var' + F8.`var' + F9.`var')/10

    }

    foreach var in vdem_violence_index v2caviol v2cagenmob v2csantimv v2cademmob {
        sum `var', d
        gen `var'_scale = (`var' - `r(min)')/(`r(max)'-`r(min)')
        gen `var'_f10yr = (F10.`var'_scale - `var'_scale)/10
        gen `var'_f5yr = (F5.`var'_scale - `var'_scale)/5
        gen `var'_5yr  = (L.`var'_scale - L5.`var'_scale)/5
    }

    keep if log_all_div_yld_5yr != .
    
end

* ===========================================================================
* Run regressions and create table
* ===========================================================================

program define run_regressions

    local n = 1
    foreach spec in log_ggdc_gdppc log_all_div log_all_cpi net_fdi_gdp vdem_violence_index v2caviol v2cagenmob {
        foreach k in _5yr _f5yr _f10yr {
            run_dem_regression `spec'`k', reg_type(alt_spec) oth_ind(combo_dem_minus_start)
            local row`n' &`r(col1)'	&`r(col2)' 	&`r(col3)'	&`r(col4)' 	&`r(col5)'	&`r(col6)'
            local ++n
        }
    }

    texdoc init "${TABLES}/table_B4_macro_political_risk_measures.tex", replace force

    tex 	\begin{tabularx}{\linewidth}{@{} l*{8}{Y} @{}} 
    tex 	\hline \hline
    tex   	& & \multicolumn{1}{c}{(1)} & \multicolumn{1}{c}{(2)}&\multicolumn{1}{c}{(3)}&\multicolumn{1}{c}{(4)} &\multicolumn{1}{c}{(5)} &\multicolumn{1}{c}{(6)} \\ 
    tex		\hline \addlinespace[0.75ex]
    tex     \textit{A. Macroeconomic risk measures}					&							&         	&			&   		&			&			&			\\
    tex     														&							&			&			&			&			&			&			\\
    local c _1
    tex   	\hspace{0.5cm} log GDP per capita growth				&	t-5 $\rightarrow$ t		`row1'	\\
    tex   	\hspace{0.5cm} 											&	t $\rightarrow$ t+5		`row2'	\\
    tex   	\hspace{0.5cm} 											&	t $\rightarrow$ t+10	`row3'	\\
    tex     														&							&			&			&			&			&			&			\\
    local c _2
    tex   	\hspace{0.5cm} log Divdend growth						&	t-5 $\rightarrow$ t		`row4'	\\
    tex   	\hspace{0.5cm} 											&	t $\rightarrow$ t+5		`row5'	\\
    tex   	\hspace{0.5cm} 											&	t $\rightarrow$ t+10	`row6'	\\
    tex     														&							&			&			&			&			&			&			\\
    local c _3
    tex   	\hspace{0.5cm} log Inflation							&	t-5 $\rightarrow$ t		`row7'	\\
    tex   	\hspace{0.5cm} 											&	t $\rightarrow$ t+5		`row8'	\\
    tex   	\hspace{0.5cm} 											&	t $\rightarrow$ t+10	`row9'	\\
    tex     														&							&			&			&			&			&			&			\\
    local c _4
    tex   	\hspace{0.5cm} Net FDI/GDP								&	t-5 $\rightarrow$ t		`row10'	\\
    tex   	\hspace{0.5cm} 											&	t $\rightarrow$ t+5		`row11'	\\
    tex   	\hspace{0.5cm} 											&	t $\rightarrow$ t+10	`row12'	\\
    tex     														&							&			&			&			&			&			&			\\
    tex     \textit{B. Political risk measures}						&							&         	&			&   		&			&			&			\\
    tex     														&							&			&			&			&			&			&			\\
    local c _5
    tex   	\hspace{0.5cm} Physical violence index					&	t-5 $\rightarrow$ t		`row13'	\\
    tex   	\hspace{0.5cm} 											&	t $\rightarrow$ t+5		`row14'	\\
    tex   	\hspace{0.5cm} 											&	t $\rightarrow$ t+10	`row15'	\\
    tex     														&							&			&			&			&			&			&			\\
    local c _6
    tex   	\hspace{0.5cm} Political violence index					&	t-5 $\rightarrow$ t		`row16'	\\
    tex   	\hspace{0.5cm} 											&	t $\rightarrow$ t+5		`row17'	\\
    tex   	\hspace{0.5cm} 											&	t $\rightarrow$ t+10	`row18'	\\
    tex     														&							&			&			&			&			&			&			\\
    local c _7
    tex   	\hspace{0.5cm} Mass mobilizations index					&	t-5 $\rightarrow$ t		`row19'	\\
    tex   	\hspace{0.5cm} 											&	t $\rightarrow$ t+5		`row20'	\\
    tex   	\hspace{0.5cm} 											&	t $\rightarrow$ t+10	`row21'	\\
    tex 	\hline \addlinespace[0.75ex]
    tex		Country FE          									&							&	No		&	No		&	Yes		&	Yes		&	Yes		&	Yes		\\
    tex		Year FE             									&							&	No		&	No		&	Yes		&	No		&	No		&	No		\\
    tex		Region $\times$ Year FE									&							&	No		&	No		&	No		&	Yes		&	No		&	No		\\
    tex		Continent $\times$ Regime $\times$ Year FE				&							&	No		&	No		&	No		&	No		&	Yes		&	Yes		\\
    tex		Event Controls      									&							&	No		&	Yes		&	Yes		&	Yes		&	Yes		&	Yes		\\
    tex		Other Controls     										&							&	No		&	No		&	No		&	No		&	No		&	Yes		\\
    tex		\bottomrule
    tex		\end{tabularx}

    texdoc close
end

program define run_dem_regression, rclass
    syntax varname, ///
		reg_type(string) /// type of regression (alt_dem, alt_spec, or alt_measure)
		[oth_ind(varlist)] /// other independent variable
		[extra_control(varlist)] /// extra control variables
    
    
    if "`reg_type'" == "alt_dem" {		
		gen _C = `varlist'
		gen _L = L.`varlist'
		gen _F = F.`varlist'

		local x _F _C _L
		local y log_all_div_yld_5yr
	}
	else if "`reg_type'" == "alt_spec" {
		gen _C = `oth_ind'

		local x _C
		local y `varlist'
	}
	else if "`reg_type'" == "alt_measure" {
		gen _C = `oth_ind'

		local x _C
		local y `varlist'
	}
    
    local col = 1
    foreach fe in "none" "$NO_FE" "$ALL_FE" "$COUNTRY_REG_YEAR" "$COUNTRY_REGIME_REGION_YEAR" "sink" {
        
        * Run appropriate regression
        if "`fe'" == "none" {
            reghdfe `y' `x' `extra_control', $NO_FE $CLUSTER_VARS
        } 
        else if "`fe'" == "sink" {
            reghdfe `y' `x' `extra_control' $EC $CC, $COUNTRY_REGIME_REGION_YEAR $CLUSTER_VARS
        } 
        else {
            reghdfe `y' `x' `extra_control' $EC, `fe' $CLUSTER_VARS
        }
        
        * Extract coefficient and t-stat
        local b: di %4.2fc 100 * _b[_C]
        local tstat = _b[_C] / _se[_C]
        local t_fmt: di %4.2fc `tstat'
        
        * Determine significance stars
        local stars ""
        if abs(`tstat') >= 2.576       local stars "\sym{***}"
        else if abs(`tstat') >= 1.96   local stars "\sym{**}"
        else if abs(`tstat') >= 1.645  local stars "\sym{*}"
        
        * Store formatted cell
        return local col`col' `"${head} `b'`stars' & (`t_fmt') ${foot}"'
        
        local ++col
    }
    
    cap drop _C 
	cap drop _L 
	cap drop _F
end


* ===========================================================================
* Run script
* ===========================================================================

main