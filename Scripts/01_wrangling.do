////////////////////////////////////////////////////////////////////////////////
// Do File: 01_wrangling.do.do
// Primary Author: James Hawkins, Berkeley Institute for Young Americans
// Date: 8/4/24
// Stata Version: 17
// Description: In this script, I import and wrangle Census microdata samples 
// from IPUMS-USA (via the IPUMS API) and commuting zone data from David Dorn
// and David Autor.
// 
// The script is separated into the following sections:
// 		1. Wrangle IPUMS-USA data
//		2. Data for commuting zone analysis
////////////////////////////////////////////////////////////////////////////////


/// ============================================================================
//# 1. Wrangle IPUMS-USA data
/// ============================================================================
/*  In this section, I obtain Decennial Census and American Community Survey 
    person records via the IPUMS api and wrangle that data in preparation for 
	analysis. */

// A. Obtain data via IPUMS-USA api
// -----------------------------------------------------------------------------
/* In this sub-section, I obtain ACS data from the IPUMS API. Instructions for 
   implementing using the IPUMS API in Stata are available here: 
   https://blog.popdata.org/making-ipums-extracts-from-stata/. General 
   instructions for creating extracts via the API are available here:
   https://v1.developer.ipums.org/docs/workflows/create_extracts/usa/. Users
   seeking to replicate my analysis will need to obtain an API key from IPUMS
   and insert it below or define their API key in their profile.do script that 
   executes every time Stata starts. Instructions to implement the latter are 
   available here: 
   https://www.stata.com/support/faqs/programming/profile-do-file/. */
cd "$directory\derived-data"
python
import gzip
import shutil

from ipumspy import IpumsApiClient, UsaExtract
from sfi import Macro

my_api_key = Macro.getGlobal("MY_API_KEY")

ipums = IpumsApiClient(my_api_key)

# define extract
ipums_collection = "usa"
samples = ["us1940a", "us1950a", "us1960b", "us1970a", "us1980a", "us1990a", 
		"us2000a", "us2001a", "us2002a", "us2003a", "us2004a", "us2005a",
		"us2006a", "us2007a", "us2008a", "us2009a", "us2010g", "us2011a",
		"us2012a", "us2013a", "us2014a", "us2015a", "us2016a", "us2017a",
		"us2018a", "us2019a", "us2020a", "us2021a", "us2022a"]
variables = ["YEAR", "SERIAL", "PERNUM", "HHWT", "PERWT", "STATEFIP", "COUNTYFIP",
"GQ", "RELATE", "AGE", "OWNERSHP", "VACANCY", "METRO", "MET2013", "METAREA", 
"PUMA", "CNTYGP98"]
extract_description = "California Homeownership"

extract = UsaExtract(samples, variables, description=extract_description)
	 
# submit your extract to the IPUMS extract system
ipums.submit_extract(extract)

# wait for the extract to finish
ipums.wait_for_extract(extract, collection=ipums_collection)

# download it to your current working directory
ipums.download_extract(extract, stata_command_file=True)

Macro.setLocal("id", str(extract.extract_id).zfill(5))
Macro.setLocal("collection", ipums_collection)

extract_name = f"{ipums_collection}_{str(extract.extract_id).zfill(5)}"
# unzip the extract data file
with gzip.open(f"{extract_name}.dat.gz", 'rb') as f_in:
	with open(f"{extract_name}.dat", 'wb') as f_out:
		shutil.copyfileobj(f_in, f_out)

# exit python
end
qui do `collection'_`id'.do

// B. Wrangle data from IPUMS API
// -----------------------------------------------------------------------------
// Restrict sample to adult records
keep if age >= 18

// Group quarter definition
keep if inlist(gq, 1, 2, 5)
	/* IPUMS states that "In most cases, a working definition of "household" as 
	GQ = 1 or 2 is appropriate. Categories are not completely comparable across 
	all years." See: 
	https://usa.ipums.org/usa-action/variables/GQ#comparability_section
	I also include GQ = 5, which is a small segment of the sample since 2000, 
	since these respondents have non-missing responses for home-ownership.
	*/

