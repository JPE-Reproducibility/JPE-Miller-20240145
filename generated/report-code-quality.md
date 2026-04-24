## Code Quality

### Python

[CRITICAL] Hardcoded absolute path detected — the package will not run on another machine. (test_misc.py, line 56)
  → mocked_environ = {'PROGRAMFILES(X86)': 'C:/Program Files (x86)'}

[CRITICAL] Hardcoded absolute path detected — the package will not run on another machine. (model_final-checkpoint.ipynb, line 485)
  → "evalue": "[Errno 2] No such file or directory: '/Users/mjmill611/Max Miller Dropbox/Maxwell Miller/Current Projects/Finance History/Paper/Tables/model_results_new.tex'",

[CRITICAL] Hardcoded absolute path detected — the package will not run on another machine. (model_final-checkpoint.ipynb, line 492)
  → "\u001b[1;31mFileNotFoundError\u001b[0m: [Errno 2] No such file or directory: '/Users/mjmill611/Max Miller Dropbox/Maxwell Miller/Current Projects/Finance History/Paper/Tables/model_results_new.tex'"

[CRITICAL] Hardcoded absolute path detected — the package will not run on another machine. (model_final-checkpoint.ipynb, line 564)
  → "table_path = \"/Users/mjmill611/Max Miller Dropbox/Maxwell Miller/Current Projects/Finance History/Paper/Tables/model_results_new.tex\"\n",

[CRITICAL] Hardcoded absolute path detected — the package will not run on another machine. (model_final-checkpoint.ipynb, line 4909)
  → "fig_path = \"/Users/mjmill611/Max Miller Dropbox/Maxwell Miller/Current Projects/Finance History/Paper/Figures/auto_model.pdf\"\n",

### Stata

[CRITICAL] No random seed set — stochastic calls detected in stata code.
  → Triggers found at: estpost.ado:20, reghdfe.ado:199, reghdfe3.ado:4086 (and 2 more)

