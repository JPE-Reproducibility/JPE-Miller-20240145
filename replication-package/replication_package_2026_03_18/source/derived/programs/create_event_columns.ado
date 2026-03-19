/* 
This script does the following for all event variables
	1. Fills in zeros
	2. Creates an indicator for the start year
	3. Creates a column that has the value of the start year
	4. Creates an episode identifier
	5. Creates a variable that tells you the number of years since start
*/

program create_event_columns
	args var
	
	replace `var' = 0 if `var' == .
	
	gen `var'_start = 1 if `var' == 1 & L.`var' == 0
	replace `var'_start = 0 if `var'_start == . & `var' != .
	
	gen `var'_start_year = year if `var'_start == 1
	replace `var'_start_year = L.`var'_start_year if `var'_start_year == . & `var' == 1
	
	egen `var'_ep_id = group(country `var'_start_year), label
	
	gen years_in_`var' = year - `var'_start_year + 1
	
end