// Top-code age
replace age = 90 if age > 90

// Define age groups
gen agegroup_ha = 0 if age < 18
replace agegroup_ha = 1 if age >= 18 & age <= 24
replace agegroup_ha = 2 if age >= 25 & age <= 34
replace agegroup_ha = 3 if age >= 35 & age <= 44
replace agegroup_ha = 4 if age >= 45 & age <= 54
replace agegroup_ha = 5 if age >= 55 & age <= 64
replace agegroup_ha = 6 if age >= 65 & age <= 74
replace agegroup_ha = 7 if age >= 75
lab var agegroup_ha "Age groups (top-coded 80)"
lab def agegroup_ha_lbl ///
	1 "18-24" ///
	2 "25-34" ///
	3 "35-44" ///
	4 "45-54" ///
	5 "55-64" ///
	6 "65-74" ///
	7 "75+"
lab val agegroup_ha agegroup_ha_lbl

// Define homeownership measure (household)
gen ownhh = 1 if ownershp == 1 & relate == 1
replace ownhh = 0 if inlist(ownershp, 2) & relate == 1
lab var ownhh "Homeownership (household)"

// Define homeownership measures (person)
** partners included (preferred measure)
/* NOTE: ACS does not include separate codes for unmarried partners (1114) in
   1980. */
gen ownp1 = 0
replace ownp1 = 1 if ownershp == 1 & inlist(related, 101, 201, 1114)
lab var ownp1 "Homeownership (person, including spouses and partners)"
** partner/roommates included (code 1115)
gen ownp2 = 0
replace ownp2 = 1 if ownershp == 1 & inlist(related, 101, 201, 1113, 1114)
lab var ownp2 "Homeownership (person, including spouses, partners, and partner/roommates)"
** spouses
gen ownp3 = 0
replace ownp3 = 1 if ownershp == 1 & inlist(related, 101, 201)
lab var ownp3 "Homeownership (person, including spouses)"

// Define headship measures
** partners included starting in 1990 (preferred measure)
gen headship1 = 0
replace headship1 = 1 if inlist(relate, 1, 2)
replace headship1 = 1 if related == 1114 // unmarried partner
lab var headship1 "Headship (including spouse and unmarried partner)"
** partner/roommates (1989 and 1992) included
gen headship2 = 0
replace headship2 = 1 if inlist(relate, 1, 2)
replace headship2 = 1 if inlist(related, 1110, 1113, 1114)
lab var headship2 "Homeownership (person, including spouse, partner/friend, partner/roommate, unmarried partner)"
** spouses
gen headship3 = 0
replace headship3 = 1 if inlist(relate, 1, 2)
lab var headship3 "Homeownership (person, including spouse)"

// Save data
cd "$directory\derived-data"
compress
save ipumsusa_wrangled.dta, replace


/// ============================================================================
//# 2. Data for commuting zone analysis
/// ============================================================================
/*  In this section, I obtain CPS records via the IPUMS api and wrangle that 
    data in preparation for analysis. */

// A. Prepare main IPUMS data set for append with additional 1970 and 2018-22 data
// -----------------------------------------------------------------------------
cd "$directory\derived-data"
use year serial pernum hhwt perwt statefip gq relate related age ownershp vacancy countyfip puma cntygp98 if inlist(year, 1980, 1990, 2000, 2010) & statefip == 6 using ipumsusa_wrangled.dta, clear

