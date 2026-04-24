clear all
version 19
set scheme s2color
adopath ++ "source/utils/analysis"

* ===========================================================================
* Set globals
* ===========================================================================

global ANALYSIS_DERIVED 		"datastore/derived/analysis"
global FIGURES 					"source/figures"

* Different specifications
global SPEC1 "absorb(country_id year)"
global SPEC2 "absorb(country_id reg_year)"
global SPEC3 "absorb(country_id regime_region_year)"
global SPEC4 "controls($EC $CC) absorb(country_id regime_region_year)"

** Controls
global CC log_ggdc_gdppc_i log_ggdc_gdppc_i_5yr v2x_clphy v2x_clphy_5yr log_all_cpi_5yr
global EC at_war default recession govt_head_death assas_succ assas_attempt md_high_action coup_detat

* Event window parameters
global EVENT_LO = -5
global EVENT_HI = 5

* ===========================================================================
* Main execution logic
* ===========================================================================

use "${ANALYSIS_DERIVED}/section_3_data.dta", clear
gen log_all_div_yld = log_gfd_div_yld
replace log_all_div_yld = log_jst_div_yld if log_all_div_yld == .
keep if log_all_div_yld != .

tempfile original
save `original'

levelsof year if combo_dem_minus_start == 1, local(eventyear)
foreach eventyr of local eventyear {
    
    use `original', clear
    
    * Include yet-to-be-treated as controls, in addition to never treated
    gen dummy = (year == `eventyr') & (combo_dem_minus_start == 1)
    bysort country_id: egen treated = max(dummy)
    
    gen _t_exit = year - `eventyr'
    assert !missing(_t_exit)

    keep if inrange(_t_exit,-5, 5)	
    gen cohort = `eventyr'
        
    sort cohort country_id year 
    
    keep country_id year _t_exit cohort treated log_all_div_yld $EC $CC e_regionpol region L_autocracy
    
    tempfile cohort_`eventyr'
    save `cohort_`eventyr''
            
}

clear
foreach eventyr of local eventyear {
    append using `cohort_`eventyr''
}

egen time = group(_t_exit cohort)
egen i = group(country_id cohort)

bys i: egen total_obs = count(_t_exit)
bys i: egen min_obs = min(_t_exit)
bys i: egen max_obs = max(_t_exit)

sort i time

gen _d_shifted = (_t_exit + 5 + 1)	
xtset i time

reghdfe log_all_div_yld ib3._d_shifted##i.treated if min_obs <= -3 & max_obs >= 3, absorb(i time) cluster(country_id year)

reghdfe log_all_div_yld ib3._d_shifted##i.treated if min_obs <= -3 & max_obs >= 3, absorb(i time#e_regionpol) cluster(country_id year)

reghdfe log_all_div_yld ib3._d_shifted##i.treated if min_obs <= -3 & max_obs >= 3, absorb(i time#region#L_autocracy) cluster(country_id year)

reghdfe log_all_div_yld ib3._d_shifted##i.treated $EC $CC if min_obs <= -3 & max_obs >= 3, absorb(i time#region#L_autocracy) cluster(country_id year)