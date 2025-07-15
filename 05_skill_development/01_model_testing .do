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
keep if time != 0 & ( treat == 0 | treat == 1) & (r != 3) 
drop x6 
encode participantid , gen(id)
sort id site semester
egen block = group(site semester)
egen p = group (id site semester)
collapse x* , by(p treat block)
recode treat (0 = 1) (1 = 2)
drop if (x1 == . & x2 == . & x3 == . & x4 == . & x5 == .)
sem (F1 -> x1 x2@1 x5) (F2 -> x3 x4)  (F2 <- F1) , group(treat) ginvariant(mcoef scoef) means(F1@0)	

include /Users/steffenerickson/Desktop/model_implied_intervention_effects_v3.ado

sem (F1 -> x1 x2@1 x3 x4 x5)  

sem (F1 -> x1 x2@1 x3 x4 x5), cov(e.x3*e.x4) 

sem (F1 -> x1 x2@1 x3 x4 x5), cov(e.x3*e.x4)


sem (F1 -> x1 x2@1 x3 x4 x5)  , group(treat) ginvariant(scoef mcoef) means(F1@0)
estimates store m1
flowcheck, estimates(m1)

sem (F1 -> x2@1 x3 x4) (F2 -> x1@1 x5) (F1 <- F2), group(treat) ginvariant(scoef mcoef) means(F2@0) cov(e.x3*e.x4)
estimates store m1
flowcheck, estimates(m1)



sem (F1 -> x2@1 x3 x4 x1 x5), group(treat) ginvariant(scoef mcoef) means(F1@0) cov(e.x3*e.x4)
estimates store m1
flowcheck, estimates(m1)









sem (F1 -> x2@1 x1 x5) (F2 -> x3@1 x4), group(treat) ginvariant(scoef mcoef) means(F1@0 F2@0)
estimates store m1
flowcheck, estimates(m1)

sem  (F34 -> x3@1 x4) (F1 -> x1@1) (F2 -> x2@1) (F5 -> x5@1) (F34 <- F1 F2 F5), var(e.x1@0 e.x2@0 e.x5@0) group(treat) ginvariant(scoef mcoef) means(F1@0 F2@0 F5@0)
estimates store m1
flowcheck, estimates(m1)


sem (F1 -> x1@1) (F2 -> x2@1) (F5 -> x5@1) (F34 <- F1 F2 F3), var(e.x1@0 e.x2@0e.x5@0) group(treat) ginvariant(scoef mcoef) means(F1@0 F2@0 F5@0)

sem (F1 -> x2@1 x3 x4) (F2 -> x1@1 x5) (F1 <- F2), group(treat) ginvariant(scoef mcoef) means(F2@0)
estimates store m1
flowcheck, estimates(m1)



sem (F1 -> x2@1 x3 x4) (F2 -> x1@1 x5)
sem (F1 -> x2@1 x1 x5) (F2 -> x3@1 x4)






preserve
rename (x3 x4) (y1 y2)
sem (F1 -> x1 x2@1 x5) (F2 -> y1@1 y2)  (F2 <- F1) (F1 F2 <- t)
estat teffects

sem (F1 -> x1 x2@1 x5) (F2 -> y1@1 y2)  (F2 <- F1) , group(treat) ginvariant(none) means(F1@0)  var(1: e.y1@0)	
estimates store m1
flowcheck, estimates(m1)

sem (F1 -> x1 x2@1 x5) (F2 -> y1@1 y2)  (F2 <- F1) , group(treat) ginvariant(scoef mcoef) means(F1@0)
estimates store m1
flowcheck, estimates(m1)
restore

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
ssd set obs 71
ssd set cov (stata) true
ssd set means (stata) mu0
ssd addgroup treat
ssd set obs  75
ssd set cov (stata) true
ssd set means (stata) mu1


include /Users/steffenerickson/Desktop/model_implied_intervention_effects_v3.ado

//rename (x3 x4) (y1 y2)
sem (j -> x1 x2@1 x5) (h -> x3@1 x4)  (h <- j) , group(treat) ginvariant(none) means(j@0) nocapslatent latent(h j)	//standardized	
estimates store m1
flowcheck, estimates(m1)



sem (F1 -> x1 x2@1 x5) (F2 -> y1@1 y2)  (F2 <- F1) , group(treat) ginvariant(none) means(F1@0)	//standardized	
estimates store m1
flowcheck, estimates(m1)


sem (F1 -> x1 x2@1 x5 y1 y2)  , group(treat) ginvariant(none) means(F1@0)	//standardized	
estimates store m1
flowcheck, estimates(m1)


sem (F1 -> x1@1) (F2 -> x2@1) (F3 -> x5@1) (F4 -> y1@1 y2)  (F4 <- F1 F2 F3) , group(treat) ginvariant(none) means(F1@0 F2@0 F3@0) var(e.x1@0 e.x2@0 e.x5@0) //standardized	
estimates store m1
flowcheck, estimates(m1)



sem (F1 -> x1@1) (F2 -> x2@1) (F3 -> x5@1) (F4 -> y1@1) (F5 -> y2@1)  (F4 F5 <- F1 F2 F3) , group(treat) ginvariant(none) means(F1@0 F2@0 F3@0) var(e.x1@0 e.x2@0 e.x5@0 e.y1@0 e.y2@0) //standardized	
estimates store m1
flowcheck, estimates(m1)



 
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


