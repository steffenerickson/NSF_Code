//----------------------------------------------------------------------------//
// Data Cleaning For Measurment Analysis 

//----------------------------------------------------------------------------//
clear all
global root     "/Users/steffenerickson/Box Sync/NSF_DR_K12/measurement"
global datapull "/Users/steffenerickson/Documents/GitHub/NSF_Code/01_project_managment/_pull_data.do"
global code     "/Users/steffenerickson/Documents/GitHub/NSF_Code/02_measurement/code"
global programs "/Users/steffenerickson/Documents/GitHub/stata_programs"
global data     "data"
global output   "output"
global nlp      "nlp_scoring_data"


do ${datapull}

//-----------------------------------------------------------------------------//
// Sim Rubric performance task scores
//-----------------------------------------------------------------------------//
frame copy performancetask_and_baseline simrubric1 , replace
frame change simrubric1

* Data set up 
keep x1-x6 site semester participantid task dc time coaching
recode task (4 = 1) (5 = 2) (6 = 3)
drop if task == .
drop if time == 2
egen dupes = tag(participantid site semester time dc task)
tab dupes
drop if dupes == 0

* reshape to a wide format 
reshape wide x1-x6 , i(participantid site semester time dc) j(task)
reshape wide x??   , i(participantid site semester time )   j(dc)

* Average scores from two raters for each task 
forvalues i = 1/6 {
	forvalue j = 1/3 {
		egen x`i'`j' = rowmean(x`i'`j'?)
	}
}
keep site semester participantid time  x??
reshape wide x* , i(site semester participantid) j(time)

//-----------------------------------------------------------------------------//
// Mathematical Knowledge for Teaching
//-----------------------------------------------------------------------------//
frame copy nsf_baseline_data covs, replace
frame change covs

foreach var of varlist d9* {
	drop if `var' == 6
}
*create item parcels 
* parcels are the rowmeans of subquestions within each content question
* c1-c6 :content questions with subquestions 
* c7    :content questions without subquestions
egen k1 = rowmean(d91_?) 
egen k2 = rowmean(d96_?)
egen k3 = rowmean(d98_?)
egen k4 = rowmean(d913_?)
egen k5 = rowmean(d916_?)
egen k6 = rowmean(d920_?)
foreach var of varlist d9* {
	local a = strpos("`var'", "_")
	if `a' == 0 local list1 : list list1 | var
	di "`list1'"
} 
egen k7 = rowmean(`list1')
keep k*  participantid site semester 

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

keep site semester participantid id coaching d121*

rename (d121_11 d121_21 d121_31 d121_41 d121_51) (e10 e20 e30 e40 e50)
rename (d121_12 d121_22 d121_32 d121_42 d121_52) (e11 e21 e31 e41 e51)

//-------------------------------------------------------------------------//
// MQI 
//-------------------------------------------------------------------------//
frame copy mqi_and_baseline mqi , replace
frame change mqi

* Data set up 
keep site semester participantid m9_1-m9_9 m5_1-m5_7 m6_1-m6_3 m7_1-m7_4 m8_1-m8_6 segment 
*drop m5_7 m6_3 m7_4 m8_6

global i1 m9* // lesson_codes
global i2 m5* // richness 
global i3 m6* // working
global i4 m7* // errors
global i5 m8* // commoncore

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
sem (F1 -> ${i1}) (F2 -> ${i2}) (F3 -> ${i3}) (F5 -> ${i5}), covstructure(_LEx, unstructured) method(mlmv) 
* ------------------------------------
predict m1 m2 m3 m5, latent 

* Estimating errors seperately because the model does not converge when the items are included
egen m4 = rowmean(${i4})


/*
forvalues i = 1/5 {
	egen m`i'2 = std(m`i')
	drop m`i'
	rename m`i'2 m`i'
}
*/

* Clean and label
label variable m1 "Whole Lesson"
label variable m2 "Richness"
label variable m3 "Working w/ Students"
label variable m4 "Errors"
label variable m5 "Common Core"
label variable mqi_fw "MQI Classroom Observation Frequency Weight"
keep site semester participantid m1 m2 m3 m4 m5 mqi_fw $i1 $i2 $i3 $i4 $i5
rename m9_? m1_?
rename m5_? m2_?

rename m6_? m3_?
rename m7_? m4_?
rename m8_? m5_?


//-------------------------------------------------------------------------//
// QCI / COSTI 
//-------------------------------------------------------------------------//
frame copy costi_and_baseline costi , replace
frame change costi
keep participantid site semester c5_1-c6_8

foreach v of varlist c?_* {
	local label_`v' : variable label `v'
}
collapse (mean) c?_* (count) qcicosti_fw = c6_1, by(participantid site semester)
foreach v of varlist c?_* {
	label variable `v' "`label_`v''"
}
label variable qcicosti_fw "QCI/COSTI Classroom Observation Frequency Weight"

//-----------------------------------------------------------------------------//
// Sim Rubric Placement scores 
//-----------------------------------------------------------------------------//
frame copy performancetask_and_baseline simrubric2 , replace
frame change simrubric2

* Data set up 
keep x1-x6 site semester participantid task rater dc time model 
keep if time == 2

* create frequency weights (for classroom obs.)
frame copy simrubric2 temp, replace
frame temp {
	egen simse2_fw = count(participantid) , by(participantid site semester) 
	keep participantid site semester simse2_fw
	collapse simse2_fw , by(participantid site semester)
	tab simse2_fw
} 

collapse x*, by(dc participantid site semester)
reshape wide x* ,   i(participantid site semester) j(dc)

global i1 x1? // Setting the objective
global i2 x2? // Unpacking the word problem 
global i3 x3? // Self instruction
global i4 x4? // Self regulation
global i5 x5? // Ending the Model
global i6 x6? // Accuracy and Clarity


rename x?? xc??
keep site semester participantid  x* 

//-------------------------------------------------------------------------//
// Merge Scores 
//-------------------------------------------------------------------------//
frame copy nsf_baseline_data rct_analytic , replace
frame change rct_analytic
keep participantid site semester coaching  

frame simrubric1: tempfile data 
frame simrubric1: save `data'
merge 1:1 site semester participantid using `data'
keep if _merge == 3
drop _merge

frame covs: tempfile data 
frame covs: save `data'
merge 1:1 site semester participantid using `data'
drop _merge

frame self_efficacy : tempfile data 
frame self_efficacy : save `data'
merge 1:1 site semester participantid using `data'
drop _merge

frame mqi: tempfile data 
frame mqi: save `data'
merge 1:1 site semester participantid using `data'
drop _merge

frame simrubric2: tempfile data 
frame simrubric2: save `data'
merge 1:1 site semester participantid using `data'
drop _merge

frame costi: tempfile data 
frame costi: save `data'
merge 1:1 site semester participantid using `data'
drop _merge


keep x1?? x2?? x3?? x4?? x5?? x6?? k? m* e* xc* c* site semester participantid coaching 
keep if x110 != . 

rename x??? x???r
rename xc??r xc??

merge 1:1 participantid site semester using "${root}/${data}/aidata.dta"
drop _merge

ds x????
local list1 `r(varlist)'
local list2: subinstr local list1 "r" "" , all
local list3: subinstr local list2 "c" "" , all
local stubs: list uniq list3
foreach stub of local stubs {
	di "`stub'"
	qui egen `stub' = rowmean(`stub'?)
}

save  "${root}/${data}/simse_validity.dta" , replace
