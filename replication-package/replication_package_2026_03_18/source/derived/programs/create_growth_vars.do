	
********************************************************************************
******** Create Growth Rates, Logs, and Log Growth Rates for everything ******** 
********************************************************************************

program createGrowthVars
args var
	
gen log_`var' = log(`var')
gen log_`var'_g = log(`var')-log(L.`var')
gen `var'_g = `var'/L.`var' - 1

// ** Winsorize at 0.1% and 99.9% levels
// qui winsor2 `var'_g, c(.1 99.9) replace

end
