//----------------------------------------------------------------------------//
//----------------------------------------------------------------------------//
// NSF Main Paper Scoring procedures
// Factor scores are estimated using the non-experimental sample when possible 
//----------------------------------------------------------------------------//
//----------------------------------------------------------------------------//
clear all
* Pull Study Data  
do /Users/steffenerickson/Desktop/repos/collab_rep_lab/nsf_v2/_pull_data.do 
frame dir 
//-----------------------------------------------------------------------------//
// Sim Rubric performance task scores
//-----------------------------------------------------------------------------//
frame copy performancetask_and_baseline simrubric1 , replace
frame change simrubric1

* Data set up 
keep x1-x6 site semester participantid task dc time 
recode task (4 = 1) (5 = 2) (6 = 3)
drop if task == .
drop if time == 2
egen dupes = tag(participantid site semester time dc task)
tab dupes
drop if dupes == 0
reshape wide x1-x6 , i(participantid site semester time dc) j(task)
reshape wide x??   , i(participantid site semester time )  j(dc)

* Scoring Model ----------------------
sem (F1 -> x1??) (F2 -> x2??) (F3 -> x3??) (F4 -> x4??) (F5 -> x5??) (F6 -> x6??), group(time) ginvariant(mcons) method(mlmv) 
* ------------------------------------
predict fx* , latent 

* Keep the experimental group and reshape to wide 
keep if site == 1 | site == 2
keep site semester participantid time fx* 
rename fx* x*
reshape wide x* , i(site semester participantid) j(time)

* label variables
local names Objective Unpacking Instruction Regulation Ending Accuracy
forvalues j = 0/1 {
	forvalues i = 1/6 {
		label variable x`i'`j' "`:word `i' of `names'' (time `j')"
	}
}

//-----------------------------------------------------------------------------//
// Sim Rubric Placement  scores 
//-----------------------------------------------------------------------------//
frame copy performancetask_and_baseline simrubric2 , replace
frame change simrubric2

* Data set up 
keep x1-x6 site semester participantid task rater dc time model
keep if time == 2
collapse x* (count) simse_fw = x2, by(dc participantid site semester)
reshape wide x* simse_fw,   i(participantid site semester) j(dc)

* Scoring Model ----------------------
sem (F1 -> x1* )(F2 -> x2* )(F3 -> x3* )(F4 -> x4* )(F5 -> x5* ) (F6 -> x6* ), method(mlmv) 	
* ------------------------------------
predict fx* , latent 

* Clean and label
rename simse_fw2 simse_fw
keep site semester participantid  fx* simse_fw
rename fx* fx*2 
rename fx* x* 
local names Objective Unpacking Instruction Regulation Ending Accuracy
forvalues i = 1/6 {
	label variable x`i'2 "`:word `i' of `names'' (time 2)"
}

//-----------------------------------------------------------------------------//
// MQI 
//-----------------------------------------------------------------------------//
frame copy mqi_and_baseline mqi , replace
frame change mqi

* Data set up 
keep site semester participantid m* segment
encode participantid , gen(ID)
tab ID , m
sort ID site semester
egen id = group (ID site semester)
global i1 m9_1-m9_9 // lesson_codes
global i2 m5_1-m5_7 // richness 
global i3 m6_1-m6_3 // working
global i4 m7_1-m7_4 // errors
global i5 m8_1-m8_6 // commoncore

