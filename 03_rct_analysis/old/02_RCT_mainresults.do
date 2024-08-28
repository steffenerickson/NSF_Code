//----------------------------------------------------------------------------//


// Main RCT results 
// Steffen Erickson
//



//----------------------------------------------------------------------------//
cd "/Users/steffenerickson/Desktop/fall_2023/nsf/g_theory_work/analysis_routines/results"
include /Users/steffenerickson/Desktop/fall_2023/nsf/g_theory_work/analysis_routines/missing_data.do
use rct_analytic.dta, replace
*ssc install xlincom

//----------------------------------------------------------------------------//
// Data set up 
//----------------------------------------------------------------------------//
rename coaching treat
* create randomization block var 
tab site semester
egen block = group(site semester)
label variable block "randomization block"
label define  blocks 1 "F22 UVA" 2 "S23 UVA" 3 "F22 UD" 4 "S23 UD"
label values block blocks 
tab block 

* Create composite scores using weights on the first principal component 
pca x?0
predict x_overall0
pca x?1
predict x_overall1
pca x?2
predict x_overall2
pca m?
predict m_overall
pca e?0
predict e_overall0
pca e?1
predict e_overall1

* Standardized Scores 
ds 
local all `r(varlist)'
local remove coaching participantid site semester simse1_fw simse2_fw mqi_fw block treat
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

* Create list of covariate variables
ds 
local all `r(varlist)'
ds m* x*1 x*2
local outcomes `r(varlist)'
local remove coaching participantid site semester simse1_fw simse2_fw mqi_fw treat m* x*1 x*2 `outcomes'
local variables : list all - remove
di "`variables'"
global variables `variables'

* Create missing value indicators for the control variables 
foreach var of global variables {
	impute_mean `var'
	replace `var' = 0 if `var'_im == 1
}

save nsf_main_rct.dta, replace 

//----------------------------------------------------------------------------//
//----------------------------------------------------------------------------//
//----------------------------------------------------------------------------//
//Regression Models 
//----------------------------------------------------------------------------//
//----------------------------------------------------------------------------//
//----------------------------------------------------------------------------//

//----------------------------------------------------------------------------//
//----------------------------------------------------------------------------//
// SimSe Performance Tasks
//----------------------------------------------------------------------------//
//----------------------------------------------------------------------------//

//----------------------------------------------------------------------------//
// Pooled AVERAGE TREATMENT EFFECTS //
//----------------------------------------------------------------------------//
*Baseline 
regress x_overall1 i.treat i.block  [fweight = simse1_fw]

*Pretest
regress x_overall1 i.treat i.block x_overall0 x_overall0_im [fweight = simse1_fw]

*Pretest with baseline covariates
regress x_overall1 i.treat i.block x_overall0 e?0 c n? x_overall0_im e?0_im c_im n?_im  [fweight = simse1_fw]

