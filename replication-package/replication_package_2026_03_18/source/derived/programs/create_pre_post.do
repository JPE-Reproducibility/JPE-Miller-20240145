********************************************************************************
************************* Create Pre and Post Windows **************************
********************************************************************************

program createPrePost

args var

gen `var'_start = 1 if `var' == 1 & L.`var'== 0
replace `var'_start = 0 if `var' != . & `var'_start == .

gen `var'_end = 1 if `var'== 1 & F.`var'== 0
replace `var'_end = 0 if `var'!= . & `var'_end == .

gen pre_`var' = 0 if `var' != .
// 	replace pre_`var' = 1 if `var'_start == 1
replace pre_`var' = 1 if F1.`var'_start == 1
replace pre_`var' = 1 if F2.`var'_start == 1
replace pre_`var' = 1 if F3.`var'_start == 1
replace pre_`var' = 1 if F4.`var'_start == 1
replace pre_`var' = 1 if F5.`var'_start == 1


gen post_`var' = 0 if `var' != .
// 	replace post_`var' = 1 if `var'_end == 1
replace post_`var' = 1 if L1.`var'_end == 1
replace post_`var' = 1 if L2.`var'_end == 1
replace post_`var' = 1 if L3.`var'_end == 1
replace post_`var' = 1 if L4.`var'_end == 1
replace post_`var' = 1 if L5.`var'_end == 1


end
