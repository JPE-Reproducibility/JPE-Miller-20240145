
program run_campbell_1991_var

args country varlist

local n_vars : word count `varlist'

* Compute rho from mean of discount rate
sum $dy if country_id == `country'
sca rho = exp(-r(mean)) / (1 + exp(-r(mean)))

* Demean variables
foreach var of varlist `varlist' {
	egen mn_`var' = mean(`var')
	gen dmn_`var' = `var' - mn_`var'
}

* Build demeaned varlist
local dmn_varlist ""
foreach var of varlist `varlist' {
	local dmn_varlist "`dmn_varlist' dmn_`var'"
}

* Run VAR
var `dmn_varlist' if country_id == `country', lag(1) nocons

* Extract Phi matrix from r(table)
mat temp_mat = r(table)
mat Phi = J(`n_vars', `n_vars', .)
forval i = 1/`n_vars' {
	forval j = 1/`n_vars' {
		local col = (`i' - 1) * `n_vars' + `j'
		mat Phi[`i', `j'] = temp_mat[1, `col']
	}
}

* Predict residuals
forval i = 1/`n_vars' {
	predict var_res`i', residuals equation(#`i')
}

* Create matrices from data
mkmat `varlist' if e(sample) == 1, mat(data_mat)
mkmat var_res* if e(sample) == 1, mat(res_mat)
mkmat year country_id if e(sample) == 1, mat(info_mat)

* Compute Campbell decomposition
mat iden = I(`n_vars')
mat e1 = J(`n_vars', 1, 0)
mat e1[1, 1] = 1
mat lambda = rho * e1' * Phi * inv(iden - rho * Phi)

mat cf_news = ((e1' + lambda) * res_mat')'
mat dr_news = (lambda * res_mat')'

* Append to output matrix
mat var_mat = (info_mat, cf_news, dr_news)
mat colnames var_mat = "year" "country_id" "cf_news_camp" "dr_news_camp"
mat shocks_mat = (shocks_mat \ var_mat)

drop mn_* dmn_* var_res*

end
