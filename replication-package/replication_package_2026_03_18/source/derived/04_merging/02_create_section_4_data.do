/*
Purpose: Create data for the Vatican II DiD
Primary author: Max Miller
Contributors: Paul Kim
Date: 11-24-2025
Details: Merging events data drops returns for BMU who do not have sufficient 
    return data to be included in analysis anyway. Merging autocracy info drops
    CDR, KSV, and TMP who are not included in the analysis anyway.
*/

* ===========================================================================
* Housekeeping
* ===========================================================================

clear all
version 19

* ===========================================================================
* Set globals
* ===========================================================================

global ANALYSIS_DERIVED "datastore/derived/analysis"
global ASSETS_DERIVED "datastore/derived/assets"
global MACRO_POLITICAL_DERIVED "datastore/derived/macro_political"
global EVENTS_DERIVED "datastore/derived/events"

global START_YEAR = 1946
global END_YEAR = 1983

global TREATMENT_START_YEAR = 1959
global TREATMENT_END_YEAR = 1963

global MAJ_CATH_AUTO	ARG BOL BRA ECU ESP MEX PER PHL PRT
global NON_CATH_AUTO	EGY GHA HKG IDN KEN MMR MYS NGA SGP THA ZAF ZWE
global MAJ_CATH_DEMO	BEL FRA CHL IRL ITA VEN
global NON_CATH_DEMO	AUS CAN CHE DEU DNK FIN GBR IND JPN LKA NLD NOR NZL SWE TTO USA

global ALL_AUTO $MAJ_CATH_AUTO $NON_CATH_AUTO
global ALL_DEMO $MAJ_CATH_DEMO $NON_CATH_DEMO
global INCLUDED_COUNTRIES $MAJ_CATH_AUTO $NON_CATH_AUTO $MAJ_CATH_DEMO $NON_CATH_DEMO
    
* ===========================================================================
* Main execution logic
* ===========================================================================

program define main

    use "${ASSETS_DERIVED}/all_excess_and_abnormal_returns.dta", clear
    merge 1:1 country year using "${EVENTS_DERIVED}/all_events.dta", nogen
    merge 1:1 country year using "${MACRO_POLITICAL_DERIVED}/real_gdp.dta", nogen
    merge 1:1 country year using "${MACRO_POLITICAL_DERIVED}/democracy_index_and_regime_info.dta", nogen
    merge 1:1 country year using "${MACRO_POLITICAL_DERIVED}/gini_coefficients.dta", nogen
    merge 1:1 country year using "${MACRO_POLITICAL_DERIVED}/resource_inequality.dta", nogen
	merge 1:1 country year using "${ASSETS_DERIVED}/all_cashflow_growth.dta", nogen
	merge 1:1 country year using "${MACRO_POLITICAL_DERIVED}/gov_rev.dta", nogen
    merge 1:1 country year using "${MACRO_POLITICAL_DERIVED}/all_inflation.dta", nogen
    merge m:1 country using "${MACRO_POLITICAL_DERIVED}/catholic_pct_1939_1983.dta", nogen

    gen included_countries = 0
    foreach c in $INCLUDED_COUNTRIES {
        replace included_countries = 1 if country == "`c'"
    }

    * KOR and PRY have 20 or more but none in pre/post period
    tab country if included_countries != 1 & all_exc_ret != . & year >= 1946 & year <= 1983

    keep if included_countries == 1

    tsset country_id year

    * Re-examine this to see if it is still used.
    gen default_first_5 = default_start
    replace default_first_5 = 1 if L.default_start == 1
    replace default_first_5 = 1 if L2.default_start == 1
    replace default_first_5 = 1 if L3.default_start == 1
    replace default_first_5 = 1 if L4.default_start == 1

	
	** Majority catholic autocracies
    gen maj_cath_aut2 = 0
    foreach c in $MAJ_CATH_AUTO {
		replace maj_cath_aut2 = 1 if country == "`c'"
	}

    gen maj_cath_aut2_post = maj_cath_aut2 if year >= 1964 & year <= 1983
    replace maj_cath_aut2_post = 0 if year >= 1946 & year <= 1958
	
	* Fill in democratizations (and autocratization)
    replace maj_cath_aut2_post = 0 if country == "PRT" & year >= 1976
    replace maj_cath_aut2_post = 0 if country == "ESP" & year >= 1978
    replace maj_cath_aut2_post = 0 if country == "ECU" & year >= 1980
    replace maj_cath_aut2_post = 0 if country == "PER" & year >= 1981
    replace maj_cath_aut2_post = 1 if country == "CHL" & year >= 1973

    gen maj_cath_aut2_post_long = maj_cath_aut2_post
    replace maj_cath_aut2_post_long = 0 if year >= 1939 & year <= 1946 

	** Majority catholic democracies
    gen maj_cath_dem2 = 0
    foreach c in $MAJ_CATH_DEMO {
		replace maj_cath_dem2 = 1 if country == "`c'"
	}
	
    gen maj_cath_dem2_post = maj_cath_dem2 if year >= 1964 & year <= 1983
    replace maj_cath_dem2_post = 0 if year >= 1946 & year <= 1958

	* Fill in autocratization
    replace maj_cath_dem2_post = 0 if country == "CHL" & year >= 1973

    gen maj_cath_dem2_post_long = maj_cath_dem2_post
    replace maj_cath_dem2_post_long = 0 if year >= 1939 & year <= 1946 

	** Non-catholic autocracies
    gen non_cath_auto2 = 0
    foreach c in $NON_CATH_AUTO {
		replace non_cath_auto2 = 1 if country == "`c'"
	}
	
	** Get all autocracies
    gen autSample2 = 0
    foreach c in $ALL_AUTO {
		replace autSample2 = 1 if country == "`c'"
	}
	

	** Get all democracies
	gen demSample2 = 0
    foreach c in $ALL_DEMO {
		replace demSample2 = 1 if country == "`c'"
	}
	
	** Fill in missing GDP observations for NGA, TTO, and ZWE
	foreach c in NGA TTO ZWE {
		qui reg log_ggdc_gdppc_i F.log_ggdc_gdppc_i if country == "`c'"
		forvalues y = 1949(-1)1945 {
			di `y'
			replace log_ggdc_gdppc_i = _b[_cons]+_b[F.log_ggdc_gdppc_i]*F.log_ggdc_gdppc_i if year == `y' & country == "`c'" & log_ggdc_gdppc_i == .
		}
	}

    replace log_ggdc_gdppc_i_g = D.log_ggdc_gdppc_i

	
    save "${ANALYSIS_DERIVED}/section_4_data.dta", replace
end


* ===========================================================================
* Run script
* ===========================================================================

main