// Temporary save
tempfile appenddata
save `appenddata'.dta, replace
	
// B. Obtain 1970 and 2018-22 data via IPUMS-USA api
// -----------------------------------------------------------------------------
/* In this sub-section, I obtain ACS data from the IPUMS API. Instructions for 
   implementing using the IPUMS API in Stata are available here: 
   https://blog.popdata.org/making-ipums-extracts-from-stata/. General 
   instructions for creating extracts via the API are available here:
   https://v1.developer.ipums.org/docs/workflows/create_extracts/usa/. Users
   seeking to replicate my analysis will need to obtain an API key from IPUMS
   and insert it below or define their API key in their profile.do script that 
   executes every time Stata starts. Instructions to implement the latter are 
   available here: 
   https://www.stata.com/support/faqs/programming/profile-do-file/. */
cd "$directory\derived-data"
python
import gzip
import shutil

from ipumspy import IpumsApiClient, UsaExtract
from sfi import Macro

my_api_key = Macro.getGlobal("MY_API_KEY")

ipums = IpumsApiClient(my_api_key)

# define extract
ipums_collection = "usa"
samples = ["us1970d", "us2022c"]
variables = ["YEAR", "SERIAL", "PERNUM", "HHWT", "PERWT", "STATEFIP", 
"COUNTYFIP", "GQ", "RELATE", "AGE", "OWNERSHP", "VACANCY", "PUMA", "CNTYGP97"]
extract_description = "California Homeownership"

extract = UsaExtract(samples, variables, description=extract_description)
	 
# submit your extract to the IPUMS extract system
ipums.submit_extract(extract)

# wait for the extract to finish
ipums.wait_for_extract(extract, collection=ipums_collection)

# download it to your current working directory
ipums.download_extract(extract, stata_command_file=True)

Macro.setLocal("id", str(extract.extract_id).zfill(5))
Macro.setLocal("collection", ipums_collection)

extract_name = f"{ipums_collection}_{str(extract.extract_id).zfill(5)}"
# unzip the extract data file
with gzip.open(f"{extract_name}.dat.gz", 'rb') as f_in:
	with open(f"{extract_name}.dat", 'wb') as f_out:
		shutil.copyfileobj(f_in, f_out)

# exit python
end
qui do `collection'_`id'.do

// C. Wrangle data from IPUMS API
// -----------------------------------------------------------------------------
/* In this sub-section, I wrangle the IPUMS-USA data in prepration for use in my 
   commuter zone analysis. */

// Append main IPUMS data for select years
append using `appenddata'.dta

// Restrict to California
keep if statefip == 6

// Restrict sample to adult records
keep if age >= 18

// Group quarter definition
keep if inlist(gq, 1, 2, 5)
	/* IPUMS states that "In most cases, a working definition of "household" as 
	GQ = 1 or 2 is appropriate. Categories are not completely comparable across 
	all years." See: 
	https://usa.ipums.org/usa-action/variables/GQ#comparability_section
	I also include GQ = 5, which is a small segment of the sample since 2000, 
	since these respondents have non-missing responses for home-ownership.
	*/

// Top-code age
replace age = 90 if age > 90

// Define age groups
gen agegroup_ha = 0 if age < 18
replace agegroup_ha = 1 if age >= 18 & age <= 24
replace agegroup_ha = 2 if age >= 25 & age <= 34
replace agegroup_ha = 3 if age >= 35 & age <= 44
replace agegroup_ha = 4 if age >= 45 & age <= 54
replace agegroup_ha = 5 if age >= 55 & age <= 64
replace agegroup_ha = 6 if age >= 65 & age <= 74
replace agegroup_ha = 7 if age >= 75
lab var agegroup_ha "Age groups (top-coded 80)"
lab def agegroup_ha_lbl ///
	1 "18-24" ///
	2 "25-34" ///
	3 "35-44" ///
	4 "45-54" ///
	5 "55-64" ///
	6 "65-74" ///
	7 "75+"
lab val agegroup_ha agegroup_ha_lbl

// Define homeownership measure (household)
gen ownhh = 1 if ownershp == 1 & relate == 1
replace ownhh = 0 if inlist(ownershp, 2) & relate == 1
lab var ownhh "Homeownership (household)"

// Define homeownership measures (person)
** partners included (preferred measure)
/* NOTE: ACS does not include separate codes for unmarried partners (1114) in
   1980. */
gen ownp1 = 0
replace ownp1 = 1 if ownershp == 1 & inlist(related, 101, 201, 1114)
lab var ownp1 "Homeownership (person, including spouses and partners)"
** partner/roommates included (code 1115)
gen ownp2 = 0
replace ownp2 = 1 if ownershp == 1 & inlist(related, 101, 201, 1113, 1114)
lab var ownp2 "Homeownership (person, including spouses, partners, and partner/roommates)"
** spouses
gen ownp3 = 0
replace ownp3 = 1 if ownershp == 1 & inlist(related, 101, 201)
lab var ownp3 "Homeownership (person, including spouses)"

// D. Merge commuting zone data onto IPUMS-USA data
// -----------------------------------------------------------------------------
/* In this sub-section, I take an identifier for commuting zone based on 
   publicly available data from David Dorn [https://www.ddorn.net/data.htm#Local%20Labor%20Market%20Geography]
   and merge it on to IPUMS-USA data. I also calculate an adjusted weight based
   on adjustment factor provided in Dorn's data. The procedure for identifying 
   commuting zones and calculating this adjustment factor is described in 
   Dorn (2009) [https://www.ddorn.net/data/Dorn_Thesis_Appendix.pdf]. */

// Merge commuter zone data from Dorn onto IPUMS data
** 2018-2022
preserve
	keep if year == 2022
	gen puma2010 = 100000*statefip + puma
	cd "$directory\raw-data"
	joinby puma2010 using cw_puma2010_czone.dta
	tempfile file_2022
	save `file_2022'.dta, replace
