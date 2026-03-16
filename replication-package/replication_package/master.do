clear all 

global path "/files/JPE-Miller-20240145/replication-package/replication_package"

cd "$path"

* DATA BUILD *

***** Building the 01 Events Data ***** 

do source/derived/01_events/01_create_valid_iso3_codes.do      // Check 
do source/derived/01_events/02_create_pre1900_dem.do           // Check
do source/derived/01_events/03_create_regime_change.do         // Check    
do source/derived/01_events/04_create_coup_detat.do	       // Check - commented out 12,13,14
do source/derived/01_events/05_create_financial_crises.do      // Check
do source/derived/01_events/06_create_sovereign_default.do     // Check
do source/derived/01_events/07_create_hog_deaths.do            // Check - commented out 13,14,15
do source/derived/01_events/08_create_international_crises.do  // Check - required ssc install carryforward
do source/derived/01_events/09_create_recession.do	       // Check
do source/derived/01_events/10_create_interstate_wars.do       // Check
do source/derived/01_events/11_create_intrastate_wars.do       // Check
do source/derived/01_events/12_create_extrastate_wars.do       // Check
do source/derived/01_events/13_create_militarized_disputes.do  // Check
do source/derived/01_events/14_combine_all_events.do           // Check, but allData.dta not found -- . !find . -name "allData.dta" returns nothing

***** Building the 02 Macro Political Data ***** 

do source/derived/02_macro_political/01_create_inflation.do             // Fail: needs allData.dta, also required ssc install winsor2 asreg
do source/derived/02_macro_political/02_create_pwt_data.do 	        // Check		
do source/derived/02_macro_political/03_create_gdp.do                   // Check
do source/derived/02_macro_political/04_create_vdem_datasets.do         // Check - required ssc install ftools require reghdfe 
do source/derived/02_macro_political/05_create_portion_catholic.do      // Check 
do source/derived/02_macro_political/06_create_gini.do                  // Check 
do source/derived/02_macro_political/07_create_tax_rates.do             // Check 
do source/derived/02_macro_political/08_create_gov_rev.do               // Check 
do source/derived/02_macro_political/09_create_economic_competition.do  // Check 
do source/derived/02_macro_political/10_create_fdi.do                   // Check 

***** Building the 03 Assets Data ***** 

do source/derived/03_assets/01_factset_clean.do 		        // Check - required ssc install gtools
do source/derived/03_assets/02_ibes_global_clean.do                     // Check
do source/derived/03_assets/03_create_dividend_yields.do 	        // Check 
do source/derived/03_assets/04_create_equity_returns.do 		// Check
do source/derived/03_assets/05_create_fixed_income.do 			// Check
do source/derived/03_assets/06_create_home_country_bond_rate.do 	// Check
do source/derived/03_assets/07_create_excess_and_abnormal_returns.do 	// Check - requires ssc install egenmore _gwtmean 
do source/derived/03_assets/08_create_cashflow_growth.do                // Fail - requires allData.dta 
do source/derived/03_assets/09_create_other_asset_market_variables.do   // Check
do source/derived/03_assets/10_create_return_news.do 			// Check

***** Building the 04 Merging Data ***** 

do source/derived/04_merging/01_create_section_3_and_5_data.do // Check - had to edit the save_estiamte.ado
do source/derived/04_merging/02_create_section_4_data.do       // Check 


* ANALYSIS *

***** Building the Main Tables ***** 

do source/analysis/main/tables/01_table_1_change_in_log_dividend_yield.do              // Check - had to edit the save_estiamte.ado
do source/analysis/main/tables/02_table_2_cashflow_growth.do                           // Check - had to edit the save_estiamte.ado
do source/analysis/main/tables/03_table_3_democratization_vs_other_political_risk.do   // Check - had to edit the save_estiamte.ado
do source/analysis/main/tables/04_table_4_revolution_risk.do                           // Check - had to edit the save_estiamte.ado
do source/analysis/main/tables/05_table_5_regional_waves_instrument.do                 // Fail - no Python installation found; minimum version required is 2.7.
do source/analysis/main/tables/06_table_6_balance_tests.do                             // Check
do source/analysis/main/tables/07_table_7_did_results.do                               // Check - had to edit the save_estiamte.ado
do source/analysis/main/tables/08_table_8_explicit_redistribution.do                   // Check - had to edit the save_estiamte.ado
do source/analysis/main/tables/09_table_9_implicit_redistribution.do                   // Check - had to edit the save_estiamte.ado
do source/analysis/main/tables/10_table_10_high_vs_low_redistribution_risk.do          // Check - had to edit the save_estiamte.ado
* python source/analysis/main/tables/11_table_11_model_calibration.py                  // 
* python source/analysis/main/tables/12_table_12_model_results.py                      // 

