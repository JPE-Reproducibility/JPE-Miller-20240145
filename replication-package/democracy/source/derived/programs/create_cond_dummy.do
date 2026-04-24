********************************************************************************
********************** Create conditional dummy variables ********************** 
********************************************************************************

program createCondDummy
args new_var old_var condition

gen `new_var' = 1 if `old_var' `condition' & `old_var' != .
replace `new_var' = 0 if `new_var' == . & `old_var' != .

end
