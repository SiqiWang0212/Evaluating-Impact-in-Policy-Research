*Title: Graded Assignment 1
*Author: Siqi Wang
*Date: February 26, 2023

clear all                                                                             
capture log close
set more off

* save log
log using "/Users/wsq/Desktop/Estimating Impact in Policy Research/WangSiqiAssignment1_log", replace

* * change to your directory & read in data
cd "/Users/wsq/Desktop/Estimating Impact in Policy Research/Graded Assignment 1"
use "Medicare EIPR Stata16 2021.dta",clear

* explore
describe
browse

*check categories of categorical variables
tabulate agegrp 
tabulate sex
tabulate race
tabulate educate 
tabulate genhelth 
tabulate supplement
label define supplement 0 "No supplemental insurance", modify
label define supplement 1 "Has a supplemental insurance", modify


*create education categories
*drop educ_cat
codebook totincm
egen totincm_tcl =  cut (totincm), group (3) label
tabulate totincm_tcl
tabstat totincm, by (totincm_tcl) stat (n min max)
codebook totincm_tcl
label variable totincm_tcl "Income tercile"
label define totincm_tcl 0 "Low", modify
label define totincm_tcl 1 "Middle", modify
label define totincm_tcl 2 "High", modify

* table 1
tabulate agegrp supplement, column chi2 missing
tabulate sex supplement, column chi2 missing
tabulate race supplement, column chi2 missing
tabulate totincm_tcl supplement, column chi2 missing
tabulate educate supplement, column chi2 missing
tabulate genhelth supplement, column chi2 missing

* table 2
describe tot_expend2015
*get means by category
mean tot_expend2015, over(supplement)
mean tot_expend2015, over(agegrp)
mean tot_expend2015, over(sex)
mean tot_expend2015, over(race)
mean tot_expend2015, over(totincm_tcl)
mean tot_expend2015, over(educate)
mean tot_expend2015, over(genhelth)

*get significance level
*oneway command
oneway tot_expend2015 supplement, tabulate means
oneway tot_expend2015 agegrp, tabulate means
oneway tot_expend2015 sex, tabulate means
oneway tot_expend2015 race, tabulate means
oneway tot_expend2015 totincm_tcl, tabulate means
oneway tot_expend2015 educate, tabulate means
oneway tot_expend2015 genhelth, tabulate means

* table 3
*unadjusted
regress tot_expend2015 i.supplement

*adjusted
regress tot_expend2015 i.supplement i.agegrp i.sex i.race i.totincm_tcl i.educate i.genhelth

capture log close

translate "/Users/wsq/Desktop/Estimating Impact in Policy Research/WangSiqiAssignment1_log.smcl" "WangSiqiAssignment1_log.pdf", replace fontsize(9) lmargin(.5) rmargin(.5) tmargin(.75) bmargin(.75) 