restore
** 2010
preserve
	keep if year == 2010
	gen puma2010 = 100000*statefip + puma
	cd "$directory\raw-data"
	joinby puma2010 using cw_puma2010_czone.dta
	tempfile file_2010
	save `file_2010'.dta, replace
restore
** 2000
preserve
	keep if year == 2000
	gen puma2000 = 10000*statefip + puma
	cd "$directory\raw-data"
	joinby puma2000 using cw_puma2000_czone.dta
	tempfile file_2000
	save `file_2000'.dta, replace
restore
** 1990
preserve
	keep if year == 1990
	gen puma1990 = 10000*statefip + puma
	cd "$directory\raw-data"
	joinby puma1990 using cw_puma1990_czone.dta
	tempfile file_1990
	save `file_1990'.dta, replace
restore
** 1980
preserve
	keep if year == 1980
	gen ctygrp1980=1000*statefip+cntygp98
	cd "$directory\raw-data"
	joinby ctygrp1980 using cw_ctygrp1980_czone_corr.dta
	tempfile file_1980
	save `file_1980'.dta, replace
restore
** 1970
preserve
	keep if year == 1970
	gen cty_grp70=cntygp97
	cd "$directory\raw-data"
	joinby cty_grp70 using cw_ctygrp1970_czone_corr.dta
	rename afact afactor
	tempfile file_1970
	save `file_1970'.dta, replace
restore

// Append all data
use `file_2022'.dta, clear
append using `file_2010'.dta
append using `file_2000'.dta
append using `file_1990'.dta
append using `file_1980'.dta
append using `file_1970'.dta

// Calculate adjusted weight
gen adjweight = perwt * afactor

// Save final microdata with commuter zone
cd "$directory\derived-data"
save czone_ca.dta, replace

// E. Wrangle commuting zone density data
// -----------------------------------------------------------------------------
/* In this sub-section, I wrangle data related to commuter zones that identify
   the the density of commuting zone in 1970. This data can be obtained from the
   replication package for Autor (2019) [https://www.aeaweb.org/articles?id=10.1257/pandp.20191110]
   via OPENICPSR [https://www.openicpsr.org/openicpsr/project/116495/version/V1/view]. */

// Wrangle density data from Autor (2019)
cd "$directory\raw-data"
use workfile5015.dta, clear
keep if yr == 1970
keep czone lndens_70
cd "$directory\derived-data"
save lndens_70.dta, replace