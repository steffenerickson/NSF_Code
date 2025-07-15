clear all 
version 18
//----------------------------------------------------------------------------//
// Set Up 
//----------------------------------------------------------------------------//
* Set up directories 
local office 0 
if `office' == 1 {
	global root 	"C:/Users/cns8vg"
	global code 	"GitHub/NSF_Code/02_measurement"  
	global programs "GitHub/stata_programs"
	global data     "Box Sync/NSF_DR_K12/measurement/data"
	global output 	"Box Sync/NSF_DR_K12/measurement/output"
}
if `office' == 0 {
	global root     "/Users/steffenerickson/Box Sync/NSF_DR_K12/measurement"
	global code     "Users/steffenerickson/Documents/GitHub/NSF_Code/02_measurement/code"
	global programs "Users/steffenerickson/Documents/GitHub/stata_programs"
	global data     "data"
	global output   "output"
}

global root_drive "/Users/steffenerickson/Box Sync/NSF_DR_K12/data_management" 
global code "/Users/steffenerickson/Documents/GitHub/NSF_Code/01_project_managment"
global mdata "/Users/steffenerickson/Box Sync/NSF_DR_K12/measurement/data"
global output "/Users/steffenerickson/Box Sync/NSF_DR_K12/measurement/output"
cd "$root_drive"
do ${code}/01_master.do
frame change nsf_baseline_data     
save "$mdata/baseline.dta" , replace

keep if coaching != 2


keep d162 d164 d167 d921 d107 d126_6 d132 d142 d1611_1 d161 d163 d101_1 d101_2 d101_3 d101_4 d101_5 d101_6 site semester participantid

rename d162 age 
rename d164 yrs
rename d167 gpa 
rename d921 mkt 
rename d107 prior
rename d126_6 seswd
rename d132 beliefs
rename d142 mteb
rename d1611_1 race
rename d161 gender
rename d163 service_type
rename d101_1 prior_swd_1  
rename d101_2 prior_swd_2  
rename d101_3 prior_swd_3  
rename d101_4 prior_swd_4  
rename d101_5 prior_swd_5  
rename d101_6 prior_swd_6  

tab race
gen white = (race == 6 | race == 7)
tab race white 
tab gender
gen female = (gender == 1 | gender == 2)
tab gender female 
tab service_type
gen preservice = (service_type == 3)
tab service_type preservice 

egen prior_avg_swd = rowmean(prior_swd_?)


label variable age "Age"
label variable yrs "Years in Program"
label variable gpa "GPA"
label variable white "Percent White"
label variable female "Percent Female"
label variable preservice "Percent Pre-service"
label variable mkt "Math Knowledge for Teaching"
label variable prior "Prior Experience with SWDs"
label variable seswd "Self Efficacy with SWDs"
label variable beliefs "Beliefs about Teaching"
label variable mteb "Math Teaching Beliefs Efficacy"
label variable prior_swd_1 "Worked with SWD Subquestion1" 
label variable prior_swd_2 "Worked with SWD Subquestion2" 
label variable prior_swd_3 "Worked with SWD Subquestion3" 
label variable prior_swd_4 "Worked with SWD Subquestion4" 
label variable prior_swd_5 "Worked with SWD Subquestion5" 
label variable prior_swd_6 "Worked with SWD Subquestion6" 
label variable prior_avg_swd "Prior Experience with SWDs" 

global covariates age yrs gpa white female preservice mkt prior_avg_swd seswd beliefs mteb 
capture matrix drop results
foreach cov of global covariates { 
	tempname temp
	qui sum `cov' 
	mat `temp' = r(mean),r(sd),r(min),r(max)
	mat rowname `temp' = "`:variable label `cov''"
	mat results = (nullmat(results)\ `temp') 
}

frmttable /*using "${root}/${output}/table4.rtf"*/ , ///
statmat(results) ///
ctitles("Variable", "Mean","SD","Min" "Max") ///
note("Math Knowledge for Teaching scores are reported as percentages," ///
     "while all otherscales are presented in raw scale units. Sources:"  "Math Knowledge for Teaching (Hill et al, 2004)," ///
	 "Self Efficacy with SWDs (Solomon & Scott, 2013)," "Beliefs about Teaching (Clark et al., 2014)," ///
	 "Math Teaching Beliefs & Efficacy (Swars et al., 2006)" ///
	 ) ///
title("Sample Characteristics") ///
coljust(c) ///
replace


// Samples for each analysis 

