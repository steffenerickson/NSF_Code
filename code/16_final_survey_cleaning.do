//----------------------------------------------------------------------------//
// Final Survey Cleaning File 
// Steffen Erickson 
// 08/25/23
// Run code blocks together 
	//-------------------------//
	
		*code {}
			
	
	
	//-------------------------//
//----------------------------------------------------------------------------//
mkf finalsurvey
frame finalsurvey {

import excel "outcome_data/F22: SimSE Final Survey_August 25, 2023_12.57.xlsx", sheet("Sheet0") firstrow case(lower) clear
keep finished q*
drop in 1
drop if finished == "False"
drop if q14 == "test@test.edu"
*------------------------------------------------------------------------------*
* Rename *
*------------------------------------------------------------------------------*


rename q2_1			  d121_1_2   
rename q2_2           d121_2_2
rename q2_3           d121_3_2
rename q2_4           d121_4_2
rename q2_5           d121_5_2
rename q2_6           d122_1_2
rename q2_7           d122_2_2
rename q2_8           d122_3_2
rename q2_9           d122_4_2
rename q2_10          d122_5_2
rename q2_11          d123_1_2
rename q2_12          d123_2_2
rename q2_13          d123_3_2
rename q2_14          d124_1_2
rename q2_15          d124_2_2
rename q2_16          d124_3_2
rename q2_17          d125_1_2
rename q2_18          d125_2_2
rename q2_19          d125_3_2
rename q14            d11_3
rename q100           d111_2 
rename q101           d112_2
rename q102           d113_2



*------------------------------------------------------------------------------*
* Create Subdimension Scores *
*------------------------------------------------------------------------------*
foreach var of varlist d121_?_2 d122_?_2 d123_?_2 d124_?_2 d125_?_2 {
	tempvar `var'_2 
	gen ``var'_2' = substr(`var',2,1)
	drop `var'
	rename ``var'_2' `var'
	destring `var' , replace
}

egen d126_1_2 = rowmean(d121_1_2 d121_2_2 d121_3_2 d121_4_2 d121_5_2)
egen d126_2_2 = rowmean(d122_1_2 d122_2_2 d122_3_2 d122_4_2 d122_5_2)
egen d126_3_2 = rowmean(d123_1_2 d123_2_2 d123_3_2)
egen d126_4_2 = rowmean(d124_1_2 d124_2_2 d124_3_2)
egen d126_5_2 = rowmean(d125_1_2 d125_2_2 d125_3_2)
egen d126_6_2 = rowmean(d126_1_2 d126_2_2 d126_3_2 d126_4_2 d126_5_2)

*------------------------------------------------------------------------------*
* Label 
*------------------------------------------------------------------------------*

cap label variable d121_1_2   "Efficacy Question 1 Subquestion 1 - time 2"
cap label variable d121_2_2   "Efficacy Question 1 Subquestion 2 - time 2"
cap label variable d121_3_2   "Efficacy Question 1 Subquestion 3 - time 2"
cap label variable d121_4_2   "Efficacy Question 1 Subquestion 4 - time 2"
cap label variable d121_5_2   "Efficacy Question 1 Subquestion 5 - time 2"
cap label variable d122_1_2   "Efficacy Question 2 Subquestion 1 - time 2"
cap label variable d122_2_2   "Efficacy Question 2 Subquestion 2 - time 2"
cap label variable d122_3_2   "Efficacy Question 2 Subquestion 3 - time 2"
cap label variable d122_4_2   "Efficacy Question 2 Subquestion 4 - time 2"
cap label variable d122_5_2   "Efficacy Question 2 Subquestion 5 - time 2"
cap label variable d123_1_2   "Efficacy Question 3 Subquestion 1 - time 2"
cap label variable d123_2_2   "Efficacy Question 3 Subquestion 2 - time 2"
cap label variable d123_3_2   "Efficacy Question 3 Subquestion 3 - time 2"
cap label variable d124_1_2   "Efficacy Question 4 Subquestion 1 - time 2"
cap label variable d124_2_2   "Efficacy Question 4 Subquestion 2 - time 2"
cap label variable d124_3_2   "Efficacy Question 4 Subquestion 3 - time 2"
cap label variable d125_1_2   "Efficacy Question 5 Subquestion 1 - time 2"
cap label variable d125_2_2   "Efficacy Question 5 Subquestion 2 - time 2"
cap label variable d125_3_2   "Efficacy Question 5 Subquestion 3 - time 2"
cap label variable d126_1_2   "Efficacy in instruction subscale - time 2" //efficacy_instruction 
cap label variable d126_2_2   "Efficacy in professionalism subscale - time 2" //efficacy_professionalism 
cap label variable d126_3_2   "Efficacy in teaching supports subscale - time 2" //efficacy_teach_support 
cap label variable d126_4_2   "Efficacy in classroom management subscale - time 2" //efficacy_class_manage 
cap label variable d126_5_2   "Efficacy in related duties subscale - time 2" //efficacy_related_duties 
cap label variable d126_6_2   "Efficacy overall score (mean of subscale scores) - time 2" //efficacy_overall 
cap label variable d111_2     "Module-Related - Supporting SWDs" 
cap label variable d112_2     "Module-Related - Math Word Problems"
cap label variable d113_2     "Module-Related - Metacognitive Modeling"

keep d*

egen dupes = tag(d11_3)
drop if dupes == 0 
drop dupes 


}
