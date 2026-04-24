/*
Purpose: create tax rate var for main paper and appendix
Primary author: Paul Kim
Date: 11-25-2025
*/

* ==============================================================================
* Housekeeping
* ==============================================================================

clear all
version 19

* ==============================================================================
* Set globals
* ==============================================================================

global CROSSWALKS				"datastore/raw/crosswalks"
global EFI_ORIG 				"datastore/raw/economic_freedom/orig"
global MACRO_POLITICAL_DERIVED 	"datastore/derived/macro_political"
global PROGRAMS 				"source/derived/programs"

do "${PROGRAMS}/create_gfd_data.do"

global START_YEAR = 1816
global END_YEAR = 2018

* ==============================================================================
* Main execution logic
* ==============================================================================

program main

	get_efi_data
	tempfile efi_data
	save "`efi_data'"

	get_gfd_n_companies	
	merge 1:1 country year using "`efi_data'", nogen

	* Drops BHS, BLZ, BMU, BRN
	merge m:1 country using "${CROSSWALKS}/valid_iso3_codes.dta", keep(3) nogen
	
	save "${MACRO_POLITICAL_DERIVED}/economic_competition.dta", replace

end

program get_gfd_n_companies

	* Number of public companies
	get_gfd_data "gfd_n_companies" "close"
	replace country = "XKX" if country == "KSV"
	
end

program get_efi_data

	use "${EFI_ORIG}/efi_data.dta", clear

	destring year efi_*, replace force
	encode country, gen(country_id)

	tsset country_id year
	tsfill, full

	drop country iso2 country_name
	decode country_id, gen(country)

	foreach var of varlist efi_* {
		cap drop temp
		bys country: ipolate `var' year, gen(temp)
		replace `var' = temp if `var' == .
		cap drop temp
	}

	sort country year
	order country year
	
	keep country year efi_5c

end

* ==============================================================================
* Run script
* ==============================================================================

main