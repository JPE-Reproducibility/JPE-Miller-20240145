
program campbellVARfull_new

args country varlist

local n_vars : word count `varlist'

sum $dy if country_id == `country'
sca zbar = -r(mean)
sca rho = exp(zbar)/(1 + exp(zbar))

foreach var of varlist `varlist' {
	
	egen mn_`var' = mean(`var')
	gen dmn_`var' = `var'-mn_`var'

}

local firstvar `: word 1 of `varlist''
local secondvar `: word 2 of `varlist''
local thirdvar `: word 3 of `varlist''
local fourthvar `: word 4 of `varlist''
local fifthvar `: word 5 of `varlist''

if `n_vars' == 2 {

	var dmn_`firstvar' dmn_`secondvar' if country_id == `country' , lag(1) nocons

	mat Phi = J(2,2,.)
	mat temp_mat = r(table)
	mat Phi[1,1] = temp_mat[1,1]
	mat Phi[1,2] = temp_mat[1,2]
	mat Phi[2,1] = temp_mat[1,3]
	mat Phi[2,2] = temp_mat[1,4]

	predict var_res1, residuals equation(#1)
	predict var_res2, residuals equation(#2)

	mkmat `varlist' if e(sample) == 1, mat(data_mat)
	mkmat var_res* if e(sample) == 1, mat(res_mat)
	mkmat year country_id if e(sample) == 1, mat(info_mat)

	mat iden = (1,0\0,1)
	mat e1 = (1\0)
	mat lambda = rho*e1'*Phi*inv(iden-rho*Phi)
	
	mat cf_news = ((e1'+lambda)*res_mat')'
	mat dr_news = (lambda*res_mat')'

	mat var_mat = (info_mat,cf_news,dr_news)
	mat colnames var_mat = "year" "country_id" "cf_news_camp" "dr_news_camp"

	mat shocks_mat = (shocks_mat \ var_mat)

}

if `n_vars' == 3 {
	
	var dmn_`firstvar' dmn_`secondvar' dmn_`thirdvar' if country_id == `country' , lag(1) nocons

	mat Phi = J(3,3,.)
	mat temp_mat = r(table)
	mat Phi[1,1] = temp_mat[1,1]
	mat Phi[1,2] = temp_mat[1,2]
	mat Phi[1,3] = temp_mat[1,3]
	mat Phi[2,1] = temp_mat[1,4]
	mat Phi[2,2] = temp_mat[1,5]
	mat Phi[2,3] = temp_mat[1,6]
	mat Phi[3,1] = temp_mat[1,7]
	mat Phi[3,2] = temp_mat[1,8]
	mat Phi[3,3] = temp_mat[1,9]

	predict var_res1, residuals equation(#1)
	predict var_res2, residuals equation(#2)
	predict var_res3, residuals equation(#3)

	mkmat `varlist' if e(sample) == 1, mat(data_mat)
	mkmat var_res* if e(sample) == 1, mat(res_mat)
	mkmat year country_id if e(sample) == 1, mat(info_mat)

	mat iden = (1,0,0\0,1,0\0,0,1)
	mat e1 = (1\0\0)
	mat lambda = rho*e1'*Phi*inv(iden-rho*Phi)
	
	mat cf_news = ((e1'+lambda)*res_mat')'
	mat dr_news = (lambda*res_mat')'

	mat var_mat = (info_mat,cf_news,dr_news)
	mat colnames var_mat = "year" "country_id" "cf_news_camp" "dr_news_camp"

	mat shocks_mat = (shocks_mat \ var_mat)

}

if `n_vars' == 4 {
	
	var dmn_`firstvar' dmn_`secondvar' dmn_`thirdvar' dmn_`fourthvar' if country_id == `country' , lag(1) nocons

	mat Phi = J(4,4,.)
	mat temp_mat = r(table)
	mat Phi[1,1] = temp_mat[1,1]
	mat Phi[1,2] = temp_mat[1,2]
	mat Phi[1,3] = temp_mat[1,3]
	mat Phi[1,4] = temp_mat[1,4]
	mat Phi[2,1] = temp_mat[1,5]
	mat Phi[2,2] = temp_mat[1,6]
	mat Phi[2,3] = temp_mat[1,7]
	mat Phi[2,4] = temp_mat[1,8]
	mat Phi[3,1] = temp_mat[1,9]
	mat Phi[3,2] = temp_mat[1,10]
	mat Phi[3,3] = temp_mat[1,11]
	mat Phi[3,4] = temp_mat[1,12]
	mat Phi[4,1] = temp_mat[1,13]
	mat Phi[4,2] = temp_mat[1,14]
	mat Phi[4,3] = temp_mat[1,15]
	mat Phi[4,4] = temp_mat[1,16]
	predict var_res1, residuals equation(#1)
	predict var_res2, residuals equation(#2)
	predict var_res3, residuals equation(#3)
	predict var_res4, residuals equation(#4)

	mkmat `varlist' if e(sample) == 1, mat(data_mat)
	mkmat var_res* if e(sample) == 1, mat(res_mat)
	mkmat year country_id if e(sample) == 1, mat(info_mat)

	mat iden = (1,0,0,0\0,1,0,0\0,0,1,0\0,0,0,1)
	mat e1 = (1\0\0\0)
	mat lambda = rho*e1'*Phi*inv(iden-rho*Phi)
	
	mat cf_news = ((e1'+lambda)*res_mat')'
	mat dr_news = (lambda*res_mat')'

	mat var_mat = (info_mat,cf_news,dr_news)
	mat colnames var_mat = "year" "country_id" "cf_news_camp" "dr_news_camp"

	mat shocks_mat = (shocks_mat \ var_mat)

}

if `n_vars' == 5 {
	
	var dmn_`firstvar' dmn_`secondvar' dmn_`thirdvar' dmn_`fourthvar' dmn_`fifthvar' if country_id == `country' , lag(1) nocons

	mat Phi = J(5,5,.)
	mat temp_mat = r(table)
	mat Phi[1,1] = temp_mat[1,1]
	mat Phi[1,2] = temp_mat[1,2]
	mat Phi[1,3] = temp_mat[1,3]
	mat Phi[1,4] = temp_mat[1,4]
	mat Phi[1,5] = temp_mat[1,5]
	mat Phi[2,1] = temp_mat[1,6]
	mat Phi[2,2] = temp_mat[1,7]
	mat Phi[2,3] = temp_mat[1,8]
	mat Phi[2,4] = temp_mat[1,9]
	mat Phi[2,5] = temp_mat[1,10]
	mat Phi[3,1] = temp_mat[1,11]
	mat Phi[3,2] = temp_mat[1,12]
	mat Phi[3,3] = temp_mat[1,13]
	mat Phi[3,4] = temp_mat[1,14]
	mat Phi[3,5] = temp_mat[1,15]
	mat Phi[4,1] = temp_mat[1,16]
	mat Phi[4,2] = temp_mat[1,17]
	mat Phi[4,3] = temp_mat[1,18]
	mat Phi[4,4] = temp_mat[1,19]
	mat Phi[4,5] = temp_mat[1,20]
	mat Phi[5,1] = temp_mat[1,21]
	mat Phi[5,2] = temp_mat[1,22]
	mat Phi[5,3] = temp_mat[1,23]
	mat Phi[5,4] = temp_mat[1,24]
	mat Phi[5,5] = temp_mat[1,25]	
	predict var_res1, residuals equation(#1)
	predict var_res2, residuals equation(#2)
	predict var_res3, residuals equation(#3)
	predict var_res4, residuals equation(#4)
	predict var_res5, residuals equation(#5)

	mkmat `varlist' if e(sample) == 1, mat(data_mat)
	mkmat var_res* if e(sample) == 1, mat(res_mat)
	mkmat year country_id if e(sample) == 1, mat(info_mat)

	mat iden = (1,0,0,0,0\0,1,0,0,0\0,0,1,0,0\0,0,0,1,0\0,0,0,0,1)
	mat e1 = (1\0\0\0\0)
	mat lambda = rho*e1'*Phi*inv(iden-rho*Phi)
	
	mat cf_news = ((e1'+lambda)*res_mat')'
	mat dr_news = (lambda*res_mat')'

	mat var_mat = (info_mat,cf_news,dr_news)
	mat colnames var_mat = "year" "country_id" "cf_news_camp" "dr_news_camp"

	mat shocks_mat = (shocks_mat \ var_mat)

}


drop mn_* dmn_* var_res*

end
