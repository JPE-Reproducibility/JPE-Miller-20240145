/*
Purpose: Generate Table 5 - Instrumental variable estimation with regional democracy waves
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

global ANALYSIS_DERIVED 		"datastore/derived/analysis"
global TABLES 					"source/tables/raw"

* ===========================================================================
* Regression specifications
* ===========================================================================

** Main variables
global OUTCOME log_all_div_yld_5yr
global X vdem_elect_5yr
global Z Z_ace_vdem_5yr

** Controls
global CC F5_log_ggdc_gdppc_i F4_log_ggdc_gdppc_i F3_log_ggdc_gdppc_i F2_log_ggdc_gdppc_i F1_log_ggdc_gdppc_i log_ggdc_gdppc_i L1_log_ggdc_gdppc_i L2_log_ggdc_gdppc_i L3_log_ggdc_gdppc_i L4_log_ggdc_gdppc_i L5_log_ggdc_gdppc_i
global EC financial_crisis at_war default recession govt_head_death assas_succ assas_attempt md_high_action coup_detat icb_crisis

** Fixed effects
global NO_FE							noabsorb
global ALL_FE							absorb(country_id year)

** Clustering of SEs
global CLUSTER_VARS     vce(cluster country_id year)

* ===========================================================================
* Main execution logic
* ===========================================================================

use "${ANALYSIS_DERIVED}/section_3_data.dta"

ivreghdfe log_all_div_yld_5yr ($X = $Z) $EC $CC , $ALL_FE cluster(year) dkraay(5) first savefirst

local F_2: di %4.2fc e(first)[4,1]
local N_4: di %15.0fc e(N)

cap drop samp
gen samp = e(sample) 

ivreghdfe log_all_div_yld_5yr ($X = $Z) $EC $CC if samp == 1, cluster(year) dkraay(5) first savefirst
local F_1: di %4.2fc e(first)[4,1]
local N_3: di %15.0fc e(N)


ivreghdfe log_all_div_yld_5yr ($X = $Z) $EC $CC if samp == 1, cluster(year) dkraay(5)

local b_3: di %4.2fc _b[vdem_elect_5yr]
local s_3: di %4.2fc _se[vdem_elect_5yr]
save_estimate, key("column3.pe") value(`=_b[vdem_elect_5yr]') file("table5")
save_estimate, key("column3.se") value(`=_se[vdem_elect_5yr]') file("table5")
local t = `b_3'/`s_3'

if abs(`t') < 1.96 & abs(`t') >= 1.645 {
	local b_3: di "`b_3'\sym{*}"
}
else if abs(`t') >= 1.96 & abs(`t') < 2.576 {
	local b_3: di "`b_3'\sym{**}"
}
else if abs(`t') > 2.576 {
	local b_3: di "`b_3'\sym{***}"
}
else {
	local b_3: di "`b_3'\sym{*}"
}

ivreghdfe log_all_div_yld_5yr ($X = $Z) $EC $CC if samp == 1, $ALL_FE cluster(year) dkraay(5) ffirst savefirst

local b_4: di %4.2fc _b[vdem_elect_5yr]
local s_4: di %4.2fc _se[vdem_elect_5yr]
save_estimate, key("column4.pe") value(`=_b[vdem_elect_5yr]') file("table5")
save_estimate, key("column4.se") value(`=_se[vdem_elect_5yr]') file("table5")

local t = `b_4'/`s_4'

if abs(`t') < 1.96 & abs(`t') >= 1.645 {
	local b_4: di "`b_4'\sym{*}"
}
else if abs(`t') >= 1.96 & abs(`t') < 2.576 {
	local b_4: di "`b_4'\sym{**}"
}
else if abs(`t') > 2.576 {
	local b_4: di "`b_4'\sym{***}"
}
else {
	local b_4: di "`b_4'\sym{*}"
}

ivreghdfe log_all_div_yld_5yr Z_ace_vdem_5yr $EC $CC if samp == 1, cluster(year) dkraay(5)
local b_1: di %4.2fc _b[Z_ace_vdem_5yr]
local s_1: di %4.2fc _se[Z_ace_vdem_5yr]
local N_1: di %15.0fc e(N)
save_estimate, key("column1.pe") value(`=_b[Z_ace_vdem_5yr]') file("table5")
save_estimate, key("column1.se") value(`=_se[Z_ace_vdem_5yr]') file("table5")

local t = `b_1'/`s_1'

if abs(`t') < 1.96 & abs(`t') >= 1.645 {
	local b_1: di "`b_1'\sym{*}"
}
else if abs(`t') >= 1.96 & abs(`t') < 2.576 {
	local b_1: di "`b_1'\sym{**}"
}
else if abs(`t') > 2.576 {
	local b_1: di "`b_1'\sym{***}"
}
else {
	local b_1: di "`b_1'\sym{*}"
}


ivreghdfe log_all_div_yld_5yr Z_ace_vdem_5yr $EC $CC if samp == 1, $ALL_FE cluster(year) dkraay(5)
local b_2: di %4.2fc _b[Z_ace_vdem_5yr]
local s_2: di %4.2fc _se[Z_ace_vdem_5yr]
local N_2: di %15.0fc e(N)
save_estimate, key("column2.pe") value(`=_b[Z_ace_vdem_5yr]') file("table5")
save_estimate, key("column2.se") value(`=_se[Z_ace_vdem_5yr]') file("table5")

local t = `b_2'/`s_2'

if abs(`t') < 1.96 & abs(`t') >= 1.645 {
	local b_2: di "`b_2'\sym{*}"
}
else if abs(`t') >= 1.96 & abs(`t') < 2.576 {
	local b_2: di "`b_2'\sym{**}"
}
else if abs(`t') > 2.576 {
	local b_2: di "`b_2'\sym{***}"
}
else {
	local b_2: di "`b_2'\sym{*}"
}

reghdfe vdem_elect_5yr Z_ace_vdem_5yr $EC $CC if log_all_div_yld_5yr != ., $ALL_FE cluster(year)
predict vdem_elect_5yr_pred, xb
sum vdem_elect_5yr_pred, d // Largest predicted change in democratization index is approximately .24
save_estimate, key("max_fitted_value") value(`r(max)') file("table5")

texdoc init "${TABLES}/table_5_regional_waves_instrument.tex", replace force

tex 	\begin{tabularx}{\linewidth}{@{} l*{5}{Y} @{}} 
tex 	\hline \hline 
tex   	&\multicolumn{2}{c}{OLS} & \multicolumn{2}{c}{Two-stage least squares} \\ \cmidrule(lr){2-3} \cmidrule(lr){4-5}
tex   	&\multicolumn{1}{c}{(1)} & \multicolumn{1}{c}{(2)}&\multicolumn{1}{c}{(3)}&\multicolumn{1}{c}{(4)}	 \\ 
tex		\hline \addlinespace[0.75ex]
tex   	5-year regional democracy index change					& `b_1'		& `b_2'		&`b_3' 		&`b_4'		\\
tex   															&(`s_1')	&(`s_2')	&(`s_3') 	&(`s_4')	\\
tex 	\hline \addlinespace[0.75ex]
tex		Country FE          									&	No		&	Yes		&	No		&	Yes		\\
tex		Year FE             									&	No		&	Yes		&	No		&	Yes		\\
tex		Event Controls      									&	Yes		&	Yes		&	Yes		&	Yes		\\
tex		Other Controls     										&	Yes		&	Yes		&	Yes		&	Yes		\\
tex		F-statistic     										&			&			&	`F_1'	&	`F_2'	\\
tex		Observations     										&	`N_1'	&	`N_2'	&	`N_3'	&	`N_4'	\\
tex		\bottomrule
tex		\end{tabularx}
