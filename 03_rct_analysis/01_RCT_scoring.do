//-----------------------------------------------------------------------------//
//-----------------------------------------------------------------------------//
// NSF Main Paper Scoring procedures
// Factor scores are estimated using the non-experimental sample when possible 
//--------------------=--------------------------------------------------------//
//-----------------------------------------------------------------------------//


clear all
cd "/Users/steffenerickson/Desktop/fall_2023/nsf/g_theory_work/full_routine"

* Pull Study Data  
do /Users/steffenerickson/Desktop/repos/collab_rep_lab/nsf_v2/_pull_data.do 

frame dir 

//-----------------------------------------------------------------------------//
//-----------------------------------------------------------------------------//
// Sim Rubric
//-----------------------------------------------------------------------------//
//-----------------------------------------------------------------------------//
frame copy performancetask_and_baseline simrubric1 , replace
frame change simrubric1

* Data set up 
keep x1-x6 site semester participantid task rater dc time 
encode participantid , gen(ID)
tab ID , m
sort ID site semester
egen id = group (ID site semester)
recode task (4 = 1) (5 = 2) (6 = 3)
drop if task == .
drop if time == 2
egen dupes = tag(id time dc task)
tab dupes
drop if dupes == 0
drop rater
reshape wide x1-x6 , i(id time dc) j(task)
reshape wide x?? , i(id time )  j(dc)

* Individual rubric domain factor scores 
forvalues i = 1/6 {
	sem (F -> x`i'11 x`i'12 x`i'21 x`i'22 x`i'31 x`i'32)					///
	,  mean(0: F@0) variance(0: F@1) 										///
	group(time) ginvariant(mcons) method(mlmv)
	estat gof, stats(all)
	estat mindices
	predict fx`i' , latent 
}		

* Individual rubric domain sum scores  	 
forvalues i = 1/6 {
	egen x`i'_sum = rowmean(x`i'11 x`i'12 x`i'21 x`i'22 x`i'31 x`i'32)
}

* Keep the experimental group and reshape to wide 
keep if site == 1 | site == 2
keep site semester participantid time fx* x?_sum
rename fx* x* 
reshape wide x* , i(site semester participantid) j(time)

* Overall performance factor score 
sem (F -> x?0) , mean(F@0) variance(F@1)
predict x_overall0 , latent 
sem (F -> x?1) , mean(F@0) variance(F@1)

predict x_overall1 , latent 

* Overall performance sum score
egen x_overall_sum0 = rowmean(x?_sum0)
egen x_overall_sum1 = rowmean(x?_sum1)

* standardize sum scores 
foreach var of varlist *sum* {
	tempvar temp 
	egen `temp' = std(`var') 
	drop `var'
	rename `temp' `var'
	sum `var'
}

* label variables
local names Objective Unpacking Instruction Regulation Ending Accuracy
forvalues j = 0/1 {
	forvalues i = 1/6 {
		label variable x`i'`j' "`:word `i' of `names'' (time `j')"
		label variable x`i'_sum`j' "`:word `i' of `names'' sum score (time `j')"
	}
}
label variable x_overall0 "Overall Simse score (time 0)"
label variable x_overall1 "Overall Simse score (time 1)"
label variable x_overall_sum0 "Overall Simse sum score (time 0)"
label variable x_overall_sum1 "Overall Simse sum score (time 1)"

//-----------------------------------------------------------------------------//
// Placement video item scores 
//-----------------------------------------------------------------------------//
frame copy performancetask_and_baseline simrubric2 , replace
frame change simrubric2

* Data set up 
keep x1-x6 site semester participantid task rater dc time model
encode participantid , gen(ID)
tab ID , m
sort ID site semester
egen id = group (ID site semester)
keep if time == 2
collapse x* (count) simse_fw = x2, by(id dc site semester participantid )
reshape wide x* simse_fw,   i(id) j(dc)