preserve
recode treat (0 =1) (1=2)
collapse x* , by(p treat block)
sem ( <- x1 x2 x3 x4 x5) //, method(adf) 
estat framework, fitted
mat true = r(Sigma)[1..5,1..5]
sem ( <- x1 x2 x3 x4 x5) , group(treat) ginvariant(mcoef) //method(adf) 
mat mu0 = _b[/mean(x1)#1.treat],_b[/mean(x2)#1.treat],_b[/mean(x3)#1.treat],_b[/mean(x4)#1.treat],_b[/mean(x5)#1.treat]
mat mu1 = _b[/mean(x1)#2.treat],_b[/mean(x2)#2.treat],_b[/mean(x3)#2.treat],_b[/mean(x4)#2.treat],_b[/mean(x5)#2.treat]
mat observed = mu1 - mu0
restore

//fillin t r p 
//forvalues i = 1/5 {
//	tempvar temp
//	regress x`i' i.p i.t i.r i.p#i.t i.p#i.r i.t#i.r
//	predict `temp'
//	replace x`i' = `temp' if x`i' == . 
//}
//
//*mvgstudy (x1 x2 x3 x4 x5 = p t  p#t r|t p#r|t)
//*mat true   = r(covcomps1)
//*mat error  = r(covcomps2) + r(covcomps3) + r(covcomps4) + r(covcomps5) 
sort p t r 
by p : gen n = _n
mvgstudy (x1 x2 x3 x4 x5 = p n|p)

//mvgstudy (x1 x2 x3 x4 x5 = p t p#t r|p#t)


mat true   = r(covcomps1)
mat error  = r(covcomps2)  

clear
ssd init x1 x2 x3 x4 x5
ssd set obs 71
ssd set cov (stata) true
ssd set means (stata) mu0
ssd addgroup treat
ssd set obs 75
ssd set cov (stata) true
ssd set means (stata) mu1


include /Users/steffenerickson/Desktop/model_implied_intervention_effects_v3.ado
sem (F1 -> x2@1 x3 x4) (F2 -> x1@1 x5), group(treat) ginvariant(scoef mcoef) means(F1@0 F2@0) cov(e.x3*e.x4)
estimates store m1
flowcheck, estimates(m1)


include /Users/steffenerickson/Desktop/model_implied_intervention_effects_v3.ado

sem (F1 -> x2@1 x3 x4) (F2 -> x1@1 x5) (F1 <- F2) , group(treat) ginvariant(scoef mcoef) means(F2@0) //cov(e.x3*e.x4)
estimates store m1
flowcheck, estimates(m1)








sem (F1 -> x1@1) (F2 -> x2@1) (F3 -> x3@1) (F4 -> x4@1) (F5 -> x5@1) (F4 <- F3) (F3 F4 <- F2 F1 F5), var(e.x1@0 e.x2@0 e.x3@0 e.x4@0 e.x5@0) group(treat) ginvariant(scoef mcoef) means(F1@0 F2@0 F5@0)

estimates store m1
flowcheck, estimates(m1)


sem (F1 -> x1@1) (F2 -> x2@1) (F3 -> x3@1) (F4 -> x4@1) (F5 -> x5@1) (F4 <- F3) (F3 F4 <- F2 ), var(e.x1@0 e.x2@0 e.x3@0 e.x4@0 e.x5@0) group(treat) ginvariant(scoef mcoef) means(F1@0 F2@0 F5@0)

estimates store m1
flowcheck, estimates(m1)



sem (F1 -> x1@1) (F2 -> x2@1) (F3 -> x3@1) (F4 -> x4@1) (F5 -> x5@1)  (F3 F4 <- F2 ), var(e.x1@0 e.x2@0 e.x3@0 e.x4@0 e.x5@0) group(treat) ginvariant(scoef mcoef) means(F1@0 F2@0 F5@0)

estimates store m1
flowcheck, estimates(m1)





 group(treat) ginvariant(scoef mcoef) means(F2@0) //cov(e.x3*e.x4)
estimates store m1
flowcheck, estimates(m1)















sem (F1 -> x2@1 x1 x5) (F2 -> x3@1 x4), group(treat) var(e.x3@0) ginvariant(scoef mcoef) means(F1@0 F2@0) cov(e.x3*e.x4)
estimates store m1
flowcheck, estimates(m1)




sem (F1 -> x2@1 x3 x4) (F2 -> x1@1 x5), group(treat) ginvariant(scoef mcoef) means(F1@0 F2@0) cov(e.x3*e.x4)
estimates store m1 

sem (F1 -> x2@1 x3 x4) (F2 -> x1@1 x5), group(treat) ginvariant(scoef mcoef mcons) cov(e.x3*e.x4)
estimates store m2

lrtest m1 m2 

sem (F1 -> x2@1 x3 x4 x1 x5), group(treat) ginvariant(scoef mcoef) means(F1@0) 
estimates store m1 

sem (F1 -> x2@1 x3 x4 x1 x5), group(treat) ginvariant(scoef mcoef mcons) 
estimates store m2

lrtest m1 m2 

flowcheck, estimates(m1)









sem (F1 -> x1 x2@1 x5) (F2 -> x3@1 x4) ,  var(e.x3@0) group(treat) ginvariant(mcoef scoef) means(F1@0 F2@0)	c//method(adf) //standardized
estimates store m1
flowcheck, estimates(m1)





		 
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

 

