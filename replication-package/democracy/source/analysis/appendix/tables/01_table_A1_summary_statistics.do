/*
Purpose: Generate Table A1 - Summary statistics
Author: Max Miller
Date: 12-11-2025
*/

* ===========================================================================
* Housekeeping
* ===========================================================================

clear all
version 19


* ===========================================================================
* Set globals
* ===========================================================================

global ANALYSIS_DERIVED         "datastore/derived/analysis"
global EVENTS_DERIVED 			"datastore/derived/events"
global ASSETS_DERIVED 			"datastore/derived/assets"
global MACRO_POLITICAL_DERIVED 	"datastore/derived/macro_political"
global TABLES 					"source/tables/raw"

global head "\begin{tabular}{@{}p{1.2cm}p{1.2cm}@{}}"
global foot "\end{tabular}"

* ===========================================================================
* Main execution logic
* ===========================================================================

use "${ANALYSIS_DERIVED}/section_3_data.dta", clear

gen log_corp_bnd_yld = log(1+gfd_corp_bond_yield)

foreach var in gfd_div_yld log_all_eq_tr log_all_bond_rate log_corp_bnd_yld log_ggdc_gdp_g IK log_all_cpi_g {
	replace `var' = `var'*100
	sum `var', d
	local `var'_N:  di %9.0fc r(N)
	local `var'_mean:  di %4.2fc r(mean)
	local `var'_sd:  di %4.2fc r(sd)
	local `var'_25:  di %4.2fc r(p25)
	local `var'_50:  di %4.2fc r(p50)
	local `var'_75:  di %4.2fc r(p75)
	
	foreach t in mean sd 25 50 75 {
		local `var'_`t' ``var'_`t''\%
	} 
}

foreach var in gfd_pe gfd_n_companies ggdc_gdppc swiid_gini_mkt vdem_elect v2x_corr {
	sum `var', d
	local `var'_N:  di %9.0fc r(N)
	local `var'_mean: di %9.2fc r(mean)
	local `var'_sd:  di %9.2fc r(sd)
	local `var'_25:  di %9.2fc r(p25)
	local `var'_50:  di %9.2fc r(p50)
	local `var'_75:  di %9.2fc r(p75)
}

texdoc init "${TABLES}/table_A1_summary_statistics.tex", replace force

tex 	\begin{tabularx}{\linewidth}{@{} l*{7}{Y} @{}} 
tex 	\hline \hline
tex   	&\multicolumn{1}{c}{Observations} & \multicolumn{1}{c}{Mean}&\multicolumn{1}{c}{Std. Dev.}&\multicolumn{1}{c}{p25} &\multicolumn{1}{c}{Median} &\multicolumn{1}{c}{p75} \\ 
tex		\hline \addlinespace[0.75ex]
tex     \textit{A. Financial market data} 				&							&								&							&							&							&							\\
tex   	\hspace{0.5cm} (1) GFD dividend yields			&	`gfd_div_yld_N'			&	`gfd_div_yld_mean'			&	`gfd_div_yld_sd' 		&	`gfd_div_yld_25'		&	`gfd_div_yld_50'		&	`gfd_div_yld_75'		\\
tex   	\hspace{0.5cm} (2) Log equity return			&	`log_all_eq_tr_N'		&	`log_all_eq_tr_mean'		&	`log_all_eq_tr_sd'		&	`log_all_eq_tr_25'		&	`log_all_eq_tr_50'		&	`log_all_eq_tr_75'		\\
tex   	\hspace{0.5cm} (3) Price-earnings ratio			&	`gfd_pe_N'				&	`gfd_pe_mean'				&	`gfd_pe_sd'				& 	`gfd_pe_25'				&	`gfd_pe_50'				&	`gfd_pe_75'				\\
tex   	\hspace{0.5cm} (4) Log government bond yield	&	`log_all_bond_rate_N'	&	`log_all_bond_rate_mean'	&	`log_all_bond_rate_sd'	& 	`log_all_bond_rate_25'	&	`log_all_bond_rate_50'	&	`log_all_bond_rate_75'	\\
tex   	\hspace{0.5cm} (5) Log corporate bond yield		&	`log_corp_bnd_yld_N'	&	`log_corp_bnd_yld_mean'		&	`log_corp_bnd_yld_sd'	& 	`log_corp_bnd_yld_25'	&	`log_corp_bnd_yld_50'	&	`log_corp_bnd_yld_75'	\\
tex   	\hspace{0.5cm} (6) Publicly traded companies	&	`gfd_n_companies_N'		&	`gfd_n_companies_mean'		&	`gfd_n_companies_sd'	& 	`gfd_n_companies_25'	&	`gfd_n_companies_50'	&	`gfd_n_companies_75'	\\
tex		\addlinespace[0.75ex]
tex     \textit{B. Macroeconomic data} 					&							&								&							&							&							&							\\
tex   	\hspace{0.5cm} (7) Real GDP per capita			&	`ggdc_gdppc_N'			&	`ggdc_gdppc_mean'			&	`ggdc_gdppc_sd'			& 	`ggdc_gdppc_25'			&	`ggdc_gdppc_50'			&	`ggdc_gdppc_75'			\\
tex   	\hspace{0.5cm} (8) Log real GDP growth			&	`log_ggdc_gdp_g_N'		&	`log_ggdc_gdp_g_mean'		&	`log_ggdc_gdp_g_sd'		& 	`log_ggdc_gdp_g_25'		&	`log_ggdc_gdp_g_50'		&	`log_ggdc_gdp_g_75'		\\
tex   	\hspace{0.5cm} (9) Investment-capital ratio		&	`IK_N'					&	`IK_mean'					&	`IK_sd'					& 	`IK_25'					&	`IK_50'					&	`IK_75'					\\
tex   	\hspace{0.5cm} (10) Gini coefficient			&	`swiid_gini_mkt_N'		&	`swiid_gini_mkt_mean'		&	`swiid_gini_mkt_sd'		& 	`swiid_gini_mkt_25'		&	`swiid_gini_mkt_50'		&	`swiid_gini_mkt_75'		\\
tex   	\hspace{0.5cm} (11) Log inflation				&	`log_all_cpi_g_N'		&	`log_all_cpi_g_mean'		&	`log_all_cpi_g_sd'		& 	`log_all_cpi_g_25'		&	`log_all_cpi_g_50'		&	`log_all_cpi_g_75'		\\
tex		\addlinespace[0.75ex]
tex     \textit{C. Political institutions data}			&							&								&							&							&							&							\\
tex   	\hspace{0.5cm} (12) Electoral Democracy Index	&	`vdem_elect_N'			&	`vdem_elect_mean'			&	`vdem_elect_sd'			& 	`vdem_elect_25'			&	`vdem_elect_50'			&	`vdem_elect_75'			\\
tex   	\hspace{0.5cm} (13) Corruption Index			&	`v2x_corr_N'			&	`v2x_corr_mean'				&	`v2x_corr_sd'			& 	`v2x_corr_25'			&	`v2x_corr_50'			&	`v2x_corr_75'			\\
tex		\bottomrule
tex		\end{tabularx}

texdoc close