[CRITICAL] Hardcoded absolute path detected — the package will not run on another machine. (ftab.ado, line 173)
  → net install ftools, from("C:/git/ftools/src")

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (asreg.ado, line 454)
  → keep if _obs != .

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (esplot.ado, line 388)
  → drop if missing(t)

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (gcollapse.ado, line 764)
  → drop if 1

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (stacked_did.ado, line 39)
  → keep if inrange(_t_exit,-`tlags', `tlags')

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (stacked_did.ado, line 61)
  → drop if min_time != -`tlags' | max_time != `tlags'

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (01_figure_B1_democracy_log_price.do, line 39)
  → keep if log_all_div_yld != .

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (01_figure_B1_democracy_log_price.do, line 40)
  → drop if log_all_div_yld_5yr == .

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (01_figure_B1_democracy_log_price.do, line 41)
  → drop if L5.log_gfd_eq_prc_ind == . |  L5.log_gfd_div_index == .

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (01_figure_B1_democracy_log_price.do, line 170)
  → drop if t > `sy' | t < -`sy'

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (01_figure_B1_democracy_log_price.do, line 240)
  → drop if t > `sy' | t < -`sy'

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (01_figure_B1_democracy_log_price.do, line 309)
  → drop if t > `sy' | t < -`sy'

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (02_figure_B2_democracy_dividend_yield_specs.do, line 41)
  → keep if log_all_div_yld != .

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (02_figure_B2_democracy_dividend_yield_specs.do, line 42)
  → drop if log_all_div_yld_5yr == . // Restrict to table 1 sample

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (02_figure_B2_democracy_dividend_yield_specs.do, line 81)
  → drop if t > `sy' | t < -`sy'

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (02_figure_B2_democracy_dividend_yield_specs.do, line 183)
  → drop if t > `sy' | t < -`sy'

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (05_figure_C5_window_end_date.do, line 39)
  → keep if year >= 1939 & year <= 1983

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (06_figure_C6_country_pair_1946_1976.do, line 37)
  → keep if year >= 1939 & year <= 1983

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (06_figure_C6_country_pair_1946_1976.do, line 40)
  → keep if year >= 1946 & year <= 1976

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (06_figure_C6_country_pair_1946_1976.do, line 75)
  → drop if pe == .

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (06_figure_C6_country_pair_1946_1976.do, line 104)
  → drop if pe == .

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (07_figure_C7_country_pair_1939_1983.do, line 41)
  → keep if year >= 1939 & year <= 1983

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (07_figure_C7_country_pair_1939_1983.do, line 76)
  → drop if pe == .

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (07_figure_C7_country_pair_1939_1983.do, line 106)
  → drop if pe == .

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (08_figure_C8_dividend_yield_event_study.do, line 50)
  → keep if year >= 1946 & year <= 1976

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (08_figure_C8_dividend_yield_event_study.do, line 98)
  → drop if log_all_div_yld_avg3 == .

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (08_figure_C8_dividend_yield_event_study.do, line 108)
  → keep if autSample2 == 1

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (10_figure_D10_democratization_end_price_response.do, line 73)
  → keep if log_all_div_yld_1yr != .

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (11_figure_F12_sweden_case_study.do, line 34)
  → keep if gfd_div_yld != .

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (11_figure_F12_sweden_case_study.do, line 36)
  → keep if year >= $START_YEAR & year <= $END_YEAR & country == "SWE"

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (12_figure_F13_france_case_study.do, line 34)
  → keep if gfd_div_yld != .

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (12_figure_F13_france_case_study.do, line 36)
  → keep if year >= $START_YEAR & year <= $END_YEAR & country == "FRA"

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (00_stacked_did_dividend_yields.do, line 34)
  → keep if log_all_div_yld != .

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (00_stacked_did_dividend_yields.do, line 51)
  → keep if inrange(_t_exit,-5, 5)

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (00_stacked_did_ik.do, line 34)
  → keep if log_IK != .

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (00_stacked_did_ik.do, line 65)
  → keep if inrange(_t_exit,-5, 5)

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (03_figure_B3_democracy_IK_specs.do, line 97)
  → drop if t > `sy' | t < -`sy'

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (03_figure_B3_democracy_IK_specs.do, line 222)
  → drop if t > `sy' | t < -`sy'

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (04_table_B4_macro_political_risk_measures.do, line 90)
  → keep if log_all_div_yld_5yr != .

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (05_table_B5_adverse_probability.do, line 31)
  → keep if log_all_div_yld_5yr != .

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (05_table_B5_adverse_probability.do, line 43)
  → drop if country_id == .

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (05_table_B5_adverse_probability.do, line 53)
  → drop if vdem_elect == .

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (05_table_B5_adverse_probability.do, line 54)
  → drop if year < 1900 // No autocratization data before 1900

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (05_table_B5_adverse_probability.do, line 74)
  → drop if has_eq_data == .

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (05_table_B5_adverse_probability.do, line 86)
  → keep if market_loss == 1

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (06_table_B6_democratize_risk_measures.do, line 62)
  → keep if year >= 1918

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (07_table_C7_probability_democratize_post_vatican_ii.do, line 39)
  → keep if autocracy == 1

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (07_table_C7_probability_democratize_post_vatican_ii.do, line 40)
  → keep if year < 1990 & year > 1946

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (08_table_C8_vatican_i.do, line 44)
  → keep if year >= 1844 & year <= 1890

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (08_table_C8_vatican_i.do, line 59)
  → keep if any_capm_unexp2 > 0

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (08_table_C8_vatican_i.do, line 60)
  → keep if maj_cath_auto2 != .

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (09_table_C9_catholic_democracies.do, line 46)
  → keep if year >= 1939 & year <= 1983

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (10_table_C10_removing_outliers.do, line 48)
  → keep if year >= 1939 & year <= 1983

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (11_table_C11_outlier_robust_weights.do, line 46)
  → keep if year >= 1939 & year <= 1983

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (12_table_C12_global_capm.do, line 46)
  → keep if year >= 1939 & year <= 1983

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (13_table_C13_no_rolling_beta.do, line 50)
  → keep if year >= 1939 & year <= 1983

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (13_table_C13_no_rolling_beta.do, line 59)
  → keep if e(sample)

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (14_table_C14_home_country_bonds.do, line 45)
  → keep if year >= 1939 & year <= 1983

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (15_table_C15_capital_gains_control.do, line 50)
  → keep if year >= 1939 & year <= 1983

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (16_table_D16_inequality_price_decline.do, line 51)
  → drop if log_all_div_yld_1yr == .

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (01_figure_1_dividend_yield_event_study.do, line 34)
  → keep if log_all_div_yld != .

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (01_figure_1_dividend_yield_event_study.do, line 35)
  → drop if log_all_div_yld_5yr == . // Restrict to table 1 sample

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (01_figure_1_dividend_yield_event_study.do, line 66)
  → drop if t > `sy' | t < -`sy'

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (02_figure_2_physical_human_capital.do, line 67)
  → drop if t > `sy' | t < -`sy'

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (05_figure_5_anti_regime_event_study.do, line 34)
  → drop if maj_cath_auto == .

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (05_figure_5_anti_regime_event_study.do, line 42)
  → keep if autocracy == 1

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (05_figure_5_anti_regime_event_study.do, line 126)
  → keep if year >= 1940 & year <= 1989

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (06_figure_6_returns_event_study.do, line 48)
  → keep if year <= ${END_YEAR} & year >= ${START_YEAR} & autSample2 == 1

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (02_table_2_cashflow_growth.do, line 86)
  → keep if e(sample) == 1

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (06_table_6_balance_tests.do, line 34)
  → keep if year >= 1946 & year <= 1958

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (07_table_7_did_results.do, line 46)
  → keep if year >= 1939 & year <= 1983

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (10_table_10_high_vs_low_redistribution_risk.do, line 48)
  → keep if $OUTCOME != .

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (02_create_pre1900_dem.do, line 76)
  → keep if country == "`country'"

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (03_create_regime_change.do, line 63)
  → keep if year >= $START_YEAR & year <= $END_YEAR

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (03_create_regime_change.do, line 112)
  → keep if dem_ep == 1

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (03_create_regime_change.do, line 122)
  → keep if aut_ep == 1

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (03_create_regime_change.do, line 146)
  → keep if dem == 1 & L.dem == 0

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (03_create_regime_change.do, line 179)
  → keep if regime_change == 1

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (04_create_coup_detat.do, line 35)
  → keep if coup_detat == 1

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (04_create_coup_detat.do, line 37)
  → keep if year >= $START_YEAR & year <= $END_YEAR

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (05_create_financial_crises.do, line 40)
  → keep if year >= $START_YEAR & year <= $END_YEAR

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (05_create_financial_crises.do, line 60)
  → keep if jst_financial_crisis == 1

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (06_create_sovereign_default.do, line 59)
  → keep if default == 1

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (06_create_sovereign_default.do, line 60)
  → keep if year >= $START_YEAR & year <= $END_YEAR

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (07_create_hog_deaths.do, line 51)
  → keep if govt_head_death == 1 | assas_attempt == 1

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (07_create_hog_deaths.do, line 53)
  → keep if year >= $START_YEAR & year <= $END_YEAR

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (08_create_international_crises.do, line 48)
  → keep if year >= $START_YEAR & year <= $END_YEAR

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (08_create_international_crises.do, line 65)
  → drop if year1 == .

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (08_create_international_crises.do, line 87)
  → drop if year == .

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (09_create_recession.do, line 33)
  → keep if year >= $START_YEAR & year <= $END_YEAR

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (10_create_interstate_wars.do, line 33)
  → drop if ccode == .

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (10_create_interstate_wars.do, line 70)
  → keep if year >= $START_YEAR & year <= $END_YEAR

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (11_create_intrastate_wars.do, line 33)
  → drop if ccode == .

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (11_create_intrastate_wars.do, line 45)
  → drop if ccode == .

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (11_create_intrastate_wars.do, line 82)
  → keep if year >= $START_YEAR & year <= $END_YEAR

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (12_create_extrastate_wars.do, line 33)
  → drop if ccode == .

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (12_create_extrastate_wars.do, line 45)
  → drop if ccode == .

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (12_create_extrastate_wars.do, line 80)
  → keep if year >= $START_YEAR & year <= $END_YEAR

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (13_create_militarized_disputes.do, line 42)
  → drop if stateabb == ""

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (13_create_militarized_disputes.do, line 67)
  → keep if year >= $START_YEAR & year <= $END_YEAR

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (01_create_inflation.do, line 72)
  → keep if year >= $START_YEAR & year <= $END_YEAR

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (02_create_pwt_data.do, line 32)
  → drop if hc == . & rconna == .

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (02_create_pwt_data.do, line 37)
  → drop if comp_sh == .

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (02_create_pwt_data.do, line 57)
  → keep if year >= $START_YEAR & year <= $END_YEAR

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (03_create_gdp.do, line 82)
  → keep if year >= $START_YEAR & year <= $END_YEAR

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (04_create_vdem_datasets.do, line 69)
  → keep if year >= $START_YEAR & year <= $END_YEAR

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (04_create_vdem_datasets.do, line 77)
  → drop if vdem_resource_inequality == .

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (04_create_vdem_datasets.do, line 78)
  → keep if year >= $START_YEAR & year <= $END_YEAR

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (04_create_vdem_datasets.do, line 151)
  → keep if year >= $START_YEAR & year <= $END_YEAR

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (05_create_portion_catholic.do, line 71)
  → keep if year >= $DID_START_YEAR & year <= $DID_END_YEAR

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (05_create_portion_catholic.do, line 92)
  → keep if country == "CHN"

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (06_create_gini.do, line 41)
  → keep if year >= $START_YEAR & year <= $END_YEAR

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (06_create_gini.do, line 54)
  → keep if giniseries == 1

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (06_create_gini.do, line 63)
  → drop if year < first_year

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (06_create_gini.do, line 86)
  → drop if country == "Czechoslovakia"

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (07_create_tax_rates.do, line 44)
  → keep if year >= $START_YEAR & year <= $END_YEAR

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (08_create_gov_rev.do, line 45)
  → keep if year >= $START_YEAR & year <= $END_YEAR

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (08_create_gov_rev.do, line 77)
  → drop if vdem_debt_gdp == .

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (10_create_fdi.do, line 37)
  → drop if fdi_inflow == . & fdi_outflow == .

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (01_factset_clean.do, line 40)
  → drop if price < .5

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (01_factset_clean.do, line 42)
  → drop if FF_DPS < 0.01

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (01_factset_clean.do, line 43)
  → drop if FF_DPS == .

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (01_factset_clean.do, line 45)
  → drop if mkt_cap <= 0

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (01_factset_clean.do, line 48)
  → drop if region == ""

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (02_ibes_global_clean.do, line 41)
  → keep if date == max_date

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (02_ibes_global_clean.do, line 49)
  → drop if ibes_div_yld == 0 | ibes_div_yld > .5

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (03_create_dividend_yields.do, line 65)
  → keep if year >= $START_YEAR & year <= $END_YEAR

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (04_create_equity_returns.do, line 69)
  → keep if year >= $START_YEAR & year <= $END_YEAR

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (04_create_equity_returns.do, line 145)
  → drop if gfd_eq_tr == .

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (04_create_equity_returns.do, line 148)
  → drop if country == "BEL" & year >= 1897

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (04_create_equity_returns.do, line 149)
  → drop if country == "VEN" // use the longer index from previous download

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (05_create_fixed_income.do, line 78)
  → keep if year >= $START_YEAR & year <= $END_YEAR

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (05_create_fixed_income.do, line 121)
  → drop if gfd_bill_tr_ia == .

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (07_create_excess_and_abnormal_returns.do, line 44)
  → keep if any_all_exc_ret > 0

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (07_create_excess_and_abnormal_returns.do, line 59)
  → keep if year >= $START_YEAR & year <= $END_YEAR

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (10_create_return_news.do, line 110)
  → drop if year == .

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (10_create_return_news.do, line 136)
  → drop if ret_obs == 0 | $rt == .

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (01_create_section_3_and_5_data.do, line 55)
  → drop if country_id == .

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (01_create_section_3_and_5_data.do, line 122)
  → drop if has_div_yld < 5

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (01_create_section_3_and_5_data.do, line 143)
  → drop if combo_dem_id == .

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (01_create_section_3_and_5_data.do, line 145)
  → keep if D_vdem_elect > .1

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (02_create_section_4_data.do, line 67)
  → keep if included_countries == 1

[ADVISORY] Sample drop (`drop if` / `keep if`) not preceded by a comment within 2 lines — consider adding a comment explaining the criterion. (create_gfd_data.do, line 28)
  → drop if `name' == .

