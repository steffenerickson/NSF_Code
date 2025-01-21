clear all
global root     "/Users/steffenerickson/Box Sync/NSF_DR_K12/rct"
global code     "/Users/steffenerickson/Documents/GitHub/NSF_Code/03_rct_analysis/code"
global data     "data"
global output   "output"


* Import files 
local filelist : dir "${root}/${output}/" files "*.dta"
if `:word count `filelist'' < 3 {
	do "${code}/02_data_set_up.do"
}
frame reset 
local filelist : dir "${root}/${output}/" files "*.dta"
local i = 1 
foreach file of local filelist {
	mkf fr`i'
	frame fr`i' : use "${root}/${output}/`file'" , clear
	frame fr`i' : gen non_complier = (site == 2 & semester == 1 & participantid == "002")
	frame fr`i' : gen t_receipt = t 
	frame fr`i' : replace t_receipt = 0 if non_complier == 1
	local++i
}

frame dir 

global covariates d162 d167 d126_1 d126_2 d126_3 d126_4 d126_5 d132 d142 d156_1 d156_2 d156_3 d156_4 d156_5 d921 d107 pre_simse white male 

		
//----------------------------------------------------------------------------//
// TOT effects
//----------------------------------------------------------------------------//	

eststo clear 
qui eststo, title("ptmm"): frame fr3: ivregress 2sls simse_s i.block i.rater i.task $covariates *_im (i.t_receipt = i.t i.block $covariates *_im) if time == 1 , vce(cluster id)
frame fr3: qui tab id if simse_s != . & time == 1
estadd scalar a = r(r)
estadd local rater "X"
estadd local segment "X"
estadd local robust "X"

qui eststo, title("cmm" ): frame fr3: ivregress 2sls simse_s i.block i.rater i.model_num  $covariates *_im (i.t_receipt = i.t i.block $covariates *_im) if time == 2 , vce(cluster id)
frame fr3: qui tab id  if simse_s != . & time == 2
estadd scalar a = r(r)
estadd local rater "X"
estadd local task "X"
estadd local robust "X"

qui eststo, title("cqci"): frame fr1: ivregress 2sls qci_s i.block i.rater i.segment $covariates *_im (i.t_receipt = i.t i.block $covariates *_im) , vce(cluster id)
frame fr1: qui tab id if qci_s != .
estadd scalar a = r(r) 
estadd local rater "X"
estadd local task "X"
estadd local robust "X"

qui eststo, title("cmqi"): frame fr2: ivregress 2sls mqi_s i.block i.rater i.segment $covariates *_im (i.t_receipt = i.t i.block $covariates *_im) , vce(cluster id)
frame fr2: qui tab id if  mqi_s != .
estadd scalar a = r(r) 
estadd local rater "X"
estadd local task "X"
estadd local robust "X"

#delimit ;
esttab /*using table_1.tex*/, 
cells(b(star label(Coef.) fmt(a3)) se(label(SE) fmt(2) par))  				 
label																	     
mtitles("Performance Task Meta. Model" "Classroom Meta. Model" "Classroom QCI" "Classroom MQI" ) 								 
stats( N a rater task segment robust, labels("N. Observations" "N. Candidates" "Rater FE" "Segment FE" "Task FE" "Clustered SEs")) 						
title("Standardized TOT Effects Across Multiple Measures")					     
keep( 1.t_receipt) 							
star(* 0.10 ** 0.05 *** 0.01)	 
legend varlabels( 1.t_receipt "TOT") noisily replace;
#delimit cr
		
		
#delimit ;
esttab using "${root}/${output}/table6.rtf" , 
cells(b(star label(Coef.) fmt(a3)) se(label(SE) fmt(2) par))  				 
label																	     
mtitles("Performance Task Meta. Model" "Classroom Meta. Model" "Classroom QCI" "Classroom MQI" ) 								 
stats( N a rater task segment robust, labels("N. Observations" "N. Candidates" "Rater FE" "Segment FE" "Task FE" "Clustered SEs")) 						
title("Standardized TOT Effects Across Multiple Measures")					     
keep( 1.t_receipt) 							
star(* 0.10 ** 0.05 *** 0.01)	 
legend varlabels( 1.t_receipt "TOT") noisily replace;
#delimit cr
		
//----------------------------------------------------------------------------//
// Item Comparisons 
//----------------------------------------------------------------------------//	




eststo clear 
forvalues i = 1/6 {
	frame fr3: tempvar std 
	frame fr3: egen `std' = std(x`i')
	eststo, title("ptmm`i'"): frame fr3: regress x`i' i.t i.block i.task i.rater $covariates *_im if time == 1, vce(cluster id)	
	frame fr3: qui tab id if simse_s != . & time == 1
	estadd scalar a = r(r)
	estadd local rater "X"
	estadd local task "X"
	estadd local robust "X"
}

#delimit ;
esttab using "${root}/${output}/table7.rtf", 
cells(b(star label(Coef.) fmt(a3)) se(label(SE) fmt(2) par))  				 
label																	     
mtitles("Objective" "Unpacking" "Self-instruction" "Self-regulation" "Ending" "Accuracy") 								 
stats( N a rater task robust, labels("N. Observations" "N. Candidates" "Rater FE" "Task FE" "Clustered SEs")) 						
title("Item Level Performance Task SimSE ITT Effects")					     
keep( 1.t) 							
star(* 0.10 ** 0.05 *** 0.01)	 
legend varlabels( 1.t "TOT") noisily replace;
#delimit cr
	

eststo clear 
forvalues i = 1/6 {
	frame fr3: tempvar std 
	frame fr3: egen `std' = std(x`i')
	eststo, title("ptmm`i'"): frame fr3: regress x`i' i.t i.block i.task i.rater $covariates *_im if time == 2, vce(cluster id)	
	frame fr3: qui tab id if simse_s != . & time == 1
	estadd scalar a = r(r)
	estadd local rater "X"
	estadd local segment "X"
	estadd local robust "X"
}

#delimit ;
esttab using "${root}/${output}/table8.rtf", 
cells(b(star label(Coef.) fmt(a3)) se(label(SE) fmt(2) par))  				 
label																	     
mtitles("Objective" "Unpacking" "Self-instruction" "Self-regulation" "Ending" "Accuracy") 								 
stats( N a rater segment robust, labels("N. Observations" "N. Candidates" "Rater FE" "Segment FE" "Clustered SEs")) 						
title("Item Level Classroom Task SimSE ITT Effects")					     
keep( 1.t) 							
star(* 0.10 ** 0.05 *** 0.01)	 
legend varlabels( 1.t "TOT") noisily replace;
#delimit cr
		