//----------------------------------------------------------------------------//
// Cohort AVERAGE TREATMENT EFFECTS TREATMENT EFFECTS //
//----------------------------------------------------------------------------//
*Cohort specific treatment effects
regress x_overall1 i.treat##i.block x_overall0 e?0 c n? x_overall0_im e?0_im c_im n?_im [fweight = simse1_fw]
xlincom (block1 =  _b[1.treat] + _b[1o.treat#1b.block]) ///
        (block2 =  _b[1.treat] + _b[1.treat#2.block]) 	///
		(block3 =  _b[1.treat] + _b[1.treat#3.block])	///
		(block4 =  _b[1.treat] + _b[1.treat#4.block]), post

* differences fromt the weighted grand mean 
regress x_overall1 i.treat##i.block x_overall0 e?0 c n? x_overall0_im e?0_im c_im n?_im [fweight = simse1_fw]
contrasts jw.treat#g.block,  post 

//----------------------------------------------------------------------------//
//----------------------------------------------------------------------------//
// SimSe Classroom Placements 
//----------------------------------------------------------------------------//
//----------------------------------------------------------------------------//

//----------------------------------------------------------------------------//
// Pooled AVERAGE TREATMENT EFFECTS //
//----------------------------------------------------------------------------//
*Baseline 
regress x_overall2 i.treat i.block [fweight = simse2_fw]

*Pretest
regress x_overall2 i.treat i.block x_overall0 x_overall0_im [fweight = simse2_fw]

*Pretest with baseline covariates
regress x_overall2 i.treat i.block x_overall0 e?0 c n? x_overall0_im e?0_im c_im n?_im [fweight = simse2_fw]

//----------------------------------------------------------------------------//
// Cohort AVERAGE TREATMENT EFFECTS TREATMENT EFFECTS //
//----------------------------------------------------------------------------//
*Cohort specific treatment effects
regress x_overall2 i.treat##i.block x_overall0 e?0 c n? x_overall0_im e?0_im c_im n?_im [fweight = simse2_fw]
xlincom (block1 =  _b[1.treat] + _b[1o.treat#1b.block]) ///
        (block2 =  _b[1.treat] + _b[1.treat#2.block]) 	///
		(block3 =  _b[1.treat] + _b[1.treat#3.block])	///
		(block4 =  _b[1.treat] + _b[1.treat#4.block]), post

	
* differences fromt the weighted grand mean 
regress x_overall1 i.treat##i.block x_overall0 e?0 c n? x_overall0_im e?0_im c_im n?_im [fweight = simse2_fw]
contrasts jw.treat#g.block,  post 

//----------------------------------------------------------------------------//
//----------------------------------------------------------------------------//
// MQI
//----------------------------------------------------------------------------//
//----------------------------------------------------------------------------//

//----------------------------------------------------------------------------//
// Pooled AVERAGE TREATMENT EFFECTS //
//----------------------------------------------------------------------------//
*Baseline 
regress m_overall i.treat i.block [fweight = mqi_fw]

*With Baseline Covariates
regress m_overall i.treat i.block e?0 c n? e?0_im c_im n?_im [fweight = mqi_fw]

//----------------------------------------------------------------------------//
// Cohort AVERAGE TREATMENT EFFECTS TREATMENT EFFECTS //
//----------------------------------------------------------------------------//
*Cohort specific treatment effects
regress m_overall i.treat##i.block x_overall0 e?0 c n? x_overall0_im e?0_im c_im n?_im [fweight = simse2_fw]
xlincom (block1 =  _b[1.treat] + _b[1o.treat#1b.block]) ///
        (block2 =  _b[1.treat] + _b[1.treat#2.block]) 	///
		(block3 =  _b[1.treat] + _b[1.treat#3.block])	///
		(block4 =  _b[1.treat] + _b[1.treat#4.block]), post

	
* differences fromt the weighted grand mean 
regress m_overall i.treat##i.block x_overall0 e?0 c n? x_overall0_im e?0_im c_im n?_im [fweight = simse2_fw]
contrasts jw.treat#g.block,  post 


//----------------------------------------------------------------------------//
//----------------------------------------------------------------------------//
//----------------------------------------------------------------------------//
// Tables 
//----------------------------------------------------------------------------//
//----------------------------------------------------------------------------//
//----------------------------------------------------------------------------//

//----------------------------------------------------------------------------//
//----------------------------------------------------------------------------//
//Pooled effect Regression tables
//----------------------------------------------------------------------------//
//----------------------------------------------------------------------------//

//----------------------------------------------------------------------------//
// Table 1 - Performance task simse
//----------------------------------------------------------------------------//
eststo clear 
qui eststo, title("base"): regress x_overall1 i.treat i.block [fweight = simse1_fw]
qui tab x_overall1  if x_overall1  != .
estadd scalar a = r(r)
qui eststo, title("+ pretest"): regress  x_overall1 i.treat i.block  x_overall0 x_overall0_im [fweight = simse1_fw]
qui tab x_overall1  if x_overall1  != .
estadd scalar a = r(r)
qui eststo, title("+ baseline covs"): regress x_overall1 i.treat i.block  x_overall0 c e?0  n? x_overall0_im e?0_im c_im n?_im [fweight = simse1_fw]
qui tab x_overall1  if x_overall1  != .
estadd scalar a = r(r)

#delimit ;
esttab using table_1.tex, 
cells(b(star label(Coef.) fmt(a3)) se(label(SE) fmt(2) par))  				 
label																	     
mtitles("base" "+ pretest" "+ baseline covs") 								 
stats( a r2 rmse, labels( "N. of cases" "R2" "RMSE" )) 						 
title("SimSE Performance Task Scores Pooled Models")					     
keep(1.treat 2.block 3.block 4.block x_overall0 							 
     c e10 e20 e40 e50 n1 n3 n4 n5 _cons) 									 
legend varlabels( 1.treat "Treatment"										 
				  2.block  "S23 UVA" 										 
				  3.block  "F22 UD" 										 
				  4.block  "S23 UD" 										 
				  x_overall0 "Simse Pretest" 								 
				  c "Mathematical knowledge for teaching" 					 
				  e10 "Efficacy in instruction" 
				  e20 "Efficacy in professionalism" 
				  e30 "Efficacy in teaching supports" 
				  e40 "Efficacy in classroom management" 
				  e50 "Efficacy in related duties" 
				  n1 "Neo neuroticism" 
				  n2 "Neo extraversion" 
				  n3 "Neo openness" 
				  n4 "Neo agreeableness" 
				  n5 "Neo conscientiousness" 
				  _cons "Constant" ) noisily replace;
#delimit cr
				  
//----------------------------------------------------------------------------//
// Table 2 - classroom simse 	
//----------------------------------------------------------------------------// 
eststo clear 
qui eststo, title("base"): regress x_overall2 i.treat i.block [fweight = simse2_fw]
qui tab x_overall2  if x_overall2  != .
estadd scalar a = r(r)
qui eststo, title("+ pretest"): regress  x_overall2 i.treat i.block  x_overall0 x_overall0_im [fweight = simse2_fw]
qui tab x_overall2  if x_overall2  != .
estadd scalar a = r(r)
qui eststo, title("+ baseline covs"): regress x_overall2 i.treat i.block  x_overall0 c e?0  n? x_overall0_im e?0_im c_im n?_im [fweight = simse2_fw]
qui tab x_overall2  if x_overall2  != .
estadd scalar a = r(r)

#delimit ;
esttab using table_2.tex, 
cells(b(star label(Coef.) fmt(a3)) se(label(SE) fmt(2) par))  
label 
mtitles("base" "+ pretest" "+ baseline covs") 
stats( a r2 rmse, labels( "N. of cases" "R2" "RMSE" )) 
title("SimSe Classroom Placement Scores Pooled Models") 
keep(1.treat 2.block  3.block 4.block x_overall0 c e10 e20 e40 e50 n1 n3 n4 n5 _cons  ) 
legend varlabels( 1.treat "Treatment"												
				  2.block  "S23 UVA"  
				  3.block  "F22 UD" 
				  4.block  "S23 UD" 
				  x_overall0 "Simse Pretest" 
				  c "Mathematical knowledge for teaching" 
				  e10 "Efficacy in instruction" 
				  e20 "Efficacy in professionalism" 
				  e30 "Efficacy in teaching supports" 
				  e40 "Efficacy in classroom management" 
				  e50 "Efficacy in related duties" 
				  n1 "Neo neuroticism" 
				  n2 "Neo extraversion" 
				  n3 "Neo openness" 
				  n4 "Neo agreeableness" 
				  n5 "Neo conscientiousness" 
				  _cons "Constant" ) replace ;
#delimit cr
				  
//----------------------------------------------------------------------------//			  
// Table 3 - classroom MQI	
//----------------------------------------------------------------------------//
eststo clear 
eststo, title("base"): regress m_overall i.treat i.block [fweight = mqi_fw]
qui tab m_overall if m_overall != .
estadd scalar a = r(r)

eststo, title("+ baseline covs"): regress m_overall i.treat i.block  x_overall0 c e?0  n? x_overall0_im e?0_im c_im n?_im  [fweight = mqi_fw]
qui tab m_overall if m_overall != .
estadd scalar a = r(r)

#delimit ;
esttab using table_3.tex, 
cells(b(star label(Coef.) fmt(a3)) se(label(SE) fmt(2) par))  
label 
mtitles("base"  "+ baseline covs") 
stats( a r2 rmse, labels( "N. of cases" "R2" "RMSE" )) 
title("MQI Classroom Placement Scores Pooled Models") 
keep(1.treat 2.block  3.block 4.block x_overall0 c e10 e20 e40 e50 n1 n3 n4 n5 _cons  ) 
legend varlabels( 1.treat "Treatment"												
				  2.block  "S23 UVA"  
				  3.block  "F22 UD" 
				  4.block  "S23 UD" 
				  x_overall0 "Simse Pretest" 
				  c "MKT" 
				  e10 "Efficacy in instruction" 
				  e20 "Efficacy in professionalism" 
				  e30 "Efficacy in teaching supports" 
				  e40 "Efficacy in classroom management" 
				  e50 "Efficacy in related duties" 
				  n1 "Neo neuroticism" 
				  n2 "Neo extraversion" 
				  n3 "Neo openness" 
				  n4 "Neo agreeableness" 
				  n5 "Neo conscientiousness" 
				  _cons "Constant" ) replace ;
#delimit cr
				 
//----------------------------------------------------------------------------//		  
//----------------------------------------------------------------------------//
// Cohort x treatment interaction effect regression tables
//----------------------------------------------------------------------------//	
//----------------------------------------------------------------------------//

//----------------------------------------------------------------------------//
// Table 4 -  performance task simse
//----------------------------------------------------------------------------//					  	
eststo clear 
eststo, title("base"): regress x_overall1 i.treat##i.block [fweight = simse1_fw]
qui tab x_overall1  if x_overall1  != .
estadd scalar a = r(r)
eststo, title("+ pretest"): regress  x_overall1 i.treat##i.block  x_overall0 x_overall0_im [fweight = simse1_fw]
qui tab x_overall1  if x_overall1  != .
estadd scalar a = r(r)
eststo, title("+ baseline covs"): regress x_overall1 i.treat##i.block  x_overall0 c e?0  n? x_overall0_im e?0_im c_im n?_im [fweight = simse1_fw]
qui tab x_overall1  if x_overall1  != .
estadd scalar a = r(r)

#delimit ;
esttab using table_4.tex, 
cells(b(star label(Coef.) fmt(a3)) se(label(SE) fmt(2) par))  
label 
mtitles("base" "+ pretest" "+ baseline covs") 
stats( a r2 rmse, labels( "N. of cases" "R2" "RMSE" )) 
title("SimSE Performance Task Scores Cohort x Treatment Interaction Models") 
keep(1.treat 2.block  3.block 4.block 1.treat#2.block 1.treat#3.block 		
     1.treat#4.block x_overall0 c e10 e20 e40 e50 n1 n3 n4 n5 _cons ) 		
order(1.treat 1.treat#2.block 1.treat#3.block 1.treat#4.block _cons 2.block 3.block 4.block )	 
legend varlabels( 1.treat  "Treatment (F22 UVA)"							
				  2.block  "S23 UVA"  
				  3.block  "F22 UD" 
				  4.block  "S23 UD" 
				  1.treat#2.block "Treatment x S23 UVA"	
				  1.treat#3.block "Treatment x F22 UD" 
				  1.treat#4.block "Treatment x S23 UD" 
				  x_overall0 "Simse Pretest" 
				  c "Mathematical knowledge for teaching" 
				  e10 "Efficacy in instruction" 
				  e20 "Efficacy in professionalism" 
				  e30 "Efficacy in teaching supports" 
				  e40 "Efficacy in classroom management" 
				  e50 "Efficacy in related duties" 
				  n1 "Neo neuroticism" 
				  n2 "Neo extraversion" 
				  n3 "Neo openness" 
				  n4 "Neo agreeableness" 
				  n5 "Neo conscientiousness" 
				  _cons "Constant (F22 UVA)" ) replace ;
#delimit cr
		
//----------------------------------------------------------------------------//
// Table 5 -  classroom simse 	
//----------------------------------------------------------------------------// 
eststo clear 
eststo, title("base"): regress x_overall2 i.treat##i.block [fweight = simse2_fw]
qui tab x_overall2  if x_overall2  != .
estadd scalar a = r(r)
eststo, title("+ pretest"): regress  x_overall2 i.treat##i.block  x_overall0 x_overall0_im [fweight = simse2_fw]
qui tab x_overall2  if x_overall2  != .
estadd scalar a = r(r)
eststo, title("+ baseline covs"): regress x_overall2 i.treat##i.block  x_overall0 c e?0  n? x_overall0_im e?0_im c_im n?_im [fweight = simse2_fw]
qui tab x_overall2  if x_overall2  != .
estadd scalar a = r(r)

#delimit ;
esttab using table_5.tex, 
cells(b(star label(Coef.) fmt(a3)) se(label(SE) fmt(2) par))  
label 
mtitles("base" "+ pretest" "+ baseline covs") 
stats( a r2 rmse, labels( "N. of cases" "R2" "RMSE" )) 
title("SimSe Classroom Placement Scores Cohort x Treatment Interaction Models") 
keep(1.treat 2.block  3.block 4.block 1.treat#2.block 1.treat#3.block 		
     1.treat#4.block x_overall0 c e10 e20 e40 e50 n1 n3 n4 n5 _cons ) 		
order(1.treat 1.treat#2.block 1.treat#3.block 1.treat#4.block _cons 2.block 3.block 4.block )	 
legend varlabels( 1.treat  "Treatment (F22 UVA)"							
				  2.block  "S23 UVA"  
				  3.block  "F22 UD" 
				  4.block  "S23 UD" 
				  1.treat#2.block "Treatment x S23 UVA"	
				  1.treat#3.block "Treatment x F22 UD" 
				  1.treat#4.block "Treatment x S23 UD" 
				  x_overall0 "Simse Pretest" 
				  c "Mathematical knowledge for teaching" 
				  e10 "Efficacy in instruction" 
				  e20 "Efficacy in professionalism" 
				  e30 "Efficacy in teaching supports" 
				  e40 "Efficacy in classroom management" 
				  e50 "Efficacy in related duties" 
				  n1 "Neo neuroticism" 
				  n2 "Neo extraversion" 
				  n3 "Neo openness" 
				  n4 "Neo agreeableness" 
				  n5 "Neo conscientiousness" 
				  _cons "Constant (F22 UVA)" ) replace ;
#delimit cr

//----------------------------------------------------------------------------//			  
// Table 6 - classroom MQI	
//----------------------------------------------------------------------------//
eststo clear 
eststo, title("base"): regress m_overall i.treat##i.block [fweight = mqi_fw]
qui tab m_overall if m_overall != .
estadd scalar a = r(r)
eststo, title("+ baseline covs"): regress m_overall i.treat##i.block  x_overall0 c e?0  n? x_overall0_im e?0_im c_im n?_im [fweight = mqi_fw]
qui tab m_overall if m_overall != .
estadd scalar a = r(r)

#delimit ;
esttab using table_6.tex, 
cells(b(star label(Coef.) fmt(a3)) se(label(SE) fmt(2) par))  
label 
mtitles("base"  "+ baseline covs") 
stats( a r2 rmse, labels( "N. of cases" "R2" "RMSE" )) 
title("MQI Classroom Placement Score Cohort x Treatment Interaction Models") 
keep(1.treat 2.block  3.block 4.block 1.treat#2.block 1.treat#3.block 		
     1.treat#4.block x_overall0 c e10 e20 e40 e50 n1 n3 n4 n5 _cons ) 		
order(1.treat 1.treat#2.block 1.treat#3.block 1.treat#4.block _cons 2.block 3.block 4.block )	 
legend varlabels( 1.treat  "Treatment (F22 UVA)"							
				  2.block  "S23 UVA"  
				  3.block  "F22 UD" 
				  4.block  "S23 UD" 
				  1.treat#2.block "Treatment x S23 UVA"	
				  1.treat#3.block "Treatment x F22 UD" 
				  1.treat#4.block "Treatment x S23 UD" 
				  x_overall0 "Simse Pretest" 
				  c "Mathematical knowledge for teaching" 
				  e10 "Efficacy in instruction" 
				  e20 "Efficacy in professionalism" 
				  e30 "Efficacy in teaching supports" 
				  e40 "Efficacy in classroom management" 
				  e50 "Efficacy in related duties" 
				  n1 "Neo neuroticism" 
				  n2 "Neo extraversion" 
				  n3 "Neo openness" 
				  n4 "Neo agreeableness" 
				  n5 "Neo conscientiousness" 
				  _cons "Constant (F22 UVA)" ) replace ;
#delimit cr
	
//----------------------------------------------------------------------------//
//----------------------------------------------------------------------------//
// Contrast tables 
//----------------------------------------------------------------------------//
//----------------------------------------------------------------------------//

//----------------------------------------------------------------------------//
// Table 7 - performance task simse
//----------------------------------------------------------------------------//	
eststo clear 
*site effects 
regress x_overall1 i.treat##i.block x_overall0 x_overall0_im e?0 c n? x_overall0_im e?0_im c_im n?_im [fweight = simse1_fw]
xlincom (jw1vs0.treat#gw1.block  =  _b[1.treat] + _b[1o.treat#1b.block]) ///
        (jw1vs0.treat#gw2.block  =  _b[1.treat] + _b[1.treat#2.block]) 	///
		(jw1vs0.treat#gw3.block  =  _b[1.treat] + _b[1.treat#3.block])	///
		(jw1vs0.treat#gw4.block  =  _b[1.treat] + _b[1.treat#4.block]), post
estimates store m1
qui tab x_overall1  if x_overall1  != .
estadd scalar a = r(r)

* differences fromt the grand mean 
regress x_overall1 i.treat##i.block x_overall0 x_overall0_im e?0 c n? x_overall0_im e?0_im c_im n?_im [fweight = simse1_fw]
contrasts jw.treat#gw.block , post
estimates store m2
qui tab x_overall1  if x_overall1  != .
estadd scalar a = r(r)

#delimit ;
esttab m1 m2 using table_7.tex, 
cells(b(star label(Coef.) fmt(a3)) se(label(SE) fmt(2) par)) 
label  
keep(jw1vs0.treat#gw1.block  
     jw1vs0.treat#gw2.block 
     jw1vs0.treat#gw3.block 
     jw1vs0.treat#gw4.block ) 
legend varlabels(jw1vs0.treat#gw1.block "F22 UVA"     
				 jw1vs0.treat#gw2.block "S23 UVA"	
				 jw1vs0.treat#gw3.block "F22 UD"     
                 jw1vs0.treat#gw4.block "S23 UD")    
mtitles("Cohort ITT" "Cohort ITT - Pooled ITT") 
title("Simse Performance Task Scores ITT Contrasts") 
stats(a, labels("N. of cases")) replace ;
#delimit cr


//----------------------------------------------------------------------------//
// Table 8 - classroom simse 	
//----------------------------------------------------------------------------// 
eststo clear 
* site effects 
regress x_overall2 i.treat##i.block x_overall0 x_overall0_im e?0 c n? x_overall0_im e?0_im c_im n?_im [fweight = simse2_fw]
xlincom (jw1vs0.treat#gw1.block  =  _b[1.treat] + _b[1o.treat#1b.block]) ///
        (jw1vs0.treat#gw2.block  =  _b[1.treat] + _b[1.treat#2.block]) 	///
		(jw1vs0.treat#gw3.block  =  _b[1.treat] + _b[1.treat#3.block])	///
		(jw1vs0.treat#gw4.block  =  _b[1.treat] + _b[1.treat#4.block]), post
estimates store m1
qui tab x_overall2  if x_overall2  != .
estadd scalar a = r(r)

* differences fromt the grand mean 
regress x_overall2  i.treat##i.block x_overall0 x_overall0_im e?0 c n? x_overall0_im e?0_im c_im n?_im [fweight = simse2_fw]
contrasts jw.treat#gw.block , post
estimates store m2
qui tab x_overall2  if x_overall2  != .
estadd scalar a = r(r)

#delimit ;
esttab m1 m2 using table_8.tex, 
cells(b(star label(Coef.) fmt(a3)) se(label(SE) fmt(2) par)) 
label  
keep(jw1vs0.treat#gw1.block  
     jw1vs0.treat#gw2.block 
     jw1vs0.treat#gw3.block 
     jw1vs0.treat#gw4.block ) 
legend varlabels(jw1vs0.treat#gw1.block "F22 UVA"     
				 jw1vs0.treat#gw2.block "S23 UVA"	
				 jw1vs0.treat#gw3.block "F22 UD"     
                 jw1vs0.treat#gw4.block "S23 UD")    
mtitles("Cohort ITT" "Cohort ITT - Pooled ITT") 
title("SimSe Classroom Placement Score ITT Contrasts") 
stats(a, labels("N. of cases")) replace;
#delimit cr

//----------------------------------------------------------------------------//			  
// Table 9 - classroom MQI	
//----------------------------------------------------------------------------//	  
eststo clear 	
*site effects 
regress m_overall i.treat##i.block x_overall0 x_overall0_im e?0 c n? x_overall0_im e?0_im c_im n?_im [fweight = mqi_fw]
xlincom (jw1vs0.treat#gw1.block  =  _b[1.treat] + _b[1o.treat#1b.block]) ///
        (jw1vs0.treat#gw2.block  =  _b[1.treat] + _b[1.treat#2.block]) 	///
		(jw1vs0.treat#gw3.block  =  _b[1.treat] + _b[1.treat#3.block])	///
		(jw1vs0.treat#gw4.block  =  _b[1.treat] + _b[1.treat#4.block]), post
estimates store m1
qui tab m_overall  if m_overall  != .
estadd scalar a = r(r)

* differences fromt the grand mean 
regress m_overall i.treat##i.block x_overall0 x_overall0_im e?0 c n? x_overall0_im e?0_im c_im n?_im [fweight = mqi_fw]
contrasts jw.treat#gw.block , post
estimates store m2
qui tab m_overall  if m_overall  != .
estadd scalar a = r(r)

#delimit ;
esttab m1 m2 using table_9.tex, 
cells(b(star label(Coef.) fmt(a3)) se(label(SE) fmt(2) par)) 
label  
keep(jw1vs0.treat#gw1.block  
     jw1vs0.treat#gw2.block 
     jw1vs0.treat#gw3.block 
     jw1vs0.treat#gw4.block ) 
legend varlabels(jw1vs0.treat#gw1.block "F22 UVA"     
				 jw1vs0.treat#gw2.block "S23 UVA"	
				 jw1vs0.treat#gw3.block "F22 UD"     
                 jw1vs0.treat#gw4.block "S23 UD")    
mtitles("Cohort ITT" "Cohort ITT - Pooled ITT") 
title("MQI Classroom Placement Score ITT Contrasts") 
stats(a, labels("N. of cases")) replace;
#delimit cr


