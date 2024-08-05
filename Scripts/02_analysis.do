////////////////////////////////////////////////////////////////////////////////
// Do File: 02_analysis.do.do
// Primary Author: James Hawkins, Berkeley Institute for Young Americans
// Date: 8/5/24
// Stata Version: 17
// Description: In this script I implement the analysis included in the issue 
// brief "Young Adults and the Decline of Homeownership in California." I 
// organize the script based on the main figures in the brief, with extended
// results included within the same section as the figure most relevant to 
// those results (e.g., the aggregate homeownership rates for CA for the 25+ 
// sub-group is included in the same section as Figure 2). Each section can be
// navigated with the Stata bookmarks feature as of Stata 17.
// 
// The script is separated into the following sections:
//		1. Figure 1: Headship rates, by age group
//		2. Figure 2: CA Aggregate Homeownership Rate
//		3. Figure 3: Homeownership rates in California and (rest of) United States, by age group
//		4. Figure 4: Homeownership Rates by Commuting Zone
// 		5. Permits Per Capita
////////////////////////////////////////////////////////////////////////////////


/// ============================================================================
**# 1. Figure 1: Headship rates, by age group
/// ============================================================================
/* In this section, I estimate and plot the share of the population represented
   by heads of households. */
cd "$directory\derived-data"
use ipumsusa_wrangled.dta, clear

// Restrict analysis to CA
keep if statefip == 6

// Estimate headship rates
collapse (mean) headship1 headship2 headship3 [pw = perwt], by(year agegroup)

// Save estimates
cd "$directory\output"
save headshiprate.dta, replace

