/*
Purpose: create excess returns and risk-adjusted returns
Primary author: Max Miller
Date: 11-10-2025
*/


* ==============================================================================
* Housekeeping
* ==============================================================================

clear all
version 19
adopath + "source/utils/analysis"

* ==============================================================================
* Set globals
* ==============================================================================

global ASSETS_DERIVED				"datastore/derived/assets"
global CROSSWALKS					"datastore/raw/crosswalks"
global MACRO_POLITICAL_DERIVED		"datastore/derived/macro_political"

global START_YEAR = 1816
global END_YEAR = 2018

* ==============================================================================
* Main execution logic
* ==============================================================================

program main

	use "${ASSETS_DERIVED}/all_equity_returns.dta", clear
	merge 1:1 country year using "${ASSETS_DERIVED}/all_fixed_income.dta", nogen
	merge 1:1 country year using "${MACRO_POLITICAL_DERIVED}/real_gdp.dta", nogen
	merge m:1 year using "${ASSETS_DERIVED}/global_safe_asset.dta", nogen
	merge m:1 country using "${CROSSWALKS}/region_map.dta", nogen
	merge m:1 country using "${CROSSWALKS}/valid_iso3_codes.dta", keep(3) nogen // drops KSV and BMU
	sort country year
	
	create_excess_returns

	bys country: egen any_all_exc_ret = count(all_exc_ret)
	keep if any_all_exc_ret > 0

	egen country_id = group(country), label
	tsset country_id year
	
	create_gdp_share
	create_world_return
	create_regional_returns
	create_global_capm
	create_global_two_factor
	
	merge 1:1 country year using "${ASSETS_DERIVED}/home_country_bond_rate.dta", nogen
	create_home_country_returns
	create_home_country_two_factor
	
	keep if year >= $START_YEAR & year <= $END_YEAR
	
	keep country year all_eq_tr all_exc_ret log_all_exc_ret all_rf global_rf world_return regional_return mkt1 mkt2 capm_*

	save "${ASSETS_DERIVED}/all_excess_and_abnormal_returns.dta", replace
	
end

program create_excess_returns

	gen all_exc_ret = all_eq_tr - global_rf
	gen log_all_exc_ret = log(1+all_eq_tr) - log(1+global_rf)

end

program create_gdp_share

	bys year: egen world_gdp = sum(ggdc_gdp_i)
	gen gdp_share = ggdc_gdp_i / world_gdp

	sum year if gdp_share == .
	local no_missing = r(max) + 1

	gen temp = gdp_share if year == `no_missing'
	bys country: egen gdp_share_fill = min(temp)

	replace gdp_share = gdp_share_fill if gdp_share == .
	drop gdp_share_fill temp
	
end

program create_world_return

	cap bys year: egen world_return = wtmean(all_exc_ret), weight(gdp_share)
	cap gen mkt1 = world_return
	sort country year

end

program create_regional_returns

	cap bys year region: egen regional_return = wtmean(all_exc_ret), weight(gdp_share)
	cap gen mkt2 = regional_return
	sort country year
	
end

program create_global_capm
	
	bys country: asreg all_exc_ret mkt1, se fitted window( year 10) min(5)
	gen capm_alpha = _b_cons
	gen capm_exp = _b_mkt1*mkt1
	gen capm_unexp = all_exc_ret - capm_exp
	gen capm_R2_one_factor = _R2

	drop _*
	sort country year
	
end

program create_global_two_factor

	bys country: asreg all_exc_ret mkt1 mkt2, se fitted window( year 10) min(5)
	gen capm_exp2_mkt = _b_mkt1*mkt1
	gen capm_exp2_reg = _b_mkt2*mkt2
	gen capm_exp2_all = capm_exp2_mkt + capm_exp2_reg
	gen capm_unexp2 = all_exc_ret - capm_exp2_all
	gen capm_R2 = _R2

	drop _*
	sort country year

end

program create_home_country_returns

	gen all_exc_ret_alt = all_eq_tr - all_rf
	gen log_all_exc_ret_alt = log(1+all_eq_tr) - log(1+all_rf)

	cap bys year: egen world_return_hc = wtmean(all_exc_ret_alt), weight(gdp_share)
	cap gen mkt1_hc = world_return_hc
	sort country year
	
	cap bys year region: egen regional_return_hc = wtmean(all_exc_ret_alt), weight(gdp_share)
	cap gen mkt2_hc = regional_return_hc
	sort country year

end

program create_home_country_two_factor

    *** Run regressions
    by country: asreg all_exc_ret_alt mkt1_hc mkt2_hc, se fitted window( year 10) min(5)
    gen capm_exp1_alt = _b_mkt1_hc*mkt1_hc
    gen capm_exp2_alt = _b_mkt2_hc*mkt2_hc
    gen capm_unexp_alt = all_exc_ret_alt - capm_exp1_alt - capm_exp2_alt
    drop _*
    sort country year
	
end

* ==============================================================================
* Run script
* ==============================================================================

main
