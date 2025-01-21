//----------------------------------------------------------------------------//
//Set up 
//----------------------------------------------------------------------------//
clear all
global root     "/Users/steffenerickson/Box Sync/NSF_DR_K12/rct"
global datapull "/Users/steffenerickson/Documents/GitHub/NSF_Code/01_project_managment/_pull_data.do"
global code     "/Users/steffenerickson/Documents/GitHub/NSF_Code/03_rct_analysis/code"
global programs "/Users/steffenerickson/Documents/GitHub/stata_programs"
global data     "data"
global output   "output"
include "${programs}/impute_missing_dummy.ado"

* Import files 
local filelist : dir "${root}/${data}/" files "*.dta"
if `:word count `filelist'' < 3 {
	do ${datapull}
	frame performancetask_and_baseline : save "${root}/${data}/performancetask_and_baseline.dta", replace 
	frame costi_and_baseline : save "${root}/${data}/costi_and_baseline.dta", replace 
	frame mqi_and_baseline   : save "${root}/${data}/mqi_and_baseline.dta", replace  
}
frame reset 
local filelist : dir "${root}/${data}/" files "*.dta"
local i = 1 
foreach file of local filelist {
	mkf fr`i'
	frame fr`i' : use "${root}/${data}/`file'" , clear
	local++i
}
frame dir 

//----------------------------------------------------------------------------//
// Data Preparation 
//----------------------------------------------------------------------------//
* Covariate list 
global covariates d162 d167 d126_1 d126_2 d126_3 d126_4 d126_5 d132 d142 d156_1 d156_2 d156_3 d156_4 d156_5 d921 d107 white male parentnotteach parentcollege 
		
* Additonal cleaning 
forvalues i = 1/3 {
	frame fr`i' {
		rename coaching t 
		egen block = group(site semester)
		egen id = group(block participantid)
		label values d156_1 d156_2 d156_3 d156_4 d156_5 d921 .
		keep if t == 0 | t == 1
		drop if block > 4
		tab d1611_1, gen(race_)
		rename race_5 white
		drop race_*
		tab d161, gen(gender_)
		rename gender_2 male
		drop gender_*
		tab d168, gen(parentteach_)
		rename parentteach_2 parentnotteach
		drop parentteach_*
		recode d169 (3 = 1) (2 = 0) (4/6 = 0)
		recode d1610 (3 = 1) (2 = 0) (4/6 = 0)
		gen parentcollege = (d169 == 1 | d1610 == 1)
	}		
}
		
* Simse pretest measure 
frame fr3 : egen simse = rowmean(x1 x2 x3 x4 x5 x6)
frame fr3 :	egen  pre_simse =  mean(simse) if time == 0, by(id)
frame fr3 :	frame put pre_simse id block, into(pretest) // use pretest scores for other datasets	
frame fr3 :	frame put simse id block time, into(posttest)  // use posttest scores for other datasets	
frame pretest: collapse pre_simse , by(id block)
frame posttest: keep if time == 1
frame posttest: rename simse simse1
frame posttest: collapse simse1, by(id block)


* File specific manipulation including creating overall scores 
*QCI
frame fr1 {
	rename c2_1 rater 
	keep $covariates site section rater block id segment t c6_1 c6_2 c6_3 c6_4 c6_5 c6_6 c6_7 c6_8 participantid semester
	egen qci = rowmean(c6_1 c6_2 c6_3 c6_4 c6_5 c6_6 c6_7 c6_8)
	egen qci_s = std(qci)
	foreach x in pretest posttest {
		frame `x': tempfile data
		frame `x': save  `data'
		merge m:1 id block using `data'
		drop if _merge == 2
		drop _merge 
	}
}

* Performance tasks
frame fr3 {
	keep if time == 1 | 2
	keep $covariates site section task time rater block id model_num t x1 x2 x3 x4 x5 x6 simse  participantid semester
	keep if t != 2
	egen simse_s = std(simse)
	foreach x in pretest posttest {
		frame `x': tempfile data
		frame `x': save  `data'
		merge m:1 id block using `data'
		drop if _merge == 2
		drop _merge 
	}
}

*MQI 
frame fr2 {
	rename m2_1 rater
	revrs m7_1 m7_2 m7_3 m7_4
	egen domain1  = rowmean(m9_1 m9_2 m9_3 m9_4 m9_5 m9_6 m9_7 m9_8 m9_9)
	egen domain2  = rowmean(m5_1 m5_2 m5_3 m5_4 m5_5 m5_6 m5_7)
	egen domain3  = rowmean(m6_1 m6_2 m6_3)
	egen domain4  = rowmean(revm7_1 revm7_2 revm7_3 revm7_4)
	egen domain5  = rowmean(m8_1 m8_2 m8_3 m8_4 m8_5 m8_6)
	keep $covariates site section rater block id domain* segment t participantid semester
	egen mqi = rowmean(domain*)
	egen mqi_s = std(mqi)
	foreach x in pretest posttest {
		frame `x': tempfile data
		frame `x': save  `data'
		merge m:1 id block using `data'
		drop if _merge == 2
		drop _merge 
	}
}

* Impute 0's for missing covariates and create a dummy indicator if the 
* covariate is missing for the observation 
global covariates $covariates  pre_simse 
forvalues i = 1/3 {
	frame fr`i' {
		foreach var of global covariates  {
			qui impute_mean `var'
			qui replace `var' = 0 if `var'_im == 1
		}
	}
}

frame fr1: save "${root}/${output}/rct_qci", replace
frame fr2: save "${root}/${output}/rct_mqi", replace
frame fr3: save "${root}/${output}/rct_simse", replace 