* reverse coding errors 
recode ${i4} (0 = 3) (1 = 2) (2 = 1) (3 = 0)
forvalues i = 1/5 {
	ds ${i`i'}
}

* average over raters and video sections 
collapse (mean) $i1 $i2 $i3 $i4 $i5  (count) mqi_fw = m5_2, by(site semester participantid) 

* dropping m5_5 (Patterns and Generalizations) because variance and mean = 0 
drop m5_5 

* Scoring Model ----------------------
sem (F1 -> ${i1}) (F2 -> ${i2}) (F3 -> ${i3}) (F5 -> ${i5}), method(mlmv) 
* ------------------------------------
predict m1 m2 m3 m5, latent 

* Estimating errors seperately because the model does not converge when the items are included
egen m4 = rowmean(${i4})

* Clean and label
label variable m1 "Whole Lesson"
label variable m2 "Richness"
label variable m3 "Working w/ Students"
label variable m4 "Errors"
label variable m5 "Common Core"
keep site semester participantid m1 m2 m3 m4 m5 mqi_fw

//-----------------------------------------------------------------------------//
// Self Efficacy
//-----------------------------------------------------------------------------//
frame copy finalsurvey_and_baseline self_efficacy , replace
frame change self_efficacy

* Data set up 
keep site semester participantid d12* coaching
encode participantid , gen(ID)
tab ID , m
sort ID site semester
egen id = group (ID site semester)
drop d126*
rename d12?_? d12?_?_1
rename d12?_?_? d12?_?? 
ds d*
local list `r(varlist)'
foreach var of local list  {
	tempvar temp 
	egen `temp' = std(`var') 
	drop `var'
	rename `temp' `var'
	sum `var'
}
ds d*
local list `r(varlist)'
foreach word of local list {
	local a = substr("`word'",1,6)
	local list2 : list list2 | a
}
local stubs : list uniq list2
reshape long `stubs' , i(site semester participantid id coaching) j(time)

* Scoring Model ----------------------
sem (F1 -> d121* ) (F2 -> d122* )(F3 -> d123* ) (F4 -> d124* )(F5 -> d125* ), method(mlmv) group(time) ginvariant(mcons mcoef) 
* ------------------------------------
predict e* , latent 

* Clean and label
keep if coaching == 0 | coaching == 1
keep e1-e5 site semester participantid time 
reshape wide e1-e5 , i(site semester participantid) j(time)
rename e?1 e?0
rename e?2 e?1
forvalues i = 0/1 {
	label variable e1`i' "Efficacy in instruction (time `i')"
	label variable e2`i' "Efficacy in professionalism (time `i')"
	label variable e3`i' "Efficacy in teaching supports (time `i')" 
	label variable e4`i' "Efficacy in classroom management (time `i')"
	label variable e5`i' "Efficacy in related duties (time `i')"
}

//-----------------------------------------------------------------------------//
// Baseline Covariates 
//-----------------------------------------------------------------------------//
frame copy baseline covs , replace
frame change covs


*MKT Content Score 

foreach var of varlist d9* {
	drop if `var' == 6
}
*create item parcels 
* parcels are the rowmeans of subquestions within each content question
* c1-c6:content questions with subquestions 
* c7   :content questions without subquestions
egen c1 = rowmean(d91_?) 
egen c2 = rowmean(d96_?)
egen c3 = rowmean(d98_?)
egen c4 = rowmean(d913_?)
egen c5 = rowmean(d916_?)
egen c6 = rowmean(d920_?)
foreach var of varlist d9* {
	local a = strpos("`var'", "_")
	if `a' == 0 local list1 : list list1 | var
	di "`list1'"
} 
egen c7 = rowmean(`list1')
* Scoring Model ----------------------
sem (F -> c1-c7) 
* ------------------------------------
predict c , latent 
label variable c "MKT"

* NEO 
local names neo_neuroticism neo_extraversion  neo_openness  neo_agreeableness  neo_conscientiousness
forvalues i = 1/5 {
	* Scoring Model ----------------------
	sem (F -> d15`i'_*),method(mlmv)
	* ------------------------------------
	predict n`i' , latent 
	label variable n`i' "`:word `i' of `names''"
}
keep c n* participantid site semester 

//-----------------------------------------------------------------------------//
// Merge Scores together  
//-----------------------------------------------------------------------------//
frame copy baseline rct_analytic , replace
frame change rct_analytic
keep if coaching == 0 | coaching == 1
keep participantid site semester coaching  

frame simrubric1: tempfile data 
frame simrubric1: save `data'
merge 1:1 site semester participantid using `data'
drop _merge

frame simrubric2: tempfile data 
frame simrubric2: save `data'
merge 1:1 site semester participantid using `data'
drop _merge

frame mqi: tempfile data 
frame mqi: save `data'
merge 1:1 site semester participantid using `data'
drop _merge

frame self_efficacy : tempfile data 
frame self_efficacy : save `data'
merge 1:1 site semester participantid using `data'
drop _merge

frame covs: tempfile data 
frame covs: save `data'
merge 1:1 site semester participantid using `data'
drop _merge

drop if coaching == .
drop if x11 == . 

cd "/Users/steffenerickson/Desktop/fall_2023/nsf/g_theory_work/analysis_routines/results"
save rct_analytic.dta, replace