mkf gstudysample 
frame gstudysample {
use "$mdata/gstudy_sample.dta" , clear 
collapse p, by(participantid site semester)
tempfile data 
save `data'
}
merge 1:1 participantid site semester using `data'
gen gstudy = (_merge == 3)
drop _merge 


mkf extrapsample 
frame extrapsample {
use "$mdata/extrapolation_sample.dta" , clear 
collapse k1, by(participantid site semester)
tempfile data 
save `data'
}
merge 1:1 participantid site semester using `data'
gen extrap = (_merge == 3)
drop _merge 

// Main Demographic Tables 

global covariates age yrs gpa white female preservice mkt prior_avg_swd seswd beliefs mteb 
capture matrix drop results
foreach cov of global covariates { 
	tempname temp
	qui sum `cov'  if gstudy == 1
	mat `temp' = r(mean),r(sd),r(min),r(max)
	mat rowname `temp' = "`:variable label `cov''"
	mat results = (nullmat(results)\ `temp') 
}

frmttable using "${output}/gstudysampledemographics.tex" , ///
statmat(results) ///
ctitles("Variable", "Mean","SD","Min" "Max") ///
tex ///
fragment ///
replace

capture matrix drop results
foreach cov of global covariates { 
	tempname temp
	qui sum `cov'  if extrap == 1
	mat `temp' = r(mean),r(sd),r(min),r(max)
	mat rowname `temp' = "`:variable label `cov''"
	mat results = (nullmat(results)\ `temp') 
}

frmttable using "${output}/extrapolationsampledemographics.tex", ///
statmat(results) ///
ctitles("Variable", "Mean","SD","Min" "Max") ///
tex ///
fragment ///
replace



// Prior experience with students with disabilities 

global covariates2 prior_swd_1 prior_swd_2 prior_swd_3 prior_swd_4 prior_swd_5 prior_swd_6 prior_avg_swd
capture matrix drop results
foreach cov of global covariates2 { 
	tempname temp
	qui sum `cov'  if gstudy == 1
	mat `temp' = r(mean),r(sd),r(min),r(max)
	mat rowname `temp' = "`:variable label `cov''"
	mat results = (nullmat(results)\ `temp') 
}

frmttable using "${output}/gstudysamplepriorswd.tex" , ///
statmat(results) ///
ctitles("Variable", "Mean","SD","Min" "Max") ///
tex ///
fragment ///
replace

capture matrix drop results
foreach cov of global covariates2 { 
	tempname temp
	qui sum `cov'  if extrap == 1
	mat `temp' = r(mean),r(sd),r(min),r(max)
	mat rowname `temp' = "`:variable label `cov''"
	mat results = (nullmat(results)\ `temp') 
}

frmttable using "${output}/extrapolationsampleswd.tex", ///
statmat(results) ///
ctitles("Variable", "Mean","SD","Min" "Max") ///
tex ///
fragment ///
replace


// Prior experience with students with disabilities percentages  

global covariates2 prior_swd_1 prior_swd_2 prior_swd_3 prior_swd_4 prior_swd_5 prior_swd_6 //prior_avg_swd
capture matrix drop results
foreach cov of global covariates2 { 
	tempname temp
	qui tab `cov'  if gstudy == 1, matcell(`temp')
	mat `temp' = (`temp' * (1/r(N)))'
	if ("`cov'" == "prior_swd_1") mat `temp' = `temp'[1,1] , 0 , `temp'[1,2..4] 
	if ("`cov'" == "prior_swd_3") mat `temp' = `temp'[1,1..3] , 0 , `temp'[1,4] 
	mat rowname `temp' = "`:variable label `cov''"
	mat results = (nullmat(results)\ `temp') 
}

frmttable using "${output}/gstudysamplepriorswd_percents.tex" , ///
statmat(results) ///
ctitles("","Not at all", "Less than 1","1 - 2","3 - 5" "6 or more") ///
tex ///
fragment ///
replace

capture matrix drop results
foreach cov of global covariates2 { 
	tempname temp
	qui tab `cov'  if extrap == 1, matcell(`temp')
	mat `temp' = (`temp' * (1/r(N)))'
	if ("`cov'" == "prior_swd_1") mat `temp' = `temp'[1,1] , 0 , `temp'[1,2..4] 
	mat rowname `temp' = "`:variable label `cov''"
	mat results = (nullmat(results)\ `temp') 
}

frmttable using "${output}/extrapolationsampleswd_percents.tex", ///
statmat(results) ///
ctitles("","Not at all", "Less than 1","1 - 2","3 - 5" "6 or more") ///
tex ///
fragment ///
replace



foreach cov of global covariates2 { 
	tab `cov' if extrap == 1
}



/*
note("Math Knowledge for Teaching scores are reported as percentages," ///
     "while all otherscales are presented in raw scale units. Sources:"  "Math Knowledge for Teaching (Hill et al, 2004)," ///
	 "Self Efficacy with SWDs (Solomon & Scott, 2013)," "Beliefs about Teaching (Clark et al., 2014)," ///
	 "Math Teaching Beliefs & Efficacy (Swars et al., 2006)" ///
	 ) ///
title("Extrapolation Analysis Sample Characteristics") ///

note("Math Knowledge for Teaching scores are reported as percentages," ///
     "while all otherscales are presented in raw scale units. Sources:"  "Math Knowledge for Teaching (Hill et al, 2004)," ///
	 "Self Efficacy with SWDs (Solomon & Scott, 2013)," "Beliefs about Teaching (Clark et al., 2014)," ///
	 "Math Teaching Beliefs & Efficacy (Swars et al., 2006)" ///
	 ) ///
title("Generalizability Study Sample Characteristics") ///

*/











* (Hill et al, 2004)
* d126_6 (Solomon & Scott, 2013)
* d132   (Clark et al., 2014)
* d142   (Swars et al., 2006)
