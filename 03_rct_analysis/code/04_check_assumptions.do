//----------------------------------------------------------------------------//
// Balance Table and Attrition (shows baseline and analytic sample balance on baseline characteristics)
//----------------------------------------------------------------------------//
clear all
global root     "/Users/steffenerickson/Box Sync/NSF_DR_K12/rct"
global code     "/Users/steffenerickson/Documents/GitHub/NSF_Code/03_rct_analysis/code"
global data     "data"
global output   "output"
global output   "output"

* Import files 
local filelist : dir "${root}/${output}/" files "*.dta"
if `:word count `filelist'' < 3 {
	do "{code}/02_data_set_up.do"
}
frame reset 
local filelist : dir "${root}/${output}/" files "*.dta"
local i = 1 
foreach file of local filelist {
	mkf fr`i'
	frame fr`i' : use "${root}/${output}/`file'" , clear
	local++i
}


frame dir 
global covariates d162 d167 d126_1 d126_2 d126_3 d126_4 d126_5 d132 d142 d156_1 d156_2 d156_3 d156_4 d156_5 d921 d107 pre_simse white male parentnotteach parentcollege 

frame fr3 {
	
	preserve
	qui tab id 
	local obs1 = `r(r)'
	collapse simse $covariates, by(t id block)
	capture matrix drop results1
	foreach cov of global covariates { 
		qui regress `cov' i.t i.block 
		mat results1 = (nullmat(results1)\(r(table)[1,2],r(table)[4,2])) 
	}
	restore
	
	preserve
	keep if time == 1
	qui tab id if simse != . 
	local obs2 = `r(r)'
	capture matrix drop results2
	foreach cov of global covariates { 
		qui regress `cov' i.t i.block if simse != . 
		mat results2 = (nullmat(results2)\(r(table)[1,2],r(table)[4,2])) 
	}
	restore
	
	preserve
	keep if time == 2
	qui tab id if simse != . 
	local obs3 = `r(r)'
	collapse simse $covariates, by(t id block )
	capture matrix drop results3
	foreach cov of global covariates { 
		qui regress `cov' i.t i.block if simse != . 
		mat results3 = (nullmat(results3)\(r(table)[1,2],r(table)[4,2])) 
	}
	restore
	
}
mat results = results1,results2,results3
mat rownames results  = "Age" "GPA" "Efficacy in Instruction" "Efficacy in Professionalism" "Efficacy in Teaching Supports" "Efficacy in Classroom Management" "Efficacy in Related Duties" "Beliefs about Teaching" "MTEB" "Neo Neuroticism" "Neo Extraversion" "Neo Openness" "Neo Agreeableness" "Neo Conscientiousness" "Math Knowledge for Teaching" "Prior Experience" "SimSe Pretest" "White" "Male" "Parent Not Teacher" "Parent With College"
matrix dcols = (0,1,0,1,0,1)
frmttable using "${root}/${output}/table3.rtf" , ///
statmat(results) ///
substat(1) ///
ctitles("", "Baseline (n = `obs1')","End of Course (n = `obs2')","Student Placement (n = `obs3')") ///
note("Differences in Baseline Characteristics (Treatment - Control) for Samples at Baseline and Outcome Periods 1 and 2") ///
title("Baseline and Analytic Sample Balance Tables") ///
coljust(c) ///
replace


// --------------- Simple baseline balance table -----------------------------//


frame change fr3 
collapse simse $covariates, by(t id block)
egen efficacy = rowmean(d126*)
global covariates white male d162 d167 pre_simse d921 efficacy d132 d107  
capture matrix drop results
foreach cov of global covariates { 
	sum `cov' if t == 0 
	local cm = r(mean)
	regress `cov' i.t i.block 
	local tm = `cm' + r(table)[1,2]
	mat results = (nullmat(results)\(`cm',., `tm',., r(table)[1,2],r(table)[4,2])) 
}

mat rownames results  = "% White" "% Male" "Age" "College GPA" "SimSe Pretest" "Math Knowledge for Teaching" "Self Efficacy" "Beliefs about Teaching" "Prior Experience"
mat colnames results = "Control" "Treatment" "Difference"
matrix dcols = (0,0,0,1)
frmttable using "${root}/${output}/table4.rtf" , ///
statmat(results) ///
substat(1) ///
ctitles("", "Control Mean","Treatment Mean","Difference") ///
note("Joint test: F(9,144) = 0.45, Prob > F = 0.9023") ///
title("Baseline Balance Table") ///
coljust(c) ///
replace





