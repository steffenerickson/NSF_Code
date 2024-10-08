//----------------------------------------------------------------------------//
// Investigating the Structural Assumption Implied by a Latent Variable Model 
// Author: Steffen Erickson
// Date  : 9/2/24
//----------------------------------------------------------------------------//
clear all
global root     "/Users/steffenerickson/Box Sync/NSF_DR_K12"
global code     "/Users/steffenerickson/Documents/GitHub/NSF_Code/05_skill_development/code"
global programs "/Users/steffenerickson/Documents/GitHub/stata_programs"
global data     "measurement/data"
global output   "skill_development/output"
include ${programs}/mvgstudy.ado

//----------------------------------------------------------------------------//
// Usingt the full data 
//----------------------------------------------------------------------------//
use "${root}/${data}/manova_data.dta", clear
rename (task rater coaching) (t r treat)
label values treat . 
keep if time == 1 & ( treat == 0 | treat == 1) & (r != 3) 
drop x6 
encode participantid , gen(id)
sort id site semester
egen block = group(site semester)
egen p = group (id site semester)
collapse x* , by(p treat block)
recode treat (0 = 1) (1 = 2)
drop if (x1 == . & x2 == . & x3 == . & x4 == . & x5 == .)
sem (F1 -> x1 x2@1 x5) (F2 -> x3 x4)  (F2 <- F1) , group(treat) ginvariant(mcoef scoef) means(F1@0)	

sem (F1 -> x1 x2@1 x5) (F2 -> x3 x4)  (F2 <- F1)
estimates store m1 
sem (F1 -> x1 x2@1 x5 x3 x4), 
estimates store m2
lrtest m1 m2 
sem (F1 -> x1 x2@1 x5 x3 ) (x3 ->  x4) 
estimates store m3
lrtest m1 m3


