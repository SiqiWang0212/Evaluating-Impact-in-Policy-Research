*Title: Graded Assignment 4
*Author: Siqi Wang
*Date: April 30, 2023

clear all                                                                             
capture log close
set more off

*change to your directory & read in data
cd "/Users/wsq/Desktop/Estimating Impact in Policy Research/Graded Assignment 4"
use "Suspensions 2009 to 2017.dta",clear

* save log
log using "WangSiqiAssignment4_log", replace

* Generate Treatment variable DPD
gen DPD = 0
replace DPD = 1 if (inlist(District, 1,5,6,7) & Year>=2013) | (inlist(District, 8,9,14,17,20,21) & Year>=2014)

gen everDPD=1 if (inlist(District,1,5,6,7,8,9,14,17,20,21))
replace everDPD=0 if (inlist(District,2,3,4,10,11,12,13,15,16,18,19,22))
save "Suspensions 2009 to 2017_panel.dta",replace

oneway Suspensions everDPD,tabulate
oneway Suspensions everDPD if (inlist(Year,2009,2010,2011,2012)), tabulate

oneway Suspensions everDPD if Year==2009, tabulate
oneway Suspensions everDPD if Year==2010, tabulate
oneway Suspensions everDPD if Year==2011, tabulate
oneway Suspensions everDPD if Year==2012, tabulate
oneway Suspensions everDPD if Year==2013, tabulate
oneway Suspensions everDPD if Year==2014, tabulate
oneway Suspensions everDPD if Year==2015, tabulate
oneway Suspensions everDPD if Year==2016, tabulate
oneway Suspensions everDPD if Year==2017, tabulate


*******************************************************************************
use "Suspensions 2009 to 2017.dta",clear

gen everDPD=1 if (inlist(District,1,5,6,7,8,9,14,17,20,21))
replace everDPD=0 if (inlist(District,2,3,4,10,11,12,13,15,16,18,19,22))

collapse (mean)meanSuS=Suspensions, by(District everDPD)
sort District everDPD

* Difference between evertreated==0 and evertreated==1
** Notes: Suspensions(Continuous), Treatment(Nominal)
oneway meanSuS everDPD,tabulate
save "descriptive_everDPD_general.dta", replace
*******************************************************************************
use "Suspensions 2009 to 2017.dta",clear
gen everDPD=1 if (inlist(District,1,5,6,7,8,9,14,17,20,21))
replace everDPD=0 if (inlist(District,2,3,4,10,11,12,13,15,16,18,19,22))
collapse (mean)meanSuS=Suspensions, by(Year everDPD)
sort Year everDPD

xtset everDPD Year 
xtline meanSuS,overlay title("Time Trend of Mean Suspenstions" , size(meansmall)) xlabel(#9) xline(2013,lpattern(-))
graph export group.png,replace
save "meanSuS_time_trend.dta",replace
*******************************************************************************

use "Suspensions 2009 to 2017_panel.dta"
* 2: Simple Bivariate Regression
gen lnsus=ln(Suspensions)
reg lnsus DPD, robust
outreg2 using Assignment4Table2,excel ctitle(DPD on Sus,Simple Bivariable Regression) append 

* 3: District Fixed Effects
xtset District
xtreg lnsus DPD, fe robust
outreg2 using Assignment4Table2,excel ctitle(DPD on Sus,FE Regression Implict) addtext(District FE,YES) append 

reg lnsus DPD i.District, robust
outreg2 using Assignment4Table3,excel ctitle(District Fixed Effects,FE Regression Explict) addtext(District FE,YES) append

* 4: District Fixed Effects with Time Effects
xtset District Year
xtreg lnsus DPD i.Year, fe robust
outreg2 using Assignment4Table2,excel ctitle(DPD on Sus,Implict) addtext(District FE,YES,Year FE,YES) append

reg lnsus DPD i.District i.Year,robust
outreg2 using Assignment4Table3,excel ctitle(District Fixed Effects with Time Effects,Explict) addtext(District FE,YES,Year FE,YES) append


save GradedAssignment4_WangSiqi, replace
translate "WangSiqiAssignment4_log.smcl" "WangSiqiAssignment4_log.pdf", replace fontsize(9) lmargin(.5) rmargin(.5) tmargin(.75) bmargin(.75) 




