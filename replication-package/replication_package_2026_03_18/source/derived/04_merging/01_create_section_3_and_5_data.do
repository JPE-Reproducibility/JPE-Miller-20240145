/*
Purpose: Create section 3 analysis data
Primary author: Max Miller
Date: 12-02-2025
Details: Merging events data drops returns for BMU who do not have sufficient 
    return data to be included in analysis anyway. Merging autocracy info drops
    CDR, KSV, and TMP who are not included in the analysis anyway.
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

global ANALYSIS_DERIVED "datastore/derived/analysis"
global ASSETS_DERIVED "datastore/derived/assets"
global MACRO_POLITICAL_DERIVED "datastore/derived/macro_political"
global EVENTS_DERIVED "datastore/derived/events"
global TABLES "source/tables"

* ===========================================================================
* Main execution logic
* ===========================================================================

program define main
	
	use "${EVENTS_DERIVED}/all_events.dta", clear
    merge 1:1 country year using "${ASSETS_DERIVED}/all_div_yld.dta", nogen
	merge 1:1 country year using "${ASSETS_DERIVED}/all_equity_returns.dta", nogen
	merge 1:1 country year using "${ASSETS_DERIVED}/all_fixed_income.dta", nogen
	merge 1:1 country year using "${ASSETS_DERIVED}/all_cashflow_growth.dta", nogen
    merge 1:1 country year using "${ASSETS_DERIVED}/other_asset_market_variables.dta", nogen
    merge 1:1 country year using "${ASSETS_DERIVED}/all_excess_and_abnormal_returns.dta", nogen
    merge 1:1 country year using "${ASSETS_DERIVED}/campbell_1991_var_shocks.dta", nogen
    merge 1:1 country year using "${MACRO_POLITICAL_DERIVED}/real_gdp.dta", nogen
    merge 1:1 country year using "${MACRO_POLITICAL_DERIVED}/all_inflation.dta", nogen
	merge 1:1 country year using "${MACRO_POLITICAL_DERIVED}/investment_capital_ratio.dta", nogen
	merge 1:1 country year using "${MACRO_POLITICAL_DERIVED}/fdi_clean.dta", nogen
	merge 1:1 country year using "${MACRO_POLITICAL_DERIVED}/tax_rates.dta", nogen
	merge 1:1 country year using "${MACRO_POLITICAL_DERIVED}/gini_coefficients.dta", nogen
    merge 1:1 country year using "${MACRO_POLITICAL_DERIVED}/democracy_index_and_regime_info.dta", nogen    
    merge 1:1 country year using "${MACRO_POLITICAL_DERIVED}/physical_and_political_violence.dta", nogen
    merge 1:1 country year using "${MACRO_POLITICAL_DERIVED}/anti_system_cso_activity_and_mobilizations.dta", nogen    
	merge 1:1 country year using "${MACRO_POLITICAL_DERIVED}/economic_competition.dta", nogen
	merge 1:1 country year using "${MACRO_POLITICAL_DERIVED}/corruption_and_bribery.dta", nogen
	merge m:1 country using "${MACRO_POLITICAL_DERIVED}/regions.dta", nogen
	sort country_id year
	drop if country_id == .
	
	* Table 2 outcome variables
	gen log_ggdc_gdppc_f5yr = (F5.log_ggdc_gdppc - log_ggdc_gdppc)/5
	gen log_all_div_f5yr = (log_all_div_g + F1.log_all_div_g + F2.log_all_div_g + F3.log_all_div_g + F4.log_all_div_g)/5
	
	* Figure 3 outcome variables
	gen log_rconna_g = log(rconna) - log(L.rconna)

	* Table 4 independent variables
	rangestat (max) v2csanmvch_4 v2csanmvch_6, interval(year 0 2) by(country_id)
	gen dem_cso = (v2csanmvch_4_max*v2csantimv_ord)
	gen interact_dem = dem_cso*combo_dem_minus_start
	gen rev_cso = (v2csanmvch_6_max*v2csantimv_ord)
	gen interact_rev = rev_cso*combo_dem_minus_start
	
	* Table 9 independent variables
    sum v2exbribe
    gen bribery_index = 1-(v2exbribe-`r(min)')/(`r(max)'-`r(min)')
	gen log_gfd_n_companies = log(gfd_n_companies)
    gen efi_5c_scale = efi_5c/10

	* Table 10 independent variables
    gen combo_dem_minus_start_elite= impgroup_elite_max*combo_dem_minus_start
    gen combo_dem_minus_start_no_elite = (1-impgroup_elite_max)*combo_dem_minus_start
	
	* Create flag for whether a country has dividend yield data
	gen has_div_yld = 1 if gfd_div_yld != .
	replace has_div_yld = 1 if jst_div_yld != .
	replace has_div_yld = 1 if factset_div_yld != .
	replace has_div_yld = 1 if ibes_div_yld != .
	replace has_div_yld = 1 if gfd_lse_div_yld != .

	label_variables

    save "${ANALYSIS_DERIVED}/section_3_data.dta", replace

	create_paper_numbers
	create_appendix_numbers

end

program label_variables

	* Variable labels for tables
	lab var combo_dem_minus_start "Democratization start"
	lab var financial_crisis_start "Financial crisis start"
    lab var aut_ep_minus_start "Autocratization start"
    lab var L_political_crisis_minus_start "Regime change start"
    lab var icb_crisis_minus_start "International political crisis start"
	lab var interact_rev "Democratization start $\times$ Revolution CSO activity"
	lab var interact_dem "Democratization start $\times$ Democratic CSO activity"
    lab var combo_dem_minus_start_elite "High Redistribution Risk Democratization"
    lab var combo_dem_minus_start_no_elite "Low Redistribution Risk Democratization"
    lab var combo_dem "Democratization"
    lab var combo_dem_succ "Successful Democratization"
    lab var post_combo_dem10 "Post-Democratization (10-years)"
	lab var post_combo_dem_succ10 "Post-Successful Democratization (10-years)"
    lab var post_combo_dem20 "Post-Democratization (20-years)"
    lab var post_combo_dem_succ20 "Post-Successful Democratization (20-years)"
    
end

program create_paper_numbers

	preserve
	collapse (sum) has_div_yld, by(country)
	drop if has_div_yld < 5
	sum has_div_yld // Average country has 70 years of dividend yield data
	save_estimate, key("avg_div_yld_years") value(`r(mean)') file("section3")
	restore

	sum log_all_div_yld_5yr if combo_dem_start == 1 // 85 episodes
	save_estimate, key("dem_episodes") value(`r(N)') file("section3")
	sum log_all_div_yld_5yr if combo_dem == 1 // 793 episode years
	save_estimate, key("dem_years") value(`r(N)') file("section3")
	sum log_all_div_yld_5yr if combo_dem_start == 1 & year <= 1900 // 9 episodes added before 1900
	save_estimate, key("dem_episodes_before_1900") value(`r(N)') file("section3")
	sum log_IK if combo_dem_start == 1 // 234 episodes
	save_estimate, key("dem_episodes_IK") value(`r(N)') file("section3")

	bys combo_dem_id : gen length = _N
	sum length if combo_dem_end == 1 & log_all_div_yld_5yr != . & year != 2018 // 9.25 years on average removing ongoing
	save_estimate, key("avg_dem_episode_length") value(`r(mean)') file("section3")
	sort country_id year

	preserve
	gen D_vdem_elect = D.vdem_elect
	drop if combo_dem_id == .
	collapse (sum) D_vdem_elect (max) has_div_yld, by(combo_dem_id)
	keep if D_vdem_elect > .1
	sum D_vdem_elect, d // Median democratization index change for a democratization is approximately .23
	save_estimate, key("median_dem_index_change") value(`r(p50)') file("section3")
	restore
	
    merge 1:1 country year using "${MACRO_POLITICAL_DERIVED}/catholic_pct_1816_2018.dta", nogen
	sum majority_catholic if year == 1963 & autocracy == 1 // 24% of autocracies are majority Catholic in 1963
	save_estimate, key("pct_aut_maj_catholic_1963") value(`r(mean)') file("section4")
	gen combo_dem_succ_start = 1 if combo_dem_succ == 1 & combo_dem_start == 1
	replace combo_dem_succ_start = 0 if combo_dem_succ_start == .
	gen maj_cath_auto = majority_catholic * autocracy
	sum maj_cath_auto if year >= 1963 & year <= 1983 & combo_dem_succ_start == 1 & autocracy == 1 // 60% of successful democratizations are majority Catholic autocracies
	save_estimate, key("pct_maj_catholic_succ_1963_1983") value(`r(mean)') file("section4")

	* 43% of democratizations end in success after 1900
	sum combo_dem_end_succ if combo_dem_end & year > 1900 & year != 2018
	save_estimate, key("pct_dem_succ") value(`r(mean)') file("section6")

	sum swiid_gini_mkt if combo_dem_succ_start == 1, d
	save_estimate, key("autocracy_gini") value(`r(mean)') file("section6")

	sum tax if combo_dem_succ_start == 1, d
	save_estimate, key("autocracy_tax") value(`r(mean)') file("section6")

	sum log_ggdc_gdppc_g if autocracy == 1
	save_estimate, key("autocracy_growth") value(`r(mean)') file("section6")
	save_estimate, key("autocracy_growth_sd") value(`r(sd)') file("section6")

	sum v2x_pubcorr if combo_dem_succ_start == 1, d
	save_estimate, key("autocracy_corrupt") value(`r(mean)') file("section6")

	gen all_div_yld = gfd_div_yld
	replace all_div_yld = jst_div_yld if all_div_yld == .
	sum all_div_yld if autocracy
	save_estimate, key("autocracy_div_yld") value(`r(mean)') file("section6")

end

program create_appendix_numbers

	gen check = log_gfd_div_yld_5yr
	sum check
	replace check = log_jst_div_yld_5yr if check == .
	replace check = log_factset_div_yld_5yr if check == .
	replace check = log_ibes_div_yld_5yr if check == .
	replace check = log_gfd_lse_div_yld_5yr if check == .
	sum check

	qui sum gfd_n_companies
	di "There are `r(N)' public company observations"
	qui tab country if gfd_n_companies != .
	di "There are `r(r)' countries with public company data"
	qui tab year if gfd_n_companies != .
	di "There are `r(r)' years with public company data"

	** PE ratio
	gen log_gfd_pe = log(gfd_pe)

	gen gfd_cape_ratio_all = gfd_cape_5yr
	replace gfd_cape_ratio_all = gfd_cape_3yr if gfd_cape_ratio_all == .
	replace gfd_cape_ratio_all = gfd_cape_7yr if gfd_cape_ratio_all == .
	gen log_gfd_cape_ratio_all = log(gfd_cape_ratio_all)

	sort country_id year

	gen log_gfd_pe_5yr = log_gfd_cape_ratio_all - L5.log_gfd_cape_ratio_all
	replace log_gfd_pe_5yr = log_gfd_pe - L5.log_gfd_pe if log_gfd_pe_5yr == .

	qui tab country if log_gfd_pe_5yr != .
	di "There are `r(r)' countries with PE ratio data"
	qui tab year if log_gfd_pe_5yr != .
	di "There are `r(r)' years with PE ratio data"

	qui tab country if gfd_corp_bond_yield != .
	di "There are `r(r)' countries with corporate bond yields"
	qui tab year if gfd_corp_bond_yield != .
	di "There are `r(r)' years with corporate bond yields"

	qui tab country if ggdc_gdppc != .
	di "There are `r(r)' countries with real GDP data"
	qui tab year if ggdc_gdppc != .
	di "There are `r(r)' years with real GDP data"

	qui tab country if rconna != .
	di "There are `r(r)' countries with real consumption data"
	qui tab year if rconna != .
	di "There are `r(r)' years with real consumption data"

	qui tab country if govt_rev_gdp != .
	di "There are `r(r)' countries with government revenue-GDP data"
	qui tab year if govt_rev_gdp != .
	di "There are `r(r)' years with government revenue-GDP data"

	qui tab country if tax != .
	di "There are `r(r)' countries with tax revenue-GDP data"
	qui tab year if tax != .
	di "There are `r(r)' years with tax revenue-GDP data"

	qui tab country if swiid_gini_mkt != .
	di "There are `r(r)' countries with Gini coefficient data"
	qui tab year if swiid_gini_mkt != .
	di "There are `r(r)' years with Gini coefficient data"

	qui tab country if financial_crisis == 1
	di "There are `r(r)' countries with financial crisis"
	qui tab year if financial_crisis == 1
	di "There are `r(r)' years with financial crisis"

	qui tab country if at_war == 1
	di "There are `r(r)' countries with war"
	qui tab year if at_war == 1
	di "There are `r(r)' years with war"

	qui tab country if md_high_action != 0
	di "There are `r(r)' countries with militarized dispute"
	qui tab year if md_high_action != 0
	di "There are `r(r)' years with militarized dispute"

	qui tab country if recession == 1
	di "There are `r(r)' countries with recession"
	qui tab year if recession == 1
	di "There are `r(r)' years with recession"

	qui tab country if govt_head_death == 1
	di "There are `r(r)' countries with head of government death"
	qui tab year if govt_head_death == 1
	di "There are `r(r)' years with head of government death"

	qui tab country if coup_detat == 1
	di "There are `r(r)' countries with coup"
	qui tab year if coup_detat == 1
	di "There are `r(r)' years with coup"

	* Dividend yield three years before democratization start is ~4.8
	sum gfd_div_yld if F3.combo_dem_start == 1

	* Dividend yield three years before democratization start is ~4.8
	sum D.vdem_elect if log_all_div_yld_5yr != . & D.vdem_elect >= .01


end


* ===========================================================================
* Run script
* ===========================================================================

main