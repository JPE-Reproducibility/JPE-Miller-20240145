********************************************************************************
******************************* By country AR(1) ******************************* 
********************************************************************************

program countryAR1
args var

sort country_id year
gen lag_`var' = L.`var'
bys country_id: asreg `var' lag_`var', fitted
gen `var'_exp = _fitted
drop _* lag_`var'
sort country_id year


end
