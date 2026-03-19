* ===============================================================================
* Set globals
* ===============================================================================

global GFD_ORIG "datastore/raw/gfd/orig"
global GFD_DATA "datastore/raw/gfd/data"


program define get_gfd_data

args name action

import excel "${GFD_ORIG}/gfd_data_series_list.xlsx", sheet("`name'") firstrow clear

cap mkdir "${GFD_DATA}/countries_data/`name'"

forvalues j = 1/`=_N' {
	local x = country[`j']
	local y = series[`j']
	frame create temp
	frame temp {
		import delimited "${GFD_ORIG}/country_series/`x'/`y'.csv", clear
		gen year = year(date(date,"MDY"))
		drop date
		order country year
		tsset year
		gen `name' = `action'
		drop if `name' == .
		keep country year `name'
		save "${GFD_DATA}/countries_data/`name'/`y'.dta", replace
	}
	frame drop temp
}

levelsof series
local s = r(levels)
clear 
foreach x of local s {
		append using "${GFD_DATA}/countries_data/`name'/`x'.dta"
}

end