sem ( <- x1 x2 x3 x4 x5) //, method(adf) 
estat framework, fitted
mat true = r(Sigma)[1..5,1..5]
sem ( <- x1 x2 x3 x4 x5) , group(treat) ginvariant(mcoef) //method(adf) 
mat mu0 = _b[/mean(x1)#1.treat],_b[/mean(x2)#1.treat],_b[/mean(x3)#1.treat],_b[/mean(x4)#1.treat],_b[/mean(x5)#1.treat]
mat mu1 = _b[/mean(x1)#2.treat],_b[/mean(x2)#2.treat],_b[/mean(x3)#2.treat],_b[/mean(x4)#2.treat],_b[/mean(x5)#2.treat]
mat observed = mu1 - mu0

clear
ssd init x1 x2 x3 x4 x5
ssd set obs 1000 //71
ssd set cov (stata) true
ssd set means (stata) mu0
ssd addgroup treat
ssd set obs  1000 // 75
ssd set cov (stata) true
ssd set means (stata) mu1

sem (F1 -> x1 x2@1 x5) (F2 -> x3 x4)  (F2 <- F1) , group(treat) ginvariant(mcoef scoef) means(F1@0)	//standardized	 
testnl ((_b[x1:2.treat#c.F1] * (_b[x2:2.treat]  -  _b[x2:1.treat]))  ==  (_b[x2:2.treat#c.F1] * (_b[x1:2.treat]  -  _b[x1:1.treat])))  ///
       ((_b[x3:2.treat#c.F2] * _b[F2:2.treat#c.F1] * (_b[x2:2.treat]  -  _b[x2:1.treat]))  ==  (_b[x2:2.treat#c.F1] * (_b[x3:2.treat]  -  _b[x3:1.treat])))  ///
       ((_b[x4:2.treat#c.F2] * _b[F2:2.treat#c.F1] * (_b[x2:2.treat]  -  _b[x2:1.treat]))  ==  (_b[x2:2.treat#c.F1] * (_b[x4:2.treat]  -  _b[x4:1.treat])))  ///
       ((_b[x5:2.treat#c.F1] * (_b[x2:2.treat]  -  _b[x2:1.treat]))  ==  (_b[x2:2.treat#c.F1] * (_b[x5:2.treat]  -  _b[x5:1.treat]))) 
	   
	   
testnl ((_b[x1:2.treat#c.F1] * (_b[x2:2.treat]  -  _b[x2:1.treat]))  ==  (_b[x2:2.treat#c.F1] * (_b[x1:2.treat]  -  _b[x1:1.treat])))  
testnl ((_b[x3:2.treat#c.F2] * _b[F2:2.treat#c.F1] * (_b[x2:2.treat]  -  _b[x2:1.treat]))  ==  (_b[x2:2.treat#c.F1] * (_b[x3:2.treat]  -  _b[x3:1.treat])))  
testnl ((_b[x4:2.treat#c.F2] * _b[F2:2.treat#c.F1] * (_b[x2:2.treat]  -  _b[x2:1.treat]))  ==  (_b[x2:2.treat#c.F1] * (_b[x4:2.treat]  -  _b[x4:1.treat])))  
testnl ((_b[x5:2.treat#c.F1] * (_b[x2:2.treat]  -  _b[x2:1.treat]))  ==  (_b[x2:2.treat#c.F1] * (_b[x5:2.treat]  -  _b[x5:1.treat])))
 


mat modelimplied = 	 (_b[x2:2.treat]  -  _b[x2:1.treat]) * _b[x1:2.treat#c.F1], ///
					 (_b[x2:2.treat]  -  _b[x2:1.treat]) * _b[x2:2.treat#c.F1], ///
					 (_b[x2:2.treat]  -  _b[x2:1.treat]) * (_b[x3:2.treat#c.F2] * _b[F2:2.treat#c.F1]), /// 
					 (_b[x2:2.treat]  -  _b[x2:1.treat]) * (_b[x4:2.treat#c.F2] * _b[F2:2.treat#c.F1]), /// 
					 (_b[x2:2.treat]  -  _b[x2:1.treat]) * _b[x5:2.treat#c.F1] 

mat adjusted  = 	 (_b[x1:2.treat]  -  _b[x1:1.treat]) /  _b[x1:2.treat#c.F1], ///
					 (_b[x2:2.treat]  -  _b[x2:1.treat]) /  _b[x2:2.treat#c.F1], ///
					 (_b[x3:2.treat]  -  _b[x3:1.treat]) /  (_b[x3:2.treat#c.F2] * _b[F2:2.treat#c.F1]), /// 
					 (_b[x4:2.treat]  -  _b[x4:1.treat]) /  (_b[x4:2.treat#c.F2] * _b[F2:2.treat#c.F1]), /// 
					 (_b[x5:2.treat]  -  _b[x5:1.treat]) /  _b[x5:2.treat#c.F1] 
				 		
mata st_matrix("adjusted")					 
mata st_matrix("observed")
mata st_matrix("modelimplied")
mata: st_matrix("observed") - st_matrix("modelimplied")

sem (F1 -> x1 x2@1 x5 x3) (x3 -> x4) , group(treat) ginvariant(mcoef scoef) means(F1@0)	//method(adf) //standardized		 
testnl ((_b[x1:2.treat#c.F1] * (_b[x2:2.treat]  -  _b[x2:1.treat]))  ==  (_b[x2:2.treat#c.F1] * (_b[x1:2.treat]  -  _b[x1:1.treat])))  ///
       ((_b[x3:2.treat#c.F1] * (_b[x2:2.treat]  -  _b[x2:1.treat]))  ==  (_b[x2:2.treat#c.F1] * (_b[x3:2.treat]  -  _b[x3:1.treat])))  ///
       ((_b[x4:2.treat#c.x3] * (_b[x2:2.treat]  -  _b[x2:1.treat]))  ==  (_b[x2:2.treat#c.F1] * (_b[x4:2.treat]  -  _b[x4:1.treat])))  ///
       ((_b[x5:2.treat#c.F1] * (_b[x2:2.treat]  -  _b[x2:1.treat]))  ==  (_b[x2:2.treat#c.F1] * (_b[x5:2.treat]  -  _b[x5:1.treat]))) 
	   
	   
testnl ((_b[x1:2.treat#c.F1] * (_b[x2:2.treat]  -  _b[x2:1.treat]))  ==  (_b[x2:2.treat#c.F1] * (_b[x1:2.treat]  -  _b[x1:1.treat])))  
testnl ((_b[x3:2.treat#c.F1] * (_b[x2:2.treat]  -  _b[x2:1.treat]))  ==  (_b[x2:2.treat#c.F1] * (_b[x3:2.treat]  -  _b[x3:1.treat])))  
testnl ((_b[x4:2.treat#c.x3]  * (_b[x2:2.treat]  -  _b[x2:1.treat]))  ==  (_b[x2:2.treat#c.F1] * (_b[x4:2.treat]  -  _b[x4:1.treat])))  
testnl ((_b[x5:2.treat#c.F1] * (_b[x2:2.treat]  -  _b[x2:1.treat]))  ==  (_b[x2:2.treat#c.F1] * (_b[x5:2.treat]  -  _b[x5:1.treat])))
 

 
 
 
 

mat modelimplied = 	 (_b[x2:2.treat]  -  _b[x2:1.treat]) * _b[x1:2.treat#c.F1], ///
					 (_b[x2:2.treat]  -  _b[x2:1.treat]) * _b[x2:2.treat#c.F1], ///
					 (_b[x2:2.treat]  -  _b[x2:1.treat]) * (_b[x3:2.treat#c.F1]), /// 
					 (_b[x2:2.treat]  -  _b[x2:1.treat]) * (_b[x4:2.treat#c.x3]), /// 
					 (_b[x2:2.treat]  -  _b[x2:1.treat]) * _b[x5:2.treat#c.F1] 

mat adjusted  = 	 (_b[x1:2.treat]  -  _b[x1:1.treat]) /  _b[x1:2.treat#c.F1], ///
					 (_b[x2:2.treat]  -  _b[x2:1.treat]) /  _b[x2:2.treat#c.F1], ///
					 (_b[x3:2.treat]  -  _b[x3:1.treat]) /  (_b[x3:2.treat#c.F1] ), /// 
					 (_b[x4:2.treat]  -  _b[x4:1.treat]) /  (_b[x4:2.treat#c.x3]), /// 
					 (_b[x5:2.treat]  -  _b[x5:1.treat]) /  _b[x5:2.treat#c.F1] 
				 		
mata st_matrix("adjusted")					 
mata st_matrix("observed")
mata st_matrix("modelimplied")
mata: st_matrix("observed") - st_matrix("modelimplied")







//---------- univariate model 

sem (F1 -> x1 x2@1 x5 x3 x4) , group(treat) ginvariant(mcoef scoef) means(F1@0)	//method(adf) //standardized		 
testnl ((_b[x1:2.treat#c.F1] * (_b[x2:2.treat]  -  _b[x2:1.treat]))  ==  (_b[x2:2.treat#c.F1] * (_b[x1:2.treat]  -  _b[x1:1.treat])))  ///
       ((_b[x3:2.treat#c.F1] * (_b[x2:2.treat]  -  _b[x2:1.treat]))  ==  (_b[x2:2.treat#c.F1] * (_b[x3:2.treat]  -  _b[x3:1.treat])))  ///
       ((_b[x4:2.treat#c.F1] * (_b[x2:2.treat]  -  _b[x2:1.treat]))  ==  (_b[x2:2.treat#c.F1] * (_b[x4:2.treat]  -  _b[x4:1.treat])))  ///
       ((_b[x5:2.treat#c.F1] * (_b[x2:2.treat]  -  _b[x2:1.treat]))  ==  (_b[x2:2.treat#c.F1] * (_b[x5:2.treat]  -  _b[x5:1.treat]))) 
	   
	   
testnl ((_b[x1:2.treat#c.F1] * (_b[x2:2.treat]  -  _b[x2:1.treat]))  ==  (_b[x2:2.treat#c.F1] * (_b[x1:2.treat]  -  _b[x1:1.treat])))  
testnl ((_b[x3:2.treat#c.F1] * (_b[x2:2.treat]  -  _b[x2:1.treat]))  ==  (_b[x2:2.treat#c.F1] * (_b[x3:2.treat]  -  _b[x3:1.treat])))  
testnl ((_b[x4:2.treat#c.F1] * (_b[x2:2.treat]  -  _b[x2:1.treat]))  ==  (_b[x2:2.treat#c.F1] * (_b[x4:2.treat]  -  _b[x4:1.treat])))  
testnl ((_b[x5:2.treat#c.F1] * (_b[x2:2.treat]  -  _b[x2:1.treat]))  ==  (_b[x2:2.treat#c.F1] * (_b[x5:2.treat]  -  _b[x5:1.treat])))
 

 
 
 
 

mat modelimplied = 	 (_b[x2:2.treat]  -  _b[x2:1.treat]) * _b[x1:2.treat#c.F1], ///
					 (_b[x2:2.treat]  -  _b[x2:1.treat]) * _b[x2:2.treat#c.F1], ///
					 (_b[x2:2.treat]  -  _b[x2:1.treat]) * (_b[x3:2.treat#c.F2] * _b[F2:2.treat#c.F1]), /// 
					 (_b[x2:2.treat]  -  _b[x2:1.treat]) * (_b[x4:2.treat#c.F2] * _b[F2:2.treat#c.F1]), /// 
					 (_b[x2:2.treat]  -  _b[x2:1.treat]) * _b[x5:2.treat#c.F1] 

mat adjusted  = 	 (_b[x1:2.treat]  -  _b[x1:1.treat]) /  _b[x1:2.treat#c.F1], ///
					 (_b[x2:2.treat]  -  _b[x2:1.treat]) /  _b[x2:2.treat#c.F1], ///
					 (_b[x3:2.treat]  -  _b[x3:1.treat]) /  (_b[x3:2.treat#c.F2] * _b[F2:2.treat#c.F1]), /// 
					 (_b[x4:2.treat]  -  _b[x4:1.treat]) /  (_b[x4:2.treat#c.F2] * _b[F2:2.treat#c.F1]), /// 
					 (_b[x5:2.treat]  -  _b[x5:1.treat]) /  _b[x5:2.treat#c.F1] 
				 		
mata st_matrix("adjusted")					 
mata st_matrix("observed")
mata st_matrix("modelimplied")
mata: st_matrix("observed") - st_matrix("modelimplied")






















 
//----------------------------------------------------------------------------//
// Completely remove confounding using mvgstudy command 
//----------------------------------------------------------------------------//		
use "${root}/${data}/manova_data.dta", clear
rename (task rater coaching) (t r treat)
label values treat . 
keep if time == 1 & ( treat == 0 | treat == 1) & r != 3
drop x6
encode participantid , gen(id)
sort id site semester
egen block = group(site semester)
egen p = group (id site semester)
drop if (x1 == . & x2 == . & x3 == . & x4 == . & x5 == .)
fillin t r p 
forvalues i = 1/5 {
	tempvar temp
	regress x`i' i.p i.t i.r i.p#i.t i.p#i.r i.t#i.r
	predict `temp'
	replace x`i' = `temp' if x`i' == . 
}

*mvgstudy (x1 x2 x3 x4 x5 = p t  p#t r|t p#r|t)
*mat true   = r(covcomps1)
*mat error  = r(covcomps2) + r(covcomps3) + r(covcomps4) + r(covcomps5) 
sort p t r 
by p : gen n = _n
mvgstudy (x1 x2 x3 x4 x5 = p n|p)
mat true   = r(covcomps1)
mat error  = r(covcomps2)  

clear
ssd init x1 x2 x3 x4 x5
ssd set obs 71
ssd set cov (stata) true
ssd set means (stata) mu0
ssd addgroup treat
ssd set obs 76
ssd set cov (stata) true
ssd set means (stata) mu1


mata : cov = st_matrix("true")
mata : means = (st_matrix("mu0") + st_matrix("mu1")):/2
mata: mvnormalcv(1000,2000,means, cov)



sem (F1 -> x1 x2@1 x5) (F2 -> x3 x4)  (F2 <- F1) ,  var(e.x3@0) group(treat)ginvariant(mcoef scoef) means(F1@0)	//method(adf) //standardized		 
testnl ((_b[x1:2.treat#c.F1] * (_b[x2:2.treat]  -  _b[x2:1.treat]))  ==  (_b[x2:2.treat#c.F1] * (_b[x1:2.treat]  -  _b[x1:1.treat])))  
testnl ((_b[x3:2.treat#c.F2] * _b[F2:2.treat#c.F1] * (_b[x2:2.treat]  -  _b[x2:1.treat]))  ==  (_b[x2:2.treat#c.F1] * (_b[x3:2.treat]  -  _b[x3:1.treat])))  
testnl ((_b[x4:2.treat#c.F2] * _b[F2:2.treat#c.F1] * (_b[x2:2.treat]  -  _b[x2:1.treat]))  ==  (_b[x2:2.treat#c.F1] * (_b[x4:2.treat]  -  _b[x4:1.treat])))  
testnl ((_b[x5:2.treat#c.F1] * (_b[x2:2.treat]  -  _b[x2:1.treat]))  ==  (_b[x2:2.treat#c.F1] * (_b[x5:2.treat]  -  _b[x5:1.treat])))
 
mat modelimplied = 	 (_b[x2:2.treat]  -  _b[x2:1.treat]) * _b[x1:2.treat#c.F1], ///
					 (_b[x2:2.treat]  -  _b[x2:1.treat]) * _b[x2:2.treat#c.F1], ///
					 (_b[x2:2.treat]  -  _b[x2:1.treat]) * (_b[x3:2.treat#c.F2] * _b[F2:2.treat#c.F1]), /// 
					 (_b[x2:2.treat]  -  _b[x2:1.treat]) * (_b[x4:2.treat#c.F2] * _b[F2:2.treat#c.F1]), /// 
					 (_b[x2:2.treat]  -  _b[x2:1.treat]) * _b[x5:2.treat#c.F1] 

mat adjusted  = 	 (_b[x1:2.treat]  -  _b[x1:1.treat]) /  _b[x1:2.treat#c.F1], ///
					 (_b[x2:2.treat]  -  _b[x2:1.treat]) /  _b[x2:2.treat#c.F1], ///
					 (_b[x3:2.treat]  -  _b[x3:1.treat]) /  (_b[x3:2.treat#c.F2] * _b[F2:2.treat#c.F1]), /// 
					 (_b[x4:2.treat]  -  _b[x4:1.treat]) /  (_b[x4:2.treat#c.F2] * _b[F2:2.treat#c.F1]), /// 
					 (_b[x5:2.treat]  -  _b[x5:1.treat]) /  _b[x5:2.treat#c.F1] 
				 		
mata st_matrix("adjusted")					 
mata st_matrix("observed")
mata st_matrix("modelimplied")
mata: st_matrix("observed") - st_matrix("modelimplied")

// 
//----------------------------------------------------------------------------//
// Investigating the Structural Assumption Implied by a Latent Variable Model 
// Author: Steffen Erickson
// Date  : 9/2/24
//----------------------------------------------------------------------------//
clear all
global root     "/Users/steffenerickson/Box Sync/NSF_DR_K12"
global code     "/Users/steffenerickson/Documents/GitHub/NSF_Code/05_skill_development/code"
global programs "/Users/steffenerickson/Documents/GitHub/stata_programs"
global data     "measurement/data"
global output   "skill_development/output"
include ${programs}/mvgstudy.ado

//----------------------------------------------------------------------------//
// Using both time points 
//----------------------------------------------------------------------------//
use "${root}/${data}/manova_data.dta", clear
rename (task rater coaching) (t r treat)
label values treat . 
keep if (r != 3) 
drop x6 
encode participantid , gen(id)
sort id site semester
egen block = group(site semester)
egen p = group (id site semester time)
collapse x* , by(p treat block time)
drop if (x1 == . & x2 == . & x3 == . & x4 == . & x5 == .)
//sem (F1 -> x1 x2@1 x5) (F2 -> x3 x4)  (F2 <- F1) , group(treat) ginvariant(mcoef scoef) means(F1@0)	

sem (F1 -> x1 x2@1 x5) (F2 -> x3 x4)  (F2 <- F1) , /*group(treat) ginvariant(mcoef scoef)*/ means(F1@0)	
estimates store m1 

sem (F1 -> x1 x2@1 x5 x3 x4)  , /*group(treat) ginvariant(mcoef scoef)*/ means(F1@0)	
estimates store m2
lrtest m1 m2 

regress x4 x3 x2 
regress x4 x3 x2 

sem ( <- x1 x2 x3 x4 x5) //, method(adf) 
estat framework, fitted
mat true = r(Sigma)[1..5,1..5]

keep if time == 1  & ( treat == 0 | treat == 1) 
recode treat (0 = 1) (1 = 2)
sem ( <- x1 x2 x3 x4 x5) , group(treat) ginvariant(mcoef) //method(adf) 
mat mu0 = _b[/mean(x1)#1.treat],_b[/mean(x2)#1.treat],_b[/mean(x3)#1.treat],_b[/mean(x4)#1.treat],_b[/mean(x5)#1.treat]
mat mu1 = _b[/mean(x1)#2.treat],_b[/mean(x2)#2.treat],_b[/mean(x3)#2.treat],_b[/mean(x4)#2.treat],_b[/mean(x5)#2.treat]
mat observed = mu1 - mu0

 

