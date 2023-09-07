
*------------------------------------------------------------------------------*
/*
Title: Performance Task Cleaning 
Person:  Steffen Erickson 
Date:    9/2/22 
Purpose: Data Cleaning - NSF Performance Task 
*/ 
*------------------------------------------------------------------------------*

mkf simse_performance_tasks
frame simse_performance_tasks {

import excel "outcome_data/F22: NSF Performance Task Coding_September 1, 2023_13.14.xlsx", sheet("Sheet0") firstrow case(lower) clear

#delimit ; 
drop in 1;
drop startdate 
	 enddate 
	 status
	 durationinseconds
	 ipaddress 
	 externalreference 
	 locationlatitude 
	 locationlongitude 
	 distributionchannel 
	 userlanguage 
	 q2_firstclick 
	 q2_lastclick 
	 q2_pagesubmit 
	 q2_clickcount
	 recipientlastname
	 recipientfirstname
	 recipientemail;
#delimit cr

keep if finished == "True"

*------------------------------------------------------------------------------*
* Create ID, site, rater, time, and semester variables from file names 
*------------------------------------------------------------------------------*
split q9, parse(_ -)

* site
rename q91 site 
encode site , gen(site2)
drop site
rename site2 site 
label define sites5 1 "UVA" 2 "UD" 3 "JMU"
label values site sites5


*id
rename q94 participantid 
drop if q92 == ""

*time and task 
encode q95, gen(Q95)
tab Q95
tab Q95, nolabel
recode Q95 (2 = 1) (4 = 3) (7 = 6) ( 11/16 = 10)
tab Q95
tab Q95, nolabel
recode Q95 (3 = 2) (5 = 3) (6 = 4) (8 = 5) (9 = 6) (10 = 7)
tab Q95 
tab Q95, nolabel
rename Q95 task 
gen time = 0 if task == 1 | task == 2 | task == 3 
replace time = 1 if task == 4 | task == 5 | task == 6
replace time = 2 if task == 7
label define t 1 "Task 1" 2 "Task 2" 3 "Task 3" 4 "Task 4" 5 "Task 5" 6 "Task 6" 7 "Placement"
label values task t 

*semester
encode q92, gen(semester)

recode semester (1=0) (2=1)
label define sems 0 "F22" 1 "S23"
label values semester sems 




drop q95  q93 
										   							   
											  
*------------------------------------------------------------------------------*
* Rename 
*------------------------------------------------------------------------------*

rename q31   rater 
rename q47   dc
rename q42_1 x1
rename q42_2 x2
rename q42_3 x3
rename q42_4 x4
rename q42_5 x5
rename q42_6 x6
rename q39   os_categorical
rename q19   use_visual
rename sc0   os_rubric_sum
rename q45 	 comment 
rename q9	 filename 

*------------------------------------------------------------------------------*
* Convert strings to encoded factor variables or numeric variables 
*------------------------------------------------------------------------------*
local varlist dc x1 x2 x3 x4 x5 x6 os_categorical use_visual 
		   
label define target 1 "Off Target" 2 "Approaching Target" 3 "On Target"
foreach var in `varlist' {
	encode `var', gen(`var'2)
	drop `var'
	rename `var'2 `var'
}

label values x1-x6 target

foreach var of varlist x1-x6  {
	recode `var' (2 = 1) (1 = 2) 
}

destring os_rubric_sum, replace 
destring rater, replace 



sort semester participantid  site task time rater
order semester participantid  site task time rater	

*------------------------------------------------------------------------------*
* Label Variables
*------------------------------------------------------------------------------*

label var time "pre/post set"
label var rater "Assigned Rater"
label var participantid  "Participant ID"
label var task "Content Task"
label var x1 "Objective for Metacognitive Model"
label var x2 "Quality of Unpacking the Word Problem"
label var x3 "Quality of Self-Instruction"
label var x4 "Quality of Self-Regulation"
label var x5  "Ending the Metacognitive Model"
label var x6 "Accuracy and Clarity"
label var os_categorical "Categorical"
label var use_visual "The teacher used a visual"
label var os_rubric_sum "Simple sum of rubric scores" //do not use this variable 
											   //- not actually rubric score sum 

											 
drop q48 q49 comment progress finished q92 responseid responseid recordeddate





}									  
