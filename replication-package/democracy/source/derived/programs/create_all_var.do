********************************************************************************
************************* Create all returns variable **************************
********************************************************************************

program createALLvar

args v log_var

if "`log_var'" == "No" | "`log_var'" == "Both" {
	gen all_`v' = gfd_`v'
	replace all_`v' = jst_`v' if all_`v' == .
	replace all_`v' = gfd_lse_`v' if all_`v' == .
}

if "`log_var'" == "Yes" | "`log_var'" == "Both" {
	gen log_all_`v' = log_gfd_`v'
	replace log_all_`v' = log_jst_`v' if log_all_`v' == .
	replace log_all_`v' = log_gfd_lse_`v' if log_all_`v' == .
}

end
