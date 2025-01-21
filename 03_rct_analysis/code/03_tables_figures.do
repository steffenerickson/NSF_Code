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
	local++i
}

frame dir 

global covariates d162 d167 d126_1 d126_2 d126_3 d126_4 d126_5 d132 d142 d156_1 d156_2 d156_3 d156_4 d156_5 d921 d107 pre_simse white male //parentnotteach parentcollege 

		
//----------------------------------------------------------------------------//
// Regession tables 
//----------------------------------------------------------------------------//	

eststo clear 
eststo, title("ptmm"): frame fr3: regress simse_s i.t i.block i.task i.rater  $covariates *_im if time == 1, vce(cluster id)	
frame fr3: qui tab id if simse_s != . & time == 1
estadd scalar a = r(r)
estadd local rater "X"
estadd local segment "X"
estadd local robust "X"

eststo, title("cmm" ): frame fr3: regress simse_s i.t i.block i.rater i.model_num   $covariates *_im if time == 2, vce(cluster id)
frame fr3: qui tab id  if simse_s != . & time == 2
estadd scalar a = r(r)
estadd local rater "X"
estadd local task "X"
estadd local robust "X"

eststo, title("cqci"): frame fr1: regress qci_s i.t i.block i.rater i.segment  $covariates *_im , vce(cluster id)
frame fr1: qui tab id if qci_s != .
estadd scalar a = r(r) 
estadd local rater "X"
estadd local task "X"
estadd local robust "X"

eststo, title("cmqi"): frame fr2: regress mqi_s i.t i.block i.rater i.segment $covariates *_im , vce(cluster id)
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
title("Standardized ITT Effects Across Multiple Measures")					     
keep(1.t) 							
star(* 0.10 ** 0.05 *** 0.01)	 
legend varlabels( 1.t "ITT") noisily replace;
#delimit cr
		
		
#delimit ;
esttab using "${root}/${output}/table1.rtf" , 
cells(b(star label(Coef.) fmt(a3)) se(label(SE) fmt(2) par))  				 
label																	     
mtitles("Performance Task Meta. Model" "Classroom Meta. Model" "Classroom QCI" "Classroom MQI" ) 								 
stats( N a rater task segment robust, labels("N. Observations" "N. Candidates" "Rater FE" "Segment FE" "Task FE" "Clustered SEs")) 						
title("Standardized ITT Effects Across Multiple Measures")					     
keep(1.t) 									 
star(* 0.10 ** 0.05 *** 0.01)	
legend varlabels( 1.t "ITT") noisily replace;
#delimit cr


		
//----------------------------------------------------------------------------//		
// Comparing Standardized Effect Sizes Across Measures With Declining Alignment plot 
//----------------------------------------------------------------------------//	
	
		
frame fr3: regress simse_s i.t i.block i.task i.rater $covariates *_im if time == 1, vce(cluster id)	
mat c1 = r(table)[1..6,2]	
frame fr3: regress simse_s i.t i.block i.rater i.model_num  $covariates *_im if time == 2, vce(cluster id)
mat c2 = r(table)[1..6,2]
frame fr1: regress qci_s i.t i.block i.rater i.segment $covariates *_im , vce(cluster id)
mat c3 = r(table)[1..6,2]
frame fr2: regress mqi_s i.t i.block i.rater i.segment $covariates *_im , vce(cluster id)
mat c4 = r(table)[1..6,2]

mat coefs = c1,c2,c3,c4
mat colnames coefs  = "ptmm" "cmm" "cqci" "cmqi"
coefplot matrix(coefs), aux(4) ci((5 6)) vertical /// 
mlabel("b = " + string(@b,"%9.3f") + (cond(@aux1<.01, "***", cond(@aux1<.05, "**", cond(@aux1<.10, "*", "")))))   ///
msymbol(circle ) msize(medium) mcolor(eltgreen) mlcolor(black) ///
ciopts(lcolor(ebblue)) ///
ytitle("Standardized Effect Size") xtitle("Proximal → Distal") ///
title("Comparing Standardized Effect Sizes Across Measures With Declining Alignment") ///
yscale(range(-.1(.1)1.2)) ylabel(-.1(.1)1.2) ///
coeflabels(ptmm = "Performance Task Meta. Model" cmm = "Classroom Meta. Model" cqci = "Classroom QCI" cmqi = "Classroom MQI" ) ///
name(g1, replace) recast(connected) lcolor(black)




// Version two of the plot 
coefplot matrix(coefs), aux(4) ci((5 6)) vertical /// 
mlabel("b = " + string(@b,"%9.3f") + (cond(@aux1<.01, "***", cond(@aux1<.05, "**", cond(@aux1<.10, "*", "")))))   ///
msymbol(circle ) msize(medium) mcolor(eltgreen) mlcolor(black) ///
ciopts(lcolor(ebblue)) ///
ytitle("Standardized Effect Size") xtitle("Proximity") ///
title("Effect Sizes Across Outcomes With Declining Proximity (Task + Instrument Alignment)" , size(medium)) ///
yscale(range(-.1(.1)1.2)) ylabel(-.1(.1)1.2) ///
coeflabels(ptmm = "SimSe" cmm = "SimSe" cqci = "QCI" cmqi = "MQI" ) ///
xline(1.5) ///
text(0 1.0 "Performance Task") text(0 3.0 "Classroom Task") ///
note("*** p <.01, ** p <.05, * p <.10") ///
name(g1, replace) recast(connected) lcolor(black) xlabel(,nogrid) ylabel(,nogrid)