* Individual rubric domain factor scores 
global variables x11 x12 x21 x22 x31 x32 x41 x42 x51 x52 x61 x62
local n: list sizeof global(variables)
mata: psi = J(`n',`n',0.0)
mata: _diag(psi,J(1,`n',.))
mata: st_matrix("psi" , psi)	   
forvalues r = 1/`n' {
	forvalues c = 1/`n' {
		 local word1 = substr("`:word `r' of $variables'",3,1)
		 local word2 = substr("`:word `c' of $variables'",3,1)
		 if ("`r'" != "`c'") & ("`word1'" == "`word2'") mat psi[`c',`r'] = .
	}
}
mat li psi
mata: phi = J(6,6,.)
mata: _diag(phi,J(1,6,1))
mata: st_matrix("phi" , phi)
sem (F1 -> x1* ) (F2 -> x2* ) 												///
    (F3 -> x3* ) (F4 -> x4* ) 												///
	(F5 -> x5* ) (F6 -> x6* ) 												///
	, covstructure(_LEx, fixed(phi)) 										///
	  covstructure(e._OEn,  fixed(psi)) method(mlmv) 
predict fx* , latent 

* Overall performance factor score  
global variables x11 x12 x21 x22 x31 x32 x41 x42 x51 x52 x61 x62
local n: list sizeof global(variables)
mata: psi = J(`n',`n',0.0)
mata: _diag(psi,J(1,`n',.))
mata: st_matrix("psi" , psi)	   
forvalues r = 1/`n' {
	forvalues c = 1/`n' {
		 local word1 = substr("`:word `r' of $variables'",2,1)
		 local word2 = substr("`:word `c' of $variables'",2,1)
		 if ("`r'" != "`c'") & ("`word1'" == "`word2'") mat psi[`c',`r'] = .
	}
}
sem (F -> $variables ), variance(F@1) mean(F@0) covstructure(e._OEn,  fixed(psi)) method(mlmv) 
predict x_overall2 , latent 

* Individual rubric domain sum scores 
forvalues i = 1/6 {
	egen x`i'_sum2 = rowmean(x`i'1 x`i'2)
}

* Overall performance sum score
egen x_overall_sum2 = rowmean(x?_sum2)

* standardize sum scores 
foreach var of varlist *sum* {
	tempvar temp 
	egen `temp' = std(`var') 
	drop `var'
	rename `temp' `var'
	sum `var'
}

* Clean and label
keep site semester participantid  fx* x?_sum2 *overall*  simse_fw2
rename fx* fx*2 
rename fx* x* 
local names Objective Unpacking Instruction Regulation Ending Accuracy
forvalues i = 1/6 {
	label variable x`i'2 "`:word `i' of `names'' (time 2)"
	label variable x`i'_sum2 "`:word `i' of `names'' sum score (time 2)"
	}
	
label variable x_overall2 "Overall Simse score (time 2)"
label variable x_overall_sum2 "Overall Simse sum score (time 2)"
label variable simse_fw2 "Simse video section frequency weight"	

//-----------------------------------------------------------------------------//
//-----------------------------------------------------------------------------//
// MQI 
//-----------------------------------------------------------------------------//
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

* standardize scores (because lesson_codes are on a different scale)
foreach var of varlist $i1 $i2 $i3 $i4 $i5  {
	tempvar temp 
	egen `temp' = std(`var') 
	drop `var'
	rename `temp' `var'
	sum `var'
}
ds $i1 $i2 $i3 $i5
global variables `r(varlist)'

* Individual rubric domain factor scores
mata: phi = J(4,4,.)
mata: _diag(phi,J(1,4,1))
mata: st_matrix("phi" , phi)
sem  (F1 -> ${i1}) (F2 -> ${i2}) ///
     (F3 -> ${i3}) (F5 -> ${i5}) ///
	 ,covstructure(_LEx, fixed(phi)) ///
	 mean(F1@0 F2@0 F3@0   F5@0) 
predict m1 m2 m3 m5, latent 
* Estimating errors seperately because the model does not converge when the items are included
egen m4 = rowmean(${i4})
egen m42 = std(m4)
drop m4
rename m42 m4

* Overall performance factor score  
forvalues i = 1/5 {
	ds ${i`i'}
	local list `r(varlist)'
	local variables : list variables | list
}
di "`variables'"
local n: list sizeof local(variables)
mata: psi = J(`n',`n',0.0)
mata: _diag(psi,J(1,`n',.))
mata: st_matrix("psi" , psi)	   
forvalues r = 1/`n' {
	forvalues c = 1/`n' {
		 local word1 = substr("`:word `r' of $variables'",2,1)
		 local word2 = substr("`:word `c' of $variables'",2,1)
		 if ("`r'" != "`c'") & ("`word1'" == "`word2'") mat psi[`c',`r'] = .
	}
}
sem (F -> `variables' ) ///
	, variance(F@1) mean(F@0) covstructure(e._OEn,  fixed(psi)) method(mlmv) 
predict m_overall, latent 

* Individual rubric domain sum scores  
egen  m1_sum = rowmean(m9_1-m9_9) // lesson_codes
egen  m2_sum = rowmean(m5_1-m5_7) // richness 
egen  m3_sum = rowmean(m6_1-m6_3) // working
egen  m4_sum = rowmean(m7_1-m7_4) // errors
egen  m5_sum = rowmean(m8_1-m8_6) // commoncore

* Overall performance sum score
egen m_overall_sum = rowmean(m?_sum)

* Clean and label
label variable m1 "Whole Lesson"
label variable m2 "Richness"
label variable m3 "Working w/ Students"
label variable m4 "Errors"
label variable m5 "Common Core"
label variable m1_sum "Whole Lesson sum score"
label variable m2_sum "Richness sum scor"
label variable m3_sum "Working w/ Students sum score"
label variable m4_sum "Errors sum score"
label variable m5_sum "Common Core sum score"
label variable m_overall "MQI overall score"
label variable m_overall_sum "MQI overall sum score"
label variable mqi_fw "MQI video section frequency weight"
keep site semester participantid m1 m2 m3 m4 m5 mqi_fw *sum* m_overall

//-----------------------------------------------------------------------------//
//-----------------------------------------------------------------------------//
// Self Efficacy
//-----------------------------------------------------------------------------//
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


* Individual rubric domain factor scores
mata: phi = J(5,5,.)
mata: _diag(phi,J(1,5,1))
mata: st_matrix("phi" , phi)
sem (F1 -> d121* ) (F2 -> d122* ) 				///
    (F3 -> d123* ) (F4 -> d124* ) 				///
	(F5 -> d125* ) 								///
	, covstructure(_LEx, fixed(phi)) method(mlmv) group(time) ginvariant(mcons mcoef) 
predict e* , latent 

* Overall performance factor score  
ds d*
local variables `r(varlist)'
local n: list sizeof local(variables)
mata: psi = J(`n',`n',0.0)
mata: _diag(psi,J(1,`n',.))
mata: st_matrix("psi" , psi)	   
forvalues r = 1/`n' {
	forvalues c = 1/`n' {
		 local word1 = substr("`:word `r' of $variables'",4,1)
		 local word2 = substr("`:word `c' of $variables'",4,1)
		 if ("`r'" != "`c'") & ("`word1'" == "`word2'") mat psi[`c',`r'] = .
	}
}
sem (F -> `variables' ) ///
	, variance(F@1) mean(F@0) covstructure(e._OEn,  fixed(psi)) ///
	mean(1: F@0) variance(1: F@1) 	///
	method(mlmv) group(time) ginvariant(mcons mcoef)
predict e_overall, latent 


* Clean and label
keep if coaching == 0 | coaching == 1
keep e1-e5 e_overall site semester participantid time 
reshape wide e1-e5 e_overall, i(site semester participantid) j(time)
rename e?1 e?0
rename e?2 e?1
rename e_overall1 e_overall0
rename e_overall2 e_overall1

forvalues i = 0/1 {
	label variable e1`i' "Efficacy in instruction (time `i')"
	label variable e2`i' "Efficacy in professionalism (time `i')"
	label variable e3`i' "Efficacy in teaching supports (time `i')" 
	label variable e4`i' "Efficacy in classroom management (time `i')"
	label variable e5`i' "Efficacy in related duties (time `i')"
	label variable e_overall`i' "Overall Efficacy (time `i')"
}

//-----------------------------------------------------------------------------//
//-----------------------------------------------------------------------------//
// Baseline Covariates 
//-----------------------------------------------------------------------------//
//-----------------------------------------------------------------------------//

frame copy baseline covs , replace
frame change covs

//----------------------//
// MKT Content Score 
//----------------------//

*sum score 
rename d921 c_sum

foreach var of varlist d9* {
	drop if `var' == 6
}

*create item parcels 
* parcels are the rowmeans of subquestions within each content question
* c1-c6 are the content questions with subquestions 
egen c1 = rowmean(d91_?) 
egen c2 = rowmean(d96_?)
egen c3 = rowmean(d98_?)
egen c4 = rowmean(d913_?)
egen c5 = rowmean(d916_?)
egen c6 = rowmean(d920_?)
* c7 is content questions without subquestions
foreach var of varlist d9* {
	local a = strpos("`var'", "_")
	if `a' == 0 local list1 : list list1 | var
	di "`list1'"
} 
egen c7 = rowmean(`list1')

foreach var of varlist c* {
	tempvar temp 
	egen `temp' = std(`var') 
	drop `var'
	rename `temp' `var'
	sum `var'
}

* Overall performance factor score 
sem (F -> c1-c7) , variance(F@1) mean(F@0)
predict c , latent 
label variable c "MKT"
label variable c_sum "MKT_sumscore"


//----------------------//
// NEO 
//----------------------//

local names neo_neuroticism neo_extraversion  neo_openness  neo_agreeableness  neo_conscientiousness
forvalues i = 1/5 {
	sem (F -> d15`i'_*),  mean(F@0) variance(F@1) method(mlmv)
	predict n`i' , latent 
	label variable n`i' "`:word `i' of `names''"
}

//----------------------//
// beliefs , prior experience, mteb
//----------------------//


// need to revisit these

//Beliefs
sem (F -> d131_*),  mean(F@0) variance(F@1) method(mlmv)
predict b , latent 
label variable b "Beliefs Scale"

//Prior Experience 
sem (F -> d10?_*),  mean(F@0) variance(F@1) method(mlmv)
predict pe , latent 
label variable pe "Prior Experience Scale"

//mteb
sem (F -> d141_*),  mean(F@0) variance(F@1) method(mlmv)
predict mteb , latent 
label variable mteb "mteb Scale"




keep c c_sum b pe mteb n* participantid site semester 


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
drop if x_overall1 == .

ds 
local all `r(varlist)'
local remove coaching participantid site semester simse_fw2 mqi_fw
local variables : list all - remove 
foreach var of local variables {
	local a : variable label `var'
	tempvar temp 
	egen `temp' = std(`var') 
	drop `var'
	rename `temp' `var'
	sum `var'
	label variable `var' "`a'"
}

save rct_analytic.dta, replace

