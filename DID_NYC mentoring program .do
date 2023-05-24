*Title: Graded Assignment 3
*Author: Siqi Wang
*Date: March 14, 2023

clear all                                                                             
capture log close
set more off

*change to your directory & read in data
cd "/Users/wsq/Desktop/Estimating Impact in Policy Research/Graded Assignment 3"
use "mentorStata9_copy.dta",clear

* save log
log using "WangSiqiAssignment3_log", replace

* explore
browse
codebook

*************************
* 2.Describe the sample *
*************************
* Check for parallel trends and attrition by comparing treatment group vs. control
* How well the randomization process worked?
** control group: 131 observaions; treatment group: 109 observations
bys program: sum pastab pastment kennedy classize black hispanic whiteoth
* notes:
** pastsc(continuous)
** score(continuous)
** pastab(continuous)
** absent(continuous)
** classize(continuous)
** kennedy(nominal)

gen race =.
replace race=0 if white==1
replace race=1 if black==1
replace race=2 if hispanic==1
*race(nominal)
oneway pastsc program, tabulate
oneway pastab program,tabulate
tabulate kennedy program,chi2 column
tabulate classize program,chi2 column
tabulate pastment program, chi2 column
tabulate race program, chi2 column

********************************************************
* 3.Basic Study Findings and Examine Program impacts   *
********************************************************
* Method 1: sum
bys program: sum score
bys program: sum pastsc
*effect_on_trt_group=post-pre
di 91.97248-90.22936 //1.74312
*effect_on_control_group=post-pre
di  75.68702-89.50382 //-13.8168
*dif_in_dif
di 1.74312-(-13.8168) //15.55992

bys program: sum absent    
bys program: sum pastab 
*effect_on_trt_group=post-pre
di 6.633028-14.88073   //-8.247702 
*effect_on_control_group=post-pre
di 17.84733-18.51145 // -.66412
*dif_in_dif
di -8.247702 -(-.66412) //-7.583582

gen difsc=score-pastsc

* Method 2: regression
*difference in score
* / without covariates / *
*score
reg pastsc program
reg score program
display 16.28545  - .725541 //15.559909
 
*absent
reg pastab program 
reg absent program
display -11.2143-(-3.630716)  // -7.583584

* / with covariates / *
*score
reg pastsc program black hispanic kennedy i.classize pastment
reg score program black hispanic kennedy i.classize pastment
display   15.43402  - (  .2312176 ) // 15.202802
*absent
reg pastab program black hispanic kennedy i.classize pastment 
reg absent program black hispanic kennedy i.classize pastment 
*dif_in_dif
di  -10.60824 -( -3.0238 ) //-7.58444

* Method 3: DiD Coding regression
*DiD Coding
gen index=_n
gen after=1 
append using mentorStata9
replace after=0 if after==.
replace index=_n-240 if after==0
sort index black hispanic whiteoth kennedy classize program score pastsc absent pastab pastment after
order program, after(after)
gen score2=score if after==1
replace score2=pastsc if after==0
gen absent2=absent if after==1
replace absent2=pastab if after==0
gen after_program = after*program
reg score2 after program after_program black hispanic kennedy i.classize pastment //  15.55991
reg absent2 after program after_program black hispanic kennedy i.classize pastment // -7.583584

* Graph_score	 
graph twoway (lfit pastsc program) (lfit score program),legend(label(1 "Control Group")label(2 "Treatment Group")) title("The program's impact on students' test scores." ) xlabel(minmax) xtitle("Time") ytitle("Score") 
graph export programimpact_on_testscores.png, replace

* Graph_absence	 
graph twoway (lfit pastab program) (lfit absent program),legend(label(1 "Control Group")label(2 "Treatment Group")) title("The program's impact on students' absence." ) xlabel(minmax) xtitle("Time") ytitle("Absent")
graph export programimpact_on_absence.png, replace 

***********************************
* 5.Program's impact on subgroups *
***********************************
* Set A: previously mentored vs. previously not mentored
** subgroup dummy
codebook pastment
** regression
reg difsc program if pastment==0 // coefficient:  16.54575, significant at 0.0000 level
reg difsc program if pastment==1 // coefficient:  3.556548, significant at  0.0042 level
** DiD coding regression
reg score2 after program after_program black hispanic kennedy i.classize if pastment==0 // 16.54575，significant at 0.0000 level
outreg2 using Assignment3Table5,excel ctitle(no past mentor experience,program) append
reg score2 after program after_program black hispanic kennedy i.classize if pastment==1 // 3.556548，significant at 0.0000 level
outreg2 using Assignment3Table5,excel ctitle(have past mentor experience,program) append

* Set B: high absences at baseline vs. low absences at baseline
** generate subgroup dummy
codebook pastab
gen pastablvl=.
replace pastablvl= 0 if pastab <= 16.8625
replace pastablvl= 1 if pastab > 16.8625
label variable pastablvl "absence level at baseline"
** regression
reg difsc program if pastablvl==0 // coefficient: 9.484127, significant at 0.0000 level 
reg difsc program if pastablvl==1 // coefficient: 17.50649, significant at 0.0000 level 
reg score2 after program after_program black hispanic kennedy i.classize if pastablvl==0 // 9.484127
outreg2 using Assignment3Table5,excel ctitle(low absences at baseline,program) append
reg score2 after program after_program black hispanic kennedy i.classize if pastablvl==1 // 17.50649
outreg2 using Assignment3Table5,excel ctitle(high absences at baseline,program) append
help label
capture log close

save GradedAssignment3_WangSiqi, replace
translate "WangSiqiAssignment3_log.smcl" "WangSiqiAssignment3_log.pdf", replace fontsize(9) lmargin(.5) rmargin(.5) tmargin(.75) bmargin(.75) 