***** Building the Main Figures ***** 

do source/analysis/main/figures/01_figure_1_dividend_yield_event_study.do              // Check
do source/analysis/main/figures/02_figure_2_physical_human_capital.do                  // Check 
do source/analysis/main/figures/03_figure_3_gdp_consumption_distributions.do           // Check
do source/analysis/main/figures/04_figure_4_regional_waves.do                          // Check
do source/analysis/main/figures/05_figure_5_anti_regime_event_study.do                 // Check - had to edit the save_estiamte.ado
do source/analysis/main/figures/06_figure_6_returns_event_study.do                     // Check
do source/analysis/main/figures/07_figure_7_dividend_yield_coefficients_over_time.do   // Check
* python source/analysis/main/figures/08_figure_8_autocratization_figure.py            // 

***** Building the Appendix Tables ***** 

do source/analysis/appendix/tables/01_table_A1_summary_statistics.do                          // Check
do source/analysis/appendix/tables/02_table_B2_adverse_dividend_growth.do                     // Check 
do source/analysis/appendix/tables/03_table_B3_risk_premium.do                                // Check - had to edit the save_estiamte.ado
do source/analysis/appendix/tables/04_table_B4_macro_political_risk_measures.do               // Check 
do source/analysis/appendix/tables/05_table_B5_adverse_probability.do                         // Check 
do source/analysis/appendix/tables/06_table_B6_democratize_risk_measures.do                   // Check
do source/analysis/appendix/tables/07_table_C7_probability_democratize_post_vatican_ii.do     // Check - had to edit the save_estiamte.ado
do source/analysis/appendix/tables/08_table_C8_vatican_i.do                                   // Check - had to edit the save_estiamte.ado
do source/analysis/appendix/tables/09_table_C9_catholic_democracies.do                        // Check
do source/analysis/appendix/tables/10_table_C10_removing_outliers.do                          // Check - had to edit the save_estiamte.ado
do source/analysis/appendix/tables/11_table_C11_outlier_robust_weights.do                     // Check - had to edit the save_estiamte.ado
do source/analysis/appendix/tables/12_table_C12_global_capm.do                                // Check - had to edit the save_estiamte.ado
do source/analysis/appendix/tables/13_table_C13_no_rolling_beta.do                            // Check
do source/analysis/appendix/tables/14_table_C14_home_country_bonds.do                         // Check
do source/analysis/appendix/tables/15_table_C15_capital_gains_control.do                      // Check
do source/analysis/appendix/tables/16_table_D16_inequality_price_decline.do                   // Check
* python source/analysis/appendix/tables/17_table_G17_ert_democracy.py                        // 

***** Building the Appendix Figures ***** 

do source/analysis/appendix/figures/01_figure_B1_democracy_log_price.do                 // Check
do source/analysis/appendix/figures/04_figure_C4_cso_activity_vs_mobilizations.do       // Fail - file source/analysis/appendix/figures/04_figure_C4_cso_activity_vs_mobilizations.do not found
do source/analysis/appendix/figures/06_figure_C6_window_end_date.do                      // Fail - file source/analysis/appendix/figures/06_figure_C6_window_end_date.do not found
do source/analysis/appendix/figures/07_figure_C7_country_pair_1946_1976.do              // Fail - file source/analysis/appendix/figures/07_figure_C7_country_pair_1946_1976.do not found
do source/analysis/appendix/figures/08_figure_C8_country_pair_1939_1983.do              // Fail - file source/analysis/appendix/figures/08_figure_C8_country_pair_1939_1983.do not found
do source/analysis/appendix/figures/09_figure_C9_dividend_yield_event_study.do          // Fail - file source/analysis/appendix/figures/09_figure_C9_dividend_yield_event_study.do not found 
do source/analysis/appendix/figures/10_figure_D10_explicit_redistribute_event_study.do  // Fail - file source/analysis/appendix/figures/10_figure_D10_explicit_redistribute_event_study.do not found
do source/analysis/appendix/figures/11_figure_D11_democratization_end_price_response.do // Fail - file source/analysis/appendix/figures/11_figure_D11_democratization_end_price_response.do not found
do source/analysis/appendix/figures/12_figure_F13_sweden_case_study.do                   // Fail - file source/analysis/appendix/figures/12_figure_F13_sweden_case_study.do not found
do source/analysis/appendix/figures/13_figure_F14_france_case_study.do                   // Fail - file source/analysis/appendix/figures/13_figure_F14_france_case_study.do not found
