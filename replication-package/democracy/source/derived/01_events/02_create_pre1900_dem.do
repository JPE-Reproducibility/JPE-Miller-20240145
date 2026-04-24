/*
Purpose: create democracy variables for main paper and appendix
Primary author: Max Miller
Contributors: Paul Kim
Date: 11-24-2025
*/

* ==============================================================================
* Housekeeping
* ==============================================================================

clear all
version 19

* ==============================================================================
* Set globals
* ==============================================================================

global VDEM_ORIG			"datastore/raw/vdem/orig"
global VDEM_DATA			"datastore/raw/vdem/data"

* Set requirements for locating democratization episodes
global START_INCL = 0.01
global CUM_INCL = 0.10
global YEAR_TURN = 0.03
global CUM_TURN = 0.10
global STASIS_YEARS = 5
global STASIS_CHANGE = 0.01
global FLOAT_TOL = 0.0001 


* ==============================================================================
* Main execution logic
* ==============================================================================

program main

	* Import pre-1900 ERT data
	use country_text_id year v2x_polyarchy using "${VDEM_ORIG}/version10/V-Dem-CY-Full+Others-v10.dta", clear
	rename country_text_id country
    sort country year
    order country year v2x_polyarchy

    get_dem_episodes

    * Keep only necessary variables and save
    keep if start_year < 1900
    keep country year pre_dem_ep
    
    save "${VDEM_DATA}/pre1900_dem.dta", replace
	
end

program get_dem_episodes

    * Create country panel identifier and set up time series
    egen country_id = group(country)
    sort country_id year
    tsset country_id year
	
	* Forward fill missings for countries with gaps in series
	replace v2x_polyarchy = L.v2x_polyarchy if v2x_polyarchy == .

    * Calculate year-over-year change in EDI
    gen edi_change = v2x_polyarchy - L.v2x_polyarchy
    drop country_id

    gen pre_dem_ep = 0
    gen start_year = .

    * Iterate over countries and identify dem periods
    levelsof country, local(countries)
    foreach country of local countries {
        
        preserve
        keep if country == "`country'"
        sort year
        
        * Check if we have observations for this country
        count
        local n_obs = r(N)
        
        * Skip if no observations
        if `n_obs' == 0 {
            restore
            continue
        }
        
        local in_episode = 0
        local cum_change = 0
        local start_year = .
        local stasis_count = 0
        
        * Loop through years for this country
        forvalues i = 1/`n_obs' {
            local current_year = year[`i']
            local current_change = edi_change[`i']
            local current_edi = v2x_polyarchy[`i']
            
            * Not in an episode
            if `in_episode' == 0 {
                if `current_change' >= $START_INCL & `current_change' != . {
                    local in_episode = 1
                    local cum_change = `current_change'
                    local start_year = `current_year'
                }
                if `cum_change' >= $CUM_INCL {
                    local in_episode = 2
                    local cum_change = 0
                    local stasis_count = 0
                }
            }
            * Possibly in an episode (needs to hit cumulative)
            else if `in_episode' == 1 {
                * Update stasis counter (consecutive years without 0.01 increase)
                if `current_change' >= ($STASIS_CHANGE - $FLOAT_TOL) {
                    local stasis_count = 0
                }
                else {
                    local stasis_count = `stasis_count' + 1
                }
                if `stasis_count' == $STASIS_YEARS {
                    local in_episode = 0
                    local cum_change = 0
                    local start_year = .
                    local stasis_count = 0
                }
                else {
                    local cum_change = `cum_change' + `current_change'
                    if `cum_change' >= $CUM_INCL {
                        local in_episode = 2
                        local cum_change = 0
                        local stasis_count = 0
                    }
                }
            }
            * In an episode
            else {

                * Update stasis counter (consecutive years without 0.01 increase)
                if `current_change' >= ($STASIS_CHANGE - $FLOAT_TOL) {
                    local stasis_count = 0
                }
                else {
                    local stasis_count = `stasis_count' + 1
                }

                local cum_change = `cum_change' + `current_change'
                
                * Check end conditions
                local should_end = 0
                local end_year = .
                * Annual drop
                if `current_change' <= -$YEAR_TURN {
                    local should_end = 1
                    local end_year = `current_year' - 1
                }
                * Cumulative drop
                if `cum_change' <= -$CUM_TURN {
                    local should_end = 1
                    local end_year = `current_year' - 1
                }
                * Stasis period
                if `stasis_count' == $STASIS_YEARS {
                    local should_end = 1
                    local end_year = `current_year' - 5
                }
                
                if `should_end' == 1 {
                    * Mark all years in the episode as 1 and record start year
                    forvalues j = `start_year'/`end_year' {
                        display "`country' `j'"
                        replace pre_dem_ep = 1 if year == `j'
                        replace start_year = `start_year' if year == `j'
                    }
                    local in_episode = 0
                    local cum_change = 0
                    local start_year = .
                    local stasis_count = 0

                }
            }
        }
        
        * Handle episodes that continue to the end of the data
        if `in_episode' == 2 {
            * Find the last year in the data for this country
            local end_year = year[`n_obs']
            forvalues j = `start_year'/`end_year' {
                replace pre_dem_ep = 1 if year == `j'
                replace start_year = `start_year' if year == `j'
            }
        }
        
        tempfile temp_country
        save "`temp_country'", replace
        
        restore
        merge 1:1 country year using "`temp_country'", nogen update replace
    }
    
end
 

* ==============================================================================
* Run script
* ==============================================================================

main