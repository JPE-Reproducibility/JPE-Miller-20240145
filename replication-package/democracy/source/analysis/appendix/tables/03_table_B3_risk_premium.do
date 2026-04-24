/*
Purpose: Generate Table B3 - Robustness on risk premium results
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

global ANALYSIS_DERIVED 			"datastore/derived/analysis"
global TABLES						"source/tables/raw"

* ===========================================================================
* Regression specifications
* ===========================================================================

** Fixed effects
global NO_FE							noabsorb
global ALL_FE							absorb(country_id year)
global COUNTRY_REG_YEAR					absorb(country_id year#e_regionpol)
global COUNTRY_REGIME_REGION_YEAR 		absorb(country_id year#region#L_autocracy)

** Clustering of SEs
global CLUSTER_VARS     vce(cluster country_id year)

** Controls
global CC log_ggdc_gdppc_i log_ggdc_gdppc_i_g v2x_clphy L.v2x_clphy log_all_cpi_g
global EC financial_crisis at_war default recession govt_head_death assas_succ assas_attempt md_high_action coup_detat

** Other globals
global head "\begin{tabular}{@{}p{1.2cm}p{1.2cm}@{}}"
global foot "\end{tabular}"
global fill "& & & & & &"
global dist1 -2 5
global dist2 -5 -3

* ===========================================================================
* Main execution logic
* ===========================================================================

program define main

	use "${ANALYSIS_DERIVED}/section_3_data.dta", clear

    create_panel_a_vars
    create_panel_b_vars
    create_panel_c_vars

    run_all_regressions	

end

* ===========================================================================
* Prepare variables
* ===========================================================================

program create_panel_a_vars

	** Row 1: ERT democratizations
	gen dem_ep_start = 1 if dem_ep == 1 & L.dem_ep == 0
	replace dem_ep_start = 0 if dem_ep_start == .
	
	gen dem_ep_minus_start = dem_ep_start
	replace dem_ep_minus_start = 0 if adverse_event2 == 1
	
	** Row 2: Index growth rate
	gen d_vdem_elect_g = (vdem_elect - L.vdem_elect)/L.vdem_elect
	sum d_vdem_elect_g if combo_dem == 1
	replace d_vdem_elect_g = d_vdem_elect_g/(r(mean)*8.5)
	replace d_vdem_elect_g = 0 if adverse_event2 == 1
	
	** Row 3: Index difference
	gen d_vdem_elect = D.vdem_elect
	sum d_vdem_elect if combo_dem == 1
	gen d_vdem_elect_std = d_vdem_elect/(r(mean)*8.5)
	replace d_vdem_elect_std = 0 if adverse_event2 == 1

	** Row 4: Top 10th percentile index jump
	sum d_vdem_elect, d
	gen dem_jump_large = 1 if d_vdem_elect > `r(p90)' & d_vdem_elect != .
	replace dem_jump_large = 0 if dem_jump_large == .

	gen dem_jump_large_minus = dem_jump_large
	replace dem_jump_large_minus = 0 if adverse_event2 == 1

	** Row 5: Lindberg et al. (2018) democratization start
	gen vod_demo_start = 1 if vod_demo == 1 & L.vod_demo == 0
	replace vod_demo_start = 0 if vod_demo_start == .
	
	gen vod_demo_minus_start = vod_demo_start
	replace vod_demo_minus_start = 0 if adverse_event2 == 1
	
	** Row 6: Acemoglu et al. (2019) democratization start
	replace acemoglu_dem = 0 if year >= 1960 & year <= 2010 & acemoglu_dem == .

	gen acemoglu_dem_start = 1 if acemoglu_dem == 1 & L.acemoglu_dem == 0
	replace acemoglu_dem_start = 0 if acemoglu_dem_start == . & acemoglu_dem != .

	gen acemoglu_dem_minus_start = acemoglu_dem_start
	replace acemoglu_dem_minus_start = 0 if adverse_event2 == 1  & acemoglu_dem_start != .

	gen acemoglu_dem_extend = autocracy == 0 & e_p_polity > 0
	replace acemoglu_dem_extend = . if e_p_polity < -10 | e_p_polity == . | autocracy == .

	gen acemoglu_dem_extend_start = 1 if acemoglu_dem_extend == 1 & L.acemoglu_dem_extend == 0
	replace acemoglu_dem_extend_start = 0 if acemoglu_dem_extend_start == .

	gen ace_minus_start = acemoglu_dem_minus_start
	replace ace_minus_start = 1 if acemoglu_dem_extend_start == 1 & adverse_event2 == 0 & year < 1960
	replace ace_minus_start = 0 if ace_minus_start == .

	sum log_all_div_yld_5yr if ace_minus_start == 1 // 32 episodes which have dividend yield data
	save_estimate, key("acemoglu_democratizations") value(`r(N)') file("tableB3")

end

program create_panel_b_vars

	gen log_all_min_max = .
	gen log_all_max_max = .
	foreach var in gfd jst factset ibes gfd_lse {
		rangestat (max) log_`var'_div_yld, interval(year $dist1) by(country_id)
		rangestat (min) log_`var'_div_yld, interval(year $dist2) by(country_id)
		gen log_`var'_min_max = log_`var'_div_yld_max - log_`var'_div_yld_min

		gen temp = log_`var'_div_yld
		rangestat (max) temp, interval(year $dist2) by(country_id)
		gen log_`var'_max_max = log_`var'_div_yld_max - temp_max
		drop temp temp_max

		replace log_all_min_max = log_`var'_min_max if log_all_min_max == .
		replace log_all_max_max = log_`var'_max_max if log_all_max_max == .

	}

	* Create maximum 5-year change in log dividend yields
	rangestat (max) log_all_div_yld_5yr, interval(year -1 1) by(country_id)

	* Use log_all_div_yld_1yr sample for Panel B regressions
	foreach var in log_all_div_yld_4yr log_all_div_yld_3yr log_all_div_yld_2yr log_all_div_yld_1yr log_all_min_max log_all_max_max log_all_div_yld_5yr_max log_gfd_div_yld {
		replace `var' = . if log_all_div_yld_5yr == .
	}

	* Create first 3 years of democratization for level of dividend yield
	gen combo_dem_minus_first_3 = combo_dem_minus_start
	replace combo_dem_minus_first_3 = 1 if L.combo_dem_minus_start == 1
	replace combo_dem_minus_first_3 = 1 if L2.combo_dem_minus_start == 1

end

program define create_panel_c_vars

	** Discount rate and cashflow news
	winsor2 cf_news_eq_tr dr_news_eq_tr, replace
	reg cf_news_eq_tr dr_news_eq_tr
	predict cf_news_eq_tr_resid, residuals
	cap drop cum_dr_news_eq_tr_alt cum_cf_news_eq_tr_alt
	gen cum_dr_news_eq_tr_alt = L.dr_news_eq_tr + dr_news_eq_tr + F.dr_news_eq_tr
	gen cum_cf_news_eq_tr_alt = L.cf_news_eq_tr_resid + cf_news_eq_tr_resid + F.cf_news_eq_tr_resid
	
	** PE ratio
	gen log_gfd_pe = log(gfd_pe)

	gen gfd_cape_ratio_all = gfd_cape_5yr
	replace gfd_cape_ratio_all = gfd_cape_3yr if gfd_cape_ratio_all == .
	replace gfd_cape_ratio_all = gfd_cape_7yr if gfd_cape_ratio_all == .
	gen log_gfd_cape_ratio_all = log(gfd_cape_ratio_all)

	gen log_gfd_pe_5yr = log_gfd_cape_ratio_all - L5.log_gfd_cape_ratio_all
	replace log_gfd_pe_5yr = log_gfd_pe - L5.log_gfd_pe if log_gfd_pe_5yr == .

	** Equity volatility
	cap drop all_exc_ret_sd all_exc_ret_sd_f5yr
	rangestat (sd) all_exc_ret, interval(year -10 0) by(country_id)
	gen all_exc_ret_sd_f5yr = F4.all_exc_ret_sd - L.all_exc_ret_sd

	** Corporate bond yields
	gen log_gfd_corp_bond_yield_5yr = log(gfd_corp_bond_yield) - log(L5.gfd_corp_bond_yield)
	sum log_gfd_corp_bond_yield_5yr if combo_dem_minus_start == 1 // 11 episodes which have corporate bond yield data
	save_estimate, key("corp_bond_democratizations") value(`r(N)') file("tableB3")

	** Create middle of democratization for excess returns regressions
	cap drop combo_dem_middle
	gen combo_dem_middle = combo_dem
	replace combo_dem_middle = 0 if combo_dem_start == 1
	replace combo_dem_middle = 0 if L.combo_dem_start == 1
	replace combo_dem_middle = 0 if combo_dem_end == 1
	replace combo_dem_middle = 0 if F.combo_dem_end == 1
	replace combo_dem_middle = 0 if F2.combo_dem_end == 1

	replace combo_dem_middle = . if log_all_div_yld_1yr == .


end

* ===========================================================================
* Run regressions and create table
* ===========================================================================

program define run_all_regressions

	local n = 1
	foreach dem in dem_ep_minus_start d_vdem_elect_g d_vdem_elect_std dem_jump_large_minus vod_demo_minus_start ace_minus_start {
		run_dem_regression `dem', reg_type(alt_dem)
		local row`n' &`r(col1)'	&`r(col2)' 	&`r(col3)'	&`r(col4)' 	&`r(col5)'	&`r(col6)'
		local ++n
	}

	foreach spec in log_all_div_yld_4yr log_all_div_yld_3yr log_all_div_yld_2yr log_all_div_yld_1yr log_all_min_max log_all_max_max log_all_div_yld_5yr_max  {
		run_dem_regression `spec', reg_type(alt_spec) oth_ind(combo_dem_minus_start)
		local row`n' &`r(col1)'	&`r(col2)' 	&`r(col3)'	&`r(col4)' 	&`r(col5)'	&`r(col6)'
		local ++n
	}

	run_dem_regression log_gfd_div_yld, reg_type(alt_spec) oth_ind(combo_dem_minus_first_3)
	local row`n' &`r(col1)'	&`r(col2)' 	&`r(col3)'	&`r(col4)' 	&`r(col5)'	&`r(col6)'
	local ++n

	foreach spec in cum_dr_news_eq_tr_alt cum_cf_news_eq_tr_alt log_gfd_pe_5yr all_exc_ret_sd_f5yr log_gfd_corp_bond_yield_5yr {
		run_dem_regression `spec', reg_type(alt_measure) oth_ind(combo_dem_minus_start)
		local row`n' &`r(col1)'	&`r(col2)' 	&`r(col3)'	&`r(col4)' 	&`r(col5)'	&`r(col6)'
		local ++n
	}

	run_dem_regression all_exc_ret, reg_type(alt_measure) oth_ind(combo_dem_middle) extra_control(d_vdem_elect dem_jump_large)
	local row`n' &`r(col1)'	&`r(col2)' 	&`r(col3)'	&`r(col4)' 	&`r(col5)'	&`r(col6)'

	texdoc init "${TABLES}/table_B3_risk_premium.tex", replace force

	tex 	\begin{tabularx}{\linewidth}{@{} l*{7}{Y} @{}} 
	tex 	\hline \hline
	tex   	&\multicolumn{1}{c}{(1)} & \multicolumn{1}{c}{(2)}&\multicolumn{1}{c}{(3)}&\multicolumn{1}{c}{(4)} &\multicolumn{1}{c}{(5)} &\multicolumn{1}{c}{(6)} \\ 
	tex		\hline \addlinespace[0.75ex]
	tex     \textit{A. Other democratization measures} 				${fill}	\\
	
	tex   	\hspace{0.5cm} (1) ERT only								`row1'	\\
	tex   	\hspace{0.5cm} (2) Index growth rate					`row2'	\\
	tex   	\hspace{0.5cm} (3) Index difference						`row3'	\\
	tex   	\hspace{0.5cm} (4) Large democratic jump				`row4'	\\
	tex   	\hspace{0.5cm} (5) Lindberg et. al (2018) 				`row5'	\\
	tex   	\hspace{0.5cm} (6) Acemoglu et. al (2019)				`row6'	\\
	tex     														${fill}	\\
	tex     \textit{B. Alternate dividend yield transformations} 	${fill}	\\
	tex 	\addlinespace[0.75ex]
	tex   	\hspace{0.5cm} (7) 4-year change						`row7'	\\
	tex   	\hspace{0.5cm} (8) 3-year change						`row8'	\\
	tex   	\hspace{0.5cm} (9) 2-year change						`row9'	\\
	tex   	\hspace{0.5cm} (10) 1-year change						`row10'	\\
	tex   	\hspace{0.5cm} (11) Peak-to-trough						`row11'	\\
	tex   	\hspace{0.5cm} (12) Peak-to-peak						`row12'	\\
	tex   	\hspace{0.5cm} (13) Maxmimum 5-year change				`row13'	\\
	tex   	\hspace{0.5cm} (14) Level of dividend yield				`row14'	\\
	tex     														${fill}	\\
	tex     \textit{C. Alternate risk premium measures}				${fill}	\\
	tex 	\addlinespace[0.75ex]
	tex   	\hspace{0.5cm} (15) VAR discount rate shocks			`row15'	\\
	tex   	\hspace{0.5cm} (16) VAR cash flow shocks				`row16'	\\
	tex   	\hspace{0.5cm} (17) 5-year log P/E ratio change			`row17'	\\
	tex   	\hspace{0.5cm} (18) Change in equity volatility			`row18'	\\
	tex   	\hspace{0.5cm} (19) log Corporate bond yields			`row19'	\\
	tex   	\hspace{0.5cm} (20) Average excess returns after start	`row20'	\\
	tex 	\hline \addlinespace[0.75ex]
	tex		Country FE          								&	No		&	No		&	Yes		&	Yes		&	Yes		&	Yes		\\
	tex		Year FE             								&	No		&	No		&	Yes		&	No		&	No		&	No		\\
	tex		Region $\times$ Year FE								&	No		&	No		&	No		&	Yes		&	No		&	No		\\
	tex		Continent $\times$ Regime $\times$ Year FE			&	No		&	No		&	No		&	No		&	Yes		&	Yes		\\
	tex		Event Controls      								&	No		&	Yes		&	Yes		&	Yes		&	Yes		&	Yes		\\
	tex		Other Controls     									&	No		&	No		&	No		&	No		&	No		&	Yes		\\
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

		save_estimate, key("`varlist'.column`col'.pe") value(`=_b[_C]') file("tableB3")
		save_estimate, key("`varlist'.column`col'.se") value(`=_se[_C]') file("tableB3")
        
        * Determine significance stars
        local stars ""
        if abs(`tstat') >= 2.576       local stars "\sym{***}"
        else if abs(`tstat') >= 1.96   local stars "\sym{**}"
        else if abs(`tstat') >= 1.645  local stars "\sym{*}"
        
        * Store formatted cell
        return local col`col' `"${head} `b'`stars' & (`t_fmt') ${foot}"'
        
        local ++col
    }

	/* JSON block end removed */
    
    cap drop _C 
	cap drop _L 
	cap drop _F
end

* ===========================================================================
* Run script
* ===========================================================================

main