// Visualization: headship rates (Figure 1)
** graph notes
linewrap, maxlength(150) name("notes") stack longstring("Visualization shows the trends in the share of the population of each age group represented by head(s) of households, which consists of the head of the householder (reference person) and any spouse/partner. Partners cannot be separately counted from roommates or friends prior to 1990.")
local notes = `" "Notes: {fontface Lato:`r(notes1)'}""'
local y = r(nlines_notes)
forvalues i = 2/`y' {
	local notes = `"`notes' "{fontface Lato:`r(notes`i')'}""'
}
** graph
twoway (connected headship1 year, msymbol(circle) msize(vsmall) mcolor("0 50 98") lpattern(solid dash) lcolor("0 50 98")) ///
, ///
by(agegroup, rows(1) imargin(l=1 r=1 b=0 t=0)) ///
by(, title("Tracking changes in California's headship rate", color("0 50 98") size(large) pos(11) justification(left))) ///
by(, subtitle("Percentage of each age group represented by head(s) of household", color("59 126 161") size(small) pos(11) justification(left))) ///
subtitle(, color(white) size(small) lcolor("59 126 161") fcolor("59 126 161")) ///
xtitle("Year", size(small) color(gs6) bmargin(zero)) xscale(lstyle(none)) ///
xlabel(1940 1950 1960 1970 1980 1990 2000 2010 2020, labsize(1.7) angle(45) glcolor(gs9%0) labcolor(gs6) tlength(1.25) tlcolor(gs6%30)) xmtick(2000(1)2022, tlength(.75) tlcolor(gs9%30)) ///
ytitle("") ///
yscale(lstyle(none)) ///
ylabel(0 "0%" .20 "20%" .40 "40%" .60 "60%".80 "80%"1 "100%", angle(0) gmax gmin glpattern(solid) glcolor(gs9%15) glwidth(vthin) labcolor("59 126 161") labsize(2.5) tlength(0) tlcolor(gs9%15)) ///
legend(order(1 "Head and spouse" 2 "Head and spouse/partner (partners since 1990)") ring(0) pos(12) rows(1) bmargin(zero)) ///
by(, legend(order(1 "Partners" 2 "Non-relatives") ring(0) pos(12) rows(1) bmargin(zero))) ///
by(, note("Source: {fontface Lato:Author's analysis of IPUMS-USA.} Sample: {fontface Lato:Adult civilian household residents in California.}" `notes', margin(l+1.5) color(gs7) span size(vsmall) position(7))) ///
by(, caption("@jamesohawkins {fontface Lato:with} youngamericans.berkeley.edu", margin(l+1.5 t-1) color(gs7%50) span size(vsmall) position(7))) ///
by(, graphregion(margin(0 0 0 0) fcolor(white) lcolor(white) lwidth(medium) ifcolor(white) ilcolor(white) ilwidth(medium))) ///
by(, plotregion(margin(0 0 0 0) fcolor(white) lcolor(white) lwidth(medium) ifcolor(white) ilcolor(white) ilwidth(medium))) ///
by(, graphregion(margin(r+2)))
cd "$directory\output"
graph export headshiprate_byagegroup.png, replace


// Extended results: Alternative measure of headship (spouse or spouse/partner)
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
cd "$directory\output"
use headshiprate.dta, clear

** graph notes
linewrap, maxlength(150) name("notes") stack longstring("Visualization shows the trends in the share of the population of each age group represented by head(s) of households, which consists of the head of the householder (reference person) and any spouse OR the reference person and any spouse/partner, depending on the measure. Partners cannot be separately counted from roommates or friends prior to 1990.")
local notes = `" "Notes: {fontface Lato:`r(notes1)'}""'
local y = r(nlines_notes)
forvalues i = 2/`y' {
	local notes = `"`notes' "{fontface Lato:`r(notes`i')'}""'
}
** graph
twoway (connected headship1 year, msymbol(circle) msize(vsmall) mcolor("0 50 98") lpattern(solid dash) lcolor("0 50 98")) ///
(connected headship3 year, msymbol(circle) msize(vsmall) mcolor("217 117 31") lpattern(solid dash) lcolor("217 117 31")) ///
if year >= 1990 ///
, ///
by(agegroup, rows(1) imargin(l=1 r=1 b=0 t=0)) ///
by(, title("Tracking changes in California's headship rate", color("0 50 98") size(large) pos(11) justification(left))) ///
by(, subtitle("Percentage of each age group represented by relationship category", color("59 126 161") size(small) pos(11) justification(left))) ///
subtitle(, color(white) size(small) lcolor("59 126 161") fcolor("59 126 161")) ///
xtitle("Year", size(small) color(gs6) bmargin(zero)) xscale(lstyle(none)) ///
xlabel(1990 2000 2010 2020, labsize(1.7) angle(45) glcolor(gs9%0) labcolor(gs6) tlength(1.25) tlcolor(gs6%30)) xmtick(2000(1)2022, tlength(.75) tlcolor(gs9%30)) ///
ytitle("") ///
yscale(lstyle(none)) ///
ylabel(0 "0%" .20 "20%" .40 "40%" .60 "60%" .80 "80%" 1 "100%", angle(0) gmax gmin glpattern(solid) glcolor(gs9%15) glwidth(vthin) labcolor("59 126 161") labsize(2.5) tlength(0) tlcolor(gs9%15)) ///
legend(order(2 "Head and spouse" 1 "Head and spouse/partner (partners since 1990)") ring(0) pos(12) rows(1) bmargin(zero)) ///
by(, legend(order(2 "Head and spouse" 1 "Head and spouse/partner (since 1990)") ring(0) pos(12) rows(1) bmargin(zero))) ///
by(, note("Source: {fontface Lato:Author's analysis of IPUMS-USA.} Sample: {fontface Lato:Adult civilian residents in California.}" `notes', margin(l+1.5) color(gs7) span size(vsmall) position(7))) ///
by(, caption("@jamesohawkins {fontface Lato:with} youngamericans.berkeley.edu", margin(l+1.5 t-1) color(gs7%50) span size(vsmall) position(7))) ///
by(, graphregion(margin(0 0 0 0) fcolor(white) lcolor(white) lwidth(medium) ifcolor(white) ilcolor(white) ilwidth(medium))) ///
by(, plotregion(margin(0 0 0 0) fcolor(white) lcolor(white) lwidth(medium) ifcolor(white) ilcolor(white) ilwidth(medium))) ///
by(, graphregion(margin(r+2)))
cd "$directory\output"
graph export headshiprate_byagegroup_alt.png, replace


// Extended results: Share of different relationship categories in population, by age group
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
/* In this sub-section, I estimate and plot population shares in California for 
   all adult age groups and different relationship statuses within the 
   household. */
cd "$directory\derived-data"
use ipumsusa_wrangled.dta, clear

// Restrict analysis to CA
keep if statefip == 6

// Define relationship groups
gen relategroup = 1 if inlist(relate, 1, 2) // head/householder OR spouse
replace relategroup = 2 if inlist(relate, 3, 4) // child/child-in-law
replace relategroup = 3 if inlist(relate, 11, 12) // partner, friend, visitor OR other non-relatives
replace relategroup = 4 if inlist(relate, 5, 6, 7, 8, 9, 10) // parent/parent-in-law OR other relatives
replace relategroup = 4 if related == 1242 // foster children
lab def relategroup_lbl ///
	1 "Head/householder or spouse" ///
	2 "Child/child-in-law" ///
	3 "Partner, friend, visitor OR other non-relatives" ///
	4 "Parent/parent-in-law OR other relatives"
lab val relategroup relategroup_lbl

// Population totals, by year age group and relate groups
gen person = 1
** estimate population totals
collapse (sum) pop = person [pw = perwt], by(year agegroup relategroup)
** reshape estimates
reshape wide pop, i(year agegroup) j(relategroup)
** zero out missing values (no persons in particular year, age group, relate group cell)
foreach var of varlist pop1 pop2 pop3 pop4 {
	replace `var' = 0 if `var' == .
}
** define total population
gen totalpop = pop1 + pop2 + pop3 + pop4
foreach var of varlist pop1 pop2 pop3 pop4 {
	gen `var'share = `var' / totalpop
}

// Save estimates
cd "$directory\output"
save relateshares.dta, replace

// Visualization: household shares 18+
** graph notes
linewrap, maxlength(150) name("notes") stack longstring("Visualization shows the trends in the relative share of the population of each age group represented by each household relationship category. The relationship category for each individual in a household is defined based on their relationship to the household reference person (head/householder). Partners are grouped with non-relatives because they cannot be separately counted from roommates or friends prior to 1990.")
local notes = `" "Notes: {fontface Lato:`r(notes1)'}""'
local y = r(nlines_notes)
forvalues i = 2/`y' {
	local notes = `"`notes' "{fontface Lato:`r(notes`i')'}""'
}
** graph
twoway (connected pop4share pop3share pop2share year, msymbol(diamond triangle square) msize(vsmall vsmall vsmall) mcolor("221 213 199" "70 87 94" "238 31 96") lpattern(solid solid solid) lcolor("221 213 199" "70 87 94" "238 31 96")) ///
, ///
by(agegroup, rows(1) imargin(l=1 r=1 b=0 t=0)) ///
by(, title("Tracking changes in California's household population", color("0 50 98") size(large) pos(11) justification(left))) ///
by(, subtitle("Percentage of each age group represented by each relationship category", color("59 126 161") size(small) pos(11) justification(left))) ///
subtitle(, color(white) size(small) lcolor("59 126 161") fcolor("59 126 161")) ///
xtitle("Year", size(small) color(gs6) bmargin(zero)) xscale(lstyle(none)) ///
xlabel(1940 1950 1960 1970 1980 1990 2000 2010 2020, labsize(1.7) angle(45) glcolor(gs9%0) labcolor(gs6) tlength(1.25) tlcolor(gs6%30)) xmtick(2000(1)2022, tlength(.75) tlcolor(gs9%30)) ///
ytitle("") ///
yscale(lstyle(none)) ///
ylabel(0 "0%" .10 "10%" .20 "20%" .30 "30%" .40 "40%" .50 "50%" .60 "60%" .70 "70%", angle(0) gmax gmin glpattern(solid) glcolor(gs9%15) glwidth(vthin) labcolor("59 126 161") labsize(2.5) tlength(0) tlcolor(gs9%15)) ///
legend(order(3 "Child/child-in-law" 1 "Other relatives" 2 "Partner or non-relatives") ring(0) pos(12) rows(2) bmargin(zero)) ///
by(, legend(order(3 "Child/child-in-law" 1 "Other relatives" 2 "Partner or non-relatives") ring(0) pos(12) rows(2) bmargin(zero))) ///
by(, note("Source: {fontface Lato:Author's analysis of IPUMS-USA.} Sample: {fontface Lato:Adult civilian household residents in California.}" `notes', margin(l+1.5) color(gs7) span size(vsmall) position(7))) ///
by(, caption("@jamesohawkins {fontface Lato:with} youngamericans.berkeley.edu", margin(l+1.5 t-1) color(gs7%50) span size(vsmall) position(7))) ///
by(, graphregion(margin(0 0 0 0) fcolor(white) lcolor(white) lwidth(medium) ifcolor(white) ilcolor(white) ilwidth(medium))) ///
by(, plotregion(margin(0 0 0 0) fcolor(white) lcolor(white) lwidth(medium) ifcolor(white) ilcolor(white) ilwidth(medium))) ///
by(, graphregion(margin(r+2)))
cd "$directory\output"
graph export relateshare_byagegroup.png, replace


/// ============================================================================
**# 2. Figure 2: CA Aggregate Homeownership Rate
/// ============================================================================
/* In this section, I estimate and plot homeownership rates in California over
   time using the conventional household measure and a person measure, as well
   as extended results restricting the analysis to ages 25+. */

// Household homeownership rates
cd "$directory\derived-data"
use ipumsusa_wrangled.dta, clear
** restrict analysis to CA
keep if statefip == 6
** estimate household homeownership rates
keep if relate == 1 // restrict sample to head of household
collapse (mean) ownhh [pw = hhwt], by(year)
tempfile household
save `household'.dta, replace

// Person homeownership rates
cd "$directory\derived-data"
use ipumsusa_wrangled.dta, clear
** restrict analysis to CA
keep if statefip == 6
** estimate person homeownership rates
collapse (mean) ownp1 ownp2 ownp3 [pw = perwt], by(year)

// Merge household and person estimates
merge 1:1 year using `household'.dta, nogen
** remove 1950 observations: homeownership var unavailable
drop if year == 1950

// Save estimates
cd "$directory\output"
save ownrate.dta, replace

// Visualization (Figure 2)
** text labels
gen ownhh_text = round(ownhh, .001) * 100
tostring(ownhh_text), replace format("%12.1f") force
replace ownhh_text = ownhh_text + "%"
gen ownp1_text = round(ownp1, .001) * 100
tostring(ownp1_text), replace format("%12.1f") force
replace ownp1_text = ownp1_text + "%"
* graph notes
linewrap, maxlength(150) name("notes") stack longstring("Visualization shows the trends in homeownership rates in California over time (1940-2022) for ages 25+. The household homeownership measure counts homeowners as any household head (reference person) who either owned their dwelling outright or with a mortgage. All other reference persons are non-owners. The individual homeownership measure counts homeowners as any reference person who either owned outright or with a mortgage AND the spouse/partner of a reference person who owned. All other persons are considered non-owners. Partners and roommates cannot be separately distinguished in 1980 or earlier; therefore, only spouses are counted as potential owners in the individual measure in 1980 or earlier. Homeownership data in 1950 is unavailable.")
local notes = `" "Notes: {fontface Lato:`r(notes1)'}""'
local y = r(nlines_notes)
forvalues i = 2/`y' {
	local notes = `"`notes' "{fontface Lato:`r(notes`i')'}""'
}
** color palette
colorpalette cblind
** graph
twoway (line ownp1 ownhh year, lcolor("`r(p4)'" "`r(p8)'") lpattern(solid solid)) ///
(scatter ownp1 ownhh year, mfcolor(white white) mlcolor("`r(p4)'" "`r(p8)'") msymbol(circle square) msize(small .8)) ///
(scatter ownhh year if year == 1980, msymbol(none) mcolor(white%0) mlabel(ownhh_text) mlabposition(12) mlabcolor("`r(p8)'") mlabsize(2.2)) ///
(scatter ownhh year if year == 2022, msymbol(none) mcolor(white%0) mlabel(ownhh_text) mlabposition(3) mlabgap(1.2) mlabcolor("`r(p8)'") mlabsize(2.2)) ///
(scatter ownp1 year if year == 1980, msymbol(none) mcolor(white%0) mlabel(ownp1_text) mlabposition(12) mlabcolor("`r(p4)'") mlabsize(2.2)) ///
(scatter ownp1 year if year == 2022, msymbol(none) mcolor(white%0) mlabel(ownp1_text) mlabposition(3) mlabgap(1.2) mlabcolor("`r(p4)'") mlabsize(2.2)) ///
if year != 1950 ///
, ///
title("Trends in California's homeownership rate", color("0 50 98") size(large) pos(11) justification(left)) ///
subtitle("Homeownership rate", color("59 126 161") size(small) pos(11) justification(left)) ///
xtitle("Year", color(gs6) margin(b-1 t-1)) xscale(lstyle(none)) ///
xlabel(1940 1960 1970 1980 1990 2000 2005 2010 2015 2020 2022, angle(45) glcolor(gs9%0) labcolor(gs6) tlength(1.25) tlcolor(gs6%30)) xmtick(2000(1)2022, tlength(.75) tlcolor(gs9%30)) ///
ytitle("") ///
yscale(lstyle(none)) ///
ylabel(.30 "30%" .40 "40%" .50 "50%" .60 "60%", angle(0) gmax gmin glpattern(solid) glcolor(gs9%15) glwidth(vthin) labcolor("59 126 161") labsize(2.5) tlength(0) tlcolor(gs9%15)) ///
legend(order(4 "Household measure" 3 "Person measure" ) ring(0) rows(2) pos(4) bmargin(t-2 b-1)) ///
note("Source: {fontface Lato:Author's analysis of IPUMS-USA.}" "Sample: {fontface Lato:California adult householders [household measure] or adult civilian residents [person measure].}" `notes', margin(l+1) color(gs7) span size(vsmall) position(7)) ///
caption("@jamesohawkins {fontface Lato:with} youngamericans.berkeley.edu", margin(l+1.5 t-1) color(gs7%50) span size(vsmall) position(7)) ///
graphregion(margin(0 0 0 0) fcolor(white) lcolor(white) lwidth(medium) ifcolor(white) ilcolor(white) ilwidth(medium)) ///
plotregion(margin(0 0 0 0) fcolor(white) lcolor(white) lwidth(medium) ifcolor(white) ilcolor(white) ilwidth(medium)) ///
graphregion(margin(r+9))
cd "$directory\output"
graph export ownrate.png, replace


// Extended results: Aggregate homeownership 25+
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Household homeownership rates
cd "$directory\derived-data"
use ipumsusa_wrangled.dta, clear
** restrict to 25+
keep if age >= 25
** restrict analysis to CA
keep if statefip == 6
** estimate household homeownership rates
keep if relate == 1 // restrict sample to head of household
collapse (mean) ownhh [pw = hhwt], by(year)
tempfile household
save `household'.dta, replace

// Person homeownership rates
cd "$directory\derived-data"
use ipumsusa_wrangled.dta, clear
** restrict to 25+
keep if age >= 25
** restrict analysis to CA
keep if statefip == 6
** estimate person homeownership rates
collapse (mean) ownp1 ownp2 ownp3 [pw = perwt], by(year)

// Merge household and person estimates
merge 1:1 year using `household'.dta, nogen
** remove 1950 observations: homeownership var unavailable
drop if year == 1950

// Save estimates
cd "$directory\output"
save ownrate_25orolder.dta, replace

// Visualization: 25+
** text labels
gen ownhh_text = round(ownhh, .001) * 100
tostring(ownhh_text), replace format("%12.1f") force
replace ownhh_text = ownhh_text + "%"
gen ownp1_text = round(ownp1, .001) * 100
tostring(ownp1_text), replace format("%12.1f") force
replace ownp1_text = ownp1_text + "%"
* graph notes
linewrap, maxlength(150) name("notes") stack longstring("Visualization shows the trends in homeownership rates in California over time (1940-2022) for ages 25+. The household homeownership measure counts homeowners as any household head (reference person) who either owned their dwelling outright or with a mortgage. All other reference persons are non-owners. The person homeownership measure counts homeowners as any reference person who either owned outright or with a mortgage AND the spouse/partner of a reference person who owned. All other persons are considered non-owners. Partners and roommates cannot be separately distinguished in 1980 or earlier; therefore, only spouses are counted as potential owners in the individual measure in 1980 or earlier. Homeownership data in 1950 is unavailable.")
local notes = `" "Notes: {fontface Lato:`r(notes1)'}""'
local y = r(nlines_notes)
forvalues i = 2/`y' {
	local notes = `"`notes' "{fontface Lato:`r(notes`i')'}""'
}
** color palette
colorpalette cblind
** graph
twoway (line ownp1 ownhh year, lcolor("`r(p4)'" "`r(p8)'") lpattern(solid solid)) ///
(scatter ownp1 ownhh year, mfcolor(white white) mlcolor("`r(p4)'" "`r(p8)'") msymbol(circle square) msize(small .8)) ///
(scatter ownhh year if year == 1980, msymbol(none) mcolor(white%0) mlabel(ownhh_text) mlabposition(12) mlabcolor("`r(p8)'") mlabsize(2.2)) ///
(scatter ownhh year if year == 2022, msymbol(none) mcolor(white%0) mlabel(ownhh_text) mlabposition(3) mlabgap(1.2) mlabcolor("`r(p8)'") mlabsize(2.2)) ///
(scatter ownp1 year if year == 1980, msymbol(none) mcolor(white%0) mlabel(ownp1_text) mlabposition(6) mlabcolor("`r(p4)'") mlabsize(2.2)) ///
(scatter ownp1 year if year == 2022, msymbol(none) mcolor(white%0) mlabel(ownp1_text) mlabposition(3) mlabgap(1.2) mlabcolor("`r(p4)'") mlabsize(2.2)) ///
if year != 1950 ///
, ///
title("Trends in California's homeownership rate", color("0 50 98") size(large) pos(11) justification(left)) ///
subtitle("Homeownership rate", color("59 126 161") size(small) pos(11) justification(left)) ///
xtitle("Year", color(gs6) margin(b-1 t-1)) xscale(lstyle(none)) ///
xlabel(1940 1960 1970 1980 1990 2000 2005 2010 2015 2020 2022, angle(45) glcolor(gs9%0) labcolor(gs6) tlength(1.25) tlcolor(gs6%30)) xmtick(2000(1)2022, tlength(.75) tlcolor(gs9%30)) ///
ytitle("") ///
yscale(lstyle(none)) ///
ylabel(.30 "30%" .40 "40%" .50 "50%" .60 "60%", angle(0) gmax gmin glpattern(solid) glcolor(gs9%15) glwidth(vthin) labcolor("59 126 161") labsize(2.5) tlength(0) tlcolor(gs9%15)) ///
legend(order(4 "Household measure" 3 "Person measure" ) ring(0) rows(2) pos(4) bmargin(t-2 b-1)) ///
note("Source: {fontface Lato:Author's analysis of IPUMS-USA.}" "Sample: {fontface Lato:California householders 25+ [household measure] or individual civilian residents 25+ [person measure].}" `notes', margin(l+1) color(gs7) span size(vsmall) position(7)) ///
caption("@jamesohawkins {fontface Lato:with} youngamericans.berkeley.edu", margin(l+1.5 t-1) color(gs7%50) span size(vsmall) position(7)) ///
graphregion(margin(0 0 0 0) fcolor(white) lcolor(white) lwidth(medium) ifcolor(white) ilcolor(white) ilwidth(medium)) ///
plotregion(margin(0 0 0 0) fcolor(white) lcolor(white) lwidth(medium) ifcolor(white) ilcolor(white) ilwidth(medium)) ///
graphregion(margin(r+9))
cd "$directory\output"
graph export ownrate_25orolder.png, replace


/// ============================================================================
**# Figure 3: Homeownership rates in California and (rest of) United States, by age group
/// ============================================================================
/* In this section, I estimate and plot person homeownership rates in California 
   and the United States over time, by age group, using ACS and Decennial Census 
   data from IPUMS-USA. */

// Estimate California homeownership rates
cd "$directory\derived-data"
use ipumsusa_wrangled.dta, clear
** restrict to CA data
keep if statefip == 6
** estimate household homeownership rates
preserve
	keep if relate == 1 // restrict sample to head of household
	collapse (mean) ownhh_CA = ownhh [pw = hhwt], by(year agegroup)
	tempfile household_CA
	save `household_CA'.dta, replace
restore
** estimate person homeownership rates
collapse (mean) ownp1_CA = ownp1 ownp2_CA = ownp2 ownp3_CA = ownp3 [pw = perwt], by(year agegroup)
** merge household measure
merge 1:1 year agegroup using `household_CA'.dta, nogen
** save CA rates
tempfile rates_CA
save `rates_CA'.dta, replace

// Estimate United States homeownership rates
cd "$directory\derived-data"
use ipumsusa_wrangled.dta, clear
** restrict to rest of US (outside of CA)
drop if statefip == 6
** estimate household homeownership rates
preserve
	keep if relate == 1 // restrict sample to head of household
	collapse (mean) ownhh_US = ownhh [pw = hhwt], by(year agegroup)
	tempfile household_US
	save `household_US'.dta, replace
restore
** estimate person homeownership rates
collapse (mean) ownp1_US = ownp1 ownp2_US = ownp2 ownp3_US = ownp3 [pw = perwt], by(year agegroup)
merge 1:1 year agegroup using `household_US'.dta, nogen

// Merge CA rates to US rates
merge 1:1 year agegroup using `rates_CA'.dta, nogen

// Save estimates
cd "$directory\output"
save ownrate_byagegroup.dta, replace

// Visualization (Figure 3)
** graph notes
linewrap, maxlength(145) name("notes") stack longstring("Visualization shows the trends in homeownership rates in California and the rest of the United States over time (1940-2022), by age group. The individual measure counts homeowners as any reference person who either owned outright or with a mortgage AND the spouse/partner of a reference person who owned. All other persons are considered non-owners. Partners and roommates cannot be separately distinguished in 1980 or earlier; therefore, only spouses are counted as potential owners in the individual measure in 1980 or earlier. Homeownership data in 1950 is unavailable.")
local notes = `" "Notes: {fontface Lato:`r(notes1)'}""'
local y = r(nlines_notes)
forvalues i = 2/`y' {
	local notes = `"`notes' "{fontface Lato:`r(notes`i')'}""'
}
** color palette
colorpalette cblind
** graph
twoway (connected ownp1_CA ownp1_US year, msize(vsmall vsmall) msymbol(circle square) mcolor("`r(p4)'" "70 87 94") lwidth(vthin vthin) lpattern(solid solid) lcolor("`r(p4)'" "70 87 94")) ///
if year != 1950 ///
, ///
by(agegroup, rows(1) imargin(l=1 r=1 b=0 t=0)) ///
by(, title("Trends in homeownership rates over time", color("0 50 98") size(large) pos(11) justification(left))) ///
by(, subtitle("Homeownership rates (person measure), by age group", color("59 126 161") size(small) pos(11) justification(left))) ///
subtitle(, color(white) size(small) lcolor("59 126 161") fcolor("59 126 161")) ///
xtitle("Year", size(small) color(gs6) margin(t-1 b-1)) xscale(lstyle(none)) ///
xlabel(1940 1960 1970 1980 1990 2000 2010 2020, labsize(1.7) angle(45) glcolor(gs9%0) labcolor(gs6) tlength(1.25) tlcolor(gs6%30)) xmtick(2000(1)2022, tlength(.75) tlcolor(gs9%30)) ///
ytitle("") ///
yscale(lstyle(none)) ///
ylabel(0 "0%" .20 "20%" .40 "40%" .60 "60%" .80 "80%", angle(0) gmax gmin glpattern(solid) glcolor(gs9%15) glwidth(vthin) labcolor("59 126 161") labsize(2.5) tlength(0) tlcolor(gs9%15)) ///
legend(order(1 "California" 2 "Rest of United States") ring(0) pos(12) rows(1) bmargin(zero)) ///
by(, legend(order(1 "California" 2 "Rest of United States") ring(0) pos(12) rows(1) bmargin(zero))) ///
by(, note("Source: {fontface Lato:Author's analysis of IPUMS-USA.} Sample: {fontface Lato:California civilian residents [person measure] age 18 or older.}" `notes', margin(l+1.5) color(gs7) span size(vsmall) position(7))) ///
by(, caption("@jamesohawkins {fontface Lato:with} youngamericans.berkeley.edu", margin(l+1.5 t-1) color(gs7%50) span size(vsmall) position(7))) ///
by(, graphregion(margin(0 0 0 0) fcolor(white) lcolor(white) lwidth(medium) ifcolor(white) ilcolor(white) ilwidth(medium))) ///
by(, plotregion(margin(0 0 0 0) fcolor(white) lcolor(white) lwidth(medium) ifcolor(white) ilcolor(white) ilwidth(medium))) ///
by(, graphregion(margin(r+2)))
cd "$directory\output"
graph export ownrate_byagegroup.png, replace


/// ============================================================================
**# Figure 4: Homeownership Rates by Commuting Zone
/// ============================================================================
/* In this section, I estimate and plot homeownership rates in California 
   over time for each group and in each commuting zone. My analysis takes 
   inspiration from Hoxie, Shoag, & Veuger (2023)
   [https://www.sciencedirect.com/science/article/pii/S0047272723000889#fn6]
   and uses commuter zone delineations from David Dorn 
   [https://www.ddorn.net/data.htm#Local%20Labor%20Market%20Geography] and 
   density data from David Autor 
   [https://www.aeaweb.org/articles?id=10.1257/pandp.20191110]. 
   Please refer to 01_wrangling.do or the README for this repository for more 
   information on the underlying data.*/

// Estimate commuting zone homeownership (weighted by adjusted person weight)
** load czone data
cd "$directory\derived-data"
use czone_ca.dta, clear
** estimate homeownership and number of people in each year/age group/commuting zone
gen person = 1
collapse (mean) ownp1 (sum) person [pw = adjweight], by(year agegroup czone)

// Merge commuting zone density (1970) data
merge m:1 czone using lndens_70.dta, nogen
drop if year == .

// Identify largest place for select commuting zones (courtesy of data provided by Philip Hoxie)
sort czone agegroup year
gen abb = "LA" if czone == 38300
replace abb = "SF" if czone == 37800
replace abb = "SD" if czone == 38000
replace abb = "Sac" if czone == 37400
replace abb = "Fresno" if czone == 37200
replace abb = "Redding" if czone == 36600

// Regression estimates
reg ownp1 c.lndens_70##ib1980.year if agegroup == 2 [pw = person]
predict pown

// Save estimates
cd "$directory\output"
save ownrateXczdensity_byagegroup.dta, replace

// Visualization (Figure 4)
** graph notes
linewrap, maxlength(155) name("notes") stack longstring("Visualization shows the relationship between person homeownership rates and the natural log of 1970 density for different commuting zone over time in California, by age group. The person homeownership measure counts homeowners as any reference person who either owned outright or with a mortgage AND the spouse/partner of a reference person who owned. All other persons are considered non-owners. Partners and roommates cannot be separately distinguished in 1980 or earlier; therefore, only spouses are counted as potential owners in the individual measure in 1980 or earlier. Commuting zone population density is based on publicly available data from Autor (2019) and is calculated as the natural log of population density. Lines of best fit weighted by the number of adult civilian residents in each age group, commuter zone, year cell. SF corresponds to the San Francisco/Bay Area commuting zone.")
local notes = `" "Notes: {fontface Lato:`r(notes1)'}""'
local y = r(nlines_notes)
forvalues i = 2/`y' {
	local notes = `"`notes' "{fontface Lato:`r(notes`i')'}""'
}
** graph
twoway ///
(lfit ownp1 lndens_70 if year == 1980 [pw = person], lpattern(dash) lcolor("0 176 218")) ///
(lfit ownp1 lndens_70 if year == 2022 [pw = person], lpattern(solid) lcolor("238 31 96") mlwidth(none)) ///
(scatter ownp1 lndens_70 if year == 1980, msymbol(circle) mcolor("0 176 218%25") mlwidth(none)) ///
(scatter ownp1 lndens_70 if year == 2022, msymbol(diamond) mcolor("238 31 96%25") mlwidth(none)) ///
(scatter ownp1 lndens_70 if year == 1980 & agegroup == 2 & inlist(abb, "SF", "Fresno", "Redding"), msymbol(none) mlab(abb) mlabcolor("0 176 218")) ///
(scatter ownp1 lndens_70 if year == 2022 & agegroup == 2 & inlist(abb, "SF", "Fresno", "Redding"), msymbol(none) mlab(abb) mlabcolor("238 31 96")) ///
(scatter ownp1 lndens_70 if year == 1980 & inlist(abb, "SF", "Fresno", "Redding"), msymbol(circle) mcolor("0 176 218%50") mlwidth(none)) ///
(scatter ownp1 lndens_70 if year == 2022 & inlist(abb, "SF", "Fresno", "Redding"), msymbol(diamond) mcolor("238 31 96%50") mlwidth(none)) ///
, ///
by(agegroup, rows(1) imargin(l=1 r=1 b=0 t=0)) ///
by(, title("Changes in relationship between homeownership and density in CA", color("0 50 98") size(large) pos(11) justification(left))) ///
by(, subtitle("Homeownership rate over commuting zone density, age group", color("59 126 161") size(small) pos(11) justification(left))) ///
subtitle(, color(white) size(small) lcolor("59 126 161") fcolor("59 126 161")) ///
xtitle("Commuting Zone Population Density (1970)", size(small) color(gs6) margin(t-1 b-1)) xscale(lstyle(none)) ///
xlabel(`=log(10)' "10" `=log(100)' "100" `=log(1000)' "1,000", labsize(1.7) angle(45) glcolor(gs9%0) labcolor(gs6) tlength(1.25) tlcolor(gs6%30)) ///
ytitle("") ///
yscale(lstyle(none)) ///
ylabel(0 "0%" .20 "20%" .40 "40%" .60 "60%" .80 "80%" 1 "100%", angle(0) gmax gmin glpattern(solid) glcolor(gs9%15) glwidth(vthin) labcolor("59 126 161") labsize(2.5) tlength(0) tlcolor(gs9%15)) ///
legend(order(1 "Line of best fit: 1980" 2 "Line of best fit: 2018-2022") ring(0) pos(12) rows(1) bmargin(zero)) ///
by(, legend(order(1 "Line of best fit: 1980" 2 "Line of best fit: 2018-2022") ring(0) pos(12) rows(2) bmargin(zero))) ///
by(, note("Source: {fontface Lato:Author's analysis of IPUMS-USA.} Sample: {fontface Lato:California civilian residents [person measure] age 18 or older.}" `notes', margin(l+1.5) color(gs7) span size(vsmall) position(7))) ///
by(, caption("@jamesohawkins {fontface Lato:with} youngamericans.berkeley.edu", margin(l+1.5 t-1) color(gs7%50) span size(vsmall) position(7))) ///
text(.6 .01 "1980          ", size(vsmall) justification(right) alignment(middle) color("0 176 218")) ///
text(.34 .01 "2018-22                  ", size(vsmall) justification(right) alignment(middle) color("238 31 96")) ///
by(, graphregion(margin(0 0 0 0) fcolor(white) lcolor(white) lwidth(medium) ifcolor(white) ilcolor(white) ilwidth(medium))) ///
by(, plotregion(margin(0 0 0 0) fcolor(white) lcolor(white) lwidth(medium) ifcolor(white) ilcolor(white) ilwidth(medium))) ///
by(, graphregion(margin(r+2)))
** graph edits
gr_edit .plotregion1.plotregion1[1].textbox2.Delete
gr_edit .plotregion1.plotregion1[1].textbox1.Delete
gr_edit .plotregion1.plotregion1[3].textbox1.Delete
gr_edit .plotregion1.plotregion1[3].textbox2.Delete
gr_edit .plotregion1.plotregion1[4].textbox2.Delete
gr_edit .plotregion1.plotregion1[5].textbox2.Delete
gr_edit .plotregion1.plotregion1[6].textbox2.Delete
gr_edit .plotregion1.plotregion1[7].textbox2.Delete
gr_edit .plotregion1.plotregion1[7].textbox1.Delete
gr_edit .plotregion1.plotregion1[6].textbox1.Delete
gr_edit .plotregion1.plotregion1[5].textbox1.Delete
gr_edit .plotregion1.plotregion1[4].textbox1.Delete
cd "$directory\output"
graph export ownrateXczdensity_byagegroup.png, replace


// Extended results: homeownership rates by commuting zone (all years)
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
cd "$directory\output"
use ownrateXczdensity_byagegroup.dta, clear

// Visualization
** graph notes
linewrap, maxlength(155) name("notes") stack longstring("Visualization shows the relationship between person homeownership rates and the natural log of 1970 density for different commuting zone over time in California, by age group. The person homeownership measure counts homeowners as any reference person who either owned outright or with a mortgage AND the spouse/partner of a reference person who owned. All other persons are considered non-owners. Partners and roommates cannot be separately distinguished in 1980 or earlier; therefore, only spouses are counted as potential owners in the individual measure in 1980 or earlier. Commuting zone population density is based on publicly available data from Autor (2019) and is calculated as the natural log of population density. Lines of best fit weighted by the number of adult civilian residents in each age group, commuter zone, year cell. SF corresponds to the San Francisco/Bay Area commuting zone.")
local notes = `" "Notes: {fontface Lato:`r(notes1)'}""'
local y = r(nlines_notes)
forvalues i = 2/`y' {
	local notes = `"`notes' "{fontface Lato:`r(notes`i')'}""'
}
** graph labels
foreach x of numlist 1970 1980 1990 2000 2010 2022 {
sum pown if year == `x' & agegroup == 2 & abb == "SF"
local own`x' = r(mean)
}
** color palette
colorpalette cblind
** graph
twoway ///
(lfit ownp1 lndens_70 if year == 1970 [pw = person], lpattern(solid) lcolor("`r(p8)'")) ///
(lfit ownp1 lndens_70 if year == 1980 [pw = person], lpattern(solid) lcolor("0 176 218")) ///
(lfit ownp1 lndens_70 if year == 1990 [pw = person], lpattern(solid) lcolor("`r(p3)'")) ///
(lfit ownp1 lndens_70 if year == 2000 [pw = person], lpattern(solid) lcolor("`r(p5)'")) ///
(lfit ownp1 lndens_70 if year == 2010 [pw = person], lpattern(solid) lcolor("`r(p7)'")) ///
(lfit ownp1 lndens_70 if year == 2022 [pw = person], lpattern(solid) lcolor("238 31 96") mlwidth(none)) ///
, ///
by(agegroup, rows(1) imargin(l=1 r=1 b=0 t=0)) ///
by(, title("Changes in relationship between homeownership and density in CA", color("0 50 98") size(large) pos(11) justification(left))) ///
by(, subtitle("Homeownership rate over commuting zone density (all years), age group", color("59 126 161") size(small) pos(11) justification(left))) ///
subtitle(, color(white) size(small) lcolor("59 126 161") fcolor("59 126 161")) ///
xtitle("Commuting Zone Population Density (1970)", size(small) color(gs6) margin(t-1 b-1)) xscale(lstyle(none)) ///
xlabel(`=log(10)' "10" `=log(100)' "100" `=log(1000)' "1,000", labsize(1.7) angle(45) glcolor(gs9%0) labcolor(gs6) tlength(1.25) tlcolor(gs6%30)) ///
ytitle("") ///
yscale(lstyle(none)) ///
ylabel(0 "0%" .20 "20%" .40 "40%" .60 "60%" .80 "80%" 1 "100%", angle(0) gmax gmin glpattern(solid) glcolor(gs9%15) glwidth(vthin) labcolor("59 126 161") labsize(2.5) tlength(0) tlcolor(gs9%15)) ///
legend(off) ///
by(, legend(off)) ///
by(, note("Source: {fontface Lato:Author's analysis of IPUMS-USA.} Sample: {fontface Lato:California civilian residents [person measure] age 18 or older.}" `notes', margin(l+1.5) color(gs7) span size(vsmall) position(7))) ///
by(, caption("@jamesohawkins {fontface Lato:with} youngamericans.berkeley.edu", margin(l+1.5 t-1) color(gs7%50) span size(vsmall) position(7))) ///
text(`own1970' 6.71 " 1970", size(vsmall) justification(left) placement(3) alignment(bottom) color("`r(p8)'")) ///
text(`own1980' 6.71 " 1980", size(vsmall) justification(left) placement(3) alignment(bottom) color("0 176 218")) ///
text(`own1990' 6.71 " 1990", size(vsmall) justification(left) placement(3) alignment(bottom) color("`r(p3)'")) ///
text(`own2000' 6.71 " 2000", size(vsmall) justification(left) placement(3) alignment(bottom) color("`r(p5)'")) ///
text(`own2010' 6.71 " 2010", size(vsmall) justification(left) placement(3) alignment(bottom) color("`r(p7)'")) ///
text(`own2022' 6.71 " 2022", size(vsmall) justification(left) placement(3) alignment(bottom) color("238 31 96")) ///
by(, graphregion(margin(0 0 0 0) fcolor(white) lcolor(white) lwidth(medium) ifcolor(white) ilcolor(white) ilwidth(medium))) ///
by(, plotregion(margin(0 0 0 0) fcolor(white) lcolor(white) lwidth(medium) ifcolor(white) ilcolor(white) ilwidth(medium))) ///
by(, graphregion(margin(r+2)))
** graph edits
gr_edit .plotregion1.plotregion1[1].textbox1.Delete
gr_edit .plotregion1.plotregion1[1].textbox2.Delete
gr_edit .plotregion1.plotregion1[1].textbox3.Delete
gr_edit .plotregion1.plotregion1[1].textbox4.Delete
gr_edit .plotregion1.plotregion1[1].textbox5.Delete
gr_edit .plotregion1.plotregion1[1].textbox6.Delete
gr_edit .plotregion1.plotregion1[3].textbox1.Delete
gr_edit .plotregion1.plotregion1[3].textbox2.Delete
gr_edit .plotregion1.plotregion1[3].textbox3.Delete
gr_edit .plotregion1.plotregion1[3].textbox4.Delete
gr_edit .plotregion1.plotregion1[3].textbox5.Delete
gr_edit .plotregion1.plotregion1[3].textbox6.Delete
gr_edit .plotregion1.plotregion1[4].textbox1.Delete
gr_edit .plotregion1.plotregion1[4].textbox2.Delete
gr_edit .plotregion1.plotregion1[4].textbox3.Delete
gr_edit .plotregion1.plotregion1[4].textbox4.Delete
gr_edit .plotregion1.plotregion1[4].textbox5.Delete
gr_edit .plotregion1.plotregion1[4].textbox6.Delete
gr_edit .plotregion1.plotregion1[5].textbox1.Delete
gr_edit .plotregion1.plotregion1[5].textbox2.Delete
gr_edit .plotregion1.plotregion1[5].textbox3.Delete
gr_edit .plotregion1.plotregion1[5].textbox4.Delete
gr_edit .plotregion1.plotregion1[5].textbox5.Delete
gr_edit .plotregion1.plotregion1[5].textbox6.Delete
gr_edit .plotregion1.plotregion1[6].textbox1.Delete
gr_edit .plotregion1.plotregion1[6].textbox2.Delete
gr_edit .plotregion1.plotregion1[6].textbox3.Delete
gr_edit .plotregion1.plotregion1[6].textbox4.Delete
gr_edit .plotregion1.plotregion1[6].textbox5.Delete
gr_edit .plotregion1.plotregion1[6].textbox6.Delete
gr_edit .plotregion1.plotregion1[7].textbox1.Delete
gr_edit .plotregion1.plotregion1[7].textbox2.Delete
gr_edit .plotregion1.plotregion1[7].textbox3.Delete
gr_edit .plotregion1.plotregion1[7].textbox4.Delete
gr_edit .plotregion1.plotregion1[7].textbox5.Delete
gr_edit .plotregion1.plotregion1[7].textbox6.Delete
cd "$directory\output"
graph export ownrateXczdensity_allyears_byagegroup.png, replace


// Extended results: Homeownership Rates by select geographic groups
// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
/* In this sub-section, I estimate and plot person homeownership rates in 
   California over time, by geographic group and age group, using IPUMS-USA. */
cd "$directory\derived-data"
use ipumsusa_wrangled.dta, clear

// Restrict to CA data
keep if statefip == 6

gen countygroup = 0 // rest of state
replace countygroup = 1 if inlist(countyfip, 75, 81, 1, 85, 13) // San Francisco, San Mateo, Alameda, Santa Clara, Contra Costa)
replace countygroup = 2 if countyfip == 37 // Los Angeles
replace countygroup = 3 if countyfip == 73 // San Diego
replace countygroup = . if inrange(year, 2001, 2004) // countyfip not available in these samples
lab def countygroup_lbl ///
	0 "Rest of state" ///
	1 "Bay Area" ///
	2 "Los Angeles" ///
	3 "San Diego"
lab val countygroup countygroup_lbl

// Estimate person homeownership rates
collapse (mean) ownp1 [pw = perwt], by(year agegroup countygroup)

// Save estimates
cd "$directory\output"
save ownrateXgeo_byagegroup.dta, replace

// Visualization
* graph notes
linewrap, maxlength(155) name("notes") stack longstring("Visualization shows the trends in homeownership rates in California for different geographic groups (1960-2022), by age group. The person homeownership measure counts homeowners as any reference person who either owned outright or with a mortgage AND the spouse/partner of a reference person who owned. All other persons are considered non-owners. Partners and roommates cannot be separately distinguished in 1980 or earlier; therefore, only spouses are counted as potential owners in the individual measure in 1980 or earlier. Metropolitan area is available in 2003; however, due to anomalous estimates for the LA, SF, SD group, I exclude these estimates.")
local notes = `" "Notes: {fontface Lato:`r(notes1)'}""'
local y = r(nlines_notes)
forvalues i = 2/`y' {
	local notes = `"`notes' "{fontface Lato:`r(notes`i')'}""'
}
* graph
twoway (connected ownp1 year if countygroup == 1, msize(vsmall) msymbol(square) mcolor("238 31 96") lwidth(vthin) lpattern(solid) lcolor("238 31 96")) ///
(connected ownp1 year if countygroup == 2, msize(vsmall) msymbol(triangle) mcolor("70 87 94") lwidth(vthin) lpattern(solid) lcolor("70 87 94")) ///
(connected ownp1 year if countygroup == 3, msize(vsmall) msymbol(circle) mcolor("0 176 218") lwidth(vthin) lpattern(solid) lcolor("0 176 218")) ///
(connected ownp1 year if countygroup == 0, msize(vsmall) msymbol(diamond) mcolor(gray) lwidth(vthin) lpattern(solid) lcolor(gray)) ///
if year >= 1960 ///
, ///
by(agegroup, rows(1) imargin(l=1 r=1 b=0 t=0)) ///
by(, title("Trends in homeownership rates over time", color("0 50 98") size(large) pos(11) justification(left))) ///
by(, subtitle("Homeownership rates, by metropolitan status and age group", color("59 126 161") size(small) pos(11) justification(left))) ///
subtitle(, color(white) size(small) lcolor("59 126 161") fcolor("59 126 161")) ///
xtitle("Year", size(small) color(gs6) bmargin(zero)) xscale(lstyle(none)) ///
xlabel(1960 1970 1980 1990 2000 2010 2020, labsize(1.7) angle(45) glcolor(gs9%0) labcolor(gs6) tlength(1.25) tlcolor(gs6%30)) xmtick(2005(1)2022, tlength(.75) tlcolor(gs9%30)) ///
ytitle("") ///
yscale(lstyle(none)) ///
ylabel(0 "0%" .20 "20%" .40 "40%" .60 "60%" .80 "80%", angle(0) gmax gmin glpattern(solid) glcolor(gs9%15) glwidth(vthin) labcolor("59 126 161") labsize(2.5) tlength(0) tlcolor(gs9%15)) ///
legend(order(1 "Bay Area" 2 "Los Angeles" 3 "San Diego" 4 "Rest of state") ring(0) pos(12) rows(1) bmargin(zero)) ///
by(, legend(order(1 "California" 2 "United States") ring(0) pos(12) rows(1) bmargin(zero))) ///
by(, note("Source: {fontface Lato:Author's analysis of IPUMS-USA.} Sample: {fontface Lato:Civilian residents [person measure] age 18 or older.}" `notes', margin(l+1.5) color(gs7) span size(vsmall) position(7))) ///
by(, caption("@jamesohawkins {fontface Lato:with} youngamericans.berkeley.edu", margin(l+1.5 t-1) color(gs7%50) span size(vsmall) position(7))) ///
by(, graphregion(margin(0 0 0 0) fcolor(white) lcolor(white) lwidth(medium) ifcolor(white) ilcolor(white) ilwidth(medium))) ///
by(, plotregion(margin(0 0 0 0) fcolor(white) lcolor(white) lwidth(medium) ifcolor(white) ilcolor(white) ilwidth(medium))) ///
by(, graphregion(margin(r+2)))
cd "$directory\output"
graph export ownrateXgeo_byagegroup.png, replace


/// ============================================================================
**# 5. Permits Per Capita
/// ============================================================================
/* In this section, I calculate housing permits in California for every thousand
   residents between 2009 and 2022. I use permit data from the U.S. Census 
   Bureau and resident population data from USA Facts (for the entire U.S.) and
   FRED (for California). */

// Resident population data (U.S.)
cd "$directory\raw-data"
import delimited resident_population_usafacts.csv, clear
keep in 1/2
xpose, clear
rename v1 year
rename v2 popUS
keep if year >= 2009 & year < 2022
collapse (sum) popUS
gen ca = 0
cd "$directory\derived-data"
save popUS.dta, replace

// Resident population data (California)
cd "$directory\raw-data"
import delimited CAPOP.csv, clear
gen year = substr(date, 1, 4)
destring year, replace
keep capop year
order year
keep if year >= 2009 & year <= 2022
replace capop = capop * 1000
collapse (sum) capop
gen ca = 1
cd "$directory\derived-data"
save popCA.dta, replace

// Permits data
cd "$directory\raw-data"
import delimited permits.csv, clear
** wrangle data
destring totalunits, replace ignore(",")
rename statename state
keep if surveydate >= 2009 & surveydate <= 2022 // same years as pop data
** estimate total units permitted by state
collapse (sum) totalunits, by(state)
gen ca = (state == "California")
collapse (sum) totalunits, by(ca)

// Merge and wrangle permits and residents data
cd "$directory\derived-data"
merge 1:1 ca using popUS.dta, nogen
merge 1:1 ca using popCA.dta, nogen
gen pop = popUS if popUS != .
replace pop = capop if capop != .
sum pop if ca == 1
replace pop = pop - r(mean) if ca == 0 // subtract CA pop from US pop to get rest of CA
drop popUS capop

// Estimate permits per 1000 residents
gen permits_per1000pop = totalunits / (pop / 1000)

// Save estimates
cd "$directory\output"
save permits_per1000pop.dta, replace