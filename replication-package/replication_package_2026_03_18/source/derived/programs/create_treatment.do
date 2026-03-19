********************************************************************************
****************************** Triple Diff Setup *******************************
********************************************************************************

program treatmentCreate

args did_beg_year did_end_year did_beg_treat_year did_end_treat_year

cap drop did_*

gen did_obs_check_tr = 1 if year >= `did_beg_year' & year <= `did_end_year' & all_eq_tr != .
bys country_id: egen did_obs_tr = sum(did_obs_check_tr)
drop did_obs_check_tr
sort country_id year

** Post Vatican-II
gen did_post_svc = 1 if year >= (`did_end_treat_year'+1) & year <= `did_end_year'
replace did_post_svc = 0 if year >= `did_beg_year' & year <= (`did_beg_treat_year'-1)

** Exclude countries with too few observations
local country_list1 = "CUB GTM JAM KOR MOZ PRY TWN"
// local country_list2 = "CUB GTM JAM KOR MOZ PRY TWN ECU EGY SGP THA"
foreach c of local country_list1 {
	replace did_post_svc = . if country == "`c'"
}

********************************************************************************
***************************** Create Interactions ******************************
********************************************************************************

** Discrete, 1963 Treatment
gen did_post_svc_maj_cath = did_post_svc*majority_catholic
gen did_post_svc_auto = did_post_svc*autocracy
gen did_post_svc_maj_cath_auto = did_post_svc_maj_cath*autocracy

** Continuous, 1963 Treatment
gen did_post_cath_pct = did_post_svc*catholic_pct
/* gen did_post_vdem = did_post_svc*vdem_total2_inv */
/* gen did_post_cath_pct_vdem = did_post_svc*cath_pct_vdem */

** Discrete labels
lab var autocracy "Autocracy"
lab var majority_catholic "Catholic"
lab var maj_cath_auto "Autocracy $\times$ Catholic"

lab var did_post_svc_maj_cath "Post $\times$ Catholic"
lab var did_post_svc_auto "Post $\times$ Autocracy"
lab var did_post_svc_maj_cath_auto "Post $\times$ Catholic $\times$ Autocracy"

** Continuous labels
lab var catholic_pct "Catholic"
/* lab var vdem_total2_inv "Autocracy" */
/* lab var cath_pct_vdem "Autocracy $\times$ Catholic" */

lab var did_post_cath_pct "Post $\times$ Catholic"
/* lab var did_post_vdem "Post $\times$ Autocracy" */
/* lab var did_post_cath_pct_vdem "Post $\times$ Catholic $\times$ Autocracy" */

end
