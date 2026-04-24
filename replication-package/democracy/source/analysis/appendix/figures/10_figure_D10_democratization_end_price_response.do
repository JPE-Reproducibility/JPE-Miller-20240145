/*
Purpose: Generate Figure D10 - Price response to successful vs. failed democratizations
Author: Max Miller
Date: 12-10-2025
*/

* ===========================================================================
* Housekeeping
* ===========================================================================

clear all
version 19
adopath ++ "source/utils/analysis"
set scheme s2color

* ===========================================================================
* Set globals
* ===========================================================================

global ANALYSIS_DERIVED         "datastore/derived/analysis"
global ASSETS_DERIVED 			"datastore/derived/assets"
global FIGURES 					"source/figures"

** Fixed effects
global NO_FE					noabsorb

** Clustering of SEs
global CLUSTER_VARS     		vce(cluster year)

global EC financial_crisis at_war default recession govt_head_death assas_succ assas_attempt md_high_action coup_detat

global CONF_INT = 1.645

* ===========================================================================
* Main execution logic
* ===========================================================================

program define main

    use "${ANALYSIS_DERIVED}/section_3_data.dta", clear

	gen rolling_log_eq_capgain_5yr_tot = (log_all_eq_capgain /// 
		+ L.log_all_eq_capgain ///
		+ L2.log_all_eq_capgain /// 
		+ L3.log_all_eq_capgain ///
		+ L4.log_all_eq_capgain )

	gen elite_support = inlist(v2regimpgroup,0,1,3)
	
	rangestat (max) vdem_regime, interval(year 0 5) by(country_id)
	rangestat (max) elite_support, interval(year 0 5) by(country_id)
    rangestat (min) vdem_regime, interval(year 0 5) by(country_id)
	rangestat (min) elite_support, interval(year 0 5) by(country_id)
	
	gen combo_dem_end_succ_ld = combo_dem_end_succ
	replace combo_dem_end_succ_ld = 0 if vdem_regime_max < 3 | elite_support_max == 1

	gen combo_dem_end_succ_oth = combo_dem_end_succ
	replace combo_dem_end_succ_oth = 0 if combo_dem_end_succ_ld == 1
	
    gen combo_dem_end_fail_aut = combo_dem_end_fail
    replace combo_dem_end_fail_aut = 0 if vdem_regime_min > 0 & elite_support_max == 0 & vdem_regime_min != .
	
	foreach var in combo_dem_end_succ combo_dem_end_fail combo_dem_end_succ_ld combo_dem_end_fail_aut combo_dem_end_succ_oth {
		forvalues i = 1(1)5 {
			gen F`i'_`var' = F`i'.`var'
			gen L`i'_`var' = L`i'.`var'
		}
	}
	
	bys combo_dem_id : egen type_ld = max(combo_dem_end_succ_ld)
	
	keep if log_all_div_yld_1yr != .
	
    create_price_response_plot 9
    create_ld_price_response_plot 9
	
	leads_lags combo_dem_end_succ_ld 4
    reghdfe rolling_log_eq_capgain_5yr_tot `leads_lags' $EC , $NO_FE $CLUSTER_VARS

	local b_ld = _b[L1_combo_dem_end_succ_ld]
	
	leads_lags combo_dem_end_succ_oth 4
    reghdfe rolling_log_eq_capgain_5yr_tot `leads_lags' $EC , $NO_FE $CLUSTER_VARS
	local b_oth = _b[L1_combo_dem_end_succ_oth]
	
	save_estimate, key("pe_ld") value(`b_ld') file("figureD10")
	save_estimate, key("pe_oth") value(`b_oth') file("figureD10")
	
	sum type_ld if combo_dem_end == 1 & combo_dem_succ == 1
	save_estimate, key("q") value(`r(mean)') file("figureD10")
	
	

end

* ===========================================================================
* Create price response plot
* ===========================================================================

program define create_price_response_plot
	args obs
	
    cap drop store_mat*
	leads_lags combo_dem_end_succ 4
    local leads_lags_succ = "`leads_lags'"
	leads_lags combo_dem_end_fail 4
    local leads_lags_fail = "`leads_lags'"

    reghdfe rolling_log_eq_capgain_5yr_tot `leads_lags_succ' `leads_lags_fail' $EC , $NO_FE $CLUSTER_VARS
    lincom combo_dem_end_fail - combo_dem_end_succ

    reghdfe rolling_log_eq_capgain_5yr_tot `leads_lags_succ' $EC , $NO_FE $CLUSTER_VARS
    mat temp_mat = r(table)
    mat store_mat = J(`obs',4,.)
    forvalues i = 1/`obs' {
        mat store_mat[`i',1] = `i'
        mat store_mat[`i',2] = temp_mat[1,`i']
        mat store_mat[`i',3] = temp_mat[1,`i'] - $CONF_INT*temp_mat[2,`i']
        mat store_mat[`i',4] = temp_mat[1,`i'] + $CONF_INT*temp_mat[2,`i']
    }
	
    reghdfe rolling_log_eq_capgain_5yr_tot `leads_lags_fail' $EC , $NO_FE $CLUSTER_VARS
    mat temp_mat = r(table)
    mat store_mat1 = J(`obs',4,.)
    forvalues i = 1/`obs' {
        mat store_mat1[`i',1] = `i'
        mat store_mat1[`i',2] = temp_mat[1,`i']
        mat store_mat1[`i',3] = temp_mat[1,`i'] - $CONF_INT*temp_mat[2,`i']
        mat store_mat1[`i',4] = temp_mat[1,`i'] + $CONF_INT*temp_mat[2,`i']
    }

    svmat store_mat
    svmat store_mat1

    cap label drop tplus
    cap label define tplus ///
        1 "t-4" ///
        2 "t-3" ///
        3 "t-2" ///
        4 "t-1" ///
        5 "t" /// 
        6 "t+1" ///
        7 "t+2" ///
        8 "t+3" ///
        9 "t+4" 
    label values store_mat1 tplus

    replace store_mat2 = store_mat2*100
    replace store_mat3 = store_mat3*100
    replace store_mat4 = store_mat4*100
    replace store_mat12 = store_mat12*100
    replace store_mat13 = store_mat13*100
    replace store_mat14 = store_mat14*100

    local labSize = "large"
    local lineWidth = 0.45
    two (rcap store_mat3 store_mat4 store_mat1, color(red%50) lw(`lineWidth')) ///
        (connected store_mat2 store_mat1, color(red) msymbol(s) lw(`lineWidth')) ///
        (rcap store_mat13 store_mat14 store_mat1, color(blue%50) lp(longdash) lw(`lineWidth')) ///
        (connected store_mat12 store_mat1, color(blue) lp(longdash) lw(`lineWidth')), ///
        xlabel(1(1)9, valuelabel nogrid labsize(`labSize')) graphregion(color(white)) ///
		ylabel(-60(15)60, nogrid labsize(`labSize')) yscale(r(-70 70)) ///
        xtitle("") bgcolor(white) ytitle("5-year equity price change (%)", size(`labSize')) ///
		yline(0, lw(.4)  lc(black)) ysize(2.5) ///
        legend(size(med) order(2 "Successful Democratization" 4 "Failed Democratization") nobox region(lcolor(white)) ring(0) position(7) rows(2))
    graph export "${FIGURES}/raw/figure_D10a_democratize_price_response_succ.pdf", replace
    drop store_mat*
end

* ===========================================================================
* Create LD price response plot
* ===========================================================================

program define create_ld_price_response_plot
	args obs

	leads_lags combo_dem_end_succ_ld 4
    reghdfe rolling_log_eq_capgain_5yr_tot `leads_lags' $EC , $NO_FE $CLUSTER_VARS
    mat temp_mat = r(table)
    mat store_mat = J(`obs',4,.)
    forvalues i = 1/`obs' {
        mat store_mat[`i',1] = `i'
        mat store_mat[`i',2] = temp_mat[1,`i']
        mat store_mat[`i',3] = temp_mat[1,`i'] - $CONF_INT*temp_mat[2,`i']
        mat store_mat[`i',4] = temp_mat[1,`i'] + $CONF_INT*temp_mat[2,`i']
    }

	leads_lags combo_dem_end_fail_aut 4
    reghdfe rolling_log_eq_capgain_5yr_tot `leads_lags' $EC , $NO_FE $CLUSTER_VARS
    mat temp_mat = r(table)
    mat store_mat1 = J(`obs',4,.)
    forvalues i = 1/`obs' {
        mat store_mat1[`i',1] = `i'
        mat store_mat1[`i',2] = temp_mat[1,`i']
        mat store_mat1[`i',3] = temp_mat[1,`i'] - $CONF_INT*temp_mat[2,`i']
        mat store_mat1[`i',4] = temp_mat[1,`i'] + $CONF_INT*temp_mat[2,`i']
    }

    svmat store_mat
    svmat store_mat1

    cap label drop tplus
    cap label define tplus ///
        1 "t-4" ///
        2 "t-3" ///
        3 "t-2" ///
        4 "t-1" ///
        5 "t" /// 
        6 "t+1" ///
        7 "t+2" ///
        8 "t+3" ///
        9 "t+4" 
    label values store_mat1 tplus

    replace store_mat2 = store_mat2*100
    replace store_mat3 = store_mat3*100
    replace store_mat4 = store_mat4*100
    replace store_mat12 = store_mat12*100
    replace store_mat13 = store_mat13*100
    replace store_mat14 = store_mat14*100

    local labSize = "large"
    local lineWidth = 0.45
    two (rcap store_mat3 store_mat4 store_mat1, color(red%50) lw(`lineWidth')) ///
        (connected store_mat2 store_mat1, color(red) msymbol(s) lw(`lineWidth')) ///
        (rcap store_mat13 store_mat14 store_mat1, color(blue%50) lp(longdash) lw(`lineWidth')) ///
        (connected store_mat12 store_mat1, color(blue) lp(longdash) lw(`lineWidth')), ///
        xlabel(1(1)9, valuelabel nogrid labsize(`labSize')) graphregion(color(white)) ///
		ylabel(-60(15)60, nogrid labsize(`labSize')) yscale(r(-70 70)) ///
        xtitle("") bgcolor(white) ytitle("5-year equity price change (%)", size(`labSize')) ///
		yline(0, lw(.4)  lc(black)) ysize(2.5) ///
        legend(size(med) order(2 "Liberal Democratization" 4 "Reversed Democratization") nobox region(lcolor(white)) ring(0) position(7) rows(2))
    graph export "${FIGURES}/raw/figure_D10b_democratize_price_response_ld.pdf", replace
    drop store_mat*

end

program define leads_lags
	args varname window
    
    local result ""
    forval i = `window'(-1)1 {
        local result `result' F`i'_`varname'
    }
    local result `result' `varname'
    forval i = 1/`window' {
        local result `result' L`i'_`varname'
    }
    
    c_local leads_lags `result'
end

* ===========================================================================
* Run script
* ===========================================================================

main